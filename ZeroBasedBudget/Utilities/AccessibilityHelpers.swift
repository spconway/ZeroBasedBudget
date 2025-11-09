//
//  AccessibilityHelpers.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//

import Foundation

/// Accessibility helpers for VoiceOver and other assistive technologies
enum AccessibilityHelpers {

    // MARK: - Currency Accessibility

    /// Creates VoiceOver-friendly label for currency amount
    /// Example: "$1,234.56" -> "1,234 dollars and 56 cents"
    static func currencyLabel(for amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "zero dollars"
    }

    /// Creates VoiceOver-friendly hint for currency input
    static func currencyInputHint() -> String {
        "Enter an amount in dollars and cents"
    }

    // MARK: - Transaction Accessibility

    /// Creates VoiceOver label for transaction row
    static func transactionLabel(
        description: String,
        amount: Decimal,
        type: String,
        date: Date,
        category: String?
    ) -> String {
        let amountLabel = currencyLabel(for: amount)
        let dateLabel = Self.dateLabel(for: date)
        let categoryLabel = category ?? "Uncategorized"

        return "\(type) transaction: \(description), \(amountLabel), \(categoryLabel), \(dateLabel)"
    }

    /// Creates VoiceOver hint for transaction row
    static func transactionHint() -> String {
        "Swipe left to edit or delete"
    }

    // MARK: - Category Accessibility

    /// Creates VoiceOver label for category row
    static func categoryLabel(
        name: String,
        budgetedAmount: Decimal,
        type: String
    ) -> String {
        let amountLabel = currencyLabel(for: budgetedAmount)
        return "\(type) category: \(name), budgeted \(amountLabel)"
    }

    /// Creates VoiceOver hint for category row
    static func categoryHint() -> String {
        "Swipe left to edit or delete"
    }

    // MARK: - Budget Analysis Accessibility

    /// Creates VoiceOver label for category comparison
    static func comparisonLabel(
        categoryName: String,
        budgeted: Decimal,
        actual: Decimal,
        difference: Decimal,
        percentageUsed: Double
    ) -> String {
        let budgetedLabel = currencyLabel(for: budgeted)
        let actualLabel = currencyLabel(for: actual)
        let diffLabel = currencyLabel(for: abs(difference))
        let status = difference >= 0 ? "under budget" : "over budget"
        let percentLabel = String(format: "%.1f percent", percentageUsed * 100)

        return "\(categoryName): budgeted \(budgetedLabel), actual \(actualLabel), \(diffLabel) \(status), \(percentLabel) used"
    }

    /// Creates VoiceOver label for summary card
    static func summaryCardLabel(
        title: String,
        amount: Decimal
    ) -> String {
        let amountLabel = currencyLabel(for: amount)
        return "\(title): \(amountLabel)"
    }

    // MARK: - Date Accessibility

    /// Creates VoiceOver-friendly label for date
    static func dateLabel(for date: Date) -> String {
        return DateFormatHelpers.accessibilityDateLabel(for: date)
    }

    /// Creates VoiceOver-friendly label for month
    static func monthLabel(for date: Date) -> String {
        return DateFormatHelpers.accessibilityMonthLabel(for: date)
    }

    // MARK: - Button Accessibility

    /// Creates VoiceOver label for add button
    static func addButtonLabel(for item: String) -> String {
        "Add \(item)"
    }

    /// Creates VoiceOver label for delete button
    static func deleteButtonLabel(for item: String) -> String {
        "Delete \(item)"
    }

    /// Creates VoiceOver label for edit button
    static func editButtonLabel(for item: String) -> String {
        "Edit \(item)"
    }

    /// Creates VoiceOver label for save button
    static func saveButtonLabel() -> String {
        "Save changes"
    }

    /// Creates VoiceOver label for cancel button
    static func cancelButtonLabel() -> String {
        "Cancel and dismiss"
    }

    // MARK: - Navigation Accessibility

    /// Creates VoiceOver label for month navigation
    static func monthNavigationLabel(direction: String, currentMonth: Date) -> String {
        let monthName = monthLabel(for: currentMonth)
        return "\(direction) month from \(monthName)"
    }

    /// Creates VoiceOver hint for tab bar item
    static func tabHint(for tabName: String) -> String {
        "Navigate to \(tabName) tab"
    }

    // MARK: - Status Accessibility

    /// Creates VoiceOver label for budget status indicator
    static func budgetStatusLabel(isOverBudget: Bool) -> String {
        isOverBudget ? "Over budget, warning" : "Under budget, on track"
    }

    /// Creates VoiceOver label for running balance
    static func runningBalanceLabel(balance: Decimal) -> String {
        let amountLabel = currencyLabel(for: abs(balance))
        let status = balance >= 0 ? "positive" : "negative"
        return "Running balance: \(amountLabel) \(status)"
    }
}
