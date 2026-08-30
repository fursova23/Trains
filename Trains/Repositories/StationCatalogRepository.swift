protocol StationCatalogRepositoryProtocol {
    func fetchCities() async throws -> [City]
}

final class StationCatalogRepository: StationCatalogRepositoryProtocol {
    private let allStationsService: AllStationsServiceProtocol
    private let allStationsMapper: AllStationsMapping
    private var cachedCities: [City]?

    init(
        allStationsService: AllStationsServiceProtocol,
        allStationsMapper: AllStationsMapping = AllStationsMapper()
    ) {
        self.allStationsService = allStationsService
        self.allStationsMapper = allStationsMapper
    }

    func fetchCities() async throws -> [City] {
        if let cachedCities {
            return cachedCities
        }

        let response = try await allStationsService.getAllStations()
        let cities = allStationsMapper.map(response)
        cachedCities = cities
        return cities
    }
}
