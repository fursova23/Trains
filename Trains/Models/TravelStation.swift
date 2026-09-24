struct TravelStation: Identifiable, Hashable, Sendable {
    let code: String
    let name: String

    var id: String { code }
}
