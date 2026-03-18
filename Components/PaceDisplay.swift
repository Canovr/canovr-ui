import SwiftUI

/// Zeigt eine Pace im Format "M:SS/km" an.
struct PaceDisplay: View {
    let pace: String
    var size: Font = CanovRTheme.paceFont

    var body: some View {
        HStack(spacing: 2) {
            Text(pace.replacingOccurrences(of: "/km", with: ""))
                .font(size)
                .foregroundStyle(.white)
            Text("/km")
                .font(CanovRTheme.captionFont)
                .foregroundStyle(CanovRTheme.textSecondary)
        }
    }
}
