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

            // Wochenkilometer
            VStack(spacing: 16) {
                Text("Wochenkilometer")
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)

                Text("\(Int(weeklyKm)) km")
                    .font(.custom("Lato-Bold", size: 36))
                    .foregroundStyle(CanovRTheme.textPrimary)

                Slider(value: $weeklyKm, in: 10...150, step: 5)
                    .tint(CanovRTheme.azure)
                    .padding(.horizontal, 24)

                HStack {
                    Text("10 km")
                    Spacer()
                    Text("150 km")
                }
                .font(CanovRTheme.captionFont)
                .foregroundStyle(CanovRTheme.textSecondary)
                .padding(.horizontal, 24)
            }

            // Erfahrung
            VStack(spacing: 16) {
                Text("Erfahrung")
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)

                Picker("Erfahrung", selection: $experience) {
                    ForEach(OnboardingData.ExperienceLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
            }

            Spacer()

            Button(action: onNext) {
                Text("Weiter")
                    .font(.custom("Lato-Bold", size: 18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(CanovRTheme.azure)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}
