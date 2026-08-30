import SwiftUI

struct CarrierListView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: TravelScheduleViewModel
    let origin: RoutePoint
    let destination: RoutePoint

    @State private var filter = CarrierFilter()

    private var filteredTrips: [CarrierTrip] {
        viewModel.trips.filter { trip in
            let matchesPeriod = filter.periods.isEmpty
                || filter.periods.contains(where: { $0.contains(hour: trip.departureHour) })

            let matchesTransfer: Bool
            switch filter.transferOption {
            case .withTransfers:
                matchesTransfer = trip.hasTransfer
            case .withoutTransfers:
                matchesTransfer = !trip.hasTransfer
            case nil:
                matchesTransfer = true
            }

            return matchesPeriod && matchesTransfer
        }
    }

    var body: some View {
        Group {
            if case .failed(let errorKind) = viewModel.scheduleState {
                ErrorStateView(kind: errorKind)
            } else {
                carrierListContent
            }
        }
        .background {
            Color("ScheduleBackground")
                .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .task(id: "\(origin.stationCode)-\(destination.stationCode)") {
            await viewModel.loadSchedule(from: origin, to: destination)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if viewModel.scheduleState == .loaded {
                NavigationLink {
                    FiltersView(filter: $filter)
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

            Text("\(origin.title) → \(destination.title)")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)

            CarrierListContentView(
                state: viewModel.scheduleState,
                trips: filteredTrips
            )
        }
    }
}
