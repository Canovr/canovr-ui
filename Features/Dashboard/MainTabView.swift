import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Training", systemImage: "house.fill")
                }

            HistoryView()
                .tabItem {
                    Label("Verlauf", systemImage: "clock.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
        }
        .tint(CanovRTheme.azure)
        .task {
            await appState.loadAthlete()
            await appState.loadWeek()
        }
    }
}
