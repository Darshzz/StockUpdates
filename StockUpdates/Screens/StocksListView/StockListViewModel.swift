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
class StockListViewModel {

    var stocks: [StockModel] = []
    var connectionState: WebSocketState = .idle
    var stockUseCase: StockUseCaseProtocol
    
    init(stockUseCase: StockUseCaseProtocol) {
        self.stockUseCase = stockUseCase
    }
    
    func toggleConnection() {
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
        Task {
            for await stocks in stockUseCase.observeStocks() {   
                self.stocks = stockUseCase.sort(stocks)
            }
        }
    }
    
    func observeState() {
        Task {
            for await state in stockUseCase.observeState() {
                connectionState = state
            }
        }
    }
}
