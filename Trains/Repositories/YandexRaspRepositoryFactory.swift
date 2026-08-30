struct YandexRaspRepositories {
    let stationCatalog: StationCatalogRepositoryProtocol
    let schedule: ScheduleRepositoryProtocol
}

enum YandexRaspRepositoryFactory {
    static func makeRepositories() throws -> YandexRaspRepositories {
        let client = try YandexRaspClientFactory.makeClient()
        let apiKey = try YandexRaspClientFactory.apiKey()

        return YandexRaspRepositories(
            stationCatalog: StationCatalogRepository(
                allStationsService: AllStationsService(client: client, apiKey: apiKey)
            ),
            schedule: ScheduleRepository(
                scheduleService: ScheduleBetweenStationsService(client: client, apiKey: apiKey)
            )
        )
    }
}
