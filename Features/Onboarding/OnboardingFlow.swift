import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthState.self) private var authState
    @State private var onboarding = OnboardingData()
    @State private var step = 0

    /// Schritte: 0=Distanz, 1=Zeit, 2=Volumen, 3=Präferenzen, 4=Zusammenfassung
    private let totalSteps = 4

    var body: some View {
        ZStack {
            CanovRTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress Bar
                ProgressView(value: Double(step), total: Double(totalSteps))
                    .tint(CanovRTheme.azure)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                // Step Content
                TabView(selection: $step) {
                    DistanceStepView(selected: $onboarding.targetDistance, onNext: {
                        onboarding.raceTimeMinutes = onboarding.defaultMinutes
                        onboarding.raceTimeSeconds = 0
                        nextStep()
                    })
                        .tag(0)

                    RaceTimeStepView(
                        distance: onboarding.targetDistance,
                        minutes: $onboarding.raceTimeMinutes,
                        seconds: $onboarding.raceTimeSeconds,
                        onNext: nextStep
                    )
                        .tag(1)

                    VolumeStepView(
                        weeklyKm: $onboarding.weeklyKm,
                        experience: $onboarding.experienceLevel,
                        onNext: nextStep
                    )
                        .tag(2)

                    PreferencesStepView(
                        restDay: $onboarding.restDay,
                        longRunDay: $onboarding.longRunDay,
                        hasRace: $onboarding.hasUpcomingRace,
                        raceDate: $onboarding.raceDate,
                        onNext: nextStep
                    )
                        .tag(3)

                    OnboardingSummaryView(data: onboarding)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: step)
            }
        }
        .onAppear {
            // Name aus Auth-Daten übernehmen
            if let profile = authState.stravaProfile {
                onboarding.name = "\(profile.firstName) \(profile.lastName)".trimmingCharacters(in: .whitespaces)
            }
        }
    }

    private func nextStep() {
        withAnimation { step += 1 }
    }
}
