//
//  ThemeEnvironment.swift
//  ZeroBasedBudget
//
//  SwiftUI Environment integration for theme system.
//  Provides @Environment(\.theme) access to current theme in all views.
//

import SwiftUI

// MARK: - Environment Key

/// Environment key for theme access
private struct ThemeEnvironmentKey: EnvironmentKey {
    /// Default theme if none provided (Midnight Mint)
    static let defaultValue: Theme = MidnightMintTheme()
}

// MARK: - Environment Values Extension

extension EnvironmentValues {
    /// Access current theme from SwiftUI environment
    ///
    /// Usage in views:
    /// ```swift
    /// struct MyView: View {
    ///     @Environment(\.theme) private var theme
    ///
    ///     var body: some View {
    ///         Text("Hello")
    ///             .foregroundColor(theme.colors.textPrimary)
    ///             .background(theme.colors.surface)
    ///     }
    /// }
    /// ```
    var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Extension for Theme Injection

extension View {
    /// Inject a theme into the SwiftUI environment
    /// - Parameter theme: Theme to make available to child views
    /// - Returns: View with theme in environment
    func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
