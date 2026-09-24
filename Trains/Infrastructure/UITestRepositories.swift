#if DEBUG
import Foundation

/// Данные для UI-тестов. При обычном запуске используются сетевые репозитории.
actor UITestRepositories: StationCatalogRepositoryProtocol, ScheduleRepositoryProtocol,
                          CarrierDetailsRepositoryProtocol {
    private var failsCatalog: Bool
    private var failsSchedule: Bool
    private let emptySchedule: Bool

    init(arguments: [String]) {
        failsCatalog = arguments.contains("-ui-fail-catalog-once")
        failsSchedule = arguments.contains("-ui-fail-schedule-once")
        emptySchedule = arguments.contains("-ui-empty-schedule")
    }

    func fetchCities() async throws -> [City] {
        try await Task.sleep(for: .milliseconds(100))
        if failsCatalog {
            failsCatalog = false
            throw URLError(.notConnectedToInternet)
        }
        return [
            City(code: "c213", name: "Москва", stations: [
                TravelStation(code: "s1", name: "Курский вокзал"),
                TravelStation(code: "s2", name: "Киевский вокзал")
            ]),
            City(code: "c15", name: "Тула", stations: [
                TravelStation(code: "s3", name: "Московский вокзал")
            ])
        ]
    }

    func fetchTrips(from: String, to: String, date: Date) async throws -> [CarrierTrip] {
        try await Task.sleep(for: .milliseconds(100))
        if failsSchedule {
            failsSchedule = false
            throw URLError(.badServerResponse)
        }
        guard !emptySchedule else { return [] }
        let morning = Calendar.current.startOfDay(for: date).addingTimeInterval(8 * 3_600)
        return [
            CarrierTrip(id: "direct", carrierCode: 112, carrierName: "Прямой перевозчик", logoURL: nil,
                        departure: morning, arrival: morning.addingTimeInterval(7_200), duration: 7_200,
                        hasTransfer: false),
            CarrierTrip(id: "transfer", carrierCode: 113, carrierName: "Перевозчик с пересадкой", logoURL: nil,
                        departure: morning.addingTimeInterval(6 * 3_600),
                        arrival: morning.addingTimeInterval(9 * 3_600), duration: 10_800, hasTransfer: true)
        ]
    }

    func fetchCarrier(code: Int) async throws -> CarrierDetails {
        CarrierDetails(name: "Тестовый перевозчик", logoURL: nil, email: "support@example.com",
                       phone: "+7 (800) 123-45-67", websiteURL: URL(string: "https://example.com"))
    }
}
#endif
