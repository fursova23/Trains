import SwiftUI

@main
struct TrainsApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: container.rootViewModel, settings: container.settingsViewModel)
                .environmentObject(container)
        }
    }
}
