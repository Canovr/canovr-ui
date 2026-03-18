import SwiftUI

struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            CanovRTheme.background.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .tint(CanovRTheme.azure)
                    .scaleEffect(1.2)
                Text(message)
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)
            }
            .padding(32)
            .background(CanovRTheme.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
