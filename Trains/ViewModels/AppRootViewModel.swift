import Combine

@MainActor
final class AppRootViewModel: ObservableObject {
    @Published private(set) var isSplashVisible = true
    @Published var selectedTab: AppTab = .schedule

    func finishLaunch() async {
        guard isSplashVisible else { return }
        do {
            try await Task.sleep(for: .seconds(1))
            try Task.checkCancellation()
            isSplashVisible = false
        } catch {
            // Не меняем состояние после отмены task экрана
        }
    }
}
