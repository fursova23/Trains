import OpenAPIRuntime

typealias NearestSettlement = Components.Schemas.NearestCityResponse

/// Сервис для работы с API "Ближайший город"
protocol NearestSettlementServiceProtocol {
    func getNearestSettlement(lat: Double, lng: Double) async throws -> NearestSettlement
}

final class NearestSettlementService: BaseAPIService, NearestSettlementServiceProtocol {
    func getNearestSettlement(lat: Double, lng: Double) async throws -> NearestSettlement {
        let response = try await client.getNearestCity(query: .init(
            apikey: apiKey,
            lat: lat,
            lng: lng
        ))
        return try response.ok.body.json
    }
}
