import OpenAPIRuntime

typealias CarrierInfo = Components.Schemas.CarrierResponse

/// Сервис для работы с API "Информация о перевозчике"
protocol CarrierInfoServiceProtocol {
    func getCarrier(code: String, system: String?) async throws -> CarrierInfo
}

final class CarrierInfoService: CarrierInfoServiceProtocol {
    private let client: Client
    private let apiKey: String

    init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }

    func getCarrier(code: String, system: String? = nil) async throws -> CarrierInfo {
        let response = try await client.getCarrierInfo(query: .init(
            apikey: apiKey,
            code: code,
            system: system
        ))
        return try response.ok.body.json
    }
}
