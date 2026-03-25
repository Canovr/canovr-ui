import SwiftUI

struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            CanovRTheme.background.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: CanovRTheme.spacingLG) {
                ProgressView()
                    .tint(CanovRTheme.primary)
                    .scaleEffect(1.2)
                Text(message)
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)
            }
            .padding(CanovRTheme.spacingXXL)
            .background(CanovRTheme.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CanovRTheme.radiusLG))
            .shadow(color: .black.opacity(0.06), radius: 20, y: 4)
        }
    }
}
