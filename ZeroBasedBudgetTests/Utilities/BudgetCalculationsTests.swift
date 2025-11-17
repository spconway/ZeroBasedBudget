//
//  BudgetCalculationsTests.swift
//  ZeroBasedBudgetTests
//
//  Created by Claude Code on 2025-11-05.
//
//  Unit tests for BudgetCalculations utility
//  Tests date calculations, transaction filtering, spending aggregation, and YNAB calculations
//

import XCTest
import SwiftData
@testable import ZeroBasedBudget

final class BudgetCalculationsTests: ZeroBasedBudgetTests {

    // MARK: - Date Calculation Tests

    /// Test: startOfMonth returns first day of month at midnight
    func test_startOfMonth_forAnyDate_returnsFirstDayAtMidnight() throws {
        // Arrange
        let midMonthDate = Date.from(year: 2024, month: 6, day: 15, hour: 14, minute: 30)

        // Act
        let startOfMonth = BudgetCalculations.startOfMonth(for: midMonthDate)

        // Assert
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startOfMonth)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 1)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
    }

    /// Test: endOfMonth returns last day of month for any date
    func test_endOfMonth_forAnyDate_returnsLastDayOfMonth() throws {
        // Arrange
        let januaryDate = Date.from(year: 2024, month: 1, day: 15) // 31 days
        let aprilDate = Date.from(year: 2024, month: 4, day: 15)   // 30 days

        // Act
        let endOfJanuary = BudgetCalculations.endOfMonth(for: januaryDate)
        let endOfApril = BudgetCalculations.endOfMonth(for: aprilDate)

        // Assert
        let calendar = Calendar.current
        let janDay = calendar.component(.day, from: endOfJanuary)
        let aprDay = calendar.component(.day, from: endOfApril)

        XCTAssertEqual(janDay, 31)
        XCTAssertEqual(aprDay, 30)
    }

    /// Test: endOfMonth handles February leap years correctly
    func test_endOfMonth_february_handlesLeapYears() throws {
        // Arrange
        let feb2024 = Date.from(year: 2024, month: 2, day: 1) // Leap year
        let feb2023 = Date.from(year: 2023, month: 2, day: 1) // Non-leap year

        // Act
        let endFeb2024 = BudgetCalculations.endOfMonth(for: feb2024)
        let endFeb2023 = BudgetCalculations.endOfMonth(for: feb2023)

        // Assert
        let calendar = Calendar.current
        let day2024 = calendar.component(.day, from: endFeb2024)
        let day2023 = calendar.component(.day, from: endFeb2023)

        XCTAssertEqual(day2024, 29, "2024 is a leap year, February should have 29 days")
        XCTAssertEqual(day2023, 28, "2023 is not a leap year, February should have 28 days")
    }

    /// Test: isDate checks if date is in same month correctly
    func test_isDate_inMonth_whenSameMonth_returnsTrue() throws {
        // Arrange
        let date1 = Date.from(year: 2024, month: 6, day: 1)
        let date2 = Date.from(year: 2024, month: 6, day: 15)
        let date3 = Date.from(year: 2024, month: 6, day: 30)

        // Act & Assert
        XCTAssertTrue(BudgetCalculations.isDate(date1, inMonth: date2))
        XCTAssertTrue(BudgetCalculations.isDate(date2, inMonth: date1))
        XCTAssertTrue(BudgetCalculations.isDate(date3, inMonth: date2))
    }

    /// Test: isDate returns false for different months
    func test_isDate_inMonth_whenDifferentMonth_returnsFalse() throws {
        // Arrange
        let juneDate = Date.from(year: 2024, month: 6, day: 15)
        let julyDate = Date.from(year: 2024, month: 7, day: 15)
        let differentYearDate = Date.from(year: 2023, month: 6, day: 15)

        // Act & Assert
        XCTAssertFalse(BudgetCalculations.isDate(juneDate, inMonth: julyDate))
        XCTAssertFalse(BudgetCalculations.isDate(juneDate, inMonth: differentYearDate))
    }

    // MARK: - Date Formatting Tests

    /// Test: formatTransactionSectionDate omits year for current year
    func test_formatTransactionSectionDate_currentYear_omitsYear() throws {
        // Arrange
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentYearDate = Date.from(year: currentYear, month: 6, day: 15)

        // Act
        let formatted = BudgetCalculations.formatTransactionSectionDate(currentYearDate)

        // Assert
        // For current year, format should be like "Jun 15" without year
        XCTAssertFalse(formatted.contains(String(currentYear)),
                      "Current year date should not include year in formatted string")
        XCTAssertTrue(formatted.contains("Jun") || formatted.contains("6"),
                     "Should contain month abbreviation or number")
        XCTAssertTrue(formatted.contains("15"),
                     "Should contain day number")
    }

    /// Test: formatTransactionSectionDate includes year for different year
    func test_formatTransactionSectionDate_differentYear_includesYear() throws {
        // Arrange
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let differentYear = currentYear - 1  // Last year
        let differentYearDate = Date.from(year: differentYear, month: 6, day: 15)

        // Act
        let formatted = BudgetCalculations.formatTransactionSectionDate(differentYearDate)

        // Assert
        // For different year, format should include year like "Jun 15, 2023"
        XCTAssertTrue(formatted.contains(String(differentYear)),
                     "Different year date should include year in formatted string")
        XCTAssertTrue(formatted.contains("Jun") || formatted.contains("6"),
                     "Should contain month abbreviation or number")
        XCTAssertTrue(formatted.contains("15"),
                     "Should contain day number")
    }

    /// Test: formatTransactionSectionDate includes year for future year
    func test_formatTransactionSectionDate_futureYear_includesYear() throws {
        // Arrange
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let futureYear = currentYear + 1  // Next year
        let futureYearDate = Date.from(year: futureYear, month: 6, day: 15)

        // Act
        let formatted = BudgetCalculations.formatTransactionSectionDate(futureYearDate)

        // Assert
        // For future year, format should include year like "Jun 15, 2026"
        XCTAssertTrue(formatted.contains(String(futureYear)),
                     "Future year date should include year in formatted string")
    }

    /// Test: formatTransactionSectionDate handles year boundary correctly
    func test_formatTransactionSectionDate_yearBoundary_formatsCorrectly() throws {
        // Arrange
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())

        // December 31 of current year
        let dec31CurrentYear = Date.from(year: currentYear, month: 12, day: 31)

        // January 1 of previous year
        let jan1PreviousYear = Date.from(year: currentYear - 1, month: 1, day: 1)

        // Act
        let dec31Formatted = BudgetCalculations.formatTransactionSectionDate(dec31CurrentYear)
        let jan1Formatted = BudgetCalculations.formatTransactionSectionDate(jan1PreviousYear)

        // Assert
        XCTAssertFalse(dec31Formatted.contains(String(currentYear)),
                      "Current year (Dec 31) should not include year")
        XCTAssertTrue(jan1Formatted.contains(String(currentYear - 1)),
                     "Previous year (Jan 1) should include year")
    }

    // MARK: - Transaction Filtering Tests

    /// Test: Filters transactions in month correctly
    func test_transactionsInMonth_filtersCorrectly_forGivenMonth() throws {
        // Arrange
        let june2024 = Date.from(year: 2024, month: 6, day: 1)
        let transactions = [
            TestDataFactory.createTransaction(date: Date.from(year: 2024, month: 6, day: 5)),
            TestDataFactory.createTransaction(date: Date.from(year: 2024, month: 6, day: 15)),
            TestDataFactory.createTransaction(date: Date.from(year: 2024, month: 6, day: 30)),
            TestDataFactory.createTransaction(date: Date.from(year: 2024, month: 7, day: 1)) // Different month
        ]

        // Act
        let juneTransactions = BudgetCalculations.transactions(in: june2024, from: transactions)

        // Assert
        XCTAssertEqual(juneTransactions.count, 3)
    }

    /// Test: Excludes transactions outside the specified month
    func test_transactionsInMonth_excludes_transactionsOutsideMonth() throws {
        // Arrange
        let june2024 = Date.from(year: 2024, month: 6, day: 1)
        let transactions = [
            TestDataFactory.createTransaction(date: Date.from(year: 2024, month: 5, day: 31)), // May
            TestDataFactory.createTransaction(date: Date.from(year: 2024, month: 7, day: 1)),  // July
        ]

        // Act
        let juneTransactions = BudgetCalculations.transactions(in: june2024, from: transactions)

        // Assert
        XCTAssertEqual(juneTransactions.count, 0, "Should exclude transactions from other months")
    }

    /// Test: Filters transactions for specific category correctly
    func test_transactionsForCategory_filtersCorrectly_byCategory() throws {
        // Arrange
        let category1 = TestDataFactory.createCategory(name: "Groceries")
        let category2 = TestDataFactory.createCategory(name: "Gas")
        let june2024 = Date.from(year: 2024, month: 6, day: 1)

        let transactions = [
            TestDataFactory.createTransaction(date: Date.from(year: 2024, month: 6, day: 5), category: category1),
            TestDataFactory.createTransaction(date: Date.from(year: 2024, month: 6, day: 10), category: category1),
            TestDataFactory.createTransaction(date: Date.from(year: 2024, month: 6, day: 15), category: category2),
        ]

        // Act
        let groceryTransactions = BudgetCalculations.transactions(
            for: category1,
            in: june2024,
            from: transactions
        )

        // Assert
        XCTAssertEqual(groceryTransactions.count, 2)
        XCTAssertTrue(groceryTransactions.allSatisfy { $0.category === category1 })
    }

    // MARK: - Spending Aggregation Tests

    /// Test: calculateActualSpending sums expenses and excludes income
    func test_calculateActualSpending_sumExpenses_excludesIncome() throws {
        // Arrange
        let category = TestDataFactory.createCategory(name: "Groceries")
        let june2024 = Date.from(year: 2024, month: 6, day: 1)

        let transactions = [
            TestDataFactory.createExpense(amount: 150, category: category),
            TestDataFactory.createExpense(amount: 200, category: category),
            TestDataFactory.createIncome(amount: 3000), // Should be excluded
        ]

        transactions.forEach { $0.date = june2024 }

        // Act
        let actualSpending = BudgetCalculations.calculateActualSpending(
            for: category,
            in: june2024,
            from: transactions
        )

        // Assert
        assertDecimalEqual(actualSpending, 350, "Should sum only expenses (150 + 200)")
    }

    /// Test: calculateActualSpending returns zero for no transactions
    func test_calculateActualSpending_withNoTransactions_returnsZero() throws {
        // Arrange
        let category = TestDataFactory.createCategory()
        let june2024 = Date.from(year: 2024, month: 6, day: 1)
        let transactions: [Transaction] = []

        // Act
        let actualSpending = BudgetCalculations.calculateActualSpending(
            for: category,
            in: june2024,
            from: transactions
        )

        // Assert
        assertDecimalZero(actualSpending)
    }

    /// Test: calculateTotalIncome sums income and excludes expenses
    func test_calculateTotalIncome_sumIncome_excludesExpenses() throws {
        // Arrange
        let june2024 = Date.from(year: 2024, month: 6, day: 1)

        let transactions = [
            TestDataFactory.createIncome(amount: 3000),
            TestDataFactory.createIncome(amount: 500),
            TestDataFactory.createExpense(amount: 150), // Should be excluded
        ]

        transactions.forEach { $0.date = june2024 }

        // Act
        let totalIncome = BudgetCalculations.calculateTotalIncome(in: june2024, from: transactions)

        // Assert
        assertDecimalEqual(totalIncome, 3500, "Should sum only income (3000 + 500)")
    }

    /// Test: calculateTotalIncome returns zero with no income
    func test_calculateTotalIncome_withNoIncome_returnsZero() throws {
        // Arrange
        let june2024 = Date.from(year: 2024, month: 6, day: 1)
        let transactions = [
            TestDataFactory.createExpense(amount: 150),
            TestDataFactory.createExpense(amount: 200),
        ]

        transactions.forEach { $0.date = june2024 }

        // Act
        let totalIncome = BudgetCalculations.calculateTotalIncome(in: june2024, from: transactions)

        // Assert
        assertDecimalZero(totalIncome, "Should return 0 when no income transactions")
    }

    /// Test: calculateTotalExpenses sums all expenses
    func test_calculateTotalExpenses_sumExpenses_excludesIncome() throws {
        // Arrange
        let june2024 = Date.from(year: 2024, month: 6, day: 1)

        let transactions = [
            TestDataFactory.createExpense(amount: 150),
            TestDataFactory.createExpense(amount: 200),
            TestDataFactory.createExpense(amount: 75),
            TestDataFactory.createIncome(amount: 3000), // Should be excluded
        ]

        transactions.forEach { $0.date = june2024 }

        // Act
        let totalExpenses = BudgetCalculations.calculateTotalExpenses(in: june2024, from: transactions)

        // Assert
        assertDecimalEqual(totalExpenses, 425, "Should sum only expenses (150 + 200 + 75)")
    }

    // MARK: - Category Comparison Tests

    /// Test: generateCategoryComparisons creates comparisons for all categories
    func test_generateCategoryComparisons_createsComparisons_forAllCategories() throws {
        // Arrange
        let groceries = TestDataFactory.createCategory(name: "Groceries", budgetedAmount: 400)
        let gas = TestDataFactory.createCategory(name: "Gas", budgetedAmount: 150)
        let categories = [groceries, gas]
        let june2024 = Date.from(year: 2024, month: 6, day: 1)

        let transactions = [
            TestDataFactory.createExpense(amount: 300, category: groceries),
            TestDataFactory.createExpense(amount: 120, category: gas),
        ]
        transactions.forEach { $0.date = june2024 }

        // Create monthly budgets for each category
        let monthlyBudgets = [
            TestDataFactory.createCategoryMonthlyBudget(category: groceries, month: june2024, budgetedAmount: 400),
            TestDataFactory.createCategoryMonthlyBudget(category: gas, month: june2024, budgetedAmount: 150)
        ]

        // Act
        let comparisons = BudgetCalculations.generateCategoryComparisons(
            categories: categories,
            month: june2024,
            transactions: transactions,
            monthlyBudgets: monthlyBudgets
        )

        // Assert
        XCTAssertEqual(comparisons.count, 2)
        XCTAssertEqual(comparisons[0].categoryName, "Groceries")
        assertDecimalEqual(comparisons[0].budgeted, 400)
        assertDecimalEqual(comparisons[0].actual, 300)
    }

    /// Test: generateCategoryComparisons filters by category type
    func test_generateCategoryComparisons_filtersByCategoryType_correctly() throws {
        // Arrange
        let fixed = TestDataFactory.createFixedCategory(name: "Rent", amount: 1500)
        let variable = TestDataFactory.createVariableCategory(name: "Groceries", amount: 400)
        let categories = [fixed, variable]
        let june2024 = Date.from(year: 2024, month: 6, day: 1)
        let transactions: [Transaction] = []

        // Create monthly budgets for each category
        let monthlyBudgets = [
            TestDataFactory.createCategoryMonthlyBudget(category: fixed, month: june2024, budgetedAmount: 1500),
            TestDataFactory.createCategoryMonthlyBudget(category: variable, month: june2024, budgetedAmount: 400)
        ]

        // Act
        let fixedComparisons = BudgetCalculations.generateCategoryComparisons(
            categories: categories,
            categoryType: "Fixed",
            month: june2024,
            transactions: transactions,
            monthlyBudgets: monthlyBudgets
        )

        // Assert
        XCTAssertEqual(fixedComparisons.count, 1)
        XCTAssertEqual(fixedComparisons[0].categoryName, "Rent")
    }

    // MARK: - Budget Summary Tests

    /// Test: totalBudgeted sums budgeted amounts for category type
    func test_totalBudgeted_sumsBudgetedAmounts_forCategoryType() throws {
        // Arrange
        let fixed1 = TestDataFactory.createFixedCategory(name: "Rent", amount: 1500)
        let fixed2 = TestDataFactory.createFixedCategory(name: "Utilities", amount: 200)
        let variable = TestDataFactory.createVariableCategory(name: "Groceries", amount: 400)
        let categories = [fixed1, fixed2, variable]

        // Act
        let totalFixed = BudgetCalculations.totalBudgeted(for: "Fixed", categories: categories)

        // Assert
        assertDecimalEqual(totalFixed, 1700, "Should sum fixed categories (1500 + 200)")
    }

    /// Test: totalActual sums actual spending for category type
    func test_totalActual_sumsActualSpending_forCategoryType() throws {
        // Arrange
        let fixed1 = TestDataFactory.createFixedCategory(name: "Rent", amount: 1500)
        let fixed2 = TestDataFactory.createFixedCategory(name: "Utilities", amount: 200)
        let categories = [fixed1, fixed2]
        let june2024 = Date.from(year: 2024, month: 6, day: 1)

        let transactions = [
            TestDataFactory.createExpense(amount: 1500, category: fixed1),
            TestDataFactory.createExpense(amount: 180, category: fixed2),
        ]
        transactions.forEach { $0.date = june2024 }

        // Act
        let totalActual = BudgetCalculations.totalActual(
            for: "Fixed",
            categories: categories,
            month: june2024,
            transactions: transactions
        )

        // Assert
        assertDecimalEqual(totalActual, 1680, "Should sum actual spending (1500 + 180)")
    }

    // MARK: - Running Balance Tests

    /// Test: calculateRunningBalance calculates correctly with mixed transactions
    func test_calculateRunningBalance_withMixedTransactions_calculatesCorrectly() throws {
        // Arrange
        let transactions = [
            TestDataFactory.createIncome(amount: 3000),    // +3000 = 3000
            TestDataFactory.createExpense(amount: 1500),   // -1500 = 1500
            TestDataFactory.createExpense(amount: 200),    // -200  = 1300
            TestDataFactory.createIncome(amount: 500),     // +500  = 1800
            TestDataFactory.createExpense(amount: 300),    // -300  = 1500
        ]

        // Set dates to ensure order
        for (index, transaction) in transactions.enumerated() {
            transaction.date = Date.from(year: 2024, month: 6, day: index + 1)
        }

        // Act
        let runningBalances = BudgetCalculations.calculateRunningBalance(for: transactions)

        // Assert
        XCTAssertEqual(runningBalances.count, 5)
        assertDecimalEqual(runningBalances[0].1, 3000)  // After income
        assertDecimalEqual(runningBalances[1].1, 1500)  // After first expense
        assertDecimalEqual(runningBalances[2].1, 1300)  // After second expense
        assertDecimalEqual(runningBalances[3].1, 1800)  // After second income
        assertDecimalEqual(runningBalances[4].1, 1500)  // After third expense
    }
}
