import SwiftUI

struct ErrorBanner: View {
    let message: String
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: CanovRTheme.spacingSM) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(CanovRTheme.error)
            Text(message)
                .font(CanovRTheme.captionFont)
                .foregroundStyle(CanovRTheme.textPrimary)
            Spacer()
            if let onDismiss {
                Button { onDismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(CanovRTheme.textTertiary)
                }
            }
        }
        .padding(CanovRTheme.spacingMD)
        .background(CanovRTheme.error.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: CanovRTheme.radiusMD))
        .overlay(
            RoundedRectangle(cornerRadius: CanovRTheme.radiusMD)
                .stroke(CanovRTheme.error.opacity(0.2), lineWidth: 1)
        )
    }
}
