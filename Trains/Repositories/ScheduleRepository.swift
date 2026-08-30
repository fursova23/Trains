import Foundation

protocol ScheduleRepositoryProtocol {
    func fetchTrips(from: String, to: String, date: Date) async throws -> [CarrierTrip]
}

final class ScheduleRepository: ScheduleRepositoryProtocol {
    private let scheduleService: ScheduleBetweenStationsServiceProtocol
    private let carrierTripMapper: CarrierTripMapping

    init(
        scheduleService: ScheduleBetweenStationsServiceProtocol,
        carrierTripMapper: CarrierTripMapping = CarrierTripMapper()
    ) {
        self.scheduleService = scheduleService
        self.carrierTripMapper = carrierTripMapper
    }

    func fetchTrips(from: String, to: String, date: Date) async throws -> [CarrierTrip] {
        let response = try await scheduleService.getSchedule(
            from: from,
            to: to,
            date: requestDateString(from: date)
        )

        return carrierTripMapper.map(response)
    }

    private func requestDateString(from date: Date) -> String {
        date.formatted(.iso8601.year().month().day())
    }
}
