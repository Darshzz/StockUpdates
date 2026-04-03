//
//  StockUseCase.swift
//  StockUpdates
//
//  Created by Darshan Mothreja on 02/04/26.
//

/// Business layer contract for managing stock streaming and sorting behavior.
protocol StockUseCaseProtocol {
    var sortOption: SortOption { get set }
    
    func connect() async
    func disconnect()
    func observeStocks() -> AsyncStream<[StockModel]>
    func observeState() -> AsyncStream<WebSocketState>
    func sort(_ stocks: [StockModel]) -> [StockModel]
}

/// Supported sort modes for the stock list.
enum SortOption {
    case price, change
}

/// Coordinates websocket data with view model friendly operations.
class StockUseCase: StockUseCaseProtocol {
    
    /// Lower-level websocket service that produces stock updates.
    private let service: WebSocketProtocol
    /// Current sort choice selected by the user.
    var sortOption: SortOption = .price
    
    /// Static list of symbols used to seed the demo feed.
    private let symbols = [
        "AAPL","GOOG","TSLA","AMZN","MSFT",
        "NVDA","META","NFLX","BABA","ORCL",
        "INTC","AMD","IBM","CSCO","ADBE",
        "CRM","UBER","LYFT","SHOP","SQ",
        "TWTR","SNAP","PINS","ZM","DOCU"
    ]
    /// Cached stream returned by the websocket service after connecting.
    private var stream: AsyncStream<[StockModel]>?
    
    init(service: WebSocketProtocol, stream: AsyncStream<[StockModel]>? = nil) {
        self.service = service
        self.stream = stream
    }
    
    func connect() async {
        // Captures the stock update stream so the view model can observe it later.
        stream = service.connect(symbols: symbols)
    }
    
    func disconnect() {
        // Delegates connection teardown to the websocket service.
        service.disconnect()
    }
    
    func observeStocks() -> AsyncStream<[StockModel]> {
        // Returns an empty stream if connect() has not been called yet.
        stream ?? AsyncStream { _ in }
    }
    
    func observeState() -> AsyncStream<WebSocketState> {
        // Exposes connection state directly from the service.
        service.observeConnectionState()
    }
    
    func sort(_ stocks: [StockModel]) -> [StockModel] {
        
        // Sorts descending so the largest values appear at the top of the list.
        switch sortOption {
        case .price:
            return stocks.sorted { $0.price > $1.price }
        case .change:
            return stocks.sorted { $0.change > $1.change }
        }
    }
}
