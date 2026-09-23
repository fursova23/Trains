import Combine
import Foundation

@MainActor
final class CarrierListViewModel: ObservableObject {
    @Published private(set) var trips: [CarrierTrip] = []
    @Published private(set) var state: NetworkLoadState = .idle
    @Published private(set) var loadID = UUID()
    @Published var filter = CarrierFilter()

    let origin: RoutePoint
    let destination: RoutePoint
    private let repository: ScheduleRepositoryProtocol

    var routeTitle: String { "\(origin.title) → \(destination.title)" }

    var filteredTrips: [CarrierTrip] {
        trips.filter { trip in
            let matchesPeriod = filter.periods.isEmpty
                || filter.periods.contains { $0.contains(hour: trip.departureHour) }
            let matchesTransfer = filter.transferOption != .withoutTransfers || !trip.hasTransfer
            return matchesPeriod && matchesTransfer
        }
    }

    init(origin: RoutePoint, destination: RoutePoint, repository: ScheduleRepositoryProtocol) {
        self.origin = origin
        self.destination = destination
        self.repository = repository
    }

    func retry() { loadID = UUID() }

    func load() async {
        guard state != .loading, state != .loaded else { return }
        state = .loading
        do {
            let trips = try await repository.fetchTrips(
                from: origin.stationCode, to: destination.stationCode, date: .now
            )
            try Task.checkCancellation()
            self.trips = trips
            state = .loaded
        } catch {
            state = Task.isCancelled || error is CancellationError ? .idle : .failed(AppErrorKind.from(error))
        }
    }
}
