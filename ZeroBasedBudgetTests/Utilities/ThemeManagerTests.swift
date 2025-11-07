//
//  ThemeManagerTests.swift
//  ZeroBasedBudgetTests
//
//  Unit tests for ThemeManager class
//  Tests theme initialization, switching, persistence, and registry
//

import XCTest
import SwiftUI
import SwiftData
@testable import ZeroBasedBudget

final class ThemeManagerTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        // Create in-memory container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: AppSettings.self,
            configurations: config
        )
        modelContext = await modelContainer.mainContext
    }

    override func tearDown() {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - Initialization Tests

    func testThemeManagerDefaultInit() {
        // When: Creating ThemeManager without parameters
        let manager = ThemeManager()

        // Then: Should use default Midnight Mint theme
        XCTAssertEqual(manager.currentTheme.identifier, "midnightMint")
        XCTAssertEqual(manager.currentTheme.name, "Midnight Mint")
    }

    func testThemeManagerInitWithSettings() {
        // Given: AppSettings with default theme
        let settings = AppSettings()
        modelContext.insert(settings)

        // When: Creating ThemeManager with settings
        let manager = ThemeManager(appSettings: settings, modelContext: modelContext)

        // Then: Should load theme from settings
        XCTAssertEqual(manager.currentTheme.identifier, settings.selectedTheme)
        XCTAssertEqual(manager.currentTheme.identifier, "midnightMint") // Default
    }

    func testThemeManagerInitWithCustomTheme() {
        // Given: AppSettings with custom theme selection
        let settings = AppSettings(selectedTheme: "midnightMint")
        modelContext.insert(settings)

        // When: Creating ThemeManager with settings
        let manager = ThemeManager(appSettings: settings, modelContext: modelContext)

        // Then: Should load specified theme
        XCTAssertEqual(manager.currentTheme.identifier, "midnightMint")
    }

    func testThemeManagerFallbackForInvalidTheme() {
        // Given: AppSettings with invalid theme identifier
        let settings = AppSettings(selectedTheme: "invalidTheme")
        modelContext.insert(settings)

        // When: Creating ThemeManager with settings
        let manager = ThemeManager(appSettings: settings, modelContext: modelContext)

        // Then: Should fall back to default Midnight Mint theme
        XCTAssertEqual(manager.currentTheme.identifier, "midnightMint")
    }

    // MARK: - Theme Switching Tests

    func testSetThemeByInstance() {
        // Given: ThemeManager with default theme
        let manager = ThemeManager()
        let newTheme = MidnightMintTheme()

        // When: Setting theme by instance
        manager.setTheme(newTheme)

        // Then: Current theme should update
        XCTAssertEqual(manager.currentTheme.identifier, "midnightMint")
    }

    func testSetThemeByIdentifier() {
        // Given: ThemeManager with default theme
        let manager = ThemeManager()

        // When: Setting theme by identifier
        manager.setTheme(identifier: "midnightMint")

        // Then: Current theme should update
        XCTAssertEqual(manager.currentTheme.identifier, "midnightMint")
    }

    func testSetThemeByInvalidIdentifier() {
        // Given: ThemeManager with default theme
        let manager = ThemeManager()

        // When: Setting theme with invalid identifier
        manager.setTheme(identifier: "nonExistentTheme")

        // Then: Should fall back to default theme
        XCTAssertEqual(manager.currentTheme.identifier, "midnightMint")
    }

    // MARK: - Persistence Tests

    func testThemePersistenceOnChange() throws {
        // Given: ThemeManager with AppSettings
        let settings = AppSettings()
        modelContext.insert(settings)
        let manager = ThemeManager(appSettings: settings, modelContext: modelContext)

        // Record initial theme
        let initialTheme = settings.selectedTheme

        // When: Changing theme
        let newTheme = MidnightMintTheme()
        manager.setTheme(newTheme)

        // Then: AppSettings should be updated
        XCTAssertEqual(settings.selectedTheme, "midnightMint")
        XCTAssertNotEqual(settings.lastModifiedDate, settings.createdDate) // Should update timestamp
    }

    func testThemePersistenceAcrossSessions() throws {
        // Given: ThemeManager that sets a theme
        let settings = AppSettings()
        modelContext.insert(settings)
        var manager = ThemeManager(appSettings: settings, modelContext: modelContext)

        // When: Setting theme and creating new manager (simulating app restart)
        manager.setTheme(identifier: "midnightMint")
        try modelContext.save()

        // Simulate app restart by creating new manager
        manager = ThemeManager(appSettings: settings, modelContext: modelContext)

        // Then: Theme should persist
        XCTAssertEqual(manager.currentTheme.identifier, "midnightMint")
    }

    // MARK: - Theme Registry Tests

    func testThemeRegistryContainsMidnightMint() {
        // When: Accessing available themes
        let themes = ThemeManager.availableThemes

        // Then: Should contain Midnight Mint
        XCTAssertTrue(themes.contains { $0.identifier == "midnightMint" })
    }

    func testThemeRegistryGetByIdentifier() {
        // When: Getting theme by valid identifier
        let theme = ThemeManager.theme(for: "midnightMint")

        // Then: Should return correct theme
        XCTAssertEqual(theme.identifier, "midnightMint")
        XCTAssertEqual(theme.name, "Midnight Mint")
    }

    func testThemeRegistryGetByInvalidIdentifier() {
        // When: Getting theme by invalid identifier
        let theme = ThemeManager.theme(for: "nonExistentTheme")

        // Then: Should return default theme
        XCTAssertEqual(theme.identifier, "midnightMint")
    }

    // MARK: - Theme Type Enum Tests

    func testThemeTypeAllCases() {
        // When: Accessing all theme types
        let types = ThemeType.allCases

        // Then: Should contain Midnight Mint (and only that for now)
        XCTAssertEqual(types.count, 1)
        XCTAssertEqual(types.first?.rawValue, "midnightMint")
    }

    func testThemeTypeGetTheme() {
        // When: Getting theme from ThemeType
        let themeType = ThemeType.midnightMint
        let theme = themeType.theme

        // Then: Should return correct theme
        XCTAssertEqual(theme.identifier, "midnightMint")
    }

    func testThemeTypeNameAndDescription() {
        // When: Accessing theme type properties
        let themeType = ThemeType.midnightMint

        // Then: Should have correct name and description
        XCTAssertEqual(themeType.name, "Midnight Mint")
        XCTAssertEqual(themeType.description, "Calm, professional fintech")
    }

    // MARK: - Individual Theme Tests

    func testNeonLedgerThemeProperties() {
        // When: Creating Neon Ledger theme
        let theme = NeonLedgerTheme()

        // Then: Should have correct properties
        XCTAssertEqual(theme.name, "Neon Ledger")
        XCTAssertEqual(theme.identifier, "neonLedger")
        XCTAssertEqual(theme.description, "Cyberpunk with neon accents")
        XCTAssertNotNil(theme.colors)
        XCTAssertNotNil(theme.typography)
        XCTAssertNotNil(theme.spacing)
        XCTAssertNotNil(theme.radius)
    }

    func testMidnightMintThemeProperties() {
        // When: Creating Midnight Mint theme
        let theme = MidnightMintTheme()

        // Then: Should have correct properties
        XCTAssertEqual(theme.name, "Midnight Mint")
        XCTAssertEqual(theme.identifier, "midnightMint")
        XCTAssertEqual(theme.description, "Calm, professional fintech")
        XCTAssertNotNil(theme.colors)
        XCTAssertNotNil(theme.typography)
        XCTAssertNotNil(theme.spacing)
        XCTAssertNotNil(theme.radius)
    }

    func testUltravioletSlateThemeProperties() {
        // When: Creating Ultraviolet Slate theme
        let theme = UltravioletSlateTheme()

        // Then: Should have correct properties
        XCTAssertEqual(theme.name, "Ultraviolet Slate")
        XCTAssertEqual(theme.identifier, "ultravioletSlate")
        XCTAssertEqual(theme.description, "Bold, energetic design")
        XCTAssertNotNil(theme.colors)
        XCTAssertNotNil(theme.typography)
        XCTAssertNotNil(theme.spacing)
        XCTAssertNotNil(theme.radius)
    }

    func testThemeRegistryContainsAllThemes() {
        // When: Accessing available themes
        let themes = ThemeManager.availableThemes

        // Then: Should contain all three themes
        XCTAssertEqual(themes.count, 3)
        XCTAssertTrue(themes.contains { $0.identifier == "neonLedger" })
        XCTAssertTrue(themes.contains { $0.identifier == "midnightMint" })
        XCTAssertTrue(themes.contains { $0.identifier == "ultravioletSlate" })
    }

    func testThemeTypeAllCasesContainsAllThemes() {
        // When: Accessing all theme types
        let types = ThemeType.allCases

        // Then: Should contain all three themes
        XCTAssertEqual(types.count, 3)
        XCTAssertTrue(types.contains(.neonLedger))
        XCTAssertTrue(types.contains(.midnightMint))
        XCTAssertTrue(types.contains(.ultravioletSlate))
    }

    func testThemeManagerCanSwitchBetweenAllThemes() {
        // Given: ThemeManager with default theme
        let manager = ThemeManager()

        // When: Switching between all themes
        manager.setTheme(identifier: "neonLedger")
        XCTAssertEqual(manager.currentTheme.identifier, "neonLedger")

        manager.setTheme(identifier: "midnightMint")
        XCTAssertEqual(manager.currentTheme.identifier, "midnightMint")

        manager.setTheme(identifier: "ultravioletSlate")
        XCTAssertEqual(manager.currentTheme.identifier, "ultravioletSlate")
    }

    // MARK: - Color Hex Extension Tests

    func testColorHexInit6Digits() {
        // When: Creating color from 6-digit hex
        let color = Color(hex: "FF0000")

        // Then: Should create red color
        // Note: Cannot directly test Color equality, but we can test it doesn't crash
        XCTAssertNotNil(color)
    }

    func testColorHexInit8Digits() {
        // When: Creating color from 8-digit hex (RGBA)
        let color = Color(hex: "FF0000FF")

        // Then: Should create red color with full opacity
        XCTAssertNotNil(color)
    }

    func testColorHexInitWithHashSymbol() {
        // When: Creating color from hex with # prefix
        let color = Color(hex: "#00FF00")

        // Then: Should create green color
        XCTAssertNotNil(color)
    }

    func testColorHexInitInvalid() {
        // When: Creating color from invalid hex
        let color = Color(hex: "invalid")

        // Then: Should create black color (default)
        XCTAssertNotNil(color)
    }
}
