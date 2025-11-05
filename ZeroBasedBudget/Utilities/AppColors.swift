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

/// Extended Color initializer for hex colors (already defined in BudgetPlanningView)
/// This is kept here for reference but the implementation stays in BudgetPlanningView
/// to avoid duplication
extension Color {
    /// Creates a color from a hex string
    /// Supports #RGB, #RRGGBB, and #RRGGBBAA formats
    /// Note: Implementation is in BudgetPlanningView.swift to avoid duplication
    static func fromHex(_ hex: String) -> Color {
        return Color(hex: hex)
    }
}
