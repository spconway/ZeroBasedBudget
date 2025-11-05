//
//  TestHelpers.swift
//  ZeroBasedBudgetTests
//
//  Created by Claude Code on 2025-11-05.
//
//  Common test utility functions and extensions.
//  Provides helper methods for testing scenarios.
//

import Foundation
import SwiftData
@testable import ZeroBasedBudget

// MARK: - Date Helpers

extension Date {
    /// Create date from components for testing
    static func from(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        Calendar.current.date(from: DateComponents(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        ))!
    }

    /// Check if date is same day as another date
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// Check if date is in same month as another date
    func isSameMonth(as other: Date) -> Bool {
        let calendar = Calendar.current
        let selfComponents = calendar.dateComponents([.year, .month], from: self)
        let otherComponents = calendar.dateComponents([.year, .month], from: other)
        return selfComponents.year == otherComponents.year &&
               selfComponents.month == otherComponents.month
    }
}

// MARK: - Decimal Helpers

extension Decimal {
    /// Create Decimal from string for testing (convenience)
    init(stringValue: String) {
        if let value = Decimal(string: stringValue) {
            self = value
        } else {
            self = 0
        }
    }

    /// Round to specified decimal places
    func rounded(toPlaces places: Int) -> Decimal {
        let divisor = pow(10.0, Double(places))
        let rounded = (self as NSDecimalNumber).doubleValue * divisor
        return Decimal(Darwin.round(rounded) / divisor)
    }
}

// MARK: - Test Scenario Helpers

/// Helper functions for common test scenarios
enum TestScenarios {

    /// Create a complete test budget scenario with accounts, categories, and transactions
    ///
    /// Scenario:
    /// - 2 accounts: Checking ($2000), Savings ($5000)
    /// - 3 categories: Rent ($1000), Groceries ($400), Savings Goal ($300)
    /// - 5 transactions: Income, Rent payment, 2 grocery purchases, savings transfer
    ///
    /// - Parameter context: ModelContext to insert data into
    /// - Returns: Tuple of (accounts, categories, transactions)
    static func createCompleteScenario(
        in context: ModelContext
    ) throws -> (accounts: [Account], categories: [BudgetCategory], transactions: [Transaction]) {

        // Create accounts
        let checking = TestDataFactory.createCheckingAccount(balance: 2000)
        let savings = TestDataFactory.createSavingsAccount(balance: 5000)
        context.insert(checking)
        context.insert(savings)

        // Create categories
        let rent = TestDataFactory.createFixedCategory(
            name: "Rent",
            amount: 1000,
            dueDayOfMonth: 1
        )
        let groceries = TestDataFactory.createVariableCategory(
            name: "Groceries",
            amount: 400
        )
        let savingsGoal = TestDataFactory.createSavingsCategory(
            name: "Emergency Fund",
            amount: 300
        )
        context.insert(rent)
        context.insert(groceries)
        context.insert(savingsGoal)

        // Create transactions
        let income = TestDataFactory.createIncome(
            amount: 3000,
            description: "Paycheck",
            account: checking
        )
        let rentPayment = TestDataFactory.createExpense(
            amount: 1000,
            description: "Monthly Rent",
            category: rent,
            account: checking
        )
        let grocery1 = TestDataFactory.createExpense(
            amount: 150,
            description: "Whole Foods",
            category: groceries,
            account: checking
        )
        let grocery2 = TestDataFactory.createExpense(
            amount: 200,
            description: "Trader Joe's",
            category: groceries,
            account: checking
        )
        let savingsTransfer = TestDataFactory.createExpense(
            amount: 300,
            description: "Transfer to savings",
            category: savingsGoal,
            account: checking
        )

        context.insert(income)
        context.insert(rentPayment)
        context.insert(grocery1)
        context.insert(grocery2)
        context.insert(savingsTransfer)

        try context.save()

        return (
            accounts: [checking, savings],
            categories: [rent, groceries, savingsGoal],
            transactions: [income, rentPayment, grocery1, grocery2, savingsTransfer]
        )
    }

    /// Create simple YNAB scenario for testing Ready to Assign calculations
    ///
    /// Scenario:
    /// - 1 account: Checking ($1000)
    /// - 2 categories: Groceries ($200), Gas ($100)
    /// - Total budgeted: $300
    /// - Ready to Assign should be: $700
    ///
    /// - Parameter context: ModelContext to insert data into
    /// - Returns: Tuple of (account, categories, readyToAssign)
    static func createYNABScenario(
        in context: ModelContext
    ) throws -> (account: Account, categories: [BudgetCategory], expectedReadyToAssign: Decimal) {

        let account = TestDataFactory.createCheckingAccount(balance: 1000)
        context.insert(account)

        let groceries = TestDataFactory.createVariableCategory(
            name: "Groceries",
            amount: 200
        )
        let gas = TestDataFactory.createVariableCategory(
            name: "Gas",
            amount: 100
        )
        context.insert(groceries)
        context.insert(gas)

        try context.save()

        let expectedReadyToAssign: Decimal = 1000 - 200 - 100 // = 700

        return (
            account: account,
            categories: [groceries, gas],
            expectedReadyToAssign: expectedReadyToAssign
        )
    }

