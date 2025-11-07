//
//  Theme.swift
//  ZeroBasedBudget
//
//  Theme protocol and supporting types for visual theming system.
//  Defines the contract for all app themes with colors, typography, spacing, and radius.
//

import SwiftUI

// MARK: - Theme Protocol

/// Protocol defining a complete visual theme for the app
protocol Theme {
    /// Human-readable theme name (e.g., "Midnight Mint")
    var name: String { get }

    /// Unique identifier for persistence (e.g., "midnightMint")
    var identifier: String { get }

    /// Theme description for UI display
    var description: String { get }

    /// Light mode color palette
    var lightColors: ThemeColors { get }

    /// Dark mode color palette
    var darkColors: ThemeColors { get }

    /// Get colors for specific color scheme
    func colors(for colorScheme: ColorScheme) -> ThemeColors

    /// Typography scale and weights
    var typography: ThemeTypography { get }

    /// Spacing scale for layout consistency
    var spacing: ThemeSpacing { get }

    /// Border radius scale for consistent roundness
    var radius: ThemeRadius { get }
}

// MARK: - Theme Protocol Extension

extension Theme {
    /// Default implementation returns appropriate colors based on color scheme
    func colors(for colorScheme: ColorScheme) -> ThemeColors {
        colorScheme == .dark ? darkColors : lightColors
    }
}

// MARK: - Theme Colors

/// Complete color palette for a theme
struct ThemeColors {
    // MARK: Base Colors

    /// Primary background color (deepest layer)
    let background: Color

    /// Surface color for cards and elevated content
    let surface: Color

    /// Further elevated surface (e.g., modals, popovers)
    let surfaceElevated: Color

    // MARK: Brand Colors

    /// Primary brand color (main accent, CTAs)
    let primary: Color

    /// Text/icon color on primary background
    let onPrimary: Color

    /// Secondary accent color
    let accent: Color

    // MARK: Semantic Colors

    /// Success color (income, positive states)
    let success: Color

    /// Warning color (approaching limits)
    let warning: Color

    /// Error color (expenses, overspending, errors)
    let error: Color

    // MARK: Text Colors

    /// Primary text color (high emphasis)
    let textPrimary: Color

    /// Secondary text color (medium emphasis)
    let textSecondary: Color

    /// Tertiary text color (low emphasis, hints)
    let textTertiary: Color

    // MARK: Border Colors

    /// Standard border color for dividers and outlines
    let border: Color

    /// Subtle border for low-emphasis separators
    let borderSubtle: Color

    // MARK: Component-Specific Colors

    /// Ready to Assign banner background
    let readyToAssignBackground: Color

    /// Ready to Assign banner text
    let readyToAssignText: Color

    /// Ready to Assign banner border (optional)
    let readyToAssignBorder: Color

    // MARK: Chart Colors

    /// Primary chart color
    let chartPrimary: Color

    /// Secondary chart color
    let chartSecondary: Color

    /// Tertiary chart color
    let chartTertiary: Color

    // MARK: Progress Colors

    /// Progress bar green (0-75% spent)
    let progressGreen: Color

    /// Progress bar yellow (75-100% spent)
    let progressYellow: Color

    /// Progress bar red (>100% spent)
    let progressRed: Color
}

// MARK: - Theme Typography

/// Typography scale for consistent text styling
struct ThemeTypography {
    /// Extra large title (e.g., main headers)
    let largeTitle: Font

    /// Standard title
    let title: Font

    /// Section headers and prominent labels
    let headline: Font

    /// Body text (default)
    let body: Font

    /// Small body text
    let callout: Font

    /// Caption text (timestamps, hints)
    let caption: Font

    /// Fine print (legal, secondary info)
    let footnote: Font
}

// MARK: - Theme Spacing

/// Spacing scale for consistent layout margins and padding
struct ThemeSpacing {
    /// Extra small spacing (4pt)
    let xs: CGFloat

    /// Small spacing (8pt)
    let sm: CGFloat

    /// Medium spacing (16pt)
    let md: CGFloat

    /// Large spacing (24pt)
    let lg: CGFloat

    /// Extra large spacing (32pt)
    let xl: CGFloat

    /// Extra extra large spacing (48pt)
    let xxl: CGFloat
}

// MARK: - Theme Radius

/// Border radius scale for consistent roundness
struct ThemeRadius {
    /// Small radius (4pt - subtle rounding)
    let sm: CGFloat

    /// Medium radius (8pt - standard cards)
    let md: CGFloat

    /// Large radius (12pt - prominent cards)
    let lg: CGFloat

    /// Extra large radius (20pt - banners, large components)
    let xl: CGFloat

    /// Circular (9999pt - pills, avatars)
    let full: CGFloat
}
