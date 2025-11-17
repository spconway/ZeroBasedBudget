//
//  StandardTheme.swift
//  ZeroBasedBudget
//
//  Minimalist Refined theme: Clean lines, subtle shadows, refined spacing
//  Default theme providing an elevated, polished aesthetic with:
//  - Subtle 1px borders with soft colors
//  - 12px corner radius for modern feel
//  - Light weight typography (300-600)
//  - Generous white space & padding
//  - Icon badges with subtle opacity
//
//  Colors based on refined iOS palette:
//  - Blue primary/accent (iOS default tint)
//  - Green/Red/Orange semantic colors
//  - Very light gray background (#FAFBFC)
//  - White cards with subtle borders
//

import SwiftUI

/// Minimalist Refined theme: Elevated iOS aesthetic with refined details
struct StandardTheme: Theme {
    let name = "Minimalist Refined"
    let identifier = "standard"
    let description = "Clean lines, subtle shadows, refined spacing"

    // MARK: - Light Mode Colors

    var lightColors: ThemeColors {
        // Minimalist Refined colors for light mode
        let bgColor = Color(red: 250/255, green: 251/255, blue: 252/255)  // Very light gray #FAFBFC
        let surfaceColor = Color.white  // Pure white cards
        let surfaceElevatedColor = Color.white  // Same as surface for clean look

        let primaryColor = Color(red: 0/255, green: 122/255, blue: 255/255)  // iOS Blue #007AFF
        let onPrimaryColor = Color.white  // White text on blue
        let accentColor = Color(red: 0/255, green: 122/255, blue: 255/255)  // Same as primary

        let successColor = Color(red: 52/255, green: 199/255, blue: 89/255)  // iOS Green #34C759
        let warningColor = Color(red: 255/255, green: 149/255, blue: 0/255)  // iOS Orange #FF9500
        let errorColor = Color(red: 255/255, green: 59/255, blue: 48/255)  // iOS Red #FF3B30

        let textPrimaryColor = Color(red: 26/255, green: 26/255, blue: 26/255)  // Slightly softer black #1A1A1A
        let textSecondaryColor = Color(red: 107/255, green: 107/255, blue: 107/255)  // Medium gray #6B6B6B
        let textTertiaryColor = Color(red: 142/255, green: 142/255, blue: 147/255)  // Light gray #8E8E93

        let borderColor = Color(red: 199/255, green: 199/255, blue: 204/255)  // separator #C7C7CC
        let borderSubtleColor = Color(red: 229/255, green: 229/255, blue: 234/255)  // Subtle border #E5E5EA (from mockup)

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
        // Minimalist Refined colors for dark mode
        let bgColor = Color(red: 18/255, green: 18/255, blue: 18/255)  // Deep dark #121212 (refined black)
        let surfaceColor = Color(red: 28/255, green: 28/255, blue: 30/255)  // Elevated surface #1C1C1E
        let surfaceElevatedColor = Color(red: 44/255, green: 44/255, blue: 46/255)  // Modal surface #2C2C2E

        let primaryColor = Color(red: 10/255, green: 132/255, blue: 255/255)  // iOS Blue (dark mode) #0A84FF
        let onPrimaryColor = Color.white  // White text on blue
        let accentColor = Color(red: 10/255, green: 132/255, blue: 255/255)  // Same as primary

        let successColor = Color(red: 48/255, green: 209/255, blue: 88/255)  // iOS Green (dark) #30D158
        let warningColor = Color(red: 255/255, green: 159/255, blue: 10/255)  // iOS Orange (dark) #FF9F0A
        let errorColor = Color(red: 255/255, green: 69/255, blue: 58/255)  // iOS Red (dark) #FF453A

        let textPrimaryColor = Color.white  // Primary text (white)
        let textSecondaryColor = Color(red: 235/255, green: 235/255, blue: 245/255, opacity: 0.6)  // Secondary text
        let textTertiaryColor = Color(red: 235/255, green: 235/255, blue: 245/255, opacity: 0.3)  // Tertiary text

        let borderColor = Color.white.opacity(0.15)  // Refined subtle border
        let borderSubtleColor = Color.white.opacity(0.1)  // Very subtle border for cards

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
