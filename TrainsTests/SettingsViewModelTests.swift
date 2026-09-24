import Foundation
import Combine
import XCTest
@testable import Trains

@MainActor
final class SettingsViewModelTests: XCTestCase {
    func testUsesLightThemeWhenNoPreferenceIsSaved() throws {
        let suiteName = "SettingsTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let viewModel = SettingsViewModel(userDefaults: defaults)

        XCTAssertFalse(viewModel.isDarkThemeEnabled)
    }

    func testThemeSurvivesRecreatingViewModelInBothDirections() throws {
        let suiteName = "SettingsTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let viewModel = SettingsViewModel(userDefaults: defaults)
        viewModel.isDarkThemeEnabled = true

        let restoredViewModel = SettingsViewModel(userDefaults: defaults)
        XCTAssertTrue(restoredViewModel.isDarkThemeEnabled)

        restoredViewModel.isDarkThemeEnabled = false
        XCTAssertFalse(SettingsViewModel(userDefaults: defaults).isDarkThemeEnabled)
    }

    func testThemeChangePublishesChanges() async throws {
        let suiteName = "SettingsTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let viewModel = SettingsViewModel(userDefaults: defaults)
        let change = expectation(description: "Theme observers receive the change")

        let subscription = viewModel.$isDarkThemeEnabled.dropFirst().prefix(1).sink { _ in
            change.fulfill()
        }
        defer { subscription.cancel() }

        viewModel.isDarkThemeEnabled = true

        await fulfillment(of: [change], timeout: 1)
        XCTAssertTrue(defaults.bool(forKey: AppSettings.darkThemeKey))
    }

    func testReloadsThemeAfterUserDefaultsNotification() async throws {
        let suiteName = "SettingsTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let viewModel = SettingsViewModel(userDefaults: defaults)
        let change = expectation(description: "Combine delivers the saved theme to the view model")

        let subscription = viewModel.$isDarkThemeEnabled.dropFirst().prefix(1).sink { _ in
            change.fulfill()
        }
        defer { subscription.cancel() }

        defaults.set(true, forKey: AppSettings.darkThemeKey)
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: defaults)

        await fulfillment(of: [change], timeout: 1)
        XCTAssertTrue(viewModel.isDarkThemeEnabled)
    }
}
