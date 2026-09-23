import Foundation

struct UnavailableRepositories: StationCatalogRepositoryProtocol, ScheduleRepositoryProtocol,
                                CarrierDetailsRepositoryProtocol {
    let error: Error

    func fetchCities() async throws -> [City] { throw error }
    func fetchTrips(from: String, to: String, date: Date) async throws -> [CarrierTrip] { throw error }
    func fetchCarrier(code: Int) async throws -> CarrierDetails { throw error }
}
