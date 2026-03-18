import SwiftUI

struct ErrorBanner: View {
    let message: String
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(CanovRTheme.captionFont)
                .foregroundStyle(.white)
            Spacer()
            if let onDismiss {
                Button { onDismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(CanovRTheme.textSecondary)
                }
            }
        }
        .padding(12)
        .background(Color.red.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
