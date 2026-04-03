//
//  StockUpdatesTests.swift
//  StockUpdatesTests
//
//  Created by Darshan Mothreja on 02/04/26.
//

import XCTest
@testable import StockUpdates

@MainActor
final class StockUpdatesTests: XCTestCase {

    func configureWebService() -> WebSocketService {
         WebSocketService()
    }
    
    func testWebSocketService_observeConnectionState_yieldsIdleInitially() async {
        let service = configureWebService()
        let stream = service.observeConnectionState()
        let state = await firstValue(from: stream)

        XCTAssertEqual(state, .idle)
    }

    func testWebSocketService_disconnect_afterObservingState_yieldsDisconnected() async {
        let service = configureWebService()
        
        let stream = service.observeConnectionState()
        var iterator = stream.makeAsyncIterator()

        let initialState = await iterator.next()
        service.disconnect()
        let disconnectedState = await iterator.next()

        XCTAssertEqual(initialState, .idle)
        XCTAssertEqual(disconnectedState, .disconnected)
    }

    func testStockUseCase_connect_requestsExpectedSymbolsFromService() async {
        let service = MockWebSocketService()
        let useCase = StockUseCase(service: service)

        await useCase.connect()

        XCTAssertEqual(service.connectCallCount, 1)
        XCTAssertEqual(service.connectedSymbols, [
            "AAPL", "GOOG", "TSLA", "AMZN", "MSFT",
            "NVDA", "META", "NFLX", "BABA", "ORCL",
            "INTC", "AMD", "IBM", "CSCO", "ADBE",
            "CRM", "UBER", "LYFT", "SHOP", "SQ",
            "TWTR", "SNAP", "PINS", "ZM", "DOCU"
        ])
    }

    func testStockUseCase_observeStocks_returnsStreamProvidedByServiceAfterConnect() async {
        let expectedStocks = [
            StockModel(id: "AAPL", name: "Apple", price: 210, change: 3),
            StockModel(id: "TSLA", name: "Tesla", price: 180, change: -4)
        ]
        let service = MockWebSocketService(stockStream: asyncStream(emitting: [expectedStocks]))
        let useCase = StockUseCase(service: service)

        await useCase.connect()
        let stocks = await firstValue(from: useCase.observeStocks())

        XCTAssertEqual(stocks?.map { $0.id }, ["AAPL", "TSLA"])
        XCTAssertEqual(stocks?.map { $0.price }, [210, 180])
    }

    func testStockUseCase_observeStocks_usesInjectedInitialStreamUntilConnectIsCalled() async {
        let initialStocks = [
            StockModel(id: "IBM", name: "IBM", price: 150, change: 1)
        ]
        let serviceStocks = [
            StockModel(id: "NVDA", name: "NVIDIA", price: 900, change: 12)
        ]
        let service = MockWebSocketService(stockStream: asyncStream(emitting: [serviceStocks]))
        let useCase = StockUseCase(
            service: service,
            stream: asyncStream(emitting: [initialStocks])
        )

        let stocks = await firstValue(from: useCase.observeStocks())

        XCTAssertEqual(stocks?.map(\.id), ["IBM"])
        XCTAssertEqual(service.connectCallCount, 0)
    }

    func testStockUseCase_connect_replacesInjectedInitialStreamWithServiceStream() async {
        let initialStocks = [
            StockModel(id: "IBM", name: "IBM", price: 150, change: 1)
        ]
        let serviceStocks = [
            StockModel(id: "NVDA", name: "NVIDIA", price: 900, change: 12)
        ]
        let service = MockWebSocketService(stockStream: asyncStream(emitting: [serviceStocks]))
        let useCase = StockUseCase(
            service: service,
            stream: asyncStream(emitting: [initialStocks])
        )

        await useCase.connect()
        let stocks = await firstValue(from: useCase.observeStocks())

        XCTAssertEqual(stocks?.map(\.id), ["NVDA"])
        XCTAssertEqual(service.connectCallCount, 1)
    }

    func testStockUseCase_observeState_returnsStateStreamProvidedByService() async {
        let service = MockWebSocketService(
            stateStream: asyncStream(emitting: [.idle, .connecting, .connected])
        )
        let useCase = StockUseCase(service: service)
        let stream = useCase.observeState()
        var iterator = stream.makeAsyncIterator()

        let first = await iterator.next()
        let second = await iterator.next()
        let third = await iterator.next()

        XCTAssertEqual(first, .idle)
        XCTAssertEqual(second, .connecting)
        XCTAssertEqual(third, .connected)
    }

    func testStockUseCase_disconnect_delegatesToService() {
        let service = MockWebSocketService()
        let useCase = StockUseCase(service: service)

        useCase.disconnect()

        XCTAssertEqual(service.disconnectCallCount, 1)
    }

    func testStockUseCase_sort_whenSortOptionIsPrice_sortsDescendingByPrice() {
        let service = MockWebSocketService()
        let useCase = StockUseCase(service: service)
        useCase.sortOption = .price

        let stocks = [
            StockModel(id: "TSLA", name: "Tesla", price: 180, change: 5),
            StockModel(id: "AAPL", name: "Apple", price: 210, change: 2),
            StockModel(id: "MSFT", name: "Microsoft", price: 195, change: 7)
        ]

        let sortedStocks = useCase.sort(stocks)

        XCTAssertEqual(sortedStocks.map(\.id), ["AAPL", "MSFT", "TSLA"])
    }

    func testStockUseCase_sort_whenSortOptionIsChange_sortsDescendingByChange() {
        let service = MockWebSocketService()
        let useCase = StockUseCase(service: service)
        useCase.sortOption = .change

        let stocks = [
            StockModel(id: "TSLA", name: "Tesla", price: 180, change: -1),
            StockModel(id: "AAPL", name: "Apple", price: 210, change: 2),
            StockModel(id: "MSFT", name: "Microsoft", price: 195, change: 7)
        ]

        let sortedStocks = useCase.sort(stocks)

        XCTAssertEqual(sortedStocks.map(\.id), ["MSFT", "AAPL", "TSLA"])
    }

    private func firstValue<T>(from stream: AsyncStream<T>) async -> T? {
        var iterator = stream.makeAsyncIterator()
        return await iterator.next()
    }

    private func asyncStream<T>(emitting values: [T]) -> AsyncStream<T> {
        AsyncStream { continuation in
            for value in values {
                continuation.yield(value)
            }
            continuation.finish()
        }
    }
}

@MainActor
private final class MockWebSocketService: WebSocketProtocol {
    private(set) var connectCallCount = 0
    private(set) var disconnectCallCount = 0
    private(set) var connectedSymbols: [String] = []

    private let stockStream: AsyncStream<[StockModel]>
    private let stateStream: AsyncStream<WebSocketState>

    init(
        stockStream: AsyncStream<[StockModel]> = AsyncStream { continuation in
            continuation.finish()
        },
        stateStream: AsyncStream<WebSocketState> = AsyncStream { continuation in
            continuation.yield(.idle)
            continuation.finish()
        }
    ) {
        self.stockStream = stockStream
        self.stateStream = stateStream
    }

    func connect(symbols: [String]) -> AsyncStream<[StockModel]> {
        connectCallCount += 1
        connectedSymbols = symbols
        return stockStream
    }

    func disconnect() {
        disconnectCallCount += 1
    }

    func observeConnectionState() -> AsyncStream<WebSocketState> {
        stateStream
    }
}
