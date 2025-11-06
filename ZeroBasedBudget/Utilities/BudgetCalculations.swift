//
//  BudgetCalculations.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//

import Foundation
import SwiftData

/// Utility functions for budget calculations and aggregations
enum BudgetCalculations {

    // MARK: - Date Utilities

    /// Returns the start date of the month for a given date
    static func startOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }

    /// Returns the end date of the month for a given date
    static func endOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let startOfMonth = self.startOfMonth(for: date)
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        return endOfMonth
    }

    /// Returns whether a date falls within a specific month
    static func isDate(_ date: Date, inMonth month: Date) -> Bool {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month], from: date)
        let monthComponents = calendar.dateComponents([.year, .month], from: month)
        return dateComponents.year == monthComponents.year && dateComponents.month == monthComponents.month
    }

    /// Formats a date for transaction section headers with absolute dates
    /// Returns format like "Nov 5" for current year, "Nov 5, 2025" for other years
    /// Respects user's locale and calendar settings
    static func formatTransactionSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        // Check if date is in current year
        let dateYear = calendar.component(.year, from: date)
        let currentYear = calendar.component(.year, from: now)

        if dateYear == currentYear {
            // Omit year for current year: "Nov 5"
            return date.formatted(.dateTime.month(.abbreviated).day())
        } else {
            // Include year for other years: "Nov 5, 2025"
            return date.formatted(.dateTime.month(.abbreviated).day().year())
        }
    }

    // MARK: - Transaction Filtering

    /// Filters transactions to only those in the specified month
    static func transactions(in month: Date, from allTransactions: [Transaction]) -> [Transaction] {
        let startOfMonth = self.startOfMonth(for: month)
        let endOfMonth = self.endOfMonth(for: month)

        return allTransactions.filter { transaction in
            transaction.date >= startOfMonth && transaction.date <= endOfMonth
        }
    }

    /// Filters transactions for a specific category in a specific month
    static func transactions(
        for category: BudgetCategory,
        in month: Date,
        from allTransactions: [Transaction]
    ) -> [Transaction] {
        let monthTransactions = transactions(in: month, from: allTransactions)
        return monthTransactions.filter { $0.category == category }
    }

    // MARK: - Spending Aggregation

    /// Calculates total actual spending for a category in a specific month
    /// Only counts expense transactions, not income
    static func calculateActualSpending(
        for category: BudgetCategory,
        in month: Date,
        from allTransactions: [Transaction]
    ) -> Decimal {
        let categoryTransactions = transactions(for: category, in: month, from: allTransactions)
        let expenseTransactions = categoryTransactions.filter { $0.type == .expense }

        return expenseTransactions.reduce(Decimal.zero) { total, transaction in
            total + transaction.amount
        }
    }

    /// Calculates total income for a specific month
    static func calculateTotalIncome(
        in month: Date,
        from allTransactions: [Transaction]
    ) -> Decimal {
        let monthTransactions = transactions(in: month, from: allTransactions)
        let incomeTransactions = monthTransactions.filter { $0.type == .income }

        return incomeTransactions.reduce(Decimal.zero) { total, transaction in
            total + transaction.amount
        }
    }

    /// Calculates total expenses for a specific month
    static func calculateTotalExpenses(
        in month: Date,
        from allTransactions: [Transaction]
    ) -> Decimal {
        let monthTransactions = transactions(in: month, from: allTransactions)
        let expenseTransactions = monthTransactions.filter { $0.type == .expense }

        return expenseTransactions.reduce(Decimal.zero) { total, transaction in
            total + transaction.amount
        }
    }

    // MARK: - Category Comparisons

    /// Generates category comparisons for all categories in a specific month
    static func generateCategoryComparisons(
        categories: [BudgetCategory],
        month: Date,
        transactions: [Transaction]
    ) -> [CategoryComparison] {
        categories.map { category in
            let actual = calculateActualSpending(
                for: category,
                in: month,
                from: transactions
            )

            return CategoryComparison(
                categoryName: category.name,
                categoryColor: category.colorHex,
                budgeted: category.budgetedAmount,
                actual: actual
            )
        }
    }

    /// Generates category comparisons filtered by category type
    static func generateCategoryComparisons(
        categories: [BudgetCategory],
        categoryType: String,
        month: Date,
        transactions: [Transaction]
    ) -> [CategoryComparison] {
        let filteredCategories = categories.filter { $0.categoryType == categoryType }
        return generateCategoryComparisons(
            categories: filteredCategories,
            month: month,
            transactions: transactions
        )
    }

    // MARK: - Budget Summary

    /// Calculates total budgeted amount for a specific category type
    static func totalBudgeted(for categoryType: String, categories: [BudgetCategory]) -> Decimal {
        categories
            .filter { $0.categoryType == categoryType }
            .reduce(Decimal.zero) { $0 + $1.budgetedAmount }
    }

    /// Calculates total actual spending for a specific category type in a month
    static func totalActual(
        for categoryType: String,
        categories: [BudgetCategory],
        month: Date,
        transactions: [Transaction]
    ) -> Decimal {
        let filteredCategories = categories.filter { $0.categoryType == categoryType }
        return filteredCategories.reduce(Decimal.zero) { total, category in
            total + calculateActualSpending(for: category, in: month, from: transactions)
        }
    }

    // MARK: - Running Balance

    /// Calculates running balance for a list of transactions
    /// Returns array of tuples with (transaction, running balance at that point)
    static func calculateRunningBalance(
        for transactions: [Transaction]
    ) -> [(Transaction, Decimal)] {
        var runningBalance: Decimal = 0
        let sortedTransactions = transactions.sorted(by: { $0.date < $1.date })

        return sortedTransactions.map { transaction in
            if transaction.type == .income {
                runningBalance += transaction.amount
            } else {
                runningBalance -= transaction.amount
            }
            return (transaction, runningBalance)
        }
    }
}
