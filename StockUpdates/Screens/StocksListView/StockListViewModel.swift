//
//  StockListViewModel.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import Observation
import SwiftUI

@Observable
class StockListViewModel {

    var stocks: [StockModel] = []
    var isConnected = false
    var stockUseCase: StockUseCaseProtocol
    var connectionState: ConnectionState = .disconnected
    
    init(stockUseCase: StockUseCaseProtocol) {
        self.stockUseCase = stockUseCase
    }
    
    func toggleConnection() {
        connectionState = connectionState.toggleConnection()
        
        Task {
            if isConnected {
                stockUseCase.disconnect()
                isConnected = false
            } else {
                await stockUseCase.connect()
                isConnected = true
                observe()
            }
        }
    }
    
    private func observe() {
        Task {
            for await stocks in stockUseCase.observeStocks() {
                self.stocks = stockUseCase.sort(stocks)
            }
        }
    }
}

enum ConnectionState: String {
    case connected = "Connected"
    case disconnected = "Disconnected"
    
    var color: Color {
        switch self {
        case .connected:
            .green
        case .disconnected:
            .orange
        }
    }
    
    func toggleConnection() -> ConnectionState {
        switch self {
        case .connected:
            .disconnected
        case .disconnected:
            .connected
        }
    }
}
