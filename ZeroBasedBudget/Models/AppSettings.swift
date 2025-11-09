//
//  AppSettings.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//

import Foundation
import SwiftData

/// Application-wide settings and preferences
/// Persisted using SwiftData for complex settings, @AppStorage for simple ones
@Model
final class AppSettings {
    /// Unique identifier (singleton pattern - only one instance should exist)
    var id: UUID

    /// Date the settings were created
    var createdDate: Date

    /// Last modified date
    var lastModifiedDate: Date

    /// Dark mode preference: "system", "light", or "dark"
    var colorSchemePreference: String

    /// Selected visual theme identifier (e.g., "midnightMint", "neonLedger", "ultravioletSlate")
    var selectedTheme: String

    /// Currency code (e.g., "USD", "EUR", "GBP")
    var currencyCode: String

    /// Date format preference
    var dateFormat: String

    /// Month start date (1-31)
    var monthStartDate: Int

    /// Enable notifications globally
    var notificationsEnabled: Bool

    /// Default notification schedule for new categories
    /// Options: "7-day", "2-day", "on-date", "custom"
    var defaultNotificationSchedule: String

    /// Number format preference (decimal/thousand separators)
    /// Options: "1,234.56", "1.234,56", "1 234,56"
    var numberFormat: String

    /// Allow negative category amounts (over-budget)
    var allowNegativeCategoryAmounts: Bool

    init(
        colorSchemePreference: String = "system",
        selectedTheme: String = "standard",
        currencyCode: String = "USD",
        dateFormat: String = "MM/DD/YYYY",
        monthStartDate: Int = 1,
        notificationsEnabled: Bool = true,
        defaultNotificationSchedule: String = "on-date",
        numberFormat: String = "1,234.56",
        allowNegativeCategoryAmounts: Bool = true
    ) {
        self.id = UUID()
        self.createdDate = Date()
        self.lastModifiedDate = Date()
        self.colorSchemePreference = colorSchemePreference
        self.selectedTheme = selectedTheme
        self.currencyCode = currencyCode
        self.dateFormat = dateFormat
        self.monthStartDate = monthStartDate
        self.notificationsEnabled = notificationsEnabled
        self.defaultNotificationSchedule = defaultNotificationSchedule
        self.numberFormat = numberFormat
        self.allowNegativeCategoryAmounts = allowNegativeCategoryAmounts
    }
}
