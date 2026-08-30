import SwiftUI

struct SplashView: View {
    var body: some View {
        Image("splash_screen")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

#Preview("Заставка") {
    SplashView()
}
