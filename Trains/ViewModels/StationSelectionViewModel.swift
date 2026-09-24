import Combine
import Foundation

@MainActor
final class StationSelectionViewModel: ObservableObject {
    @Published var query = ""
    let city: City

    var filteredStations: [TravelStation] {
        let search = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return search.isEmpty ? city.stations : city.stations.filter {
            $0.name.localizedCaseInsensitiveContains(search)
        }
    }

    init(city: City) { self.city = city }

    func routePoint(for station: TravelStation) -> RoutePoint {
        RoutePoint(city: city.name, station: station.name, stationCode: station.code)
    }
}
