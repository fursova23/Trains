import Combine
import Foundation

@MainActor
final class CarrierDetailsViewModel: ObservableObject {
    private let carrierCode: Int
    private let repository: CarrierDetailsRepositoryProtocol

    @Published private(set) var state: NetworkLoadState = .idle
    @Published private(set) var details: CarrierDetails?

    init(
        carrierCode: Int,
        repository: CarrierDetailsRepositoryProtocol
    ) {
        self.carrierCode = carrierCode
        self.repository = repository
    }

    func load() async {
        guard state != .loading, state != .loaded else { return }

        state = .loading

        do {
            let details = try await repository.fetchCarrier(code: carrierCode)
            try Task.checkCancellation()

            self.details = details
            state = .loaded
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failed(AppErrorKind.from(error))
        }
    }
}
