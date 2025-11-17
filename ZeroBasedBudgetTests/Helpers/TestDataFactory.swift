//
//  TestDataFactory.swift
//  ZeroBasedBudgetTests
//
//  Created by Claude Code on 2025-11-05.
//
//  Factory for creating test data with sensible defaults.
//  Provides consistent, predictable test data across all test cases.
//

import Foundation
@testable import ZeroBasedBudget

/// Factory for creating test data with default values
///
/// Usage:
/// ```swift
/// let account = TestDataFactory.createAccount(name: "Test Checking", balance: 1000)
/// let transaction = TestDataFactory.createTransaction(amount: 50, type: .expense)
/// ```
enum TestDataFactory {

    // MARK: - Account Factory Methods

    /// Create test account with default or custom values
    ///
    /// - Parameters:
    ///   - name: Account name (default: "Test Account")
    ///   - balance: Current balance (default: 1000)
    ///   - accountType: Optional account type (default: "Checking")
    /// - Returns: New Account instance
    static func createAccount(
        name: String = "Test Account",
        balance: Decimal = 1000,
        accountType: String? = "Checking"
    ) -> Account {
        Account(
            name: name,
            balance: balance,
            accountType: accountType
        )
    }

    /// Create checking account with default values
    static func createCheckingAccount(balance: Decimal = 1000) -> Account {
        createAccount(name: "Test Checking", balance: balance, accountType: "Checking")
    }

    /// Create savings account with default values
    static func createSavingsAccount(balance: Decimal = 5000) -> Account {
        createAccount(name: "Test Savings", balance: balance, accountType: "Savings")
    }

    /// Create cash account with default values
    static func createCashAccount(balance: Decimal = 200) -> Account {
        createAccount(name: "Test Cash", balance: balance, accountType: "Cash")
    }

    /// Create credit card account (negative balance for debt)
    static func createCreditCardAccount(balance: Decimal = -500) -> Account {
        createAccount(name: "Test Credit Card", balance: balance, accountType: "Credit Card")
    }

    // MARK: - Transaction Factory Methods

    /// Create test transaction with default or custom values
    ///
    /// - Parameters:
    ///   - date: Transaction date (default: current date)
    ///   - amount: Transaction amount (default: 50)
    ///   - description: Transaction description (default: "Test Transaction")
    ///   - type: Transaction type (default: .expense)
    ///   - category: Optional budget category
    ///   - account: Optional account
    /// - Returns: New Transaction instance
    static func createTransaction(
        date: Date = Date(),
        amount: Decimal = 50,
        description: String = "Test Transaction",
        type: TransactionType = .expense,
        category: BudgetCategory? = nil,
        account: Account? = nil
    ) -> Transaction {
        Transaction(
            date: date,
            amount: amount,
            description: description,
            type: type,
            category: category,
            account: account
        )
    }

    /// Create expense transaction with default values
    static func createExpense(
        amount: Decimal = 50,
        description: String = "Test Expense",
        category: BudgetCategory? = nil,
        account: Account? = nil
    ) -> Transaction {
        createTransaction(
            amount: amount,
            description: description,
            type: .expense,
            category: category,
            account: account
        )
    }

    /// Create income transaction with default values
    static func createIncome(
        amount: Decimal = 1000,
        description: String = "Test Income",
        account: Account? = nil
    ) -> Transaction {
        createTransaction(
            amount: amount,
            description: description,
            type: .income,
            category: nil,  // Income typically has no category
            account: account
        )
    }

    // MARK: - Budget Category Factory Methods

    /// Create test budget category with default or custom values
    ///
    /// - Parameters:
    ///   - name: Category name (default: "Test Category")
    ///   - budgetedAmount: Budgeted amount (default: 200)
    ///   - categoryType: Category type (default: "Variable")
    ///   - colorHex: Color hex code (default: "#FF0000")
    ///   - dueDayOfMonth: Optional due day of month
    ///   - isLastDayOfMonth: If true, due date is last day of month (default: false)
    /// - Returns: New BudgetCategory instance
    static func createCategory(
        name: String = "Test Category",
        budgetedAmount: Decimal = 200,
        categoryType: String = "Variable",
        colorHex: String = "#FF0000",
        dueDayOfMonth: Int? = nil,
        isLastDayOfMonth: Bool = false
    ) -> BudgetCategory {
        let category = BudgetCategory(
            name: name,
            budgetedAmount: budgetedAmount,
            categoryType: categoryType,
            colorHex: colorHex
        )

        if let dueDayOfMonth = dueDayOfMonth {
            category.dueDayOfMonth = dueDayOfMonth
        }

        category.isLastDayOfMonth = isLastDayOfMonth

        return category
    }

