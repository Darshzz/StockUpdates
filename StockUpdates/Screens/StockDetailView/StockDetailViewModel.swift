//
//  StockDetailViewModel.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

import Observation

@Observable
/// Holds the selected stock for the detail screen.
class StockDetailViewModel {
    
    /// Observable model displayed by the detail view.
    var stock: StockModel
    
    init(stock: StockModel) {
        self.stock = stock
    }
}
