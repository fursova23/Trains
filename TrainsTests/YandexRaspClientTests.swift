import Foundation
import HTTPTypes
import OpenAPIRuntime
import XCTest
@testable import Trains

final class YandexRaspClientTests: XCTestCase {
    func testAllServiceMethodsDecodeModelsAndForwardParameters() async throws {
        let transport = RecordingTransport()
        let generatedClient = Client(serverURL: URL(string: "https://example.com")!, transport: transport)
        let client = YandexRaspClient(client: generatedClient, apiKey: "test-key")

        async let stations = client.getAllStations()
        async let schedule = client.getSchedule(from: "s1", to: "s2", date: "2026-09-22")
        async let stationSchedule = client.getSchedule(station: "s3", date: "2026-09-23")
        async let route = client.getRouteStations(uid: "route-1", date: "2026-09-24")
        async let nearest = client.getNearestStations(lat: 55.75, lng: 37.61, distance: 10)
        async let city = client.getNearestSettlement(lat: 55.76, lng: 37.62)
        async let carrier = client.getCarrier(code: "112", system: "yandex")
        async let copyright = client.getCopyright()

        let models = try await (stations, schedule, stationSchedule, route, nearest, city, carrier, copyright)
        XCTAssertEqual(models.0.countries?.first?.title, "Россия")
        XCTAssertEqual(models.1.segments?.count, 0)
        XCTAssertEqual(models.2.schedule?.count, 0)
        XCTAssertEqual(models.3.uid, "route-1")
        XCTAssertEqual(models.4.stations?.first?.code, "s1")
        XCTAssertEqual(models.5.title, "Москва")
        XCTAssertEqual(models.6.carrier?.code, 112)
        XCTAssertEqual(models.7.copyright?.text, "Яндекс Расписания")

        let requests = await transport.requests
        XCTAssertEqual(requests.count, 8)
        for request in requests.values {
            XCTAssertEqual(request.method, .get)
            XCTAssertEqual(query(request)["apikey"], "test-key")
        }
        let between = query(try XCTUnwrap(requests["getSchedualBetweenStations"]))
        XCTAssertEqual(between["from"], "s1")
        XCTAssertEqual(between["to"], "s2")
        XCTAssertEqual(between["date"], "2026-09-22")
        XCTAssertEqual(between["transfers"], "true")
        let station = query(try XCTUnwrap(requests["getStationSchedule"]))
        XCTAssertEqual(station["station"], "s3")
        XCTAssertEqual(station["date"], "2026-09-23")
        let routeQuery = query(try XCTUnwrap(requests["getRouteStations"]))
        XCTAssertEqual(routeQuery["uid"], "route-1")
        XCTAssertEqual(routeQuery["date"], "2026-09-24")
        let nearestQuery = query(try XCTUnwrap(requests["getNearestStations"]))
        XCTAssertEqual(nearestQuery["lat"], "55.75")
        XCTAssertEqual(nearestQuery["lng"], "37.61")
        XCTAssertEqual(nearestQuery["distance"], "10")
        let cityQuery = query(try XCTUnwrap(requests["getNearestCity"]))
        XCTAssertEqual(cityQuery["lat"], "55.76")
        XCTAssertEqual(cityQuery["lng"], "37.62")
        let carrierQuery = query(try XCTUnwrap(requests["getCarrierInfo"]))
        XCTAssertEqual(carrierQuery["code"], "112")
        XCTAssertEqual(carrierQuery["system"], "yandex")
        XCTAssertEqual(query(try XCTUnwrap(requests["getCopyright"]))["format"], "json")
    }

    func testServerErrorIsPropagatedThroughClientAndRepository() async {
        let transport = RecordingTransport(fails: true)
        let generatedClient = Client(serverURL: URL(string: "https://example.com")!, transport: transport)
        let client = YandexRaspClient(client: generatedClient, apiKey: "test-key")
        let repository = CarrierDetailsRepository(service: client)
        do {
            _ = try await repository.fetchCarrier(code: 112)
            XCTFail("HTTP 500 must not be converted to a successful response")
        } catch {
            XCTAssertEqual(AppErrorKind.from(error), .server)
        }
    }

    private func query(_ request: HTTPRequest) -> [String: String] {
        let items = URLComponents(string: "https://example.com" + (request.path ?? ""))?.queryItems ?? []
        return Dictionary(items.map { ($0.name, $0.value ?? "") }, uniquingKeysWith: { first, _ in first })
    }
}

private actor RecordingTransport: ClientTransport {
    private(set) var requests: [String: HTTPRequest] = [:]
    private let fails: Bool

    init(fails: Bool = false) { self.fails = fails }

    func send(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String) async throws
        -> (HTTPResponse, HTTPBody?) {
        requests[operationID] = request
        if fails { return (HTTPResponse(status: .internalServerError), nil) }
        let json: String
        switch operationID {
        case "getAllStations": json = #"{"countries":[{"title":"Россия"}]}"#
        case "getSchedualBetweenStations": json = #"{"segments":[]}"#
        case "getStationSchedule": json = #"{"schedule":[]}"#
        case "getRouteStations": json = #"{"uid":"route-1"}"#
        case "getNearestStations": json = #"{"stations":[{"code":"s1"}]}"#
        case "getNearestCity": json = #"{"title":"Москва"}"#
        case "getCarrierInfo": json = #"{"carrier":{"code":112}}"#
        case "getCopyright": json = #"{"copyright":{"text":"Яндекс Расписания"}}"#
        default: throw URLError(.unsupportedURL)
        }
        let contentType = operationID == "getAllStations" ? "text/html" : "application/json"
        return (HTTPResponse(status: .ok, headerFields: [.contentType: contentType]), HTTPBody(json))
    }
}
