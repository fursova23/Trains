import XCTest
@testable import Trains

final class ScheduleMappingTests: XCTestCase {
    func testTransferFlagComesFromAPIInsteadOfThreadPresence() throws {
        let json = """
        {"segments":[
          {"departure":"2026-09-22T08:00:00+03:00","arrival":"2026-09-22T10:00:00+03:00",
           "has_transfers":true,"thread":{"uid":"transfer","carrier":{"title":"Перевозчик","code":112}}},
          {"departure":"2026-09-22T14:00:00+03:00","arrival":"2026-09-22T15:00:00+03:00",
           "has_transfers":false},
          {"has_transfers":false}
        ]}
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(ScheduleBetweenStations.self, from: Data(json.utf8))
        let trips = CarrierTripMapper().map(response)
        XCTAssertEqual(trips.count, 2)
        XCTAssertEqual(trips.map(\.hasTransfer), [true, false])
        XCTAssertEqual(trips.first?.carrierCode, 112)
        XCTAssertEqual(trips.first?.duration, 7_200)
    }
}
