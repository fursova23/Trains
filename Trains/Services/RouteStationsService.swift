import OpenAPIRuntime

typealias RouteStations = Components.Schemas.ThreadStationsResponse

/// Сервис для работы с API "Список станций следования"
protocol RouteStationsServiceProtocol {
    func getRouteStations(uid: String, date: String) async throws -> RouteStations
}

final class RouteStationsService: BaseAPIService, RouteStationsServiceProtocol {
    func getRouteStations(uid: String, date: String) async throws -> RouteStations {
        let response = try await client.getRouteStations(query: .init(
            apikey: apiKey,
            uid: uid,
            date: date
        ))
        return try response.ok.body.json
    }
}
