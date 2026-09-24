import Combine

@MainActor
final class MainViewModel: ObservableObject {
    @Published private(set) var origin: RoutePoint?
    @Published private(set) var destination: RoutePoint?
    @Published var selectionTarget: RouteSelectionTarget?
    @Published var showsCarriers = false

    let stories = Story.mocks

    var isRouteComplete: Bool {
        origin != nil && destination != nil
    }

    init(origin: RoutePoint? = nil, destination: RoutePoint? = nil) {
        self.origin = origin
        self.destination = destination
    }

    func beginSelection(_ target: RouteSelectionTarget) {
        selectionTarget = target
    }

    func select(_ point: RoutePoint, for target: RouteSelectionTarget) {
        switch target {
        case .origin:
            origin = point
        case .destination:
            destination = point
        }
        selectionTarget = nil
    }

    func swapRoute() {
        let previousOrigin = origin
        origin = destination
        destination = previousOrigin
    }

    func search() {
        guard isRouteComplete else { return }
        showsCarriers = true
    }
}
