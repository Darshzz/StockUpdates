//
//  StockModel.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import Observation

@Observable
/// Observable stock entity used by the list and detail screens.
class StockModel: Identifiable {
    /// Unique ticker symbol used as the row identifier.
    let id: String
    /// Display name shown in the UI.
    let name: String
    /// Latest simulated price.
    var price: Double
    /// Delta between the latest price and the previous one.
    var change: Double
    
    init(id: String, name: String, price: Double, change: Double) {
        self.id = id
        self.name = name
        self.price = price
        self.change = change
    }
}
