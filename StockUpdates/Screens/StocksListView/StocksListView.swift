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
        NavigationView {
            VStack {
                HStack {
                    Button(viewModel.connectionState.rawValue) {
                        viewModel.toggleConnection()
                    }
                    .padding()
                    .font(.custom("Avenir-Medium", size: 15))
                    .foregroundStyle(.white)
                    .background(viewModel.connectionState.color)
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    Picker("Sort", selection: $viewModel.stockUseCase.sortOption) {
                        Text("Price").tag(SortOption.price)
                        Text("Change").tag(SortOption.change)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                
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
            .navigationTitle("Stocks")
        }
    }
}

#Preview {
    StocksListView(viewModel: StockListViewModel(stockUseCase: StockUseCase(service: WebSocketService())))
}
