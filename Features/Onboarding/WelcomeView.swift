import SwiftUI

struct WelcomeView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: CanovRTheme.spacingXXL) {
            Spacer()

            Image(systemName: "figure.run")
                .font(.system(size: 72))
                .foregroundStyle(CanovRTheme.primary)

            VStack(spacing: CanovRTheme.spacingMD) {
                Text("CANOVR")
                    .font(.custom("FugazOne-Regular", size: 42))
                    .foregroundStyle(CanovRTheme.primary)

                Text("Dein intelligenter Trainingsplan")
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)

                Text("Full-Spectrum Percentage-Based Training")
                    .font(CanovRTheme.captionFont)
                    .foregroundStyle(CanovRTheme.textTertiary)
            }

            Spacer()

            Button(action: onNext) {
                Text("Los geht's")
                    .primaryButtonStyle()
            }
            .padding(.horizontal, CanovRTheme.spacingXL)
            .padding(.bottom, 48)
        }
    }
}
