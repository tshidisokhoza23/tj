import SwiftUI

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let darkCharcoal = Color(hex: "1A1A1A")
    static let cardDark = Color(hex: "222222")
    static let borderDark = Color(hex: "333333")
    static let tealAccent = Color(hex: "14B8A6")
    static let purpleAccent = Color(hex: "A855F7")
    static let openGreen = Color(hex: "22C55E")
    static let waitlistOrange = Color(hex: "F59E0B")
    static let textSecondary = Color(hex: "A1A1AA")
    static let textTertiary = Color(hex: "71717A")
    static let surfaceElevated = Color(hex: "2A2A2A")
    static let errorRed = Color(hex: "EF4444")

    static let appPrimary = Color(hex: "14B8A6")
    static let appAccent = Color(hex: "A855F7")
    static let appSecondary = Color(hex: "242424")
    static let appBackgroundLight = Color(hex: "F5F5F5")
    static let appBackgroundDarkTop = Color(hex: "1A1A1A")
    static let appBackgroundDarkBottom = Color(hex: "1A1A1A")
    static let appBottomNavBg = Color(hex: "1A1A1A")
    static let appBottomNavPill = Color(hex: "242424")
    static let logoBlueDark = Color(hex: "14B8A6")
    static let boyishPurple = Color(hex: "A855F7")
}

public struct AppColors {
    public static let darkCharcoal = Color.darkCharcoal
    public static let cardDark = Color.cardDark
    public static let borderDark = Color.borderDark
    public static let tealAccent = Color.tealAccent
    public static let purpleAccent = Color.purpleAccent
    public static let openGreen = Color.openGreen
    public static let waitlistOrange = Color.waitlistOrange

    public static let primary = Color.tealAccent
    public static let secondary = Color.cardDark
    public static let accent = Color.purpleAccent
    public static let backgroundDarkTop = Color.darkCharcoal
    public static let backgroundDarkBottom = Color.darkCharcoal
    public static let backgroundLight = Color.appBackgroundLight
    public static let logoBlueDark = Color.tealAccent
    public static let boyishPurple = Color.purpleAccent
    public static let brandPrimary = Color.tealAccent
    public static let brandAccent = Color.purpleAccent
    public static let darkBackgroundTop = Color.darkCharcoal
    public static let darkBackgroundBottom = Color.darkCharcoal
    public static let greyMedium = Color.textSecondary
    public static let greyLight = Color.surfaceElevated
    public static let textSecondary = Color.textSecondary
    public static let textTertiary = Color.textTertiary
    public static let surfaceElevated = Color.surfaceElevated
    public static let error = Color.errorRed

    public static let primaryGradient = LinearGradient(
        colors: [Color(hex: "A855F7"), Color(hex: "14B8A6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
