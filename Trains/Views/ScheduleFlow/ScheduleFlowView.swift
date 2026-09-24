import SwiftUI

struct ScheduleFlowView: View {
    @EnvironmentObject private var container: AppContainer

    @ObservedObject private var viewModel: MainViewModel

    init(viewModel: MainViewModel) { self.viewModel = viewModel }

    var body: some View {
        NavigationStack {
            MainView(
                viewModel: viewModel
            )
            .navigationDestination(isPresented: $viewModel.showsCarriers) {
                if let origin = viewModel.origin, let destination = viewModel.destination {
                    CarrierListView(
                        viewModel: container.makeCarrierListViewModel(origin: origin, destination: destination)
                    )
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $viewModel.selectionTarget) { target in
            CitySelectionFlow(viewModel: container.makeCitySelectionViewModel()) { point in
                viewModel.select(point, for: target)
            }
        }
    }
}
