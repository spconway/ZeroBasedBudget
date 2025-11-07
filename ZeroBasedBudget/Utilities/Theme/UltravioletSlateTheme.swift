//
//  UltravioletSlateTheme.swift
//  ZeroBasedBudget
//
//  Ultraviolet Slate theme: Bold, energetic with saturated colors.
//  Charcoal base with deep violet and vivid cyan accents.
//  Design tokens from: Designs/UltravioletSlate/tokens.json
//

import SwiftUI

/// Ultraviolet Slate theme: Bold, energetic design
struct UltravioletSlateTheme: Theme {
    let name = "Ultraviolet Slate"
    let identifier = "ultravioletSlate"
    let description = "Bold, energetic design"

    // MARK: - Dark Mode Colors

    var darkColors: ThemeColors {
        // Break up color initialization to help Swift compiler
        let bgColor = Color(hex: "1A1A1F")
        let surfaceColor = Color(hex: "222228")
        let surfaceElevatedColor = Color(hex: "2A2A32")

        let primaryColor = Color(hex: "6366F1")
        let onPrimaryColor = Color(hex: "FFFFFF")
        let accentColor = Color(hex: "22D3EE")

        let successColor = Color(hex: "84CC16")
        let warningColor = Color(hex: "FB923C")
        let errorColor = Color(hex: "F43F5E")

        let textPrimaryColor = Color(hex: "6366F1")
        let textSecondaryColor = Color(hex: "22D3EE")
        let textTertiaryColor = Color(hex: "FFFFFF")

        let borderColor = Color(hex: "3A3A42")
        let borderSubtleColor = Color(hex: "2A2A32")

        let chartTertiaryColor = Color(hex: "A78BFA")

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
            readyToAssignBackground: primaryColor,
            readyToAssignText: onPrimaryColor,
            readyToAssignBorder: accentColor,
            chartPrimary: primaryColor,
            chartSecondary: accentColor,
            chartTertiary: chartTertiaryColor,
            progressGreen: successColor,
            progressYellow: warningColor,
            progressRed: errorColor
        )
    }

    // MARK: - Light Mode Colors

    var lightColors: ThemeColors {
        // Bold energy in daylight - vibrant and readable
        let bgColor = Color(hex: "F8F8FE")  // Subtle indigo tint
        let surfaceColor = Color(hex: "FFFFFF")  // Pure white
        let surfaceElevatedColor = Color(hex: "FAFAFA")  // Slightly elevated

        let primaryColor = Color(hex: "5B51F1")  // Vibrant indigo for accents
        let onPrimaryColor = Color(hex: "FFFFFF")  // White on indigo
        let accentColor = Color(hex: "06B6D4")  // Bright cyan for accents

        let successColor = Color(hex: "65A30D")  // Readable lime green
        let warningColor = Color(hex: "EA580C")  // Readable orange
        let errorColor = Color(hex: "E11D48")  // Readable rose

        let textPrimaryColor = Color(hex: "4338CA")  // Deep indigo (5.2:1 contrast)
        let textSecondaryColor = Color(hex: "0E7490")  // Dark cyan (4.8:1 contrast)
        let textTertiaryColor = Color(hex: "1F2937")  // Charcoal (12:1 contrast)

        let borderColor = Color(hex: "E5E7EB")  // Light gray border
        let borderSubtleColor = Color(hex: "F3F4F6")  // Very light border

        let chartTertiaryColor = Color(hex: "8B5CF6")  // Purple

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
            readyToAssignBackground: primaryColor,
            readyToAssignText: onPrimaryColor,
            readyToAssignBorder: accentColor,
            chartPrimary: primaryColor,
            chartSecondary: accentColor,
            chartTertiary: chartTertiaryColor,
            progressGreen: successColor,
            progressYellow: warningColor,
            progressRed: errorColor
        )
    }

    let typography = ThemeTypography(
        largeTitle: .system(size: 34, weight: .bold, design: .default),
        title: .system(size: 28, weight: .bold, design: .default),
        headline: .system(size: 17, weight: .semibold, design: .default),
        body: .system(size: 17, weight: .regular, design: .default),
        callout: .system(size: 16, weight: .regular, design: .default),
        caption: .system(size: 12, weight: .regular, design: .default),
        footnote: .system(size: 13, weight: .regular, design: .default)
    )

    let spacing = ThemeSpacing(
        xs: 4,
        sm: 8,
        md: 16,
        lg: 24,
        xl: 32,
        xxl: 48
    )

    let radius = ThemeRadius(
        sm: 4,
        md: 8,
        lg: 12,
        xl: 20,
        full: 9999
    )
}
