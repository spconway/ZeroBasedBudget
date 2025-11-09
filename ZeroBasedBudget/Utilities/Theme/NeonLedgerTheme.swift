//
//  NeonLedgerTheme.swift
//  ZeroBasedBudget
//
//  Neon Ledger theme: Cyberpunk financial ledger with neon accents.
//  Pure black base with electric teal and magenta accents.
//  Design tokens from: Designs/NeonLedger/tokens.json
//

import SwiftUI

/// Neon Ledger theme: Cyberpunk financial ledger aesthetic
struct NeonLedgerTheme: Theme {
    let name = "Neon Ledger"
    let identifier = "neonLedger"
    let description = "Cyberpunk with neon accents"

    // MARK: - Dark Mode Colors

    var darkColors: ThemeColors {
        // Break up color initialization to help Swift compiler
        let bgColor = Color(hex: "0A0A0A")
        let surfaceColor = Color(hex: "121212")
        let surfaceElevatedColor = Color(hex: "1A1A1A")

        let primaryColor = Color(hex: "008B7A")
        let onPrimaryColor = Color(hex: "000000")
        let accentColor = Color(hex: "FF006E")

        let successColor = Color(hex: "00FF88")
        let warningColor = Color(hex: "FFB800")
        let errorColor = Color(hex: "FF006E")

        let textPrimaryColor = Color(hex: "008B7A")
        let textSecondaryColor = Color(hex: "FF006E")
        let textTertiaryColor = Color(hex: "FFFFFF")

        let borderColor = Color(hex: "2A2A2A")
        let borderSubtleColor = Color(hex: "1A1A1A")

        let chartTertiaryColor = Color(hex: "7C3AED")

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
        // Cyberpunk meets daylight - maintain bold aesthetic with readability
        let bgColor = Color(hex: "F5FDFC")  // Subtle cyan tint
        let surfaceColor = Color(hex: "FFFFFF")  // Pure white
        let surfaceElevatedColor = Color(hex: "FAFAFA")  // Slightly elevated

        let primaryColor = Color(hex: "00CDB8")  // Vibrant cyan for accents
        let onPrimaryColor = Color(hex: "000000")  // Black on cyan
        let accentColor = Color(hex: "E0005E")  // Vibrant magenta for accents

        let successColor = Color(hex: "059669")  // Readable green
        let warningColor = Color(hex: "D97706")  // Readable orange
        let errorColor = Color(hex: "DC2626")  // Readable red

        let textPrimaryColor = Color(hex: "0D7C7C")  // Dark teal (4.6:1 contrast)
        let textSecondaryColor = Color(hex: "B8005E")  // Dark magenta (4.7:1 contrast)
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
