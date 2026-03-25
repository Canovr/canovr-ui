import SwiftUI

// MARK: - Design System

enum CanovRTheme {

    // MARK: - Colors

    // Primary accent (vibrant blue)
    static let primary = Color(hex: "2563EB")
    static let primaryLight = Color(hex: "DBEAFE")
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "2563EB"), Color(hex: "3B82F6")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // Legacy alias
    static let azure = primary
    static let azureGradient = primaryGradient

    // Backgrounds — bright and clean
    static let background = Color.white
    static let surface = Color(hex: "F0F1F3")
    static let surfaceElevated = Color.white

    // Borders & dividers
    static let border = Color(hex: "E5E7EB")
    static let divider = Color(hex: "F0F0F2")

    // Text
    static let textPrimary = Color(hex: "0A0F1A")
    static let textSecondary = Color(hex: "0A0F1A")
    static let textTertiary = Color(hex: "0A0F1A")
    static let placeholder = Color(hex: "8B8F96")
    static let primaryBtnText = Color.white

    // Input fields
    static let inputBackground = Color(hex: "EAEBEE")

    // Session types
    static let hardSession = primary
    static let easySession = Color(hex: "9CA3AF")
    static let longRun = primary
    static let restDay = Color(hex: "D1D5DB")

    // Semantic
    static let success = primary
    static let error = Color(hex: "EF4444")
    static let warning = Color(hex: "F59E0B")

    // Strava
    static let strava = Color(hex: "FC4C02")

    // MARK: - Zone colors (opacity-based on primary)

    static func zoneColor(percentage: Int) -> Color {
        let opacity: Double
        switch percentage {
        case ...80:  opacity = 0.25
        case 85:     opacity = 0.35
        case 90:     opacity = 0.50
        case 95:     opacity = 0.65
        case 100:    opacity = 0.80
        case 105:    opacity = 0.88
        case 110:    opacity = 0.94
        default:     opacity = 1.00
        }
        return primary.opacity(opacity)
    }

    // Session type → color
    static func sessionColor(_ type: String) -> Color {
        switch type {
        case "hard", "moderate": return hardSession
        case "long_run":         return longRun
        case "easy", "easy+strides": return easySession
        case "rest":             return restDay
        default:                 return easySession
        }
    }

    // MARK: - Typography (Lato)

    static let titleFont   = Font.custom("Lato-Bold", size: 22)
    static let headlineFont = Font.custom("Lato-Bold", size: 18)
    static let bodyFont    = Font.custom("Lato-Regular", size: 16)
    static let captionFont = Font.custom("Lato-Regular", size: 13)
    static let paceFont    = Font.system(size: 18, weight: .semibold, design: .monospaced)

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

    // Logo (Fugaz One)
    static let logoFont = Font.custom("FugazOne-Regular", size: 20)

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 20
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 20
    static let spacingXXL: CGFloat = 32

    // MARK: - Radii

    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16

    // MARK: - Tab Bar

    static let tabBarHeight: CGFloat = 56
    static let tabBarBackground = Color.white
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
            .padding(.horizontal, CanovRTheme.spacingXL)
            .padding(.vertical, CanovRTheme.spacingLG)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(elevated ? CanovRTheme.surfaceElevated : CanovRTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: CanovRTheme.radiusLG))
            .overlay(
                RoundedRectangle(cornerRadius: CanovRTheme.radiusLG)
                    .stroke(CanovRTheme.border.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal, CanovRTheme.spacingXL)
    }
}

extension View {
    func cardStyle(elevated: Bool = false) -> some View {
        modifier(CardStyle(elevated: elevated))
    }

    func inputStyle() -> some View {
        self
            .font(CanovRTheme.bodyFont)
            .foregroundStyle(CanovRTheme.textPrimary)
            .padding(.horizontal, CanovRTheme.spacingLG)
            .padding(.vertical, 14)
            .background(CanovRTheme.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: CanovRTheme.radiusMD))
    }

    /// Standard primary button: blue bg, white bold text, full width.
    func primaryButtonStyle(disabled: Bool = false) -> some View {
        self
            .font(CanovRTheme.lato(17, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(CanovRTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: CanovRTheme.radiusMD))
            .opacity(disabled ? 0.5 : 1)
    }
}
