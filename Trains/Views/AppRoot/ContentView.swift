import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel: AppRootViewModel
    @ObservedObject private var settings: SettingsViewModel

    init(viewModel: AppRootViewModel, settings: SettingsViewModel) {
        self.viewModel = viewModel
        self.settings = settings
    }

    var body: some View {
        ZStack {
            RootTabView(viewModel: viewModel)
                .allowsHitTesting(!viewModel.isSplashVisible)
                .accessibilityHidden(viewModel.isSplashVisible)

            if viewModel.isSplashVisible {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .preferredColorScheme(settings.isDarkThemeEnabled ? .dark : .light)
        .animation(.easeOut(duration: 0.25), value: viewModel.isSplashVisible)
        .task { await viewModel.finishLaunch() }
    }
}

#Preview("Приложение") {
    let container = AppContainer()
    ContentView(viewModel: container.rootViewModel, settings: container.settingsViewModel)
        .environmentObject(container)
}
