struct City: Identifiable, Hashable {
    let code: String
    let name: String
    let stations: [TravelStation]

    var id: String { code }
}
