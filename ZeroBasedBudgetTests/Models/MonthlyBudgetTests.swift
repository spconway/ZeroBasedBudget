//
//  MonthlyBudgetTests.swift
//  ZeroBasedBudgetTests
//
//  Created by Claude Code on 2025-11-05.
//
//  Unit tests for MonthlyBudget model
//  Tests monthly budget initialization, starting balance, and ZeroBudget principles
//

import XCTest
import SwiftData
@testable import ZeroBasedBudget

final class MonthlyBudgetTests: ZeroBasedBudgetTests {

    // MARK: - Initialization Tests

    /// Test: Monthly budget initializes with valid data
    func test_monthlyBudgetInit_withValidData_createsSuccessfully() throws {
        // Arrange
        let month = TestDataFactory.fixedDate2024Jan1
        let startingBalance: Decimal = 5000

        // Act
        let budget = TestDataFactory.createMonthlyBudget(
            month: month,
            startingBalance: startingBalance
        )

        // Assert
        XCTAssertEqual(budget.month, month)
        assertDecimalEqual(budget.startingBalance, startingBalance)
        XCTAssertNil(budget.notes) // Default value
    }

    // MARK: - Starting Balance Tests

    /// Test: Starting balance maintains Decimal precision
    /// ZeroBudget Principle: startingBalance represents actual money available at month start
    func test_startingBalance_withDecimal_maintainsPrecision() throws {
        // Arrange
        let preciseBalance = Decimal(string: "3456.78")!

        // Act
        let budget = TestDataFactory.createMonthlyBudget(startingBalance: preciseBalance)

        // Assert
        assertDecimalEqual(budget.startingBalance, preciseBalance, accuracy: 0.001)
    }

    /// Test: Starting balance allows zero (ZeroBudget principle: start with what you have)
    /// ZeroBudget Principle: If you have $0, you start with $0 (no future income assumed)
    func test_startingBalance_withZero_allowsZeroBudgetStartingPoint() throws {
        // Arrange & Act
        let budget = TestDataFactory.createMonthlyBudget(startingBalance: 0)

        // Assert
        assertDecimalZero(budget.startingBalance)
        // Budget should still be valid even with $0
        XCTAssertNotNil(budget.month)
    }

    // MARK: - Month Date Tests

    /// Test: Month stores first day of month correctly
    /// ZeroBudget Principle: Budgets are organized by month
    func test_month_storesFirstDayOfMonth_correctly() throws {
        // Arrange
        let january2024 = Date.from(year: 2024, month: 1, day: 1)
        let february2024 = Date.from(year: 2024, month: 2, day: 1)

        // Act
        let budget1 = TestDataFactory.createMonthlyBudget(month: january2024)
        let budget2 = TestDataFactory.createMonthlyBudget(month: february2024)

        // Assert
        let calendar = Calendar.current

        // January budget
        let jan1Components = calendar.dateComponents([.year, .month, .day], from: budget1.month)
        XCTAssertEqual(jan1Components.year, 2024)
        XCTAssertEqual(jan1Components.month, 1)
        XCTAssertEqual(jan1Components.day, 1)

        // February budget
        let feb1Components = calendar.dateComponents([.year, .month, .day], from: budget2.month)
        XCTAssertEqual(feb1Components.year, 2024)
        XCTAssertEqual(feb1Components.month, 2)
        XCTAssertEqual(feb1Components.day, 1)
    }

    // MARK: - Optional Field Tests

    /// Test: Notes field is optional and allows nil and strings
    func test_notes_whenOptional_allowsNilAndStrings() throws {
        // Arrange & Act
        let budget = TestDataFactory.createMonthlyBudget()

        // Assert - Initially nil
        XCTAssertNil(budget.notes)

        // Add notes
        budget.notes = "Expecting large bonus this month"
        XCTAssertEqual(budget.notes, "Expecting large bonus this month")

        // Clear notes
        budget.notes = nil
        XCTAssertNil(budget.notes)
    }
}
