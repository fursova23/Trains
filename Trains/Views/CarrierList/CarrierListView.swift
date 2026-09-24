import SwiftUI

struct CarrierListView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: CarrierListViewModel

    init(viewModel: @autoclosure @escaping () -> CarrierListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        carrierListContent
            .background {
                Color("ScheduleBackground")
                    .ignoresSafeArea()
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
            .task(id: viewModel.loadID) { await viewModel.load() }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if viewModel.state == .loaded {
                    NavigationLink {
                        FiltersView(filter: $viewModel.filter)
                    } label: {
                        Text("Уточнить время")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("BrandBlue"))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .background(Color("ScheduleBackground"))
                }
            }
    }

    private var carrierListContent: some View {
        VStack(spacing: 0) {
            HStack {
                AppBackButton { dismiss() }
                Spacer()
            }
            .padding(.horizontal, 4)

            Text(viewModel.routeTitle)
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)

            CarrierListContentView(
                state: viewModel.state,
                trips: viewModel.filteredTrips
            )

            if case .failed = viewModel.state {
                Button("Повторить", action: viewModel.retry)
                    .padding(.bottom, 24)
            }
        }
    }
}
