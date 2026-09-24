protocol StationCatalogRepositoryProtocol: Sendable {
    func fetchCities() async throws -> [City]
}

actor StationCatalogRepository: StationCatalogRepositoryProtocol {
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
        try Task.checkCancellation()
        if let cachedCities { return cachedCities }
        let cities = allStationsMapper.map(response)
        try Task.checkCancellation()
        cachedCities = cities
        return cities
    }
}
