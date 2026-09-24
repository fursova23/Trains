import SwiftUI

struct CitySelectionFlow: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: CitySelectionViewModel
    let onComplete: (RoutePoint) -> Void

    @State private var path: [City] = []

    init(viewModel: @autoclosure @escaping () -> CitySelectionViewModel,
         onComplete: @escaping (RoutePoint) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack(path: $path) {
            cityContent
                .navigationDestination(for: City.self) { city in
                    StationSelectionView(city: city, onBack: { path.removeLast() }, onSelect: onComplete)
                }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .task(id: viewModel.loadID) {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var cityContent: some View {
        switch viewModel.state {
        case .idle, .loading:
            SelectionLoadingView(title: "Выбор города") {
                dismiss()
            }
        case .loaded:
            SearchableSelectionView(
                configuration: SearchableSelectionConfiguration(
                    title: "Выбор города",
                    items: viewModel.filteredCities,
                    itemTitle: \.name,
                    emptyMessage: "Город не найден"
                ),
                onBack: { dismiss() },
                onSelect: { path.append($0) },
                query: $viewModel.query
            )
        case .failed(let errorKind):
            VStack(spacing: 16) {
                SelectionErrorView(title: "Выбор города", errorKind: errorKind) { dismiss() }
                Button("Повторить", action: viewModel.retry)
                    .padding(.bottom, 24)
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
