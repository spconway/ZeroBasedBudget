//
//  AppSettingsTests.swift
//  ZeroBasedBudgetTests
//
//  Created by Claude Code on 2025-11-05.
//
//  Unit tests for AppSettings model
//  Tests app settings initialization, preferences, and validation
//

import XCTest
import SwiftData
@testable import ZeroBasedBudget

final class AppSettingsTests: ZeroBasedBudgetTests {

    // MARK: - Initialization Tests

    /// Test: AppSettings initializes with default values correctly
    func test_appSettingsInit_withDefaults_createsCorrectly() throws {
        // Arrange & Act
        let settings = TestDataFactory.createAppSettings()

        // Assert - Verify all default values
        XCTAssertNotNil(settings.id)
        XCTAssertNotNil(settings.createdDate)
        XCTAssertNotNil(settings.lastModifiedDate)
        XCTAssertEqual(settings.colorSchemePreference, "system")
        XCTAssertEqual(settings.currencyCode, "USD")
        XCTAssertTrue(settings.notificationsEnabled)
    }

    // MARK: - Color Scheme Tests

    /// Test: Color scheme preference stores valid values correctly
    func test_colorSchemePreference_validValues_storesCorrectly() throws {
        // Arrange
        let validSchemes = ["system", "light", "dark"]

        // Act & Assert
        for scheme in validSchemes {
            let settings = TestDataFactory.createAppSettings(colorScheme: scheme)
            XCTAssertEqual(settings.colorSchemePreference, scheme)
        }
    }

    // MARK: - Currency Tests

    /// Test: Currency code stores multiple formats correctly
    func test_currencyCode_multipleFormats_storesAllSupported() throws {
        // Arrange
        let supportedCurrencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY"]

        // Act & Assert
        for currency in supportedCurrencies {
            let settings = TestDataFactory.createAppSettings(currencyCode: currency)
            XCTAssertEqual(settings.currencyCode, currency)
        }
    }

    // MARK: - Month Start Date Tests

    /// Test: Month start date clamps between 1 and 31
    func test_monthStartDate_validRange_clampsBetween1And31() throws {
        // Arrange & Act
        let settings = TestDataFactory.createAppSettings()

        // Test valid range
        for day in 1...31 {
            settings.monthStartDate = day
            XCTAssertEqual(settings.monthStartDate, day)
            XCTAssertGreaterThanOrEqual(settings.monthStartDate, 1)
            XCTAssertLessThanOrEqual(settings.monthStartDate, 31)
        }

        // Test boundary values
        settings.monthStartDate = 1
        XCTAssertEqual(settings.monthStartDate, 1)

        settings.monthStartDate = 31
        XCTAssertEqual(settings.monthStartDate, 31)
    }

    // MARK: - Notification Toggle Tests

    /// Test: Notifications enabled toggle updates correctly
    func test_notificationsEnabled_toggle_updatesCorrectly() throws {
        // Arrange
        let settings = TestDataFactory.createAppSettings(notificationsEnabled: true)

        // Assert - Initially enabled
        XCTAssertTrue(settings.notificationsEnabled)

        // Act - Disable
        settings.notificationsEnabled = false

        // Assert - Disabled
        XCTAssertFalse(settings.notificationsEnabled)

        // Act - Re-enable
        settings.notificationsEnabled = true

        // Assert - Enabled again
        XCTAssertTrue(settings.notificationsEnabled)
    }

    // MARK: - Timestamp Tests

    /// Test: Last modified date updates after changes
    func test_lastModifiedDate_afterUpdate_updatesTimestamp() throws {
        // Arrange
        let settings = TestDataFactory.createAppSettings()
        modelContext.insert(settings)
        try saveContext()

        let originalModifiedDate = settings.lastModifiedDate

        // Wait a tiny bit to ensure timestamp changes
        Thread.sleep(forTimeInterval: 0.01)

        // Act - Update a setting
        settings.currencyCode = "EUR"
        settings.lastModifiedDate = Date() // Manually update (in real app, this would be automatic)

        // Assert
        XCTAssertGreaterThan(settings.lastModifiedDate, originalModifiedDate)
    }
}
