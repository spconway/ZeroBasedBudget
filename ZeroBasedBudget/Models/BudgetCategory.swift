//
//  BudgetCategory.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//

import Foundation
import SwiftData

@Model
final class BudgetCategory {
    @Attribute(.unique)
    var name: String
    var budgetedAmount: Decimal  // DEPRECATED: Use CategoryMonthlyBudget instead. Kept for migration.
    var categoryType: String  // "Fixed", "Variable", "Quarterly", "Income"
    var colorHex: String
    var dueDate: Date?  // DEPRECATED: Kept for backward compatibility. Use dueDayOfMonth instead.
    var dueDayOfMonth: Int?  // Day of month (1-31) for ZeroBudget-style recurring due dates
    var notificationID: UUID  // UUID for notification tracking
    var isLastDayOfMonth: Bool  // If true, due date is always last day of current month

    // Notification frequency settings
    var notify7DaysBefore: Bool
    var notify2DaysBefore: Bool
    var notifyOnDueDate: Bool
    var notifyCustomDays: Bool
    var customDaysCount: Int  // Number of days before due date for custom notification

    // Notification delivery time override (nil = use global setting from AppSettings)
    var notificationTimeHour: Int?  // Hour (0-23), nil = use global setting
    var notificationTimeMinute: Int?  // Minute (0-59), nil = use global setting

    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction] = []

    @Relationship(deleteRule: .cascade, inverse: \CategoryMonthlyBudget.category)
    var monthlyBudgets: [CategoryMonthlyBudget] = []

    /// The category group this budget category belongs to (optional for backward compatibility)
    var categoryGroup: CategoryGroup?

    /// Sort order for displaying categories within group (lower values appear first)
    /// Default 0 allows existing categories to work - migration assigns proper values
    var sortOrder: Int = 0

    /// Date the category was created (optional for backwards compatibility with existing records)
    /// Used for "Default" sort order - categories sorted by creation date
    var createdDate: Date?

    init(name: String, budgetedAmount: Decimal, categoryType: String, colorHex: String, dueDate: Date? = nil, categoryGroup: CategoryGroup? = nil) {
        self.name = name
        self.budgetedAmount = budgetedAmount
        self.categoryType = categoryType
        self.colorHex = colorHex
        self.dueDate = dueDate
        self.categoryGroup = categoryGroup
        self.dueDayOfMonth = nil  // Will be set by UI for new categories
        self.notificationID = UUID()
        self.isLastDayOfMonth = false

        // Default notification settings: notify on due date only
        self.notify7DaysBefore = false
        self.notify2DaysBefore = false
        self.notifyOnDueDate = true
        self.notifyCustomDays = false
        self.customDaysCount = 1

        // Default: use global notification time setting (nil = use global)
        self.notificationTimeHour = nil
        self.notificationTimeMinute = nil

        // Track creation date for default sort order
        self.createdDate = Date()
    }

    // MARK: - Computed Properties

    /// Returns the effective due date calculated from dueDayOfMonth or legacy dueDate
    /// Priority order:
    /// 1. If isLastDayOfMonth = true → last day of current month
    /// 2. If dueDayOfMonth is set → that day in current month
    /// 3. If dueDate is set (legacy) → extract day and use in current month
    /// 4. Otherwise → nil
    var effectiveDueDate: Date? {
        // Special case: last day of month
        if isLastDayOfMonth {
            return lastDayOfCurrentMonth()
        }

        // Prefer new dueDayOfMonth field
        if let dayOfMonth = dueDayOfMonth {
            return dateFromDayOfMonth(dayOfMonth)
        }

        // Backward compatibility: extract day from legacy dueDate
        if let legacyDate = dueDate {
            let calendar = Calendar.current
            let day = calendar.component(.day, from: legacyDate)
            return dateFromDayOfMonth(day)
        }

        return nil
    }

    // MARK: - Helper Methods

    /// Calculate a Date for the given day-of-month in the current month
    /// Handles edge cases (e.g., 31st day in 30-day month)
    private func dateFromDayOfMonth(_ day: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()

        // Get current month and year
        let monthComponents = calendar.dateComponents([.year, .month], from: now)

        // Get the maximum day in this month
        guard let firstDayOfMonth = calendar.date(from: monthComponents),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return now
        }

        let maxDay = range.upperBound - 1 // upperBound is exclusive, so subtract 1

        // Clamp day to valid range (1 to last day of month)
        let clampedDay = min(max(day, 1), maxDay)

        // Create date components with clamped day
        var components = monthComponents
        components.day = clampedDay
        components.hour = 0
        components.minute = 0
        components.second = 0

        // Create date - should always succeed now with clamped value
        return calendar.date(from: components) ?? now
    }

    /// Calculate the last day of the current month
    func lastDayOfCurrentMonth() -> Date {
        let calendar = Calendar.current
        let now = Date()

        // Get the current month and year
        let components = calendar.dateComponents([.year, .month], from: now)

        // Get the range of days in this month
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return now
        }

        // Create date for last day of month
        var lastDayComponents = components
        lastDayComponents.day = range.count  // Last day number (28, 29, 30, or 31)
        lastDayComponents.hour = 0
        lastDayComponents.minute = 0
        lastDayComponents.second = 0

        return calendar.date(from: lastDayComponents) ?? now
    }
}
