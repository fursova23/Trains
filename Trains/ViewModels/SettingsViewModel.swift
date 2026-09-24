import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isDarkThemeEnabled: Bool {
        didSet {
            guard isDarkThemeEnabled != oldValue else { return }
            userDefaults.set(isDarkThemeEnabled, forKey: AppSettings.darkThemeKey)
        }
    }
    @Published var showsAgreement = false

    private let userDefaults: UserDefaults
    private var preferencesSubscription: AnyCancellable?

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        isDarkThemeEnabled = userDefaults.bool(forKey: AppSettings.darkThemeKey)

        preferencesSubscription = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification, object: userDefaults)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadPreferences()
            }
    }

    func showAgreement() {
        showsAgreement = true
    }

    private func loadPreferences() {
        let savedValue = userDefaults.bool(forKey: AppSettings.darkThemeKey)
        guard isDarkThemeEnabled != savedValue else { return }
        isDarkThemeEnabled = savedValue
    }
}
