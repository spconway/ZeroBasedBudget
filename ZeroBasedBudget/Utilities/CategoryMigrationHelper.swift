//
//  CategoryMigrationHelper.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/16/25.
//  Migration helper for transitioning from global budgetedAmount to CategoryMonthlyBudget
//

import Foundation
import SwiftData

/// Helper functions for migrating categories to monthly budget tracking
enum CategoryMigrationHelper {

    /// Migrates a category's global budgetedAmount to a CategoryMonthlyBudget for the current month
    /// This is a one-time migration for existing categories
    /// - Parameters:
    ///   - category: The category to migrate
    ///   - month: The month to create the budget for (normalized to first of month)
    ///   - modelContext: SwiftData model context
    /// - Returns: The created CategoryMonthlyBudget
    @discardableResult
    static func migrateCategory(
        _ category: BudgetCategory,
        forMonth month: Date,
        in modelContext: ModelContext
    ) -> CategoryMonthlyBudget {
        let normalizedMonth = normalizeToFirstOfMonth(month)

        // Check if monthly budget already exists for this month
        if let existing = category.monthlyBudgets.first(where: { $0.isForMonth(normalizedMonth) }) {
            return existing
        }

        // Create new monthly budget with the current budgetedAmount
        let monthlyBudget = CategoryMonthlyBudget(
            category: category,
            month: normalizedMonth,
            budgetedAmount: category.budgetedAmount,
            availableFromPrevious: 0  // First month has no carryover
        )

        modelContext.insert(monthlyBudget)

        // DO NOT zero out category.budgetedAmount yet - keep for backward compatibility
        // This allows rollback if needed

        return monthlyBudget
    }

    /// Get or create a CategoryMonthlyBudget for a specific category and month
    /// This is the main function to use when navigating months
    /// - Parameters:
    ///   - category: The category
    ///   - month: The month
    ///   - allTransactions: All transactions (needed to calculate carry-forward)
    ///   - modelContext: SwiftData model context
    /// - Returns: The CategoryMonthlyBudget for this month
    static func getOrCreateMonthlyBudget(
        for category: BudgetCategory,
        month: Date,
        allTransactions: [Transaction],
        in modelContext: ModelContext
    ) -> CategoryMonthlyBudget {
        let normalizedMonth = normalizeToFirstOfMonth(month)

        // Check if monthly budget already exists
        if let existing = category.monthlyBudgets.first(where: { $0.isForMonth(normalizedMonth) }) {
            return existing
        }

        // Calculate available from previous month (only for current and future months)
        let availableFromPrevious = calculateAvailableFromPreviousMonth(
            category: category,
            currentMonth: normalizedMonth,
            allTransactions: allTransactions
        )

        // Create new monthly budget with $0 budgeted (YNAB principle)
        let monthlyBudget = CategoryMonthlyBudget(
            category: category,
            month: normalizedMonth,
            budgetedAmount: 0,  // Always start at $0 for new months
            availableFromPrevious: availableFromPrevious
        )

        modelContext.insert(monthlyBudget)

        return monthlyBudget
    }

    /// Calculate the available balance to carry forward from the previous month
    /// Returns 0 for past months (no carry-forward to past)
    /// - Parameters:
    ///   - category: The category
    ///   - currentMonth: The month we're calculating for
    ///   - allTransactions: All transactions
    /// - Returns: Available balance from previous month
    private static func calculateAvailableFromPreviousMonth(
        category: BudgetCategory,
        currentMonth: Date,
        allTransactions: [Transaction]
    ) -> Decimal {
        let calendar = Calendar.current
        let now = Date()
        let normalizedNow = normalizeToFirstOfMonth(now)

        // Only carry forward to current or future months, not past months
        guard currentMonth >= normalizedNow else {
            return 0
        }

        // Get previous month
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else {
            return 0
        }

        let normalizedPreviousMonth = normalizeToFirstOfMonth(previousMonth)

        // Get or calculate previous month's budget
        let previousMonthBudgeted: Decimal
        if let previousBudget = category.monthlyBudgets.first(where: { $0.isForMonth(normalizedPreviousMonth) }) {
            previousMonthBudgeted = previousBudget.budgetedAmount + previousBudget.availableFromPrevious
        } else {
            // No monthly budget exists for previous month - use legacy budgetedAmount if it's the first migration
            previousMonthBudgeted = category.budgetedAmount
        }

        // Calculate actual spent in previous month
        let previousMonthSpent = BudgetCalculations.calculateActualSpending(
            for: category,
            in: normalizedPreviousMonth,
            from: allTransactions
        )

        // Available = Budgeted - Spent
        let available = previousMonthBudgeted - previousMonthSpent

        // Only carry forward positive balances
        return max(available, 0)
    }

    /// Normalize a date to the first day of its month
    private static func normalizeToFirstOfMonth(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    /// Migrate all categories to monthly budgets for a specific month
    /// This is useful for initial migration or ensuring all categories have monthly budgets
    /// - Parameters:
    ///   - categories: All budget categories
    ///   - month: The month to migrate to
    ///   - allTransactions: All transactions
    ///   - modelContext: SwiftData model context
    static func migrateAllCategories(
        _ categories: [BudgetCategory],
        forMonth month: Date,
        allTransactions: [Transaction],
        in modelContext: ModelContext
    ) {
        for category in categories {
            _ = getOrCreateMonthlyBudget(
                for: category,
                month: month,
                allTransactions: allTransactions,
                in: modelContext
            )
        }

        // Save changes
        try? modelContext.save()
    }
}
