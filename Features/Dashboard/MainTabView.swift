import SwiftUI

enum Tab: Int, CaseIterable {
    case training, history, profile

    var icon: String {
        switch self {
        case .training: return "flame"
        case .history:  return "chart.bar"
        case .profile:  return "gearshape"
        }
    }

    var label: String {
        switch self {
        case .training: return String(localized: "Training")
        case .history:  return String(localized: "Verlauf")
        case .profile:  return String(localized: "Profil")
        }
    }
}

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Tab = .training
    @State private var navigationPath = NavigationPath()

    var body: some View {
        VStack(spacing: 0) {
            // Top Nav
            HStack {
                // Back button (left)
                if !navigationPath.isEmpty {
                    Button {
                        navigationPath.removeLast()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(CanovRTheme.primary)
                    }
                    .padding(.leading, CanovRTheme.spacingXL)
                }

                Spacer()

                // Section label (right)
                Text(selectedTab.label)
                    .font(CanovRTheme.lato(13, weight: .regular))
                    .foregroundStyle(CanovRTheme.textTertiary)
                    .padding(.trailing, CanovRTheme.spacingXL)
            }
            .overlay {
                Text("CANOVR")
                    .font(CanovRTheme.logoFont)
                    .foregroundStyle(CanovRTheme.primary)
            }
            .padding(.vertical, 12)
            .background(CanovRTheme.background)

            // Thin divider
            CanovRTheme.divider.frame(height: 1)

            // Content
            Group {
                switch selectedTab {
                case .training: DashboardView()
                case .history:  HistoryView()
                case .profile:  ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Thin divider above tab bar
            CanovRTheme.divider.frame(height: 1)

            // Bottom Tab Bar
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18, weight: .medium))
                                .symbolVariant(selectedTab == tab ? .fill : .none)
                            Text(tab.label)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(selectedTab == tab ? CanovRTheme.tabIconActive : CanovRTheme.tabIconInactive)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 4)
            .background(CanovRTheme.tabBarBackground)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .task {
            if appState.athlete == nil {
                await appState.loadAthlete()
            }
        }
    }
}
