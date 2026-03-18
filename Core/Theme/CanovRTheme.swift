import SwiftUI

// MARK: - Farben & Design-System

enum CanovRTheme {
    // Akzent
    static let azure = Color(hex: "007AFF")
    static let azureGradient = LinearGradient(
        colors: [Color(hex: "0055D4"), Color(hex: "007AFF")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // Hintergründe
    static let background = Color(hex: "F2F2F7")
    static let surface = Color(hex: "FFFDF7")
    static let surfaceElevated = Color(hex: "F5F3ED")

    // Text
    static let textPrimary = Color(hex: "1C1C1E")
    static let textSecondary = Color(hex: "6B6B70")

    // Session-Typen
    static let hardSession = azure
    static let easySession = Color(hex: "A2A2A7")
    static let longRun = Color(hex: "30D158")
    static let restDay = Color(hex: "C7C7CC")

    // Zonen-Farben (z80 grün → z100 azur → z115 rot)
    static func zoneColor(percentage: Int) -> Color {
        switch percentage {
        case ...80:  return Color(hex: "30D158")
        case 85:     return Color(hex: "34C759")
        case 90:     return Color(hex: "00A3FF")
        case 95:     return Color(hex: "007AFF")
        case 100:    return azure
        case 105:    return Color(hex: "FF9500")
        case 110:    return Color(hex: "FF6B35")
        default:     return Color(hex: "FF3B30")
        }
    }

    // Session-Typ → Farbe
    static func sessionColor(_ type: String) -> Color {
        switch type {
        case "hard", "moderate": return hardSession
        case "long_run":         return longRun
        case "easy", "easy+strides": return easySession
        case "rest":             return restDay
        default:                 return easySession
        }
    }

    // Typografie
    static let titleFont = Font.system(size: 28, weight: .bold, design: .default)
    static let headlineFont = Font.system(size: 22, weight: .bold, design: .default)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .default)
    static let captionFont = Font.system(size: 13, weight: .regular, design: .default)
    static let paceFont = Font.system(size: 18, weight: .semibold, design: .monospaced)
}

// MARK: - Color Extension (Hex)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Card Style Modifier

struct CardStyle: ViewModifier {
    var elevated: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(elevated ? CanovRTheme.surfaceElevated : CanovRTheme.surface)
    }
}

extension View {
    func cardStyle(elevated: Bool = false) -> some View {
        modifier(CardStyle(elevated: elevated))
    }
}
