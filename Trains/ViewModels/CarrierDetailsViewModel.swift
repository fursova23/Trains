import Combine
import Foundation

@MainActor
final class CarrierDetailsViewModel: ObservableObject {
    @Published private(set) var details: CarrierDetails
    @Published private(set) var state: NetworkLoadState = .idle
    private let carrierCode: Int?
    private let repository: CarrierDetailsRepositoryProtocol?

    init(trip: CarrierTrip, repository: CarrierDetailsRepositoryProtocol? = nil) {
        details = CarrierDetails(name: trip.carrierName, logoURL: trip.logoURL, email: nil, phone: nil)
        carrierCode = trip.carrierCode
        self.repository = repository
    }

    func load() async {
        guard state != .loaded, state != .loading else { return }
        guard let carrierCode else {
            state = .loaded
            return
        }
        state = .loading
        do {
            let repository = try (self.repository ?? CarrierDetailsRepository(service: CarrierInfoService(
                client: try YandexRaspClientFactory.makeClient(),
                apiKey: try YandexRaspClientFactory.apiKey()
            )))
            details = try await repository.fetchCarrier(code: carrierCode)
            state = .loaded
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failed(AppErrorKind.from(error))
        }
    }
}
