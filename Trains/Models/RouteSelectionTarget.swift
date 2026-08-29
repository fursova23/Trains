enum RouteSelectionTarget: String, Identifiable {
    case origin
    case destination

    var id: String { rawValue }
}
