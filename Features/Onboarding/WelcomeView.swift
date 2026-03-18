import SwiftUI

struct WelcomeView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Logo
            Image(systemName: "figure.run")
                .font(.system(size: 72))
                .foregroundStyle(CanovRTheme.azureGradient)

            VStack(spacing: 12) {
                Text("CanovR")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.white)

                Text("Dein intelligenter Trainingsplan")
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)

                Text("Full-Spectrum Percentage-Based Training")
                    .font(CanovRTheme.captionFont)
                    .foregroundStyle(CanovRTheme.textSecondary)
            }

            Spacer()

            Button(action: onNext) {
                Text("Los geht's")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(CanovRTheme.azureGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}
