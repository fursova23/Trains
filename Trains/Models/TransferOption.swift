enum TransferOption: String, CaseIterable, Identifiable, Sendable {
    case withTransfers
    case withoutTransfers

    var id: String { rawValue }

    var title: String {
        switch self {
        case .withTransfers: "Да"
        case .withoutTransfers: "Нет"
        }
    }
}
