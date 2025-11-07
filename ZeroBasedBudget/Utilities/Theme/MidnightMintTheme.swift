//
//  MidnightMintTheme.swift
//  ZeroBasedBudget
//
//  Midnight Mint theme: Calm, professional modern fintech aesthetic.
//  Blue-tinted black base with seafoam mint accents.
//  Design tokens from: Designs/MidnightMint/tokens.json
//

import SwiftUI

/// Midnight Mint theme: Calm, professional fintech design
struct MidnightMintTheme: Theme {
    let name = "Midnight Mint"
    let identifier = "midnightMint"
    let description = "Calm, professional fintech"

    // MARK: - Dark Mode Colors

    var darkColors: ThemeColors {
        // Break up color initialization to help Swift compiler
        let bgColor = Color(hex: "0B0E11")
        let surfaceColor = Color(hex: "14181C")
        let surfaceElevatedColor = Color(hex: "1C2128")

        let primaryColor = Color(hex: "3BFFB4")
        let onPrimaryColor = Color(hex: "0B0E11")
        let accentColor = Color(hex: "14B8A6")

        let successColor = Color(hex: "10B981")
        let warningColor = Color(hex: "F59E0B")
        let errorColor = Color(hex: "EF4444")

        let textPrimaryColor = Color(hex: "3BFFB4")
        let textSecondaryColor = Color(hex: "14B8A6")
        let textTertiaryColor = Color(hex: "FFFFFF")

        let borderColor = Color(hex: "2A3138")
        let borderSubtleColor = Color(hex: "1C2128")

        let chartTertiaryColor = Color(hex: "6366F1")

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
        // Professional fintech daylight - calm and readable
        let bgColor = Color(hex: "F7FFFC")  // Subtle seafoam tint
        let surfaceColor = Color(hex: "FFFFFF")  // Pure white
        let surfaceElevatedColor = Color(hex: "FAFAFA")  // Slightly elevated

        let primaryColor = Color(hex: "14B8A6")  // Bright mint for accents
        let onPrimaryColor = Color(hex: "000000")  // Black on mint
        let accentColor = Color(hex: "0D9F89")  // Deep teal for accents

        let successColor = Color(hex: "059669")  // Readable green
        let warningColor = Color(hex: "D97706")  // Readable orange
        let errorColor = Color(hex: "DC2626")  // Readable red

        let textPrimaryColor = Color(hex: "0A7C6E")  // Deep teal (4.8:1 contrast)
        let textSecondaryColor = Color(hex: "0F766E")  // Darker teal (5.1:1 contrast)
        let textTertiaryColor = Color(hex: "1F2937")  // Charcoal (12:1 contrast)

        let borderColor = Color(hex: "E5E7EB")  // Light gray border
        let borderSubtleColor = Color(hex: "F3F4F6")  // Very light border

        let chartTertiaryColor = Color(hex: "6366F1")  // Indigo

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
