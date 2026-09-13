import Combine
import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let travelScheduleViewModel: TravelScheduleViewModel

    private let carrierDetailsRepository: CarrierDetailsRepositoryProtocol

    init() {
        do {
            let repositories = try YandexRaspRepositoryFactory.makeRepositories()
            travelScheduleViewModel = TravelScheduleViewModel(
                stationCatalogRepository: repositories.stationCatalog,
                scheduleRepository: repositories.schedule
            )
            carrierDetailsRepository = repositories.carrierDetails
        } catch {
            travelScheduleViewModel = TravelScheduleViewModel(configurationError: error)
            carrierDetailsRepository = UnavailableCarrierDetailsRepository(error: error)
        }
    }

    func makeCarrierDetailsViewModel(carrierCode: Int) -> CarrierDetailsViewModel {
        CarrierDetailsViewModel(
            carrierCode: carrierCode,
            repository: carrierDetailsRepository
        )
    }
}

private struct UnavailableCarrierDetailsRepository: CarrierDetailsRepositoryProtocol {
    let error: Error

    func fetchCarrier(code: Int) async throws -> CarrierDetails {
        throw error
    }
}
