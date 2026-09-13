import SwiftUI

struct ScheduleFlowView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var origin: RoutePoint?
    @State private var destination: RoutePoint?
    @State private var selectionTarget: RouteSelectionTarget?

    private var viewModel: TravelScheduleViewModel {
        container.travelScheduleViewModel
    }

    var body: some View {
        NavigationStack {
            MainView(
                viewModel: viewModel,
                origin: $origin,
                destination: $destination,
                onSelectOrigin: { selectionTarget = .origin },
                onSelectDestination: { selectionTarget = .destination }
            )
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $selectionTarget) { target in
            CitySelectionFlow(viewModel: viewModel) { point in
                setRoutePoint(point, for: target)
                selectionTarget = nil
            }
        }
    }

    private func setRoutePoint(_ point: RoutePoint, for target: RouteSelectionTarget) {
        switch target {
        case .origin:
            origin = point
        case .destination:
            destination = point
        }
    }
}
