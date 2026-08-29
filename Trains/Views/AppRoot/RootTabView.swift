import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: AppTab = .schedule

    var body: some View {
        TabView(selection: $selectedTab) {
            ScheduleFlowView()
                .tabItem {
                    Image(systemName: "arrow.up.message.fill")
                }
                .accessibilityLabel("Расписание")
                .tag(AppTab.schedule)

            NavigationStack {
                PlaceholderView(title: "Настройки")
            }
            .toolbar(.hidden, for: .navigationBar)
            .tabItem {
                Image(systemName: "gearshape.fill")
            }
            .accessibilityLabel("Настройки")
            .tag(AppTab.settings)
        }
    }
}

#Preview("Главная — светлая") {
    RootTabView()
        .preferredColorScheme(.light)
}

#Preview("Главная — тёмная") {
    RootTabView()
        .preferredColorScheme(.dark)
}
