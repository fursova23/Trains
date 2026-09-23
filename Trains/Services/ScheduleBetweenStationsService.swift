import OpenAPIRuntime

typealias ScheduleBetweenStations = Components.Schemas.Segments

/// Сервис для работы с API "Расписание рейсов между станциями"
protocol ScheduleBetweenStationsServiceProtocol: Sendable {
    func getSchedule(from: String, to: String, date: String) async throws -> ScheduleBetweenStations
}

actor ScheduleBetweenStationsService: ScheduleBetweenStationsServiceProtocol {
    private let client: Client
    private let apiKey: String

    init(client: Client, apiKey: String) {
        self.client = client
        self.apiKey = apiKey
    }

    func getSchedule(from: String, to: String, date: String) async throws -> ScheduleBetweenStations {
        let response = try await client.getSchedualBetweenStations(query: .init(
            apikey: apiKey,
            from: from,
            to: to,
            date: date,
            transfers: true
        ))
        return try response.ok.body.json
    }
}
