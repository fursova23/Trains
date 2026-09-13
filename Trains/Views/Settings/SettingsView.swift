import SwiftUI

struct SettingsView: View {
    @AppStorage(AppSettings.darkThemeKey) private var isDarkThemeEnabled = false
    @State private var showsAgreement = false

    var body: some View {
        VStack(spacing: 0) {
            Toggle("Темная тема", isOn: $isDarkThemeEnabled)
                .tint(Color("BrandBlue"))
                .frame(minHeight: 60)
                .accessibilityIdentifier("darkThemeToggle")

            Button { showsAgreement = true } label: {
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
        .fullScreenCover(isPresented: $showsAgreement) {
            UserAgreementView()
                .preferredColorScheme(isDarkThemeEnabled ? .dark : .light)
        }
    }
}

#Preview { SettingsView() }
