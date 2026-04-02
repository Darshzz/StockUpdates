//
//  StockDetailViewModel.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import Observation

@Observable
class StockDetailViewModel {
    
    var stock: StockModel
    
    init(stock: StockModel) {
        self.stock = stock
    }
}
