import SwiftUI

struct StationSelectionView: View {
    @StateObject private var viewModel: StationSelectionViewModel
    let onBack: () -> Void
    let onSelect: (RoutePoint) -> Void

    init(city: City, onBack: @escaping () -> Void, onSelect: @escaping (RoutePoint) -> Void) {
        _viewModel = StateObject(wrappedValue: StationSelectionViewModel(city: city))
        self.onBack = onBack
        self.onSelect = onSelect
    }

    var body: some View {
        SearchableSelectionView(
            configuration: SearchableSelectionConfiguration(
                title: "Выбор станции", items: viewModel.filteredStations,
                itemTitle: \.name, emptyMessage: "Станция не найдена"
            ),
            onBack: onBack,
            onSelect: { onSelect(viewModel.routePoint(for: $0)) },
            query: $viewModel.query
        )
    }
}

#Preview {
    StationSelectionView(
        city: City(code: "c213", name: "Москва", stations: [TravelStation(code: "s1", name: "Курский")]),
        onBack: {}, onSelect: { _ in }
    )
}
