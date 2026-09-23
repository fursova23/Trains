import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var container: AppContainer
    @ObservedObject private var viewModel: AppRootViewModel

    init(viewModel: AppRootViewModel) { self.viewModel = viewModel }

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ScheduleFlowView(viewModel: container.mainViewModel)
                .tabItem {
                    Image(systemName: "arrow.up.message.fill")
                        .accessibilityLabel("Расписание")
                }
                .accessibilityLabel("Расписание")
                .tag(AppTab.schedule)

            NavigationStack {
                SettingsView(viewModel: container.settingsViewModel)
            }
            .toolbar(.hidden, for: .navigationBar)
            .tabItem {
                Image(systemName: "gearshape.fill")
                    .accessibilityLabel("Настройки")
            }
            .accessibilityLabel("Настройки")
            .tag(AppTab.settings)
        }
    }
}

#Preview("Главная - светлая") {
    RootTabView(viewModel: AppRootViewModel())
        .preferredColorScheme(.light)
        .environmentObject(AppContainer())
}

#Preview("Главная - тёмная") {
    RootTabView(viewModel: AppRootViewModel())
        .preferredColorScheme(.dark)
        .environmentObject(AppContainer())
}
