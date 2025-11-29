//
//  CategoryMonthlyBudget.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/16/25.
//  ZeroBudget-style monthly budget tracking per category
//

import Foundation
import SwiftData

/// Tracks budget data for a specific category in a specific month
/// This model implements ZeroBudget's carry-forward methodology where:
/// - Budgeted amounts reset to $0 each month (fresh budgeting decision)
/// - Available balances carry forward from previous months
/// - Formula: Available = (Previous Available) + (This Month Budgeted) - (This Month Spent)
@Model
final class CategoryMonthlyBudget {
    /// The category this budget belongs to
    var category: BudgetCategory

    /// The month this budget is for (normalized to first day of month)
    var month: Date

    /// Amount budgeted for this category THIS month only
    /// Resets to $0 when navigating to a new month (ZeroBudget principle)
    var budgetedAmount: Decimal

    /// Available balance carried forward from the previous month
    /// Formula: Previous month's (budgeted + availableFromPrevious - actualSpent)
    /// Note: Only set for months >= current month, not for past months
    var availableFromPrevious: Decimal

    init(category: BudgetCategory, month: Date, budgetedAmount: Decimal = 0, availableFromPrevious: Decimal = 0) {
        self.category = category
        // Normalize month to first day
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        self.month = calendar.date(from: components) ?? month
        self.budgetedAmount = budgetedAmount
        self.availableFromPrevious = availableFromPrevious
    }

    // MARK: - Computed Properties

    /// Total available for this category in this month
    /// Formula: budgetedAmount + availableFromPrevious - actualSpent
    /// Note: actualSpent must be passed in as it requires transaction data
    func totalAvailable(actualSpent: Decimal) -> Decimal {
        return budgetedAmount + availableFromPrevious - actualSpent
    }

    /// Calculate what will be available at the END of this month
    /// This is what carries forward to the next month
    func endingAvailable(actualSpent: Decimal) -> Decimal {
        return totalAvailable(actualSpent: actualSpent)
    }
}

// MARK: - Month Comparison Extension
extension CategoryMonthlyBudget {
    /// Returns true if this budget is for the specified month
    func isForMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let thisComponents = calendar.dateComponents([.year, .month], from: month)
        let dateComponents = calendar.dateComponents([.year, .month], from: date)
        return thisComponents.year == dateComponents.year && thisComponents.month == dateComponents.month
    }

    /// Returns true if this budget is before the specified month
    func isBeforeMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let normalized = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
        return month < normalized
    }

    /// Returns true if this budget is after the specified month
    func isAfterMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let normalized = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
        return month > normalized
    }
}
