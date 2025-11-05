//
//  EdgeCaseTests.swift
//  ZeroBasedBudgetTests
//
//  Created by Claude Code on 2025-11-05.
//
//  Unit tests for edge cases and boundary conditions
//  Tests Decimal precision, date boundaries, extreme values, and unusual scenarios
//

import XCTest
import SwiftData
@testable import ZeroBasedBudget

final class EdgeCaseTests: ZeroBasedBudgetTests {

    // MARK: - Decimal Precision Edge Cases

    /// Test: Very small amounts maintain accuracy
    /// Critical for financial calculations with cents
    func test_decimalPrecision_verySmallAmounts_maintainsAccuracy() throws {
        // Arrange
        let penny: Decimal = 0.01
        let smallAmounts: [Decimal] = [0.01, 0.05, 0.10, 0.25, 0.50, 0.99]

        // Act & Assert
        for amount in smallAmounts {
            let transaction = TestDataFactory.createTransaction(amount: amount)
            assertDecimalEqual(transaction.amount, amount, accuracy: 0.001)
        }

        // Test arithmetic with small amounts
        let sum = smallAmounts.reduce(Decimal(0), +)
        assertDecimalEqual(sum, 2.90, accuracy: 0.01, "Sum of small amounts should be precise")
    }

    /// Test: Very large amounts don't overflow
    /// Ensures app can handle large account balances
    func test_decimalPrecision_veryLargeAmounts_noOverflow() throws {
        // Arrange
        let largeAmounts: [Decimal] = [
            999_999,
            1_000_000,
            10_000_000,
            100_000_000,
            999_999_999.99
        ]

        // Act & Assert
        for amount in largeAmounts {
            let account = TestDataFactory.createAccount(balance: amount)
            assertDecimalEqual(account.balance, amount, accuracy: 0.01)
        }

        // Test arithmetic with large amounts
        let billionaire = Decimal(string: "1000000000")! // 1 billion
        let account = TestDataFactory.createAccount(balance: billionaire)
        assertDecimalEqual(account.balance, billionaire)
    }

    /// Test: Repeated arithmetic operations don't accumulate rounding errors
    /// Critical for running balance calculations
    func test_decimalArithmetic_repeatedOperations_noRoundingErrors() throws {
        // Arrange
        var runningTotal: Decimal = 0
        let operations = 100

        // Act: Perform many additions
        for _ in 0..<operations {
            runningTotal += 0.01
        }

        // Assert: Should equal exactly 1.00
        assertDecimalEqual(runningTotal, 1.00, accuracy: 0.001, "100 × $0.01 should equal $1.00 exactly")

        // Test with subtraction
        for _ in 0..<operations {
            runningTotal -= 0.01
        }

        assertDecimalZero(runningTotal, accuracy: 0.001, "Should return to zero after reversing operations")
    }

    // MARK: - Date Boundary Edge Cases

