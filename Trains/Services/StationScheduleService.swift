import OpenAPIRuntime

typealias StationSchedule = Components.Schemas.ScheduleResponse

/// Сервис для работы с API  "Расписание рейсов по станции"
protocol StationScheduleServiceProtocol {
    func getSchedule(station: String, date: String) async throws -> StationSchedule
}

final class StationScheduleService: StationScheduleServiceProtocol {
    private let client: Client
    private let apiKey: String

    init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }

    func getSchedule(station: String, date: String) async throws -> StationSchedule {
        let response = try await client.getStationSchedule(query: .init(
            apikey: apiKey,
            station: station,
            date: date
        ))
        return try response.ok.body.json
    }
}
