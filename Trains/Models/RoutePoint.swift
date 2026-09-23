struct RoutePoint: Equatable, Hashable, Sendable {
    let city: String
    let station: String
    let stationCode: String

    var title: String {
        "\(city) (\(station))"
    }
}
