//
//  StandardTheme.swift
//  ZeroBasedBudget
//
//  Standard theme: Clean, familiar iOS system colors.
//  Provides a native Apple aesthetic for users who prefer the default iOS look.
//
//  Colors based on iOS system palette:
//  - Blue primary/accent (iOS default tint)
//  - Green/Red/Orange semantic colors
//  - System gray backgrounds
//  - Native text colors
//

import SwiftUI

/// Standard theme: Clean and familiar iOS system colors
struct StandardTheme: Theme {
    let name = "Standard"
    let identifier = "standard"
    let description = "Clean iOS system colors"

    // MARK: - Light Mode Colors

    var lightColors: ThemeColors {
        // iOS system colors for light mode
        let bgColor = Color(red: 242/255, green: 242/255, blue: 247/255)  // systemGroupedBackground
        let surfaceColor = Color.white  // systemBackground
        let surfaceElevatedColor = Color.white  // Same as surface in light mode

        let primaryColor = Color(red: 0/255, green: 122/255, blue: 255/255)  // iOS Blue #007AFF
        let onPrimaryColor = Color.white  // White text on blue
        let accentColor = Color(red: 0/255, green: 122/255, blue: 255/255)  // Same as primary

        let successColor = Color(red: 52/255, green: 199/255, blue: 89/255)  // iOS Green #34C759
        let warningColor = Color(red: 255/255, green: 149/255, blue: 0/255)  // iOS Orange #FF9500
        let errorColor = Color(red: 255/255, green: 59/255, blue: 48/255)  // iOS Red #FF3B30

        let textPrimaryColor = Color(red: 0/255, green: 0/255, blue: 0/255)  // label (black)
        let textSecondaryColor = Color(red: 60/255, green: 60/255, blue: 67/255, opacity: 0.6)  // secondaryLabel
        let textTertiaryColor = Color(red: 60/255, green: 60/255, blue: 67/255, opacity: 0.3)  // tertiaryLabel

        let borderColor = Color(red: 199/255, green: 199/255, blue: 204/255)  // separator
        let borderSubtleColor = Color(red: 229/255, green: 229/255, blue: 234/255)  // Light border

        let chartSecondaryColor = Color(red: 88/255, green: 86/255, blue: 214/255)  // iOS Purple #5856D6
        let chartTertiaryColor = Color(red: 175/255, green: 82/255, blue: 222/255)  // iOS Pink #AF52DE

        return ThemeColors(
            background: bgColor,
            surface: surfaceColor,
            surfaceElevated: surfaceElevatedColor,
            primary: primaryColor,
            onPrimary: onPrimaryColor,
            accent: accentColor,
            success: successColor,
            warning: warningColor,
            error: errorColor,
            textPrimary: textPrimaryColor,
            textSecondary: textSecondaryColor,
            textTertiary: textTertiaryColor,
            border: borderColor,
            borderSubtle: borderSubtleColor,
            readyToAssignBackground: Color(red: 0/255, green: 122/255, blue: 255/255, opacity: 0.1),  // Light blue tint
            readyToAssignText: primaryColor,
            readyToAssignBorder: primaryColor,
            chartPrimary: primaryColor,
            chartSecondary: chartSecondaryColor,
            chartTertiary: chartTertiaryColor,
            progressGreen: successColor,
            progressYellow: warningColor,
            progressRed: errorColor
        )
    }

    // MARK: - Dark Mode Colors

    var darkColors: ThemeColors {
        // iOS system colors for dark mode
        let bgColor = Color(red: 0/255, green: 0/255, blue: 0/255)  // systemGroupedBackground (black)
        let surfaceColor = Color(red: 28/255, green: 28/255, blue: 30/255)  // systemBackground #1C1C1E
        let surfaceElevatedColor = Color(red: 44/255, green: 44/255, blue: 46/255)  // secondarySystemGroupedBackground #2C2C2E

        let primaryColor = Color(red: 10/255, green: 132/255, blue: 255/255)  // iOS Blue (dark mode) #0A84FF
        let onPrimaryColor = Color.white  // White text on blue
        let accentColor = Color(red: 10/255, green: 132/255, blue: 255/255)  // Same as primary

        let successColor = Color(red: 48/255, green: 209/255, blue: 88/255)  // iOS Green (dark) #30D158
        let warningColor = Color(red: 255/255, green: 159/255, blue: 10/255)  // iOS Orange (dark) #FF9F0A
        let errorColor = Color(red: 255/255, green: 69/255, blue: 58/255)  // iOS Red (dark) #FF453A

        let textPrimaryColor = Color.white  // label (white)
        let textSecondaryColor = Color(red: 235/255, green: 235/255, blue: 245/255, opacity: 0.6)  // secondaryLabel
        let textTertiaryColor = Color(red: 235/255, green: 235/255, blue: 245/255, opacity: 0.3)  // tertiaryLabel

        let borderColor = Color(red: 56/255, green: 56/255, blue: 58/255)  // separator (dark)
        let borderSubtleColor = Color(red: 44/255, green: 44/255, blue: 46/255)  // Subtle border

        let chartSecondaryColor = Color(red: 94/255, green: 92/255, blue: 230/255)  // iOS Purple (dark) #5E5CE6
        let chartTertiaryColor = Color(red: 191/255, green: 90/255, blue: 242/255)  // iOS Pink (dark) #BF5AF2

        return ThemeColors(
            background: bgColor,
            surface: surfaceColor,
            surfaceElevated: surfaceElevatedColor,
            primary: primaryColor,
            onPrimary: onPrimaryColor,
            accent: accentColor,
            success: successColor,
            warning: warningColor,
            error: errorColor,
            textPrimary: textPrimaryColor,
            textSecondary: textSecondaryColor,
            textTertiary: textTertiaryColor,
            border: borderColor,
            borderSubtle: borderSubtleColor,
            readyToAssignBackground: Color(red: 10/255, green: 132/255, blue: 255/255, opacity: 0.15),  // Darker blue tint
            readyToAssignText: primaryColor,
            readyToAssignBorder: primaryColor,
            chartPrimary: primaryColor,
            chartSecondary: chartSecondaryColor,
            chartTertiary: chartTertiaryColor,
            progressGreen: successColor,
            progressYellow: warningColor,
            progressRed: errorColor
        )
    }

    // MARK: - Typography (iOS system defaults)

    let typography = ThemeTypography(
        largeTitle: .system(size: 34, weight: .bold, design: .default),
        title: .system(size: 28, weight: .bold, design: .default),
        headline: .system(size: 17, weight: .semibold, design: .default),
        body: .system(size: 17, weight: .regular, design: .default),
        callout: .system(size: 16, weight: .regular, design: .default),
        caption: .system(size: 12, weight: .regular, design: .default),
        footnote: .system(size: 13, weight: .regular, design: .default)
    )

    // MARK: - Spacing (iOS standard spacing)

    let spacing = ThemeSpacing(
        xs: 4,
        sm: 8,
        md: 16,
        lg: 24,
        xl: 32,
        xxl: 48
    )

    // MARK: - Radius (iOS standard radius)

    let radius = ThemeRadius(
        sm: 4,
        md: 8,
        lg: 12,
        xl: 20,
        full: 9999
    )
}
