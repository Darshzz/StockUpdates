//
//  WebSocketService.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

protocol WebSocketProtocol {
    func connect(symbols: [String]) -> AsyncStream<[StockModel]>
    func disconnect()
}

final class WebSocketService: WebSocketProtocol {
    
    private var continuation: AsyncStream<[StockModel]>.Continuation?
    
    func connect(symbols: [String]) -> AsyncStream<[StockModel]> {
        AsyncStream { continuation in
            
        }
    }
    func disconnect() {
        
    }
}
