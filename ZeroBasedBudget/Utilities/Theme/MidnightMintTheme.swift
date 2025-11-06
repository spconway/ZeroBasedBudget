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

    let colors = ThemeColors(
        // MARK: Base Colors
        background: Color(hex: "0B0E11"),        // Blue-tinted near-black
        surface: Color(hex: "14181C"),           // Elevated surface
        surfaceElevated: Color(hex: "1C2128"),   // Further elevated (modals)

        // MARK: Brand Colors
        primary: Color(hex: "3BFFB4"),           // Seafoam mint
        onPrimary: Color(hex: "0B0E11"),         // Dark text on mint
        accent: Color(hex: "14B8A6"),            // Soft teal

        // MARK: Semantic Colors
        success: Color(hex: "10B981"),           // Pine green (income)
        warning: Color(hex: "F59E0B"),           // Warm orange
        error: Color(hex: "EF4444"),             // Coral red (expenses)

        // MARK: Text Colors
        textPrimary: Color(hex: "FFFFFF"),       // White text
        textSecondary: Color(hex: "9CA3AF"),     // Gray text (muted)
        textTertiary: Color(hex: "6B7280"),      // Subtle gray (low emphasis)

        // MARK: Border Colors
        border: Color(hex: "2A3138"),            // Subtle borders
        borderSubtle: Color(hex: "1C2128"),      // Very subtle separators

        // MARK: Ready to Assign Banner
        readyToAssignBackground: Color(hex: "3BFFB4"),  // Seafoam mint
        readyToAssignText: Color(hex: "0B0E11"),        // Dark text on mint
        readyToAssignBorder: Color(hex: "14B8A6"),      // Teal border

        // MARK: Chart Colors
        chartPrimary: Color(hex: "3BFFB4"),      // Mint (budgeted)
        chartSecondary: Color(hex: "14B8A6"),    // Teal (actual)
        chartTertiary: Color(hex: "6366F1"),     // Indigo (alternate)

        // MARK: Progress Colors
        progressGreen: Color(hex: "10B981"),     // Pine green (0-75%)
        progressYellow: Color(hex: "F59E0B"),    // Warm orange (75-100%)
        progressRed: Color(hex: "EF4444")        // Coral red (>100%)
    )

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
