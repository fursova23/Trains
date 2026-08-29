import SwiftUI

struct CarrierListContentView: View {
    let state: NetworkLoadState
    let trips: [CarrierTrip]

    var body: some View {
        Group {
            switch state {
            case .idle, .loading:
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let errorKind):
                ErrorStateView(kind: errorKind)
            case .loaded:
                if trips.isEmpty {
                    Text("Вариантов нет")
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(trips) { trip in
                                NavigationLink {
                                    PlaceholderView(
                                        title: "Карточка перевозчика",
                                        showsBackButton: true
                                    )
                                    .toolbar(.hidden, for: .tabBar)
                                } label: {
                                    CarrierCardView(trip: trip)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
    }
}