    /// Create edge case scenario with boundary values
    ///
    /// - Zero amounts
    /// - Very large amounts
    /// - Negative amounts (credit cards)
    /// - Decimal precision edge cases
    ///
    /// - Parameter context: ModelContext to insert data into
    static func createEdgeCaseScenario(in context: ModelContext) throws {

        // Zero balance account
        let zeroAccount = TestDataFactory.createAccount(balance: 0)
        context.insert(zeroAccount)

        // Very large balance
        let richAccount = TestDataFactory.createAccount(balance: 999_999_999.99)
        context.insert(richAccount)

        // Negative balance (credit card debt)
        let creditCard = TestDataFactory.createCreditCardAccount(balance: -5000.00)
        context.insert(creditCard)

        // Category with zero budget (YNAB principle: tracked but unfunded)
        let unfundedCategory = TestDataFactory.createCategory(
            name: "Unfunded Category",
            budgetedAmount: 0
        )
        context.insert(unfundedCategory)

        // Very small transaction (penny)
        let pennyTransaction = TestDataFactory.createExpense(
            amount: 0.01,
            description: "Penny transaction"
        )
        context.insert(pennyTransaction)

        // Transaction with precise decimal
        let preciseTransaction = TestDataFactory.createExpense(
            amount: 123.456789, // Will be rounded to 2 decimal places
            description: "Precise amount"
        )
        context.insert(preciseTransaction)

        try context.save()
    }
}

// MARK: - SwiftData Testing Helpers

extension ModelContext {
    /// Fetch all objects of a given type
    func fetchAll<T: PersistentModel>(_ type: T.Type) throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try fetch(descriptor)
    }

    /// Count all objects of a given type
    func count<T: PersistentModel>(_ type: T.Type) throws -> Int {
        let descriptor = FetchDescriptor<T>()
        return try fetchCount(descriptor)
    }

    /// Delete all objects of a given type
    func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let objects = try fetchAll(type)
        objects.forEach { delete($0) }
        try save()
    }
}

// MARK: - YNAB Methodology Testing Helpers

/// Helpers for validating YNAB methodology compliance
enum YNABTestHelpers {

    /// Calculate expected Ready to Assign amount following YNAB rules
    ///
    /// Formula: Sum(account.startingBalance) + Sum(income transactions) - Sum(category.budgetedAmount)
    ///
    /// - Parameters:
    ///   - accounts: All accounts
    ///   - transactions: All transactions
    ///   - categories: All budget categories
    /// - Returns: Expected Ready to Assign amount
    static func calculateExpectedReadyToAssign(
        accounts: [Account],
        transactions: [Transaction],
        categories: [BudgetCategory]
    ) -> Decimal {
        // Sum of starting balances (money that existed when budgeting began)
        let totalStartingBalance = accounts.reduce(Decimal(0)) { $0 + $1.startingBalance }

        // Sum of income transactions (new money that arrived)
        let totalIncome = transactions
            .filter { $0.type == .income }
            .reduce(Decimal(0)) { $0 + $1.amount }

        // Sum of budgeted amounts (money assigned to categories)
        let totalBudgeted = categories.reduce(Decimal(0)) { $0 + $1.budgetedAmount }

        // YNAB Formula: Available money = Starting money + Income - Budgeted
        return totalStartingBalance + totalIncome - totalBudgeted
    }

    /// Validate YNAB principle: Expenses don't reduce Ready to Assign
    ///
    /// Only budgeting reduces Ready to Assign, not spending.
    /// Spending reduces account balances and category available amounts.
    ///
    /// - Parameters:
    ///   - readyToAssignBefore: Ready to Assign before expense
    ///   - readyToAssignAfter: Ready to Assign after expense
    /// - Returns: True if amounts are equal (YNAB compliant)
    static func validateExpenseDoesNotReduceReadyToAssign(
        before: Decimal,
        after: Decimal
    ) -> Bool {
        abs(before - after) < 0.01 // Should be equal within precision
    }

    /// Validate YNAB principle: Income increases Ready to Assign
    ///
    /// - Parameters:
    ///   - readyToAssignBefore: Ready to Assign before income
    ///   - readyToAssignAfter: Ready to Assign after income
    ///   - incomeAmount: Amount of income transaction
    /// - Returns: True if increase matches income amount (YNAB compliant)
    static func validateIncomeIncreasesReadyToAssign(
        before: Decimal,
        after: Decimal,
        incomeAmount: Decimal
    ) -> Bool {
        let increase = after - before
        return abs(increase - incomeAmount) < 0.01
    }
}
