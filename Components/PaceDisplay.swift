import SwiftUI

/// Displays a pace in "M:SS/km" format.
struct PaceDisplay: View {
    let pace: String
    var size: Font = CanovRTheme.paceFont

    var body: some View {
        HStack(spacing: 2) {
            Text(pace.replacingOccurrences(of: "/km", with: ""))
                .font(size)
                .foregroundStyle(CanovRTheme.textPrimary)
            Text("/km")
                .font(CanovRTheme.captionFont)
                .foregroundStyle(CanovRTheme.textTertiary)
        }
    }
}