    /// Create fixed expense category (e.g., rent, utilities)
    static func createFixedCategory(
        name: String = "Test Fixed Expense",
        amount: Decimal = 500,
        dueDayOfMonth: Int? = 1
    ) -> BudgetCategory {
        createCategory(
            name: name,
            budgetedAmount: amount,
            categoryType: "Fixed",
            colorHex: "#FF6B6B",
            dueDayOfMonth: dueDayOfMonth
        )
    }

    /// Create variable expense category (e.g., groceries, entertainment)
    static func createVariableCategory(
        name: String = "Test Variable Expense",
        amount: Decimal = 200
    ) -> BudgetCategory {
        createCategory(
            name: name,
            budgetedAmount: amount,
            categoryType: "Variable",
            colorHex: "#4ECDC4"
        )
    }

    /// Create savings category
    static func createSavingsCategory(
        name: String = "Test Savings Goal",
        amount: Decimal = 300
    ) -> BudgetCategory {
        createCategory(
            name: name,
            budgetedAmount: amount,
            categoryType: "Savings",
            colorHex: "#95E1D3"
        )
    }

    // MARK: - Monthly Budget Factory Methods

    /// Create test monthly budget with default or custom values
    ///
    /// - Parameters:
    ///   - month: Budget month (default: current month start)
    ///   - startingBalance: Starting balance (default: 0)
    /// - Returns: New MonthlyBudget instance
    static func createMonthlyBudget(
        month: Date = Date(),
        startingBalance: Decimal = 0
    ) -> MonthlyBudget {
        // Ensure month is first day of month at midnight
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        let firstOfMonth = calendar.date(from: components) ?? month

        return MonthlyBudget(
            month: firstOfMonth,
            startingBalance: startingBalance
        )
    }

    // MARK: - Category Monthly Budget Factory Methods

    /// Create test category monthly budget with default or custom values
    ///
    /// - Parameters:
    ///   - category: Budget category
    ///   - month: Budget month (default: current month start)
    ///   - budgetedAmount: Amount budgeted for this month (default: 0)
    ///   - availableFromPrevious: Amount carried forward from previous month (default: 0)
    /// - Returns: New CategoryMonthlyBudget instance
    static func createCategoryMonthlyBudget(
        category: BudgetCategory,
        month: Date = Date(),
        budgetedAmount: Decimal = 0,
        availableFromPrevious: Decimal = 0
    ) -> CategoryMonthlyBudget {
        return CategoryMonthlyBudget(
            category: category,
            month: month,
            budgetedAmount: budgetedAmount,
            availableFromPrevious: availableFromPrevious
        )
    }

    // MARK: - App Settings Factory Methods

    /// Create test app settings with default values
    ///
    /// - Parameters:
    ///   - colorScheme: Color scheme preference (default: "system")
    ///   - currencyCode: Currency code (default: "USD")
    ///   - notificationsEnabled: Notifications enabled (default: true)
    /// - Returns: New AppSettings instance
    static func createAppSettings(
        colorScheme: String = "system",
        currencyCode: String = "USD",
        notificationsEnabled: Bool = true
    ) -> AppSettings {
        let settings = AppSettings()
        settings.colorSchemePreference = colorScheme
        settings.currencyCode = currencyCode
        settings.notificationsEnabled = notificationsEnabled
        return settings
    }

    // MARK: - Fixed Test Dates

    /// Fixed date for testing: January 1, 2024 at midnight
    static var fixedDate2024Jan1: Date {
        Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 1))!
    }

    /// Fixed date for testing: February 29, 2024 (leap year)
    static var fixedDate2024Feb29: Date {
        Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 29))!
    }

    /// Fixed date for testing: December 31, 2024 at midnight
    static var fixedDate2024Dec31: Date {
        Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 31))!
    }

    /// First day of current month
    static var firstDayOfCurrentMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: components)!
    }

    /// Last day of current month
    static var lastDayOfCurrentMonth: Date {
        let calendar = Calendar.current
        let firstOfMonth = firstDayOfCurrentMonth
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstOfMonth)!
        return calendar.date(byAdding: .day, value: -1, to: nextMonth)!
    }
}
