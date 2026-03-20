import SwiftUI

enum Tab: Int, CaseIterable {
    case training, history, profile

    var icon: String {
        switch self {
        case .training: return "flame"
        case .history:  return "chart.bar"
        case .profile:  return "person"
        }
    }

    var label: String {
        switch self {
        case .training: return "Training"
        case .history:  return "Verlauf"
        case .profile:  return "Profil"
        }
    }
}

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Tab = .training

    var body: some View {
        VStack(spacing: 0) {
            // Top Nav
            HStack {
                Spacer()
                Text("CANOVR")
                    .font(CanovRTheme.logoFont)
                    .foregroundStyle(CanovRTheme.primary)
                Spacer()
            }
            .padding(.vertical, 10)
            .background(CanovRTheme.surface)

            // Content
            Group {
                switch selectedTab {
                case .training: DashboardView()
                case .history:  HistoryView()
                case .profile:  ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom Tab Bar
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18, weight: .medium))
                            Text(tab.label)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(selectedTab == tab ? CanovRTheme.tabIconActive : CanovRTheme.tabIconInactive)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 2)
            .background(CanovRTheme.tabBarBackground)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .task {
            if appState.athlete == nil {
                await appState.loadAthlete()
            }
            if appState.currentWeek == nil {
                await appState.loadWeek()
            }
        }
    }
}
