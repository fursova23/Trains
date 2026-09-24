import XCTest
@testable import Trains

@MainActor
final class CarrierResponseTests: XCTestCase {
    func testYandexResponseLoadsContactsThroughRepository() async throws {
        let service = CarrierJSONService(json: """
        {
          "carrier": {
            "code": 112,
            "title": " Тестовый перевозчик ",
            "email": " support@example.com ",
            "phone": "+7 (800) 123-45-67",
            "logo": "//example.com/carrier.png",
            "url": "https://example.com/",
            "codes": {"iata": null, "icao": null, "sirena": null}
          }
        }
        """)
        let repository = CarrierDetailsRepository(service: service)

        let details = try await repository.fetchCarrier(code: 112)

        XCTAssertEqual(service.requestedCode, "112")
        XCTAssertEqual(service.requestedSystem, "yandex")
        XCTAssertEqual(details.name, "Тестовый перевозчик")
        XCTAssertEqual(details.email, "support@example.com")
        XCTAssertEqual(details.phone, "+7 (800) 123-45-67")
        XCTAssertEqual(details.logoURL?.absoluteString, "https://example.com/carrier.png")
        XCTAssertEqual(details.websiteURL?.absoluteString, "https://example.com/")
    }

    func testCarrierWithoutContactsIsStillSuccessful() async throws {
        let service = CarrierJSONService(json: """
        {"carrier": {"code": 112, "title": "Перевозчик", "email": "", "phone": null}}
        """)
        let details = try await CarrierDetailsRepository(service: service).fetchCarrier(code: 112)

        XCTAssertEqual(details.name, "Перевозчик")
        XCTAssertNil(details.email)
        XCTAssertNil(details.phone)
        XCTAssertNil(details.logoURL)
    }

    func testMissingCarrierRemainsAnError() async {
        let service = CarrierJSONService(json: "{}")
        do {
            _ = try await CarrierDetailsRepository(service: service).fetchCarrier(code: 112)
            XCTFail("Ответ без carrier не должен считаться успешным")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .badServerResponse)
        }
    }

    func testIATAArrayRemainsSupportedByServiceSchema() throws {
        let json = """
        {"carriers": [{"code": 112, "title": "Первый"}, {"code": 113, "title": "Второй"}]}
        """
        let response = try JSONDecoder().decode(CarrierInfo.self, from: Data(json.utf8))

        XCTAssertNil(response.carrier)
        XCTAssertEqual(response.carriers?.map(\.code), [112, 113])
    }
}

@MainActor
private final class CarrierJSONService: CarrierInfoServiceProtocol {
    let json: String
    private(set) var requestedCode: String?
    private(set) var requestedSystem: String?

    init(json: String) { self.json = json }

    @MainActor func getCarrier(code: String, system: String?) async throws -> CarrierInfo {
        requestedCode = code
        requestedSystem = system
        return try JSONDecoder().decode(CarrierInfo.self, from: Data(json.utf8))
    }
}
