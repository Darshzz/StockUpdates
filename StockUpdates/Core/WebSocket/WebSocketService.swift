//
//  WebSocketService.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import Foundation

/// Defines the websocket operations consumed by the use case layer.
protocol WebSocketProtocol {
    func connect(symbols: [String]) -> AsyncStream<[StockModel]>
    func disconnect()
    func observeConnectionState() -> AsyncStream<WebSocketState>
}

/// Manages a websocket connection and emits simulated live stock updates.
final class WebSocketService: WebSocketProtocol {
    
    /// Active websocket task used to send and receive messages.
    private var webSocketTask: URLSessionWebSocketTask?
    /// Stream continuation used to push updated stock arrays to observers.
    private var continuation: AsyncStream<[StockModel]>.Continuation?
    /// Echo websocket endpoint used to simulate round-trip stock updates.
    private let url = URL(string: "wss://ws.postman-echo.com/raw")!
    
    /// Stream continuation used to broadcast connection state changes.
    private var stateContinuation: AsyncStream<WebSocketState>.Continuation?
    
    /// Shared stream for consumers that need connection state updates.
    private lazy var stateStream: AsyncStream<WebSocketState> = {
        AsyncStream { continuation in
            self.stateContinuation = continuation
            continuation.yield(.idle)
        }
    }()
    
    /// In-memory stock cache that is mutated as updates arrive.
    private var stocks: [StockModel] = []
    
    func connect(symbols: [String]) -> AsyncStream<[StockModel]> {
        
        // Reuse the current stream when a connection is already active.
        guard webSocketTask == nil else {
            print("Already connected")
            return getAsyncStream()
        }
        
        // Notify observers that the connection flow has started.
        stateContinuation?.yield(.connecting)
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Seed the stream with mock stock values for the requested symbols.
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
        
        // Creates the async stream returned to higher layers for stock updates.
        func getAsyncStream() -> AsyncStream<[StockModel]> {
            AsyncStream { continuation in
                self.continuation = continuation
                
                // Starts the local loop that sends random prices through the echo socket.
                Task {
                    await sendRandomUpdatesLoop()
                }
            }
        }
        
        return getAsyncStream()
    }
    
    private func sendRandomUpdatesLoop() async {
        // Continuously generate one random stock price update per second while connected.
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
        // Receive echoed websocket messages and translate them into model updates.
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
        // Parse the echoed payload and update the matching stock in place.
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
        // Emit the disconnected state before tearing down the websocket resources.
        stateContinuation?.yield(.disconnected)
        removeAll()
    }
    
    func removeAll() {
        // Cancel the socket and finish the update stream for current subscribers.
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        continuation?.finish()
    }
    
    func observeConnectionState() -> AsyncStream<WebSocketState> {
        // Returns the shared stream so multiple consumers can observe connection changes.
        stateStream
    }
}
