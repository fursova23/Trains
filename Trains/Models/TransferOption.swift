enum TransferOption: String, CaseIterable, Identifiable {
    case yes
    case no

    var id: String { rawValue }

    var title: String {
        switch self {
        case .yes: "Да"
        case .no: "Нет"
        }
    }
}
