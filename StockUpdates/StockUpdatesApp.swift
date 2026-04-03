//
//  StockUpdatesApp.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import SwiftUI

@main
/// Application entry point that boots the stock list flow.
struct StockUpdatesApp: App {
    var body: some Scene {
        WindowGroup {
            // Creates the root screen with concrete service, use case, and view model dependencies.
            StocksListView(viewModel: StockListViewModel(stockUseCase: StockUseCase(service: WebSocketService())))
        }
    }
}
