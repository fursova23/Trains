struct TravelStation: Identifiable, Hashable {
    let code: String
    let name: String

    var id: String { code }
}
