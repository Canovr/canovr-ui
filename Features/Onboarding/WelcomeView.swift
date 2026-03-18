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
                Text("CANOVR")
                    .font(.custom("FugazOne-Regular", size: 42))
                    .foregroundStyle(CanovRTheme.primary)

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
                    .font(.custom("Lato-Bold", size: 18))
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
