import Combine

@MainActor
final class FiltersViewModel: ObservableObject {
    @Published private(set) var draft: CarrierFilter

    var canApply: Bool { draft.hasSelection }

    init(filter: CarrierFilter) { draft = filter }

    func toggle(_ period: DeparturePeriod) {
        if draft.periods.contains(period) {
            draft.periods.remove(period)
        } else {
            draft.periods.insert(period)
        }
    }

    func select(_ option: TransferOption) { draft.transferOption = option }
}
