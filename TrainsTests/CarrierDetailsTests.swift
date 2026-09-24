import XCTest
@testable import Trains

@MainActor
final class CarrierDetailsTests: XCTestCase {
    func testContactLinksPreserveEmailAndNormalizePhone() {
        let details = CarrierDetails(
            name: "Перевозчик", logoURL: nil,
            email: "support@example.com", phone: "+7 (800) 123-45-67"
        )
        XCTAssertEqual(details.emailURL?.absoluteString, "mailto:support@example.com")
        XCTAssertEqual(details.phoneURL?.absoluteString, "tel:+78001234567")
        XCTAssertNil(CarrierDetails(name: "Без контактов", logoURL: nil, email: nil, phone: nil).phoneURL)
    }

    func testLoadsSelectedCarrierAndDoesNotFetchAgain() async {
        let repository = CarrierRepositoryStub()
        let model = CarrierDetailsViewModel(carrierCode: 112, repository: repository)
        await model.load()
        await model.load()
        XCTAssertEqual(repository.requestedCodes, [112])
        XCTAssertEqual(model.state, .loaded)
        XCTAssertEqual(model.details?.name, "ОАО «РЖД»")
        XCTAssertEqual(model.details?.email, "support@example.com")
    }

    func testFailedLoadCanBeRetried() async {
        let repository = CarrierRepositoryStub()
        repository.shouldFail = true
        let model = CarrierDetailsViewModel(carrierCode: 112, repository: repository)
        await model.load()
        XCTAssertEqual(model.state, .failed(.noInternet))
        repository.shouldFail = false
        await model.load()
        XCTAssertEqual(model.state, .loaded)
        XCTAssertEqual(repository.requestedCodes, [112, 112])
    }

}

@MainActor
private final class CarrierRepositoryStub: CarrierDetailsRepositoryProtocol {
    var requestedCodes: [Int] = []
    var shouldFail = false

    @MainActor func fetchCarrier(code: Int) async throws -> CarrierDetails {
        requestedCodes.append(code)
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return CarrierDetails(name: "ОАО «РЖД»", logoURL: nil, email: "support@example.com", phone: nil)
    }
}
