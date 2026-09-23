import OpenAPIRuntime

typealias NearestStations = Components.Schemas.Stations

/// Сервис для работы с API "Список ближайших станций"
protocol NearestStationsServiceProtocol: Sendable {
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations
}

actor NearestStationsService: NearestStationsServiceProtocol {
    private let client: Client
    private let apiKey: String

    init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }

    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations {
        let response = try await client.getNearestStations(query: .init(
            apikey: apiKey,
            lat: lat,
            lng: lng,
            distance: distance
        ))
        return try response.ok.body.json
    }
}
