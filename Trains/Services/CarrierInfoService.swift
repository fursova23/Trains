import OpenAPIRuntime

typealias CarrierInfo = Components.Schemas.CarrierResponse

/// Сервис для работы с API "Информация о перевозчике"
protocol CarrierInfoServiceProtocol {
    func getCarrier(code: String, system: String?) async throws -> CarrierInfo
}

final class CarrierInfoService: BaseAPIService, CarrierInfoServiceProtocol {
    func getCarrier(code: String, system: String? = nil) async throws -> CarrierInfo {
        let response = try await client.getCarrierInfo(query: .init(
            apikey: apiKey,
            code: code,
            system: system
        ))
        return try response.ok.body.json
    }
}
