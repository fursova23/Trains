import OpenAPIRuntime

typealias ScheduleBetweenStations = Components.Schemas.Segments

/// Сервис для работы с API "Расписание рейсов между станциями"
protocol ScheduleBetweenStationsServiceProtocol {
    func getSchedule(from: String, to: String, date: String) async throws -> ScheduleBetweenStations
}

final class ScheduleBetweenStationsService: BaseAPIService, ScheduleBetweenStationsServiceProtocol {
    func getSchedule(from: String, to: String, date: String) async throws -> ScheduleBetweenStations {
        let response = try await client.getSchedualBetweenStations(query: .init(
            apikey: apiKey,
            from: from,
            to: to,
            date: date
        ))
        return try response.ok.body.json
    }
}
