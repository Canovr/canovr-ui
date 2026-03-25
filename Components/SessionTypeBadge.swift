import SwiftUI

struct SessionTypeBadge: View {
    let type: String

    private var label: String {
        switch type {
        case "hard", "moderate": return String(localized: "Hart")
        case "long_run":         return String(localized: "Long Run")
        case "easy":             return String(localized: "Easy")
        case "easy+strides":     return String(localized: "Easy + Strides")
        case "rest":             return String(localized: "Ruhetag")
        default:                 return type
        }
    }

    var body: some View {
        Text(label)
            .font(CanovRTheme.lato(11, weight: .bold))
            .foregroundStyle(CanovRTheme.textPrimary)
            .padding(.horizontal, CanovRTheme.spacingSM)
            .padding(.vertical, CanovRTheme.spacingXS)
            .clipShape(RoundedRectangle(cornerRadius: CanovRTheme.radiusSM))
            .overlay(
                RoundedRectangle(cornerRadius: CanovRTheme.radiusSM)
                    .stroke(CanovRTheme.textTertiary, lineWidth: 1)
            )
    }
}
