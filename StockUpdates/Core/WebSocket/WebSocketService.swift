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
    func observeConnectionState() -> AsyncStream<WebSocketState>
}

final class WebSocketService: WebSocketProtocol {
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var continuation: AsyncStream<[StockModel]>.Continuation?
    private let url = URL(string: "wss://ws.postman-echo.com/raw")!
    
    private var stateContinuation: AsyncStream<WebSocketState>.Continuation?
    
    private lazy var stateStream: AsyncStream<WebSocketState> = {
        AsyncStream { continuation in
            self.stateContinuation = continuation
            continuation.yield(.idle)
        }
    }()
    
    private var stocks: [StockModel] = []
    
    func connect(symbols: [String]) -> AsyncStream<[StockModel]> {
        
        guard webSocketTask == nil else {
            print("Already connected")
            return getAsyncStream()
        }
        
        stateContinuation?.yield(.connecting)
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        stocks = symbols.map {
            StockModel(id: $0, name: $0, price: Double.random(in: 100...500), change: 0)
        }
        
        // Confirm connection using ping
        webSocketTask?.sendPing { [weak self] error in
            if let error {
                print(error)
                self?.stateContinuation?.yield(.failed)
            } else {
                self?.stateContinuation?.yield(.connected)
            }
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
                webSocketTask?.send(message) { [weak self] error in
                    guard let self = self else { return }
                    
                    if error != nil {
                        self.continuation?.finish()
                        self.stateContinuation?.yield(.failed)
                        self.removeAll()
                    }
                }
            }
        }
    }
    
    private func listen() {
        Task {
            while let task = webSocketTask {
                do {
                    let message = try await task.receive()
                    
                    switch message {
                    case .string(let text):
                        print("Received:", text)
                        self.handleMessage(text)
                    default:
                        print("response not available",)
                    }
                    
                } catch {
                    print("Receive error:", error)
                    break
                }
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let symbol = json["symbol"] as? String,
              let price = json["price"] as? Double else { return }
        
        if let index = stocks.firstIndex(where: { $0.id == symbol }) {
            let stock = stocks[index]
            let change = price - stock.price
            stock.price = price
            stock.change = change
        }
        
        continuation?.yield(stocks)
    }
    
    func disconnect() {
        stateContinuation?.yield(.disconnected)
        removeAll()
    }
    
    func removeAll() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        continuation?.finish()
    }
    
    func observeConnectionState() -> AsyncStream<WebSocketState> {
        stateStream
    }
}
