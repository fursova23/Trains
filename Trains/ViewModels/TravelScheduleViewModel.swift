import Combine
import Foundation

@MainActor
final class TravelScheduleViewModel: ObservableObject {
    @Published private(set) var cities: [City] = []
    @Published private(set) var catalogState: NetworkLoadState = .idle
    @Published private(set) var trips: [CarrierTrip] = []
    @Published private(set) var scheduleState: NetworkLoadState = .idle

    private let stationCatalogRepository: StationCatalogRepositoryProtocol?
    private let scheduleRepository: ScheduleRepositoryProtocol?
    private let configurationError: Error?
    private var loadedRouteKey: String?

    init() {
        do {
            let repositories = try YandexRaspRepositoryFactory.makeRepositories()
            stationCatalogRepository = repositories.stationCatalog
            scheduleRepository = repositories.schedule
            configurationError = nil
        } catch {
            stationCatalogRepository = nil
            scheduleRepository = nil
            configurationError = error
        }
    }

    func loadCitiesIfNeeded() async {
        guard catalogState != .loading,
              catalogState != .loaded else {
            return
        }

        guard let stationCatalogRepository else {
            catalogState = .failed(AppErrorKind.from(configurationError ?? NetworkConfigurationError.missingAPIKey))
            return
        }

        catalogState = .loading

        do {
            cities = try await stationCatalogRepository.fetchCities()
            catalogState = .loaded
        } catch {
            catalogState = .failed(AppErrorKind.from(error))
        }
    }

    func loadSchedule(from origin: RoutePoint, to destination: RoutePoint) async {
        let routeKey = "\(origin.stationCode)-\(destination.stationCode)"
        guard routeKey != loadedRouteKey || scheduleState != .loaded else {
            return
        }

        guard let scheduleRepository else {
            scheduleState = .failed(AppErrorKind.from(configurationError ?? NetworkConfigurationError.missingAPIKey))
            return
        }

        loadedRouteKey = routeKey
        trips = []
        scheduleState = .loading

        do {
            trips = try await scheduleRepository.fetchTrips(
                from: origin.stationCode,
                to: destination.stationCode,
                date: Date()
            )
            scheduleState = .loaded
        } catch {
            scheduleState = .failed(AppErrorKind.from(error))
        }
    }
}
