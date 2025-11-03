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
    var budgetedAmount: Decimal
    var categoryType: String  // "Fixed", "Variable", "Quarterly", "Income"
    var colorHex: String
    var dueDate: Date?  // Optional due date for expense tracking
    var notificationID: UUID  // UUID for notification tracking
    var isLastDayOfMonth: Bool  // If true, due date is always last day of current month

    // Notification frequency settings
    var notify7DaysBefore: Bool
    var notify2DaysBefore: Bool
    var notifyOnDueDate: Bool
    var notifyCustomDays: Bool
    var customDaysCount: Int  // Number of days before due date for custom notification

    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction] = []

    init(name: String, budgetedAmount: Decimal, categoryType: String, colorHex: String, dueDate: Date? = nil) {
        self.name = name
        self.budgetedAmount = budgetedAmount
        self.categoryType = categoryType
        self.colorHex = colorHex
        self.dueDate = dueDate
        self.notificationID = UUID()
        self.isLastDayOfMonth = false

        // Default notification settings: notify on due date only
        self.notify7DaysBefore = false
        self.notify2DaysBefore = false
        self.notifyOnDueDate = true
        self.notifyCustomDays = false
        self.customDaysCount = 1
    }

    // MARK: - Computed Properties

    /// Returns the effective due date - either the stored date or the last day of the current month
    var effectiveDueDate: Date? {
        guard dueDate != nil else { return nil }

        if isLastDayOfMonth {
            return lastDayOfCurrentMonth()
        } else {
            return dueDate
        }
    }

    // MARK: - Helper Methods

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
