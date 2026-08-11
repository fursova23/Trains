import Combine
import Foundation

@MainActor
final class NetworkServicesDemo: ObservableObject {
    @Published private(set) var messages: [String] = []
    @Published private(set) var isRunning = false

    func runBasicChecks() async {
        guard !isRunning else { return }
        isRunning = true
        messages = []
        defer {
            isRunning = false
        }

        do {
            let apiKey = try YandexRaspClientFactory.apiKey()
            let client = try YandexRaspClientFactory.makeClient()
            let date = Self.requestDateString()

            let schedule = await check("Расписание рейсов между станциями") {
                try await ScheduleBetweenStationsService(client: client, apiKey: apiKey)
                    .getSchedule(from: "c213", to: "c2", date: date)
            }

            let stationSchedule = await check("Расписание рейсов по станции") {
                try await StationScheduleService(client: client, apiKey: apiKey)
                    .getSchedule(station: "s9600213", date: date)
            }

            let routeUID = schedule?.segments?.first?.thread?.uid
                ?? stationSchedule?.schedule?.first?.thread?.uid
            if let routeUID {
                await check("Список станций следования") {
                    try await RouteStationsService(client: client, apiKey: apiKey)
                        .getRouteStations(uid: routeUID, date: date)
                }
            } else {
                append("Список станций следования: API не вернул актуальный uid")
            }

            await check("Список ближайших станций") {
                try await NearestStationsService(client: client, apiKey: apiKey)
                    .getNearestStations(lat: 55.7558, lng: 37.6173, distance: 10)
            }

            await check("Ближайший город") {
                try await NearestSettlementService(client: client, apiKey: apiKey)
                    .getNearestSettlement(lat: 55.7558, lng: 37.6173)
            }

            await check("Информация о перевозчике") {
                try await CarrierInfoService(client: client, apiKey: apiKey)
                    .getCarrier(code: "SU", system: "iata")
            }

            await check("Копирайт") {
                try await CopyrightService(client: client, apiKey: apiKey)
                    .getCopyright()
            }

        } catch {
            append("❌ Ошибка конфигурации: \(error.localizedDescription)")
        }
    }

    func loadAllStations() async {
        guard !isRunning else { return }
        isRunning = true
        defer { isRunning = false }

        do {
            let apiKey = try YandexRaspClientFactory.apiKey()
            let client = try YandexRaspClientFactory.makeClient()

            await check("Полный список станций") {
                try await AllStationsService(client: client, apiKey: apiKey)
                    .getAllStations()
            }
        } catch {
            append("❌ Ошибка конфигурации: \(error.localizedDescription)")
        }
    }

    @discardableResult
    private func check<Value>(_ name: String, operation: () async throws -> Value) async -> Value? {
        do {
            let value = try await operation()
            append("✅ \(name)")
            return value
        } catch {
            append("❌ \(name): \(error.localizedDescription)")
            return nil
        }
    }

    private func append(_ message: String) {
        messages.append(message)
        print(message)
    }

    private static func requestDateString(from date: Date = Date()) -> String {
        date.formatted(.iso8601.year().month().day())
    }
}
