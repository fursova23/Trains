import SwiftUI

struct CitySelectionFlow: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: TravelScheduleViewModel
    let onComplete: (RoutePoint) -> Void

    @State private var path: [City] = []

    var body: some View {
        NavigationStack(path: $path) {
            cityContent
            .navigationDestination(for: City.self) { city in
                SearchableSelectionView(
                    title: "Выбор станции",
                    items: city.stations,
                    itemTitle: \.name,
                    emptyMessage: "Станция не найдена",
                    onBack: { path.removeLast() },
                    onSelect: { station in
                        onComplete(RoutePoint(
                            city: city.name,
                            station: station.name,
                            stationCode: station.code
                        ))
                    }
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .task {
            await viewModel.loadCitiesIfNeeded()
        }
    }

    @ViewBuilder
    private var cityContent: some View {
        switch viewModel.catalogState {
        case .idle, .loading:
            SelectionLoadingView(title: "Выбор города") {
                dismiss()
            }
        case .loaded:
            SearchableSelectionView(
                title: "Выбор города",
                items: viewModel.cities,
                itemTitle: \.name,
                emptyMessage: "Город не найден",
                onBack: { dismiss() },
                onSelect: { path.append($0) }
            )
        case .failed(let errorKind):
            SelectionErrorView(title: "Выбор города", errorKind: errorKind) {
                dismiss()
            }
        }
    }
}

private struct SelectionLoadingView: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SelectionHeader(title: title, onBack: onBack)

            Spacer()
            ProgressView()
                .controlSize(.large)
            Spacer()
        }
        .background(Color(uiColor: .systemBackground))
    }
}

private struct SelectionErrorView: View {
    let title: String
    let errorKind: AppErrorKind
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SelectionHeader(title: title, onBack: onBack)
            ErrorStateView(kind: errorKind)
        }
        .background(Color(uiColor: .systemBackground))
    }
}

private struct SelectionHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 17, weight: .bold))

            HStack {
                AppBackButton(action: onBack)
                Spacer()
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 4)
    }
}
