/// Общая точка входа в API
actor YandexRaspClient: AllStationsServiceProtocol, ScheduleBetweenStationsServiceProtocol,
                       StationScheduleServiceProtocol, RouteStationsServiceProtocol,
                       NearestStationsServiceProtocol, NearestSettlementServiceProtocol,
                       CarrierInfoServiceProtocol, CopyrightServiceProtocol {
    private let allStations: AllStationsService
    private let scheduleBetweenStations: ScheduleBetweenStationsService
    private let stationSchedule: StationScheduleService
    private let routeStations: RouteStationsService
    private let nearestStations: NearestStationsService
    private let nearestSettlement: NearestSettlementService
    private let carrierInfo: CarrierInfoService
    private let copyright: CopyrightService

    init(client: Client, apiKey: String) {
        allStations = AllStationsService(client: client, apiKey: apiKey)
        scheduleBetweenStations = ScheduleBetweenStationsService(client: client, apiKey: apiKey)
        stationSchedule = StationScheduleService(client: client, apiKey: apiKey)
        routeStations = RouteStationsService(client: client, apiKey: apiKey)
        nearestStations = NearestStationsService(client: client, apiKey: apiKey)
        nearestSettlement = NearestSettlementService(client: client, apiKey: apiKey)
        carrierInfo = CarrierInfoService(client: client, apiKey: apiKey)
        copyright = CopyrightService(client: client, apiKey: apiKey)
    }

    func getAllStations() async throws -> AllStations {
        try await allStations.getAllStations()
    }

    func getSchedule(from: String, to: String, date: String) async throws -> ScheduleBetweenStations {
        try await scheduleBetweenStations.getSchedule(from: from, to: to, date: date)
    }

    func getSchedule(station: String, date: String) async throws -> StationSchedule {
        try await stationSchedule.getSchedule(station: station, date: date)
    }

    func getRouteStations(uid: String, date: String) async throws -> RouteStations {
        try await routeStations.getRouteStations(uid: uid, date: date)
    }

    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations {
        try await nearestStations.getNearestStations(lat: lat, lng: lng, distance: distance)
    }

    func getNearestSettlement(lat: Double, lng: Double) async throws -> NearestSettlement {
        try await nearestSettlement.getNearestSettlement(lat: lat, lng: lng)
    }

    func getCarrier(code: String, system: String? = nil) async throws -> CarrierInfo {
        try await carrierInfo.getCarrier(code: code, system: system)
    }

    func getCopyright() async throws -> YandexCopyright {
        try await copyright.getCopyright()
    }
}
