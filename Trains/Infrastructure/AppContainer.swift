import Combine
import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let settingsViewModel: SettingsViewModel
    let mainViewModel: MainViewModel
    let rootViewModel = AppRootViewModel()

    private let stationCatalogRepository: StationCatalogRepositoryProtocol
    private let scheduleRepository: ScheduleRepositoryProtocol
    private let carrierDetailsRepository: CarrierDetailsRepositoryProtocol

    init(
        userDefaults: UserDefaults = .standard,
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) {
        settingsViewModel = SettingsViewModel(userDefaults: userDefaults)
        mainViewModel = MainViewModel()

#if DEBUG
        if arguments.contains("-ui-testing") {
            let repositories = UITestRepositories(arguments: arguments)
            stationCatalogRepository = repositories
            scheduleRepository = repositories
            carrierDetailsRepository = repositories
            return
        }
#endif

        do {
            let repositories = try YandexRaspRepositoryFactory.makeRepositories()
            stationCatalogRepository = repositories.stationCatalog
            scheduleRepository = repositories.schedule
            carrierDetailsRepository = repositories.carrierDetails
        } catch {
            let unavailable = UnavailableRepositories(error: error)
            stationCatalogRepository = unavailable
            scheduleRepository = unavailable
            carrierDetailsRepository = unavailable
        }
    }

    func makeCitySelectionViewModel() -> CitySelectionViewModel {
        CitySelectionViewModel(repository: stationCatalogRepository)
    }

    func makeCarrierListViewModel(origin: RoutePoint, destination: RoutePoint) -> CarrierListViewModel {
        CarrierListViewModel(origin: origin, destination: destination, repository: scheduleRepository)
    }

    func makeCarrierDetailsViewModel(carrierCode: Int) -> CarrierDetailsViewModel {
        CarrierDetailsViewModel(carrierCode: carrierCode, repository: carrierDetailsRepository)
    }
}
