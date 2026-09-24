import Combine
import XCTest
@testable import Trains

@MainActor
final class MainViewModelTests: XCTestCase {
    private let origin = RoutePoint(city: "Москва", station: "Курский", stationCode: "s2000001")
    private let destination = RoutePoint(city: "Тула", station: "Московский", stationCode: "s2000170")

    func testSearchRequiresBothRoutePoints() {
        let viewModel = MainViewModel()

        viewModel.search()
        XCTAssertFalse(viewModel.showsCarriers)

        viewModel.beginSelection(.origin)
        viewModel.select(origin, for: .origin)
        viewModel.search()
        XCTAssertFalse(viewModel.isRouteComplete)
        XCTAssertFalse(viewModel.showsCarriers)

        viewModel.beginSelection(.destination)
        viewModel.select(destination, for: .destination)
        viewModel.search()
        XCTAssertTrue(viewModel.isRouteComplete)
        XCTAssertTrue(viewModel.showsCarriers)
        XCTAssertNil(viewModel.selectionTarget)
    }

    func testReplacingDestinationPreservesOrigin() {
        let viewModel = MainViewModel(origin: origin, destination: destination)
        let replacement = RoutePoint(city: "Калуга", station: "Калуга-1", stationCode: "s2000250")

        viewModel.beginSelection(.destination)
        viewModel.select(replacement, for: .destination)

        XCTAssertEqual(viewModel.origin, origin)
        XCTAssertEqual(viewModel.destination, replacement)
        XCTAssertNil(viewModel.selectionTarget)
    }

    func testCancellingSelectionPreservesRoute() {
        let viewModel = MainViewModel(origin: origin, destination: destination)

        viewModel.beginSelection(.origin)
        viewModel.selectionTarget = nil

        XCTAssertEqual(viewModel.origin, origin)
        XCTAssertEqual(viewModel.destination, destination)
    }

    func testSwapExchangesCompleteStationDataAndCanBeReversed() {
        let viewModel = MainViewModel(origin: origin, destination: destination)

        viewModel.swapRoute()
        XCTAssertEqual(viewModel.origin, destination)
        XCTAssertEqual(viewModel.destination, origin)
        XCTAssertTrue(viewModel.isRouteComplete)

        viewModel.swapRoute()
        XCTAssertEqual(viewModel.origin, origin)
        XCTAssertEqual(viewModel.destination, destination)
    }

    func testSwapWithOneStationDoesNotAllowSearch() {
        let viewModel = MainViewModel(origin: origin)

        viewModel.swapRoute()
        viewModel.search()

        XCTAssertNil(viewModel.origin)
        XCTAssertEqual(viewModel.destination, origin)
        XCTAssertFalse(viewModel.showsCarriers)
    }

    func testRouteReadinessPublishesChanges() async {
        let viewModel = MainViewModel(origin: origin)
        let change = expectation(description: "Route readiness observers receive the change")

        let subscription = viewModel.$destination.dropFirst().prefix(1).sink { _ in
            change.fulfill()
        }
        defer { subscription.cancel() }

        viewModel.select(destination, for: .destination)

        await fulfillment(of: [change], timeout: 1)
        XCTAssertTrue(viewModel.isRouteComplete)
    }
}
