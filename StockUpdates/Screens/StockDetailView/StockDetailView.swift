//
//  StockDetailView.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import SwiftUI

/// Displays the latest details for a single observable stock model.
struct StockDetailView: View {
    /// Binding keeps the detail screen in sync with live price updates.
    @Bindable var stock: StockModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(stock.name)
                .font(.largeTitle)

            // Shows the current simulated trading price with two decimal places.
            Text("Price: \(stock.price, specifier: "%.2f")")

            // Indicates whether the most recent price movement was positive or negative.
            Text(stock.change >= 0 ? "↑ Up" : "↓ Down")
                .foregroundColor(stock.change >= 0 ? .green : .red)

            Text("This is a simulated stock detail screen.")
                .padding()
        }
    }
}

#Preview {
    // Preview uses a static sample stock for canvas rendering.
    StockDetailView(stock: StockModel(id: "888", name: "Apple", price: 247.10, change: 0.20))
}
