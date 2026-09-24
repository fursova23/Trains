import XCTest
@testable import Trains

@MainActor
final class CarrierListViewModelTests: XCTestCase {
    private let origin = RoutePoint(city: "Москва", station: "Курский", stationCode: "s1")
    private let destination = RoutePoint(city: "Тула", station: "Московский", stationCode: "s2")

    func testScheduleLoadsOnceAndCombinesPeriodAndTransferFilters() async {
        let start = Calendar.current.startOfDay(for: .now)
        let trips = [trip("morning", date: start.addingTimeInterval(8 * 3_600), transfer: false),
                     trip("day", date: start.addingTimeInterval(14 * 3_600), transfer: true)]
        let repository = ScheduleStub(trips: trips)
        let model = CarrierListViewModel(origin: origin, destination: destination, repository: repository)
        await model.load()
        await model.load()
        XCTAssertEqual(model.state, .loaded)
        XCTAssertEqual(repository.calls, 1)
        XCTAssertEqual(repository.requestedRoute, ["s1", "s2"])
        model.filter.transferOption = .withTransfers
        XCTAssertEqual(model.filteredTrips.count, 2)
        model.filter.transferOption = .withoutTransfers
        XCTAssertEqual(model.filteredTrips.map(\.id), ["morning"])
        model.filter.periods = [.day]
        XCTAssertTrue(model.filteredTrips.isEmpty)
        model.filter.transferOption = .withTransfers
        XCTAssertEqual(model.filteredTrips.map(\.id), ["day"])
    }

    func testFailedScheduleCanRetryAndEmptyResponseIsLoaded() async {
        let repository = ScheduleStub(trips: [], shouldFail: true)
        let model = CarrierListViewModel(origin: origin, destination: destination, repository: repository)
        await model.load()
        XCTAssertEqual(model.state, .failed(.server))
        repository.shouldFail = false
        model.retry()
        await model.load()
        XCTAssertEqual(model.state, .loaded)
        XCTAssertTrue(model.trips.isEmpty)
    }

    func testCancellationDiscardsLateResponseAndAllowsNextLoad() async {
        let repository = DelayedScheduleRepository()
        let model = CarrierListViewModel(origin: origin, destination: destination, repository: repository)
        let request = Task { await model.load() }
        await repository.waitUntilStarted()
        XCTAssertEqual(model.state, .loading)
        await model.load()
        let calls = await repository.calls
        XCTAssertEqual(calls, 1)
        request.cancel()
        await repository.finish(with: [trip("stale", date: .now, transfer: false)])
        await request.value
        XCTAssertEqual(model.state, .idle)
        XCTAssertTrue(model.trips.isEmpty)

        let retry = Task { await model.load() }
        await repository.waitUntilStarted()
        await repository.finish(with: [])
        await retry.value
        XCTAssertEqual(model.state, .loaded)
    }

    private func trip(_ id: String, date: Date, transfer: Bool) -> CarrierTrip {
        CarrierTrip(id: id, carrierCode: 112, carrierName: "Перевозчик", logoURL: nil,
                    departure: date, arrival: date.addingTimeInterval(3_600), duration: 3_600,
                    hasTransfer: transfer)
    }
}

@MainActor
private final class ScheduleStub: ScheduleRepositoryProtocol {
    let trips: [CarrierTrip]
    var shouldFail: Bool
    var calls = 0
    var requestedRoute: [String] = []
    init(trips: [CarrierTrip], shouldFail: Bool = false) {
        self.trips = trips
        self.shouldFail = shouldFail
    }
    @MainActor func fetchTrips(from: String, to: String, date: Date) async throws -> [CarrierTrip] {
        calls += 1
        requestedRoute = [from, to]
        if shouldFail { throw URLError(.badServerResponse) }
        return trips
    }
}

private actor DelayedScheduleRepository: ScheduleRepositoryProtocol {
    private var response: CheckedContinuation<[CarrierTrip], Never>?
    private var started: CheckedContinuation<Void, Never>?
    private(set) var calls = 0

    func fetchTrips(from: String, to: String, date: Date) async throws -> [CarrierTrip] {
        calls += 1
        return await withCheckedContinuation { continuation in
            response = continuation
            started?.resume()
            started = nil
        }
    }

    func waitUntilStarted() async {
        if response != nil { return }
        await withCheckedContinuation { started = $0 }
    }

    func finish(with trips: [CarrierTrip]) {
        let continuation = response
        response = nil
        continuation?.resume(returning: trips)
    }
}
