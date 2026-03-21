import SwiftUI

// MARK: - Farben & Design-System

enum CanovRTheme {
    // Akzent (Tailwind blue-400)
    static let primary = Color(hex: "60A5FA")
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "3B82F6"), Color(hex: "60A5FA")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // Legacy alias
    static let azure = primary
    static let azureGradient = primaryGradient

    // Hintergründe
    static let background = Color(hex: "E8E8ED")
    static let surface = Color(hex: "F5F5F7")
    static let surfaceElevated = Color(hex: "EDEDF0")

    // Text
    static let textPrimary = Color(hex: "1C1C1E")
    static let primaryBtnText = Color(hex: "ffffff")
    static let textSecondary = Color(hex: "6B6B70")

    // Session-Typen
    static let hardSession = primary
    static let easySession = Color(hex: "A2A2A7")
    static let longRun = Color(hex: "30D158")
    static let restDay = Color(hex: "C7C7CC")

    // Zonen-Farben (opacity-basiert auf primary)
    static func zoneColor(percentage: Int) -> Color {
        let opacity: Double
        switch percentage {
        case ...80:  opacity = 0.25
        case 85:     opacity = 0.35
        case 90:     opacity = 0.45
        case 95:     opacity = 0.60
        case 100:    opacity = 0.75
        case 105:    opacity = 0.85
        case 110:    opacity = 0.92
        default:     opacity = 1.00
        }
        return primary.opacity(opacity)
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

    // MARK: - Typografie (Lato)

    static let titleFont = Font.custom("Lato-Bold", size: 20)
    static let headlineFont = Font.custom("Lato-Bold", size: 18)
    static let bodyFont = Font.custom("Lato-Regular", size: 16)
    static let captionFont = Font.custom("Lato-Regular", size: 13)
    static let paceFont = Font.system(size: 18, weight: .semibold, design: .monospaced)

    // Helpers für inline-Fonts
    static func lato(_ size: CGFloat, weight: FontWeight = .regular) -> Font {
        switch weight {
        case .bold, .semibold, .heavy, .black:
            return .custom("Lato-Bold", size: size)
        case .light, .ultraLight, .thin:
            return .custom("Lato-Light", size: size)
        default:
            return .custom("Lato-Regular", size: size)
        }
    }

    enum FontWeight {
        case regular, bold, semibold, heavy, black, light, ultraLight, thin, medium
    }

    // CANOVR Logo-Schrift (Fugaz One)
    static let logoFont = Font.custom("FugazOne-Regular", size: 20)

    // MARK: - Tab Bar

    static let tabBarHeight: CGFloat = 56
    static let tabBarBackground = Color(hex: "F5F5F7")
    static let tabIconInactive = Color(hex: "9CA3AF")
    static let tabIconActive = primary
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
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(elevated ? CanovRTheme.surfaceElevated : CanovRTheme.surface)
    }
}

extension View {
    func cardStyle(elevated: Bool = false) -> some View {
        modifier(CardStyle(elevated: elevated))
    }
}
