//
//  WebSocketService.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import Foundation

protocol WebSocketProtocol {
    func connect(symbols: [String]) -> AsyncStream<[StockModel]>
    func disconnect()
}

final class WebSocketService: WebSocketProtocol {
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var continuation: AsyncStream<[StockModel]>.Continuation?
    private let url = URL(string: "wss://ws.postman-echo.com/raw")!
    
    private var stocks: [StockModel] = []
    
    func connect(symbols: [String]) -> AsyncStream<[StockModel]> {
        
        guard webSocketTask == nil else {
            print("Already connected")
            return getAsyncStream()
        }
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        stocks = symbols.map {
            StockModel(id: $0, name: $0, price: Double.random(in: 100...500), change: 0)
        }
        
        listen()
        
        func getAsyncStream() -> AsyncStream<[StockModel]> {
            AsyncStream { continuation in
                self.continuation = continuation
                
                Task {
                    await sendRandomUpdatesLoop()
                }
            }
        }
        
        return getAsyncStream()
    }
    
    private func sendRandomUpdatesLoop() async {
        while webSocketTask != nil {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            guard let randomIndex = stocks.indices.randomElement() else { continue }
            
            let stock = stocks[randomIndex]
            let newPrice = stock.price + Double.random(in: -5...5)
            
            let payload: [String: Any] = [
                "symbol": stock.id,
                "price": newPrice
            ]
            
            if let data = try? JSONSerialization.data(withJSONObject: payload),
               let string = String(data: data, encoding: .utf8) {
                
                let message = URLSessionWebSocketTask.Message.string(string)
                webSocketTask?.send(message) { error in
                    if let error = error {
                        print("Send error:", error)
                    }
                }
            }
        }
    }
    
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("Receive error:", error)
                
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleMessage(text)
                default:
                    break
                }
            }
            
            self.listen() // keep listening
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let symbol = json["symbol"] as? String,
              let price = json["price"] as? Double else { return }
        
        if let index = stocks.firstIndex(where: { $0.id == symbol }) {
            var stock = stocks[index]
            let change = price - stock.price
            stock.price = price
            stock.change = change
            stocks[index] = stock
        }
        
        continuation?.yield(stocks)
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        continuation?.finish()
    }
}
