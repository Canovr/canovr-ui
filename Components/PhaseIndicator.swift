import SwiftUI

struct PhaseIndicator: View {
    let phase: String
    let week: Int
    let total: Int

    private var phaseLabel: String {
        switch phase {
        case "general":    return "General"
        case "supportive": return "Supportive"
        case "specific":   return "Specific"
        default:           return phase
        }
    }

    private var phaseColor: Color {
        switch phase {
        case "general":    return CanovRTheme.longRun
        case "supportive": return CanovRTheme.azure
        case "specific":   return Color(hex: "FF9500")
        default:           return CanovRTheme.azure
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(phaseLabel)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(CanovRTheme.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(phaseColor.opacity(0.3))
                .clipShape(Capsule())

            Text("Woche \(week)/\(total)")
                .font(CanovRTheme.captionFont)
                .foregroundStyle(CanovRTheme.textSecondary)
        }
    }
}
