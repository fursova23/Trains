import Foundation
import OpenAPIRuntime

typealias AllStations = Components.Schemas.AllStationsResponse

/// Сервис для работы с API  "Список всех доступных станций"
protocol AllStationsServiceProtocol {
    func getAllStations() async throws -> AllStations
}

final class AllStationsService: BaseAPIService, AllStationsServiceProtocol {
    func getAllStations() async throws -> AllStations {
        let response = try await client.getAllStations(query: .init(apikey: apiKey))
        let responseBody = try response.ok.body.html
        let limit = 50 * 1024 * 1024 // 50 MB
        let fullData = try await Data(collecting: responseBody, upTo: limit)

        return try await Task.detached(priority: .userInitiated) {
            try JSONDecoder().decode(AllStations.self, from: fullData)
        }.value
    }
}
