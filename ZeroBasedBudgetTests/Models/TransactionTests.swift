//
//  TransactionTests.swift
//  ZeroBasedBudgetTests
//
//  Created by Claude Code on 2025-11-05.
//
//  Unit tests for Transaction model
//  Tests transaction initialization, types, relationships, and data integrity
//

import XCTest
import SwiftData
@testable import ZeroBasedBudget

final class TransactionTests: ZeroBasedBudgetTests {

    // MARK: - Initialization Tests

    /// Test: Transaction initializes successfully with valid data
    func test_transactionInitialization_withValidData_createsSuccessfully() throws {
        // Arrange
        let date = TestDataFactory.fixedDate2024Jan1
        let amount: Decimal = 150.50
        let description = "Test Transaction"

        // Act
        let transaction = TestDataFactory.createTransaction(
            date: date,
            amount: amount,
            description: description,
            type: .expense
        )

        // Assert
        XCTAssertEqual(transaction.date, date)
        assertDecimalEqual(transaction.amount, amount)
        XCTAssertEqual(transaction.transactionDescription, description)
        XCTAssertEqual(transaction.type, .expense)
        XCTAssertNotNil(transaction.id)
    }

    // MARK: - Decimal Precision Tests

    /// Test: Transaction amount maintains Decimal precision
    /// Critical: Prevents rounding errors in financial calculations
    func test_transactionAmount_withDecimal_maintainsPrecision() throws {
        // Arrange
        let preciseAmount = Decimal(string: "123.456789")!

        // Act
        let transaction = TestDataFactory.createTransaction(amount: preciseAmount)

        // Assert
        // Full precision is maintained in Decimal type
        XCTAssertEqual(transaction.amount, preciseAmount)

        // Test with common monetary values
        transaction.amount = Decimal(string: "999.99")!
        assertDecimalEqual(transaction.amount, 999.99, accuracy: 0.001)
    }

    // MARK: - Transaction Type Tests

    /// Test: Income transaction is created correctly
    /// ZeroBudget Principle: Income increases Ready to Assign
    func test_transactionType_income_createdCorrectly() throws {
        // Arrange & Act
        let income = TestDataFactory.createIncome(
            amount: 3000,
            description: "Paycheck"
        )

        // Assert
        XCTAssertEqual(income.type, .income)
        assertDecimalEqual(income.amount, 3000)
        XCTAssertNil(income.category) // Income typically has no category
    }

    /// Test: Expense transaction is created correctly
    /// ZeroBudget Principle: Expenses reduce account balance, not Ready to Assign
    func test_transactionType_expense_createdCorrectly() throws {
        // Arrange
        let category = TestDataFactory.createCategory(name: "Groceries")
        modelContext.insert(category)

        // Act
        let expense = TestDataFactory.createExpense(
            amount: 150,
            description: "Whole Foods",
            category: category
        )

        // Assert
        XCTAssertEqual(expense.type, .expense)
        assertDecimalEqual(expense.amount, 150)
        XCTAssertEqual(expense.category?.name, "Groceries")
    }

    // MARK: - Category Relationship Tests

    /// Test: Transaction allows optional category (nil value)
    /// Use case: Uncategorized transactions, income
    func test_categoryRelationship_whenOptional_allowsNil() throws {
        // Arrange & Act
        let transaction = TestDataFactory.createTransaction(category: nil)

        // Assert
        XCTAssertNil(transaction.category)
    }

    /// Test: Transaction links to category correctly
    func test_categoryRelationship_whenSet_linksCorrectly() throws {
        // Arrange
        let category = TestDataFactory.createCategory(name: "Rent")
        modelContext.insert(category)

        // Act
        let transaction = TestDataFactory.createExpense(
            amount: 1500,
            category: category
        )
        modelContext.insert(transaction)
        try saveContext()

        // Assert
        XCTAssertNotNil(transaction.category)
        XCTAssertEqual(transaction.category?.name, "Rent")

        // Verify inverse relationship
        XCTAssertTrue(category.transactions.contains(transaction))
    }

    // MARK: - Account Relationship Tests

    /// Test: Transaction allows optional account (nil value)
    /// Use case: Legacy transactions before account feature added
    func test_accountRelationship_whenOptional_allowsNil() throws {
        // Arrange & Act
        let transaction = TestDataFactory.createTransaction(account: nil)

        // Assert
        XCTAssertNil(transaction.account)
    }

    /// Test: Transaction links to account correctly
    /// ZeroBudget Principle: Transactions update account balances
    func test_accountRelationship_whenSet_linksCorrectly() throws {
        // Arrange
        let account = TestDataFactory.createCheckingAccount(balance: 1000)
        modelContext.insert(account)

        // Act
        let transaction = TestDataFactory.createExpense(
            amount: 250,
            account: account
        )
        modelContext.insert(transaction)
        try saveContext()

        // Assert
        XCTAssertNotNil(transaction.account)
        XCTAssertEqual(transaction.account?.name, "Test Checking")

        // Verify inverse relationship
        XCTAssertTrue(account.transactions.contains(transaction))
    }

    // MARK: - Optional Field Tests

    /// Test: Receipt image data is optional (allows nil and data)
    func test_receiptImageData_whenOptional_allowsNilAndData() throws {
        // Arrange
        let transaction = TestDataFactory.createTransaction()

        // Act & Assert - Initially nil
        XCTAssertNil(transaction.receiptImageData)

        // Add image data
        let imageData = Data([0x00, 0x01, 0x02, 0x03])
        transaction.receiptImageData = imageData

        // Assert - Data is stored
        XCTAssertNotNil(transaction.receiptImageData)
        XCTAssertEqual(transaction.receiptImageData, imageData)
    }

    /// Test: Transaction description stores correctly
    func test_transactionDescription_whenValid_storesCorrectly() throws {
        // Arrange
        let descriptions = [
            "Grocery shopping at Whole Foods",
            "Rent payment",
            "Gas - Shell Station",
            "Amazon purchase"
        ]

        // Act & Assert
        for desc in descriptions {
            let transaction = TestDataFactory.createTransaction(description: desc)
            XCTAssertEqual(transaction.transactionDescription, desc)
        }
    }

    // MARK: - Date Tests

    /// Test: Transaction date stores exact time
    func test_transactionDate_withSpecificDate_storesExactTime() throws {
        // Arrange
        let specificDate = Date.from(year: 2024, month: 6, day: 15, hour: 14, minute: 30)

        // Act
        let transaction = TestDataFactory.createTransaction(date: specificDate)

        // Assert
        XCTAssertEqual(transaction.date, specificDate)

        // Verify date components
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: transaction.date)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.hour, 14)
        XCTAssertEqual(components.minute, 30)
    }

    // MARK: - ID Uniqueness Tests

    /// Test: Multiple transactions generate unique IDs
    func test_idUniqueness_forMultipleTransactions_generatesUniqueIDs() throws {
        // Arrange & Act
        let transaction1 = TestDataFactory.createTransaction()
        let transaction2 = TestDataFactory.createTransaction()
        let transaction3 = TestDataFactory.createTransaction()

        // Assert
        XCTAssertNotEqual(transaction1.id, transaction2.id)
        XCTAssertNotEqual(transaction2.id, transaction3.id)
        XCTAssertNotEqual(transaction1.id, transaction3.id)

        // Verify all IDs are valid UUIDs
        XCTAssertNotEqual(transaction1.id, UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
        XCTAssertNotEqual(transaction2.id, UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
        XCTAssertNotEqual(transaction3.id, UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
    }
}
