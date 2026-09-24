import Combine
import Foundation

@MainActor
final class CarrierDetailsViewModel: NetworkLoadingViewModel {
    private let carrierCode: Int
    private let repository: CarrierDetailsRepositoryProtocol

    @Published private(set) var details: CarrierDetails?

    init(
        carrierCode: Int,
        repository: CarrierDetailsRepositoryProtocol
    ) {
        self.carrierCode = carrierCode
        self.repository = repository
        super.init()
    }

    func load() async {
        await load(
            operation: { try await repository.fetchCarrier(code: carrierCode) },
            onSuccess: { details = $0 }
        )
    }
}
