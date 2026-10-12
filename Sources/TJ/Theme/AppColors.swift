import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum AppColors {
    // --- Dynamic Light vs Dark Mode Theme Palette ---

    public static var brandPrimary: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.0, green: 0.82, blue: 0.76, alpha: 1.0) : // Electric Cyan-Teal #00D2C2 (Dark)
                UIColor(red: 0.04, green: 0.34, blue: 0.82, alpha: 1.0)  // Royal Blue #0B57D0 (Light)
        })
        #else
        return Color(red: 0.04, green: 0.34, blue: 0.82)
        #endif
    }

    public static var brandAccent: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.55, green: 0.36, blue: 0.96, alpha: 1.0) : // Purple #8B5CF6 (Dark)
                UIColor(red: 0.01, green: 0.52, blue: 0.78, alpha: 1.0)  // Sky Accent #0284C7 (Light)
        })
        #else
        return Color(red: 0.01, green: 0.52, blue: 0.78)
        #endif
    }

    public static let tealAccent = Color(red: 0.0, green: 0.82, blue: 0.76)
    public static let purpleAccent = Color(red: 0.55, green: 0.36, blue: 0.96)

    public static var cardDark: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.12, green: 0.13, blue: 0.15, alpha: 1.0) : // #1E2026 (Dark)
                UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)  // #F2F4F8 (Light)
        })
        #else
        return Color(red: 0.95, green: 0.96, blue: 0.98)
        #endif
    }

    public static var darkCharcoal: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0) : // #121316 (Dark)
                UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)  // #FAFAFD (Light)
        })
        #else
        return Color(red: 0.07, green: 0.07, blue: 0.09)
        #endif
    }

    public static var borderDark: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.16, green: 0.17, blue: 0.20, alpha: 1.0) : // #2A2C34 (Dark)
                UIColor(red: 0.88, green: 0.88, blue: 0.90, alpha: 1.0)  // #E0E0E0 (Light)
        })
        #else
        return Color(red: 0.88, green: 0.88, blue: 0.90)
        #endif
    }

    public static var surfaceElevated: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.12, green: 0.13, blue: 0.15, alpha: 1.0) : // #1E2026 (Dark)
                UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)  // #F2F4F8 (Light)
        })
        #else
        return Color(red: 0.95, green: 0.96, blue: 0.98)
        #endif
    }

    // Bottom Nav Palette
    public static var appBottomNavBg: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0) : // #121316 (Dark)
                UIColor(red: 0.91, green: 0.93, blue: 0.98, alpha: 1.0)  // #E8EEF9 (Light)
        })
        #else
        return Color(red: 0.91, green: 0.93, blue: 0.98)
        #endif
    }

    public static var appBottomNavPill: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.12, green: 0.17, blue: 0.27, alpha: 1.0) : // #1E2B45 (Dark)
                UIColor(red: 0.82, green: 0.89, blue: 0.99, alpha: 1.0)  // #D3E3FD (Light)
        })
        #else
        return Color(red: 0.82, green: 0.89, blue: 0.99)
        #endif
    }

    public static var appBottomNavActive: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.0, green: 0.82, blue: 0.76, alpha: 1.0) : // #00D2C2 (Dark)
                UIColor(red: 0.04, green: 0.34, blue: 0.82, alpha: 1.0)  // #0B57D0 (Light)
        })
        #else
        return Color(red: 0.04, green: 0.34, blue: 0.82)
        #endif
    }

    public static var appBottomNavUnselected: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.56, green: 0.57, blue: 0.61, alpha: 1.0) : // #8E929B (Dark)
                UIColor(red: 0.27, green: 0.28, blue: 0.27, alpha: 1.0)  // #444746 (Light)
        })
        #else
        return Color(red: 0.27, green: 0.28, blue: 0.27)
        #endif
    }

    public static var darkBackgroundTop: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0) : // #121316
                UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)
        })
        #else
        return Color(red: 0.07, green: 0.07, blue: 0.09)
        #endif
    }

    public static var darkBackgroundBottom: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.04, green: 0.05, blue: 0.07, alpha: 1.0) :
                UIColor(red: 0.95, green: 0.96, blue: 0.97, alpha: 1.0)
        })
        #else
        return Color(red: 0.04, green: 0.05, blue: 0.07)
        #endif
    }

    public static var greyMedium: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.56, green: 0.57, blue: 0.61, alpha: 1.0) :
                UIColor(red: 0.45, green: 0.47, blue: 0.46, alpha: 1.0)
        })
        #else
        return Color(red: 0.45, green: 0.47, blue: 0.46)
        #endif
    }

    public static var greyLight: Color {
        #if canImport(UIKit)
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.12, green: 0.13, blue: 0.15, alpha: 1.0) :
                UIColor(red: 0.95, green: 0.96, blue: 0.97, alpha: 1.0)
        })
        #else
        return Color(red: 0.95, green: 0.96, blue: 0.97)
        #endif
    }

    public static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [brandPrimary, brandAccent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

public extension Color {
    static var appPrimary: Color { AppColors.brandPrimary }
    static var appAccent: Color { AppColors.brandAccent }
    static var appBottomNavBg: Color { AppColors.appBottomNavBg }
    static var appBottomNavPill: Color { AppColors.appBottomNavPill }
    static var appBottomNavActive: Color { AppColors.appBottomNavActive }
    static var appBottomNavUnselected: Color { AppColors.appBottomNavUnselected }
    static var logoBlueDark: Color { AppColors.brandPrimary }
    static var appBackgroundDarkTop: Color { AppColors.darkBackgroundTop }
    static var appBackgroundDarkBottom: Color { AppColors.darkBackgroundBottom }

    init(hex: String) {
        let hexClean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexClean).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexClean.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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
}
