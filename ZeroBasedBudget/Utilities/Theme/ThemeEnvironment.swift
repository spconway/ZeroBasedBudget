//
//  ThemeEnvironment.swift
//  ZeroBasedBudget
//
//  SwiftUI Environment integration for theme system.
//  Provides @Environment(\.theme) access to current theme in all views.
//

import SwiftUI

// MARK: - Theme Environment Key

/// Environment key for theme access
private struct ThemeEnvironmentKey: EnvironmentKey {
    /// Default theme if none provided (Midnight Mint)
    static let defaultValue: Theme = MidnightMintTheme()
}

// MARK: - ThemeManager Environment Key

/// Environment key for ThemeManager access
private struct ThemeManagerEnvironmentKey: EnvironmentKey {
    /// Default is nil - must be provided by root
    static let defaultValue: ThemeManager? = nil
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

    /// Access ThemeManager from SwiftUI environment
    ///
    /// Usage in views:
    /// ```swift
    /// struct SettingsView: View {
    ///     @Environment(\.themeManager) private var themeManager
    ///
    ///     var body: some View {
    ///         Button("Change Theme") {
    ///             themeManager?.setTheme(identifier: "neonLedger")
    ///         }
    ///     }
    /// }
    /// ```
    var themeManager: ThemeManager? {
        get { self[ThemeManagerEnvironmentKey.self] }
        set { self[ThemeManagerEnvironmentKey.self] = newValue }
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

    /// Inject a ThemeManager into the SwiftUI environment
    /// - Parameter themeManager: ThemeManager to make available to child views
    /// - Returns: View with themeManager in environment
    func themeManager(_ themeManager: ThemeManager) -> some View {
        environment(\.themeManager, themeManager)
    }
}
