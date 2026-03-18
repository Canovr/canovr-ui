import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppState.self) private var appState
    @State private var onboarding = OnboardingData()
    @State private var step = 0

    private let totalSteps = 6

    var body: some View {
        ZStack {
            CanovRTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress Bar
                if step > 0 {
                    ProgressView(value: Double(step), total: Double(totalSteps))
                        .tint(CanovRTheme.azure)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                }

                // Step Content
                TabView(selection: $step) {
                    WelcomeView(onNext: nextStep)
                        .tag(0)

                    NameStepView(name: $onboarding.name, onNext: nextStep)
                        .tag(1)

                    DistanceStepView(selected: $onboarding.targetDistance, onNext: {
                        onboarding.raceTimeMinutes = onboarding.defaultMinutes
                        onboarding.raceTimeSeconds = 0
                        nextStep()
                    })
                        .tag(2)

                    RaceTimeStepView(
                        distance: onboarding.targetDistance,
                        minutes: $onboarding.raceTimeMinutes,
                        seconds: $onboarding.raceTimeSeconds,
                        onNext: nextStep
                    )
                        .tag(3)

                    VolumeStepView(
                        weeklyKm: $onboarding.weeklyKm,
                        experience: $onboarding.experienceLevel,
                        onNext: nextStep
                    )
                        .tag(4)

                    PreferencesStepView(
                        restDay: $onboarding.restDay,
                        longRunDay: $onboarding.longRunDay,
                        hasRace: $onboarding.hasUpcomingRace,
                        raceDate: $onboarding.raceDate,
                        onNext: nextStep
                    )
                        .tag(5)

                    OnboardingSummaryView(data: onboarding)
                        .tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: step)
            }
        }
    }

    private func nextStep() {
        withAnimation { step += 1 }
    }
}
