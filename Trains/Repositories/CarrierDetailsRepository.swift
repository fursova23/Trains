import Foundation

protocol CarrierDetailsRepositoryProtocol {
    func fetchCarrier(code: Int) async throws -> CarrierDetails
}

final class CarrierDetailsRepository: CarrierDetailsRepositoryProtocol {
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
            phone: carrier.phone?.trimmedNonEmpty
        )
    }

    private func makeLogoURL(from value: String?) -> URL? {
        guard let value = value?.trimmedNonEmpty else { return nil }
        return URL(string: value.hasPrefix("//") ? "https:\(value)" : value)
    }
}
