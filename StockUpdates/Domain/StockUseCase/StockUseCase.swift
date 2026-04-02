//
//  StockUseCase.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

protocol StockUseCaseProtocol {
    var sortOption: SortOption { get set }
    
    func connect() async
    func disconnect()
    func observeStocks() -> AsyncStream<[StockModel]>
    func sort(_ stocks: [StockModel]) -> [StockModel]
}

enum SortOption {
    case price, change
}

class StockUseCase: StockUseCaseProtocol {
    
    private let service: WebSocketProtocol
    var sortOption: SortOption = .price
    
    private let symbols = [
        "AAPL","GOOG","TSLA","AMZN","MSFT",
        "NVDA","META","NFLX","BABA","ORCL",
        "INTC","AMD","IBM","CSCO","ADBE",
        "CRM","UBER","LYFT","SHOP","SQ",
        "TWTR","SNAP","PINS","ZM","DOCU"
    ]
    private var stream: AsyncStream<[StockModel]>?
    
    init(service: WebSocketProtocol, stream: AsyncStream<[StockModel]>? = nil) {
        self.service = service
        self.stream = stream
    }
    
    func connect() async {
        stream = service.connect(symbols: symbols)
    }
    
    func disconnect() {
        service.disconnect()
    }
    
    func observeStocks() -> AsyncStream<[StockModel]> {
        stream ?? AsyncStream { _ in }
    }
    
    func sort(_ stocks: [StockModel]) -> [StockModel] {
        
        switch sortOption {
        case .price:
            return stocks.sorted { $0.price > $1.price }
        case .change:
            return stocks.sorted { $0.change > $1.change }
        }
    }
}
