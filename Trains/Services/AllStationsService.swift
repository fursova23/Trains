import Foundation
import OpenAPIRuntime

typealias AllStations = Components.Schemas.AllStationsResponse

/// Сервис для работы с API  "Список всех доступных станций"
protocol AllStationsServiceProtocol {
    func getAllStations() async throws -> AllStations
}

final class AllStationsService: AllStationsServiceProtocol {
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
        return try JSONDecoder().decode(AllStations.self, from: fullData)
    }
}
