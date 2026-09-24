import SwiftUI

struct SettingsView: View {
    @ObservedObject private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            Toggle("Темная тема", isOn: $viewModel.isDarkThemeEnabled)
                .tint(Color("BrandBlue"))
                .frame(minHeight: 60)
                .accessibilityIdentifier("darkThemeToggle")

            Button(action: viewModel.showAgreement) {
                HStack {
                    Text("Пользовательское соглашение")
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 24, weight: .medium))
                }
                .frame(minHeight: 60)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("openAgreement")

            Spacer()

            VStack(spacing: 16) {
                Text("Приложение использует API «Яндекс.Расписания»")
                Text("Версия 1.0 (beta)")
            }
            .font(.system(size: 12))
            .multilineTextAlignment(.center)
            .padding(.bottom, 24)
        }
        .font(.system(size: 17))
        .foregroundStyle(.primary)
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
        .fullScreenCover(isPresented: $viewModel.showsAgreement) {
            UserAgreementView()
                .preferredColorScheme(viewModel.isDarkThemeEnabled ? .dark : .light)
        }
    }
}

#Preview("Настройки — светлая тема") {
    let defaults = UserDefaults(suiteName: "SettingsPreview.\(UUID().uuidString)")!
    let viewModel = SettingsViewModel(userDefaults: defaults)

    SettingsView(viewModel: viewModel)
        .preferredColorScheme(viewModel.isDarkThemeEnabled ? .dark : .light)
}

#Preview("Настройки — тёмная тема") {
    let defaults = UserDefaults(suiteName: "SettingsPreview.\(UUID().uuidString)")!
    let viewModel = SettingsViewModel(userDefaults: defaults)
    viewModel.isDarkThemeEnabled = true

    return SettingsView(viewModel: viewModel)
        .preferredColorScheme(viewModel.isDarkThemeEnabled ? .dark : .light)
}
