import Foundation

struct YandexRaspRepositories: Sendable {
    let stationCatalog: StationCatalogRepositoryProtocol
    let schedule: ScheduleRepositoryProtocol
    let carrierDetails: CarrierDetailsRepositoryProtocol
}

enum YandexRaspRepositoryFactory {
    static func makeRepositories() throws -> YandexRaspRepositories {
        let client = try YandexRaspClientFactory.makeClient()

        return YandexRaspRepositories(
            stationCatalog: StationCatalogRepository(
                allStationsService: client
            ),
            schedule: ScheduleRepository(
                scheduleService: client
            ),
            carrierDetails: CarrierDetailsRepository(
                service: client
            )
        )
    }
}
