struct CarrierFilter: Equatable {
    var periods: Set<DeparturePeriod> = []
    var transferOption: TransferOption?

    var hasSelection: Bool {
        !periods.isEmpty || transferOption != nil
    }
}
