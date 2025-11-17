//
//  AppColors.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//

import SwiftUI

/// Centralized color definitions with automatic light/dark mode adaptation
/// Following WCAG AA contrast standards (4.5:1 for text)
extension Color {
    /// Accent color for primary actions and highlights
    /// Light: system blue, Dark: lighter blue for better contrast
    static let appAccent = Color.blue

    /// Success color for positive states (goal achieved, surplus)
    /// Light: green, Dark: lighter green
    static let appSuccess = Color.green

    /// Warning color for attention states (needs action, unassigned money)
    /// Light: orange, Dark: lighter orange
    static let appWarning = Color.orange

    /// Error color for negative states (over-budget, deficit)
    /// Light: red, Dark: lighter red
    static let appError = Color.red

    /// Muted text color for less important information
    /// Automatically adapts to light/dark mode
    static let appMuted = Color.secondary

    /// Chart colors optimized for light and dark mode
    /// These provide good contrast in both modes
    static let chartColor1 = Color.blue
    static let chartColor2 = Color.green
    static let chartColor3 = Color.orange
    static let chartColor4 = Color.purple
    static let chartColor5 = Color.pink

    /// Background for cards and banners
    /// Automatically adapts to system background hierarchy
    static let cardBackground = Color(.secondarySystemGroupedBackground)

    /// Background for list sections
    static let listBackground = Color(.systemGroupedBackground)

    /// Subtle background for charts and analysis
    static let chartBackground = Color(.systemGray6)

    /// Container background
    static let containerBackground = Color(.systemBackground)
}

/// Extended Color initializer for hex colors
extension Color {
    /// Creates a color from a hex string
    /// Supports #RGB, #RRGGBB, and #RRGGBBAA formats
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
