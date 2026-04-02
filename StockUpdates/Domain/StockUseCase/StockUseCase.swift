//
//  StockUseCase.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

protocol StockUseCaseProtocol {
    func connect() async
    func disconnect()
    func observeStocks() -> AsyncStream<[StockModel]>
}

class StockUseCase: StockUseCaseProtocol {
    
    private var stream: AsyncStream<[StockModel]>?
    
    func connect() async {
        
    }
    
    func disconnect() {
        
    }
    
    func observeStocks() -> AsyncStream<[StockModel]> {
        stream ?? AsyncStream { _ in }
    }
    
    
}
