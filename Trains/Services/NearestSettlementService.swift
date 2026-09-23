import OpenAPIRuntime

typealias NearestSettlement = Components.Schemas.NearestCityResponse

/// Сервис для работы с API "Ближайший город"
protocol NearestSettlementServiceProtocol: Sendable {
    func getNearestSettlement(lat: Double, lng: Double) async throws -> NearestSettlement
}

actor NearestSettlementService: NearestSettlementServiceProtocol {
    private let client: Client
    private let apiKey: String

    init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }

    func getNearestSettlement(lat: Double, lng: Double) async throws -> NearestSettlement {
        let response = try await client.getNearestCity(query: .init(
            apikey: apiKey,
            lat: lat,
            lng: lng
        ))
        return try response.ok.body.json
    }
}
