import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthState.self) private var authState
    @State private var onboarding = OnboardingData()
    @State private var step = 0

    /// Steps: 0=Distance, 1=Time, 2=Volume, 3=Preferences, 4=Summary
    private let totalSteps = 4

    var body: some View {
        ZStack {
            CanovRTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(CanovRTheme.border)
                            .frame(height: 3)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(CanovRTheme.primary)
                            .frame(width: geo.size.width * (Double(step) / Double(totalSteps)), height: 3)
                            .animation(.easeInOut(duration: 0.3), value: step)
                    }
                }
                .frame(height: 3)
                .padding(.horizontal, CanovRTheme.spacingXL)
                .padding(.top, CanovRTheme.spacingSM)

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
            if let profile = authState.stravaProfile {
                onboarding.name = "\(profile.firstName) \(profile.lastName)".trimmingCharacters(in: .whitespaces)
            } else if let name = authState.registeredName {
                onboarding.name = name
            }
        }
    }

    private func nextStep() {
        withAnimation { step += 1 }
    }
}
