import SwiftUI

struct SessionTypeBadge: View {
    let type: String

    private var label: String {
        switch type {
        case "hard", "moderate": return "Hart"
        case "long_run":         return "Long Run"
        case "easy":             return "Easy"
        case "easy+strides":     return "Easy + Strides"
        case "rest":             return "Ruhetag"
        default:                 return type
        }
    }

    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(CanovRTheme.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(CanovRTheme.sessionColor(type))
            .clipShape(Capsule())
    }
}
