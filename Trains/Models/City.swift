struct City: Identifiable, Hashable, Sendable {
    let code: String
    let name: String
    let stations: [TravelStation]

    var id: String { code }
}
