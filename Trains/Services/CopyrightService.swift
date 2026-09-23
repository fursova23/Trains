import OpenAPIRuntime

typealias YandexCopyright = Components.Schemas.CopyrightResponse

/// Сервис для работы с API "Копирайт Яндекс Расписаний"
protocol CopyrightServiceProtocol: Sendable {
    func getCopyright() async throws -> YandexCopyright
}

actor CopyrightService: CopyrightServiceProtocol {
    private let client: Client
    private let apiKey: String

    init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }

    func getCopyright() async throws -> YandexCopyright {
        let response = try await client.getCopyright(query: .init(
            apikey: apiKey,
            format: "json"
        ))
        return try response.ok.body.json
    }
}
