import OpenAPIRuntime

typealias StationSchedule = Components.Schemas.ScheduleResponse

/// Сервис для работы с API  "Расписание рейсов по станции"
protocol StationScheduleServiceProtocol {
    func getSchedule(station: String, date: String) async throws -> StationSchedule
}

final class StationScheduleService: BaseAPIService, StationScheduleServiceProtocol {
    func getSchedule(station: String, date: String) async throws -> StationSchedule {
        let response = try await client.getStationSchedule(query: .init(
            apikey: apiKey,
            station: station,
            date: date
        ))
        return try response.ok.body.json
    }
}
