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
            .font(.custom("Lato-Bold", size: 12))
            .foregroundStyle(CanovRTheme.textSecondary)
    }
}