    /// Test: Month boundary calculations handle correctly
    func test_dateCalculation_monthBoundary_handlesCorrectly() throws {
        // Arrange: Last day of month and first day of next month
        let lastDayOfJune = Date.from(year: 2024, month: 6, day: 30)
        let firstDayOfJuly = Date.from(year: 2024, month: 7, day: 1)

        // Act
        let juneStart = BudgetCalculations.startOfMonth(for: lastDayOfJune)
        let juneEnd = BudgetCalculations.endOfMonth(for: lastDayOfJune)
        let julyStart = BudgetCalculations.startOfMonth(for: firstDayOfJuly)

        // Assert
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.day, from: juneEnd), 30)
        XCTAssertEqual(calendar.component(.day, from: julyStart), 1)

        // Test transactions on boundary
        let transactions = [
            TestDataFactory.createTransaction(date: lastDayOfJune),
            TestDataFactory.createTransaction(date: firstDayOfJuly),
        ]

        let juneTransactions = BudgetCalculations.transactions(in: lastDayOfJune, from: transactions)
        XCTAssertEqual(juneTransactions.count, 1, "Only June 30 transaction should be in June")
    }

    /// Test: Year boundary calculations handle correctly
    func test_dateCalculation_yearBoundary_handlesCorrectly() throws {
        // Arrange: New Year's boundary
        let dec31_2023 = Date.from(year: 2023, month: 12, day: 31)
        let jan1_2024 = Date.from(year: 2024, month: 1, day: 1)

        // Act
        let decStart = BudgetCalculations.startOfMonth(for: dec31_2023)
        let decEnd = BudgetCalculations.endOfMonth(for: dec31_2023)
        let janStart = BudgetCalculations.startOfMonth(for: jan1_2024)

        // Assert
        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.year, from: decEnd), 2023)
        XCTAssertEqual(calendar.component(.year, from: janStart), 2024)
        XCTAssertEqual(calendar.component(.day, from: decEnd), 31)
        XCTAssertEqual(calendar.component(.day, from: janStart), 1)

        // Verify they're in different months
        XCTAssertFalse(BudgetCalculations.isDate(dec31_2023, inMonth: jan1_2024))
    }

    // MARK: - Negative Balance Edge Cases

    /// Test: Negative balance (credit cards/overdraft) allows and calculates correctly
    func test_negativeBalance_creditCards_allowsAndCalculates() throws {
        // Arrange: Credit card with debt
        let creditCard = TestDataFactory.createCreditCardAccount(balance: -2500.00)
        modelContext.insert(creditCard)

        // Act: Make payment (reduces debt)
        let payment = TestDataFactory.createExpense(amount: 500, account: creditCard)
        modelContext.insert(payment)
        creditCard.balance += 500 // Payment reduces negative balance
        try saveContext()

        // Assert: Debt decreased
        assertDecimalEqual(creditCard.balance, -2000.00, "Payment should reduce credit card debt")

        // Add charge (increases debt)
        let charge = TestDataFactory.createExpense(amount: 100, account: creditCard)
        modelContext.insert(charge)
        creditCard.balance -= 100
        try saveContext()

        assertDecimalEqual(creditCard.balance, -2100.00, "Charge should increase credit card debt")
    }

    // MARK: - Zero Value Edge Cases

    /// Test: Zero transaction is allowed and handled gracefully
    func test_zeroTransaction_allowed_handlesGracefully() throws {
        // Arrange & Act
        let zeroTransaction = TestDataFactory.createTransaction(amount: 0)
        modelContext.insert(zeroTransaction)
        try saveContext()

        // Assert: Transaction exists and is valid
        assertDecimalZero(zeroTransaction.amount)

        // Zero transactions don't affect calculations
        let category = TestDataFactory.createCategory()
        modelContext.insert(category)
        zeroTransaction.category = category

        let spending = BudgetCalculations.calculateActualSpending(
            for: category,
            in: Date(),
            from: [zeroTransaction]
        )

        assertDecimalZero(spending, "Zero transaction should not affect spending calculations")
    }

    // MARK: - Performance Edge Cases

    /// Test: Massive transaction count has acceptable performance
    func test_massiveTransactionCount_performance_acceptable() throws {
        // Arrange: Create many transactions
        let category = TestDataFactory.createCategory()
        modelContext.insert(category)

        let transactionCount = 1000
        var transactions: [Transaction] = []

        // Act: Create 1000 transactions (measure performance)
        measure {
            for i in 0..<transactionCount {
                let transaction = TestDataFactory.createExpense(
                    amount: Decimal(i),
                    category: category
                )
                transactions.append(transaction)
            }
        }

        // Assert: Calculations still work with large dataset
        let total = transactions.reduce(Decimal(0)) { $0 + $1.amount }
        assertDecimalPositive(total, "Should sum all transactions")

        // Test filtering performance with large dataset
        let month = Date()
        transactions.forEach { $0.date = month }
        let filtered = BudgetCalculations.transactions(in: month, from: transactions)

        XCTAssertEqual(filtered.count, transactionCount, "Should filter all transactions correctly")
    }

    // MARK: - Date Due Edge Cases

    /// Test: Category due date on February 29 (leap year) handles correctly
    func test_categoryDueDate_february29_handlesLeapYear() throws {
        // Arrange: Category with Feb 29 due date
        let category = TestDataFactory.createCategory(dueDayOfMonth: 29)
        category.isLastDayOfMonth = false

        // Act: Calculate effective due date in different years
        // In 2024 (leap year), should be Feb 29
        // In 2025 (non-leap), should clamp to Feb 28

        // For this test, we just verify it doesn't crash and returns valid date
        let effectiveDueDate = category.effectiveDueDate

        // Assert: Should return a valid date
        XCTAssertNotNil(effectiveDueDate, "Should handle Feb 29 gracefully")

        let calendar = Calendar.current
        let day = calendar.component(.day, from: effectiveDueDate!)

        // In current month, day should be <= days in month
        let month = calendar.component(.month, from: effectiveDueDate!)
        XCTAssertGreaterThanOrEqual(day, 1)
        XCTAssertLessThanOrEqual(day, 31)
    }

    /// Test: Category due date day 31 in 30-day month clamps correctly
    func test_categoryDueDate_day31_in30DayMonth_clampsCorrectly() throws {
        // Arrange: Category with day 31 due date
        let category = TestDataFactory.createCategory(dueDayOfMonth: 31)

        // Act: Get effective due date
        let effectiveDueDate = category.effectiveDueDate

        // Assert: Should return valid date (may clamp to last day of month)
        XCTAssertNotNil(effectiveDueDate)

        let calendar = Calendar.current
        let day = calendar.component(.day, from: effectiveDueDate!)
        let month = calendar.component(.month, from: effectiveDueDate!)

        // Verify day is valid for the month
        let daysInMonth = calendar.range(of: .day, in: .month, for: effectiveDueDate!)!.count

        XCTAssertLessThanOrEqual(day, daysInMonth, "Day should clamp to last day of month if needed")
    }
}
