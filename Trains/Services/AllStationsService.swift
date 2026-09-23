import Foundation
import OpenAPIRuntime

typealias AllStations = Components.Schemas.AllStationsResponse

/// Сервис для работы с API  "Список всех доступных станций"
protocol AllStationsServiceProtocol: Sendable {
    func getAllStations() async throws -> AllStations
}

actor AllStationsService: AllStationsServiceProtocol {
    private let client: Client
    private let apiKey: String

    init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }

    func getAllStations() async throws -> AllStations {
        let response = try await client.getAllStations(query: .init(apikey: apiKey))
        let responseBody = try response.ok.body.html
        let limit = 50 * 1024 * 1024 // 50 MB
        let fullData = try await Data(collecting: responseBody, upTo: limit)

        try Task.checkCancellation()
        let stations = try JSONDecoder().decode(AllStations.self, from: fullData)
        try Task.checkCancellation()
        return stations
    }
}
