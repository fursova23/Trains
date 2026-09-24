import Combine
import XCTest
@testable import Trains

@MainActor
final class ScreenViewModelTests: XCTestCase {
    private let city = City(code: "c213", name: "Москва", stations: [
        TravelStation(code: "s1", name: "Курский вокзал"),
        TravelStation(code: "s2", name: "Киевский вокзал")
    ])

    func testCityLoadRetryCacheAndSearch() async {
        let repository = CatalogStub(cities: [city])
        let model = CitySelectionViewModel(repository: repository)
        await model.load()
        XCTAssertEqual(model.state, .failed(.noInternet))
        await model.load()
        await model.load()
        XCTAssertEqual(model.state, .loaded)
        XCTAssertEqual(repository.calls, 2)
        model.query = "  МОСК  "
        XCTAssertEqual(model.filteredCities, [city])
        model.query = "Несуществующий город"
        XCTAssertTrue(model.filteredCities.isEmpty)
        model.query = ""
        XCTAssertEqual(model.filteredCities, [city])
    }

    func testStationSearchAndRoutePointPreserveCodes() {
        let model = StationSelectionViewModel(city: city)
        model.query = " КУРСК "
        XCTAssertEqual(model.filteredStations.map(\.code), ["s1"])
        XCTAssertEqual(model.routePoint(for: city.stations[0]),
                       RoutePoint(city: "Москва", station: "Курский вокзал", stationCode: "s1"))
        model.query = "нет такой станции"
        XCTAssertTrue(model.filteredStations.isEmpty)
    }

    func testFilterDraftDoesNotChangeAppliedFilterUntilConfirmation() {
        let original = CarrierFilter(periods: [.morning], transferOption: .withoutTransfers)
        let model = FiltersViewModel(filter: original)
        model.toggle(.morning)
        model.toggle(.night)
        model.select(.withTransfers)
        XCTAssertEqual(original.periods, [.morning])
        XCTAssertEqual(original.transferOption, .withoutTransfers)
        XCTAssertEqual(model.draft.periods, [.night])
        XCTAssertEqual(model.draft.transferOption, .withTransfers)
        XCTAssertTrue(model.canApply)
    }

    func testAllDeparturePeriodBoundariesBelongToExactlyOnePeriod() {
        for hour in 0..<24 {
            XCTAssertEqual(DeparturePeriod.allCases.filter { $0.contains(hour: hour) }.count, 1)
        }
        XCTAssertTrue(DeparturePeriod.morning.contains(hour: 6))
        XCTAssertTrue(DeparturePeriod.day.contains(hour: 12))
        XCTAssertTrue(DeparturePeriod.evening.contains(hour: 18))
        XCTAssertTrue(DeparturePeriod.night.contains(hour: 0))
    }

    func testAgreementRetryIgnoresPreviousWebViewCallbacks() async throws {
        let model = UserAgreementViewModel()
        let first = Task { await model.load() }
        defer { first.cancel() }
        let oldRequest = try await waitForRequest(model)
        XCTAssertEqual(model.state, .loading)
        XCTAssertEqual(oldRequest.url, AppSettings.agreementURL)
        oldRequest.complete(.failure(URLError(.notConnectedToInternet)))
        await first.value
        XCTAssertEqual(model.state, .failed(.noInternet))
        model.retry()
        let second = Task { await model.load() }
        defer { second.cancel() }
        let currentRequest = try await waitForRequest(model)
        oldRequest.complete(.success(()))
        XCTAssertEqual(model.state, .loading)
        currentRequest.complete(.success(()))
        await second.value
        XCTAssertEqual(model.state, .loaded)
    }

    func testAgreementCancellationResumesContinuationAndDiscardsLateCallback() async throws {
        let model = UserAgreementViewModel()
        let task = Task { await model.load() }
        defer { task.cancel() }
        let request = try await waitForRequest(model)
        task.cancel()
        await task.value
        request.complete(.success(()))
        XCTAssertEqual(model.state, .idle)
        XCTAssertNil(model.request)
    }

    func testAgreementWithoutURLFailsInsteadOfLoadingForever() async {
        let model = UserAgreementViewModel(url: nil)
        await model.load()
        XCTAssertEqual(model.state, .failed(.server))
    }

    func testWebResultBeforeAwaitAndDuplicateCallbacksAreSafe() async throws {
        let request = WebPageRequest(url: AppSettings.agreementURL)
        request.complete(.success(()))
        request.complete(.failure(URLError(.badServerResponse)))
        try await request.waitForCompletion()
    }

    private func waitForRequest(_ model: UserAgreementViewModel) async throws -> WebPageRequest {
        let ready = expectation(description: "Web request is ready")
        let subscription = model.$request.compactMap { $0 }.prefix(1).sink { _ in ready.fulfill() }
        defer { subscription.cancel() }
        await fulfillment(of: [ready], timeout: 2)
        return try XCTUnwrap(model.request)
    }

    func testViewedStoriesPersistAndSelectedCoverIsPreserved() throws {
        let suite = "StoriesTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let model = StoriesCollectionViewModel(stories: Story.mocks, userDefaults: defaults)
        model.select(Story.mocks[1])
        XCTAssertEqual(model.selectedStory?.id, 2)
        XCTAssertTrue(model.viewedIDs.isEmpty)
        model.markViewed(Story.mocks[1])
        model.markViewed(Story.mocks[1])
        let restored = StoriesCollectionViewModel(stories: Story.mocks, userDefaults: defaults)
        XCTAssertEqual(restored.viewedIDs, [2])
        XCTAssertNil(restored.selectedStory)
    }
}

@MainActor
private final class CatalogStub: StationCatalogRepositoryProtocol {
    let cities: [City]
    var calls = 0
    init(cities: [City]) { self.cities = cities }
    @MainActor func fetchCities() async throws -> [City] {
        calls += 1
        if calls == 1 { throw URLError(.notConnectedToInternet) }
        return cities
    }
}
