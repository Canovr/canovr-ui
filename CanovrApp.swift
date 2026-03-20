import SwiftUI
import CoreText

@main
struct CanovRApp: App {
    @State private var appState = AppState()

    init() {
        FontRegistrar.registerAppFonts()
    }

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
                        // Wenn loadAthlete 404 gibt → reset() → isOnboarded false → Onboarding
                        // loadWeek wird in DashboardView geladen, nicht hier —
                        // sonst cancelled SwiftUI den Task beim View-Wechsel.
                    }
                } else {
                    OnboardingFlow()
                }
            }
            .environment(appState)
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
