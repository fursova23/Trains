import OpenAPIRuntime

typealias RouteStations = Components.Schemas.ThreadStationsResponse

/// Сервис для работы с API "Список станций следования"
protocol RouteStationsServiceProtocol: Sendable {
    func getRouteStations(uid: String, date: String) async throws -> RouteStations
}

actor RouteStationsService: RouteStationsServiceProtocol {
    private let client: Client
    private let apiKey: String

    init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }

    func getRouteStations(uid: String, date: String) async throws -> RouteStations {
        let response = try await client.getRouteStations(query: .init(
            apikey: apiKey,
            uid: uid,
            date: date
        ))
        return try response.ok.body.json
    }
}
