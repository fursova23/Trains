import SwiftUI

struct ContentView: View {
    @State private var isSplashVisible = true

    var body: some View {
        ZStack {
            RootTabView()

            if isSplashVisible {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
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
}
