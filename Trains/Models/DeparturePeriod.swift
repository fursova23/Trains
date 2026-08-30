enum DeparturePeriod: String, CaseIterable, Identifiable, Hashable {
    case morning
    case day
    case evening
    case night

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning:
            "Утро 06:00 - 12:00"
        case .day:
            "День 12:00 - 18:00"
        case .evening:
            "Вечер 18:00 - 00:00"
        case .night:
            "Ночь 00:00 - 06:00"
        }
    }

    func contains(hour: Int) -> Bool {
        switch self {
        case .morning:
            (6..<12).contains(hour)
        case .day:
            (12..<18).contains(hour)
        case .evening:
            (18..<24).contains(hour)
        case .night:
            (0..<6).contains(hour)
        }
    }
}
