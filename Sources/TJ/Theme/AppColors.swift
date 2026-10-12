import SwiftUI

public enum AppColors {
    public static let brandPrimary = Color(red: 0.04, green: 0.34, blue: 0.82) // #0B57D0 Royal Blue
    public static let brandAccent = Color(red: 0.01, green: 0.52, blue: 0.78)  // #0284C7 Sky Accent

    // Bottom Nav Palette (Exact match to screenshot)
    public static let appBottomNavBg = Color(red: 0.91, green: 0.93, blue: 0.98)   // #E8EEF9
    public static let appBottomNavPill = Color(red: 0.82, green: 0.89, blue: 0.99) // #D3E3FD
    public static let appBottomNavActive = Color(red: 0.04, green: 0.34, blue: 0.82) // #0B57D0
    public static let appBottomNavUnselected = Color(red: 0.27, green: 0.28, blue: 0.27) // #444746

    public static let darkBackgroundTop = Color(red: 0.07, green: 0.07, blue: 0.09)
    public static let darkBackgroundBottom = Color(red: 0.04, green: 0.05, blue: 0.07)
    public static let greyMedium = Color(red: 0.45, green: 0.47, blue: 0.46)
    public static let greyLight = Color(red: 0.95, green: 0.96, blue: 0.97)
}

public extension Color {
    static let appPrimary = AppColors.brandPrimary
    static let appAccent = AppColors.brandAccent
    static let appBottomNavBg = AppColors.appBottomNavBg
    static let appBottomNavPill = AppColors.appBottomNavPill
    static let appBottomNavActive = AppColors.appBottomNavActive
    static let appBottomNavUnselected = AppColors.appBottomNavUnselected
}
