struct RoutePoint: Equatable, Hashable {
    let city: String
    let station: String
    let stationCode: String

    var title: String {
        "\(city) (\(station))"
    }
}
