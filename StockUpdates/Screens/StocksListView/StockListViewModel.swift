//
//  StockListViewModel.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import Observation
import SwiftUI

@MainActor
@Observable
/// View model that drives the stock list screen and connection lifecycle.
class StockListViewModel {

    /// Current stock rows displayed in the list.
    var stocks: [StockModel] = []
    /// Latest websocket state reflected in the UI.
    var connectionState: WebSocketState = .idle
    /// Use case responsible for streaming and sorting stocks.
    var stockUseCase: StockUseCaseProtocol
    
    init(stockUseCase: StockUseCaseProtocol) {
        self.stockUseCase = stockUseCase
    }
    
    func toggleConnection() {
        // Starts streaming when disconnected, otherwise stops the active connection.
        Task {
            if connectionState == .connected {
                stockUseCase.disconnect()
            } else {
                await stockUseCase.connect()
                observe()
            }
        }
    }
    
    private func observe() {
        // Consumes the stock stream and keeps the list sorted using the selected option.
        Task {
            for await stocks in stockUseCase.observeStocks() {   
                self.stocks = stockUseCase.sort(stocks)
            }
        }
    }
    
    func observeState() {
        // Listens for connection state changes so the button and status text stay in sync.
        Task {
            for await state in stockUseCase.observeState() {
                connectionState = state
            }
        }
    }
}
