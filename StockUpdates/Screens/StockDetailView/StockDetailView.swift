//
//  StockDetailView.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import SwiftUI

struct StockDetailView: View {
    var stock: StockModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(stock.name)
                .font(.largeTitle)

            Text("Price: \(stock.price, specifier: "%.2f")")

            Text(stock.change >= 0 ? "↑ Up" : "↓ Down")
                .foregroundColor(stock.change >= 0 ? .green : .red)

            Text("This is a simulated stock detail screen.")
                .padding()
        }
    }
}

#Preview {
    StockDetailView(stock: StockModel(id: "888", name: "Apple", price: 247.10, change: 0.20))
}
