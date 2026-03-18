import SwiftUI

@main
struct CanovRApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isOnboarded {
                    MainTabView()
                } else {
                    OnboardingFlow()
                }
            }
            .environment(appState)
        }
    }
}
