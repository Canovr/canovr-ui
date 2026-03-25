import SwiftUI

struct VolumeStepView: View {
    @Binding var weeklyKm: Double
    @Binding var experience: OnboardingData.ExperienceLevel
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("Dein Training")
                .font(CanovRTheme.titleFont)
                .foregroundStyle(CanovRTheme.textPrimary)

            // Weekly kilometers
            VStack(spacing: CanovRTheme.spacingLG) {
                Text("Wochenkilometer")
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)

                Text("\(Int(weeklyKm)) km")
                    .font(CanovRTheme.lato(36, weight: .bold))
                    .foregroundStyle(CanovRTheme.textPrimary)

                Slider(value: $weeklyKm, in: 10...150, step: 5)
                    .tint(CanovRTheme.primary)
                    .padding(.horizontal, CanovRTheme.spacingXL)

                HStack {
                    Text("10 km")
                    Spacer()
                    Text("150 km")
                }
                .font(CanovRTheme.captionFont)
                .foregroundStyle(CanovRTheme.textTertiary)
                .padding(.horizontal, CanovRTheme.spacingXL)
            }

            // Experience
            VStack(spacing: CanovRTheme.spacingLG) {
                Text("Erfahrung")
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)

                Picker("Erfahrung", selection: $experience) {
                    ForEach(OnboardingData.ExperienceLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, CanovRTheme.spacingXL)
            }

            Spacer()

            Button(action: onNext) {
                Text("Weiter")
                    .primaryButtonStyle()
            }
            .padding(.horizontal, CanovRTheme.spacingXL)
            .padding(.bottom, 48)
        }
    }
}
