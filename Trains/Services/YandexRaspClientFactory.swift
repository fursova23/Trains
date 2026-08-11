import Foundation
import OpenAPIURLSession

enum NetworkConfigurationError: LocalizedError {
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Добавьте YANDEX_RASP_API_KEY в Environment Variables схемы запуска"
        }
    }
}

enum YandexRaspClientFactory {
    static func makeClient() throws -> Client {
        Client(
            serverURL: try Servers.Server1.url(),
            transport: URLSessionTransport()
        )
    }

    static func apiKey() throws -> String {
        guard let
            apiKey = ProcessInfo.processInfo.environment["YANDEX_RASP_API_KEY"],
            !apiKey.isEmpty else {
            throw NetworkConfigurationError.missingAPIKey
        }
        return apiKey
    }
}
