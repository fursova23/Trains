import Foundation

protocol CarrierDetailsRepositoryProtocol: Sendable {
    func fetchCarrier(code: Int) async throws -> CarrierDetails
}

actor CarrierDetailsRepository: CarrierDetailsRepositoryProtocol {
    private enum URLScheme {
        static let http = "http"
        static let https = "https"
    }

    private let service: CarrierInfoServiceProtocol

    init(service: CarrierInfoServiceProtocol) {
        self.service = service
    }

    func fetchCarrier(code: Int) async throws -> CarrierDetails {
        let response = try await service.getCarrier(code: String(code), system: "yandex")
        guard let carrier = response.carrier else {
            throw URLError(.badServerResponse)
        }
        return CarrierDetails(
            name: carrier.title?.trimmedNonEmpty ?? "Перевозчик",
            logoURL: makeLogoURL(from: carrier.logo),
            email: carrier.email?.trimmedNonEmpty,
            phone: carrier.phone?.trimmedNonEmpty,
            websiteURL: makeWebsiteURL(from: carrier.url)
        )
    }

    private func makeWebsiteURL(from value: String?) -> URL? {
        guard let value = value?.trimmedNonEmpty else { return nil }
        let address = value.hasPrefix("//") ? "\(URLScheme.https):\(value)" : value
        guard let url = URL(string: address),
              let scheme = url.scheme?.lowercased(),
              [URLScheme.http, URLScheme.https].contains(scheme) else { return nil }
        return url
    }

    private func makeLogoURL(from value: String?) -> URL? {
        guard let value = value?.trimmedNonEmpty else { return nil }
        return URL(string: value.hasPrefix("//") ? "\(URLScheme.https):\(value)" : value)
    }
}
