import SwiftUI

@main
struct CanovRApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isOnboarded {
                    MainTabView()
                } else if appState.athleteId != nil && appState.athlete == nil {
                    // athleteId in UserDefaults, aber Athlet noch nicht geladen
                    // → Server-Check läuft, Ladescreen zeigen
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(CanovRTheme.primary)
                        Text("Verbinde mit Server...")
                            .font(CanovRTheme.bodyFont)
                            .foregroundStyle(CanovRTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(CanovRTheme.background)
                    .task {
                        await appState.loadAthlete()
                        if appState.athlete != nil {
                            await appState.loadWeek()
                        }
                        // Wenn loadAthlete 404 gibt → reset() → isOnboarded false → Onboarding
                    }
                } else {
                    OnboardingFlow()
                }
            }
            .environment(appState)
        }
    }
}
