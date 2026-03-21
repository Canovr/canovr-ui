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

    var body: some View {
        HStack(spacing: 8) {
            Text(phaseLabel)
                .font(.custom("Lato-Bold", size: 13))
                .foregroundStyle(CanovRTheme.textPrimary)

            Text("Woche \(week)/\(total)")
                .font(CanovRTheme.captionFont)
                .foregroundStyle(CanovRTheme.textSecondary)
        }
    }
}
