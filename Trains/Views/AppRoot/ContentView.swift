import SwiftUI

struct ContentView: View {
    @AppStorage(AppSettings.darkThemeKey) private var isDarkThemeEnabled = false
    @State private var isSplashVisible = true

    var body: some View {
        ZStack {
            RootTabView()
                .allowsHitTesting(!isSplashVisible)
                .accessibilityHidden(isSplashVisible)

            if isSplashVisible {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .preferredColorScheme(isDarkThemeEnabled ? .dark : .light)
        .task {
            guard isSplashVisible else { return }

            try? await Task.sleep(nanoseconds: 1_000_000_000)

            withAnimation(.easeOut(duration: 0.25)) {
                isSplashVisible = false
            }
        }
    }
}

#Preview("Приложение") {
    ContentView()
        .environmentObject(AppContainer())
}
