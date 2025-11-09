//
//  ThemeManager.swift
//  ZeroBasedBudget
//
//  Centralized theme management with persistence and SwiftUI integration.
//  Manages current theme state and handles loading/saving user preferences.
//

import SwiftUI
import SwiftData

/// Observable theme manager for app-wide theme state
@Observable
final class ThemeManager {
    // MARK: - Properties

    /// Current active theme
    var currentTheme: Theme {
        didSet {
            // Save preference when theme changes
            saveThemePreference()
        }
    }

    /// Reference to AppSettings for persistence
    private var appSettings: AppSettings?

    /// ModelContext for SwiftData operations
    private var modelContext: ModelContext?

    // MARK: - Theme Registry

    /// All available themes
    static let availableThemes: [Theme] = [
        StandardTheme(),
        NeonLedgerTheme(),
        MidnightMintTheme(),
        UltravioletSlateTheme()
    ]

    /// Get theme by identifier
    static func theme(for identifier: String) -> Theme {
        availableThemes.first { $0.identifier == identifier } ?? StandardTheme()
    }

    // MARK: - Initialization

    /// Initialize with default theme (no persistence)
    init() {
        self.currentTheme = StandardTheme()
        self.appSettings = nil
        self.modelContext = nil
    }

    /// Initialize with AppSettings and ModelContext for persistence
    /// - Parameters:
    ///   - appSettings: AppSettings instance to read/write theme preference
    ///   - modelContext: ModelContext for saving changes
    init(appSettings: AppSettings, modelContext: ModelContext) {
        self.appSettings = appSettings
        self.modelContext = modelContext

        // Load saved theme preference
        let savedIdentifier = appSettings.selectedTheme
        self.currentTheme = ThemeManager.theme(for: savedIdentifier)
    }

    // MARK: - Public Methods

    /// Set the current theme and persist the change
    /// - Parameter theme: The theme to apply
    func setTheme(_ theme: Theme) {
        currentTheme = theme
    }

    /// Set theme by identifier
    /// - Parameter identifier: Theme identifier string
    func setTheme(identifier: String) {
        let theme = ThemeManager.theme(for: identifier)
        setTheme(theme)
    }

    // MARK: - Private Methods

    /// Save current theme preference to AppSettings
    private func saveThemePreference() {
        guard let appSettings = appSettings,
              let modelContext = modelContext else {
            return
        }

        // Update AppSettings
        appSettings.selectedTheme = currentTheme.identifier
        appSettings.lastModifiedDate = Date()

        // Save to SwiftData
        do {
            try modelContext.save()
        } catch {
            print("Error saving theme preference: \(error.localizedDescription)")
        }
    }
}

// MARK: - Theme Type Enum

/// Enum for type-safe theme selection in UI
enum ThemeType: String, CaseIterable, Identifiable {
    case standard = "standard"
    case neonLedger = "neonLedger"
    case midnightMint = "midnightMint"
    case ultravioletSlate = "ultravioletSlate"

    var id: String { rawValue }

    /// Get Theme instance for this type
    var theme: Theme {
        switch self {
        case .standard:
            return StandardTheme()
        case .neonLedger:
            return NeonLedgerTheme()
        case .midnightMint:
            return MidnightMintTheme()
        case .ultravioletSlate:
            return UltravioletSlateTheme()
        }
    }

    /// Human-readable name
    var name: String {
        theme.name
    }

    /// Theme description
    var description: String {
        theme.description
    }
}
