//
//  ContentView.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import SwiftUI

struct StocksListView: View {
    
    @State var viewModel: StockListViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(viewModel.connectionState.title) {
                        viewModel.toggleConnection()
                    }
                    .frame(width: 90)
                    .modifier(PrimaryButtonModifier(backgroundColor: viewModel.connectionState.color))
                    .animation(.bouncy, value: viewModel.connectionState)
                    
                    Picker("Sort", selection: $viewModel.stockUseCase.sortOption) {
                        Text("Price").tag(SortOption.price)
                        Text("Change").tag(SortOption.change)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                
                Text("\(viewModel.connectionState.description.uppercased())")
                    .foregroundStyle(viewModel.connectionState.descriptionColor)
                
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
                viewModel.observeState()
            }
            .navigationTitle("Stocks")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    StocksListView(viewModel: StockListViewModel(stockUseCase: StockUseCase(service: WebSocketService())))
}
