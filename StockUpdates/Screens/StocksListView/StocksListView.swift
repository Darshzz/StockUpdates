//
//  ContentView.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import SwiftUI

/// Main screen that shows stock prices and connection controls.
struct StocksListView: View {
    
    /// State-backed view model keeps UI updates local to this screen.
    @State var viewModel: StockListViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    // Button toggles the simulated websocket connection on and off.
                    Button(viewModel.connectionState.title) {
                        viewModel.toggleConnection()
                    }
                    .frame(width: 90)
                    .modifier(PrimaryButtonModifier(backgroundColor: viewModel.connectionState.color))
                    .animation(.bouncy, value: viewModel.connectionState)
                    
                    // Picker changes the sort strategy applied by the view model.
                    SortPickerView(selectedOption: $viewModel.stockUseCase.sortOption)
                }
                .padding()
                
                Text("\(viewModel.connectionState.description.uppercased())")
                    .foregroundStyle(viewModel.connectionState.descriptionColor)
                
                // Each row navigates to a detail screen while sharing the same stock model instance.
                List(viewModel.stocks) { stock in
                    NavigationLink(
                        destination: StockDetailView(stock: stock)
                    ) {
                        HStack {
                            Text(stock.name)
                            Spacer()
                            Text(String(format: "%.2f", stock.price))
                            Text(stock.change >= 0 ? "↑" : "↓")
                                .foregroundColor(stock.change >= 0 ? .green : .red)
                        }
                    }
                }
            }
            .task {
                // Starts listening for connection state updates when the view appears.
                viewModel.observeState()
            }
            .navigationTitle("Stocks")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    // Preview wires the screen with concrete app dependencies for quick inspection.
    StocksListView(viewModel: StockListViewModel(stockUseCase: StockUseCase(service: WebSocketService())))
}
