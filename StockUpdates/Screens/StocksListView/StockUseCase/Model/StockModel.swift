//
//  StockModel.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import Observation

@Observable
class StockModel: Identifiable {
    let id: String
    let name: String
    var price: Double
    var change: Double
    
    init(id: String, name: String, price: Double, change: Double) {
        self.id = id
        self.name = name
        self.price = price
        self.change = change
    }
}
