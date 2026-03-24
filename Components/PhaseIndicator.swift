import SwiftUI

struct PhaseIndicator: View {
    let phase: String
    let week: Int
    let total: Int

    private var phaseLabel: String {
        switch phase {
        case "general":    return String(localized: "General")
        case "supportive": return String(localized: "Supportive")
        case "specific":   return String(localized: "Specific")
        default:           return phase
        }
    }

    var body: some View {
        HStack(spacing: CanovRTheme.spacingSM) {
            Text(phaseLabel)
                .font(CanovRTheme.lato(13, weight: .bold))
                .foregroundStyle(CanovRTheme.primary)
                .padding(.horizontal, CanovRTheme.spacingSM)
                .padding(.vertical, CanovRTheme.spacingXS)
                .background(CanovRTheme.primaryLight.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: CanovRTheme.radiusSM)
                        .stroke(CanovRTheme.primary, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: CanovRTheme.radiusSM))

            Text("Woche \(week)/\(total)")
                .font(CanovRTheme.captionFont)
                .foregroundStyle(CanovRTheme.textTertiary)
        }
    }
}
