import SwiftUI

struct AppColors {
    static let primaryBlue = Color(red: 0.12, green: 0.35, blue: 0.75)
    static let lightBlue = Color(red: 0.26, green: 0.65, blue: 0.96)
    static let skyBlue = Color(red: 0.53, green: 0.81, blue: 0.98)
    static let deepBlue = Color(red: 0.05, green: 0.24, blue: 0.55)
    
    static let white = Color.white
    static let lightGray = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let mediumGray = Color(red: 0.85, green: 0.85, blue: 0.85)
    static let darkGray = Color(red: 0.20, green: 0.20, blue: 0.20)
    static let black = Color.black
    
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let warning = Color(red: 1.0, green: 0.80, blue: 0.0)
    static let error = Color(red: 1.0, green: 0.23, blue: 0.19)
    static let info = Color(red: 0.35, green: 0.78, blue: 0.98)
    
    static let chartGreen = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let chartRed = Color(red: 1.0, green: 0.23, blue: 0.19)
    static let chartNeutral = Color(red: 0.55, green: 0.55, blue: 0.55)
    
    static let primaryBackground = primaryBlue
    static let secondaryBackground = lightBlue
    static let cardBackground = white
    static let overlayBackground = Color.black.opacity(0.3)
    
    static let primaryText = white
    static let secondaryText = darkGray
    static let accentText = primaryBlue
    static let mutedText = mediumGray
    
    static let primaryButton = lightBlue
    static let secondaryButton = mediumGray
    static let destructiveButton = error
    
    static let primaryBorder = lightBlue
    static let secondaryBorder = mediumGray
    static let errorBorder = error
}

extension LinearGradient {
    static let primaryBackground = LinearGradient(
        colors: [AppColors.primaryBlue, AppColors.deepBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryBackground = LinearGradient(
        colors: [AppColors.lightBlue, AppColors.skyBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardBackground = LinearGradient(
        colors: [AppColors.white, AppColors.lightGray],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let buttonGradient = LinearGradient(
        colors: [AppColors.lightBlue, AppColors.primaryBlue],
        startPoint: .leading,
        endPoint: .trailing
    )
}

extension Color {
    static func dynamic(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

struct AppColorScheme {
    let background: Color
    let secondaryBackground: Color
    let cardBackground: Color
    let primaryText: Color
    let secondaryText: Color
    let accent: Color
    let border: Color
    let error: Color
    let success: Color
    
    static let light = AppColorScheme(
        background: AppColors.primaryBackground,
        secondaryBackground: AppColors.secondaryBackground,
        cardBackground: AppColors.cardBackground,
        primaryText: AppColors.primaryText,
        secondaryText: AppColors.secondaryText,
        accent: AppColors.accentText,
        border: AppColors.primaryBorder,
        error: AppColors.error,
        success: AppColors.success
    )
    
    static let dark = AppColorScheme(
        background: AppColors.deepBlue,
        secondaryBackground: AppColors.primaryBlue,
        cardBackground: AppColors.darkGray,
        primaryText: AppColors.white,
        secondaryText: AppColors.lightGray,
        accent: AppColors.lightBlue,
        border: AppColors.lightBlue,
        error: AppColors.error,
        success: AppColors.success
    )
}

struct ColorSchemeKey: EnvironmentKey {
    static let defaultValue = AppColorScheme.light
}

extension EnvironmentValues {
    var appColorScheme: AppColorScheme {
        get { self[ColorSchemeKey.self] }
        set { self[ColorSchemeKey.self] = newValue }
    }
}

