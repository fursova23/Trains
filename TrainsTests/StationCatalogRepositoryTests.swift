import XCTest
@testable import Trains

final class StationCatalogRepositoryTests: XCTestCase {
    func testConcurrentLoadsUseFirstCompletedCacheWithoutOverwritingIt() async throws {
        let service = CatalogServiceStub()
        let repository = StationCatalogRepository(allStationsService: service)
        async let first = repository.fetchCities()
        async let second = repository.fetchCities()
        let (firstCities, secondCities) = try await (first, second)
        let cachedCities = try await repository.fetchCities()
        XCTAssertEqual(firstCities, secondCities)
        XCTAssertEqual(cachedCities, firstCities)
        let calls = await service.calls
        XCTAssertEqual(calls, 2)
    }

    func testCancelledRequestDoesNotPopulateCache() async throws {
        let service = CatalogServiceStub()
        let repository = StationCatalogRepository(allStationsService: service)
        let request = Task { try await repository.fetchCities() }
        await service.waitUntilStarted()
        request.cancel()
        do {
            _ = try await request.value
            XCTFail("Cancelled catalog must not be returned or cached")
        } catch is CancellationError {
            // Expected even when the service itself ignores cancellation.
        }
        _ = try await repository.fetchCities()
        let calls = await service.calls
        XCTAssertEqual(calls, 2)
    }
}

private actor CatalogServiceStub: AllStationsServiceProtocol {
    private(set) var calls = 0
    private var started: CheckedContinuation<Void, Never>?

    func waitUntilStarted() async {
        if calls > 0 { return }
        await withCheckedContinuation { started = $0 }
    }

    func getAllStations() async throws -> AllStations {
        calls += 1
        let call = calls
        started?.resume()
        started = nil
        try? await Task.sleep(for: .milliseconds(call == 1 ? 100 : 10))
        let json = """
        {"countries":[{"regions":[{"settlements":[
          {"title":"Город \(call)","codes":{"yandex_code":"c\(call)"},"stations":[
            {"title":"Вокзал","codes":{"yandex_code":"s1"},"transport_type":"train"}
          ]}
        ]}]}]}
        """
        return try JSONDecoder().decode(AllStations.self, from: Data(json.utf8))
    }
}
