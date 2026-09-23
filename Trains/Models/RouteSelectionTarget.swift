enum RouteSelectionTarget: String, Identifiable, Sendable {
    case origin
    case destination

    var id: String { rawValue }
}
