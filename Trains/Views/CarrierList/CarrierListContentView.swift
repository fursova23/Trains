import SwiftUI

struct CarrierListContentView: View {
    @EnvironmentObject private var container: AppContainer

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
                                if let carrierCode = trip.carrierCode {
                                    NavigationLink {
                                        CarrierDetailsView(
                                            trip: trip,
                                            viewModel: container.makeCarrierDetailsViewModel(
                                                carrierCode: carrierCode
                                            )
                                        )
                                        .toolbar(.hidden, for: .tabBar)
                                    } label: {
                                        CarrierCardView(trip: trip)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    CarrierCardView(trip: trip)
                                }
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

#Preview("Список перевозчиков") {
    NavigationStack {
        CarrierListContentView(
            state: .loaded,
            trips: CarrierListPreviewData.trips
        )
        .background(Color("ScheduleBackground"))
        .environmentObject(AppContainer())
    }
}

#Preview("Вариантов нет") {
    CarrierListContentView(state: .loaded, trips: [])
        .environmentObject(AppContainer())
}

#Preview("Загрузка") {
    CarrierListContentView(state: .loading, trips: [])
        .environmentObject(AppContainer())
}

#Preview("Ошибка сервера") {
    CarrierListContentView(state: .failed(.server), trips: [])
        .environmentObject(AppContainer())
}

private enum CarrierListPreviewData {
    static let trips = [
        makeTrip(
            id: "direct",
            carrierName: "ФГК",
            departureOffset: 0,
            duration: 9 * 3_600,
            hasTransfer: false
        ),
        makeTrip(
            id: "transfer",
            carrierName: "РЖД",
            departureOffset: 24 * 3_600,
            duration: 20 * 3_600,
            hasTransfer: true
        )
    ]

    private static func makeTrip(
        id: String,
        carrierName: String,
        departureOffset: TimeInterval,
        duration: Int,
        hasTransfer: Bool
    ) -> CarrierTrip {
        let departure = Date.now.addingTimeInterval(departureOffset)

        return CarrierTrip(
            id: id,
            carrierCode: nil,
            carrierName: carrierName,
            logoURL: nil,
            departure: departure,
            arrival: departure.addingTimeInterval(TimeInterval(duration)),
            duration: duration,
            hasTransfer: hasTransfer
        )
    }
}
