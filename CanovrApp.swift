import SwiftUI
import CoreText

@main
struct CanovRApp: App {
    @State private var authState = AuthState()
    @State private var appState: AppState

    init() {
        FontRegistrar.registerAppFonts()
        let auth = AuthState()
        let api = APIClient(authState: auth)
        self._authState = State(initialValue: auth)
        self._appState = State(initialValue: AppState(api: api))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !authState.isAuthenticated {
                    // State 1: Nicht eingeloggt → Login
                    LoginView()
                } else if authState.needsOnboarding {
                    // State 2: Eingeloggt, aber kein Athlete → Onboarding
                    OnboardingFlow()
                } else if appState.isOnboarded {
                    // State 3: Eingeloggt + Athlete geladen → Dashboard
                    MainTabView()
                } else if appState.athleteId != nil && appState.athlete == nil {
                    // Athlete laden
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
                    }
                } else {
                    // Authentifiziert, User-Info laden → prüfen ob Athlete existiert
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(CanovRTheme.primary)
                        Text("Lade Profil...")
                            .font(CanovRTheme.bodyFont)
                            .foregroundStyle(CanovRTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(CanovRTheme.background)
                    .task {
                        await checkUserState()
                    }
                }
            }
            .environment(appState)
            .environment(authState)
        }
    }

    private func checkUserState() async {
        do {
            let userInfo = try await appState.api.getMe()
            await MainActor.run {
                if let athleteId = userInfo.athleteId, userInfo.hasAthlete {
                    appState.athleteId = athleteId
                    authState.needsOnboarding = false
                } else {
                    appState.reset()
                    authState.needsOnboarding = true
                }
            }
        } catch {
            // Token ungültig → Logout
            await MainActor.run {
                authState.clearTokens()
            }
        }
    }
}

private enum FontRegistrar {
    // Registriert die Font-Dateien beim Start explizit im Prozess.
    private static let appFontFiles = [
        "FugazOne-Regular.ttf",
        "Lato-Bold.ttf",
        "Lato-Light.ttf",
        "Lato-Regular.ttf",
    ]

    static func registerAppFonts() {
        for fileName in appFontFiles {
            registerFont(named: fileName)
        }
    }

    private static func registerFont(named fileName: String) {
        guard let fontURL = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            #if DEBUG
            print("Font-Datei nicht im Bundle gefunden: \(fileName)")
            #endif
            return
        }

        var registrationError: Unmanaged<CFError>?
        let didRegister = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &registrationError)
        guard !didRegister else { return }

        if let registrationError {
            let nsError = registrationError.takeRetainedValue() as Error as NSError
            if nsError.domain == kCTFontManagerErrorDomain as String,
               nsError.code == CTFontManagerError.alreadyRegistered.rawValue {
                return
            }

            #if DEBUG
            print("Font-Registrierung fehlgeschlagen (\(fileName)): \(nsError.localizedDescription)")
            #endif
        }
    }
}
