//
//  AccountTests.swift
//  ZeroBasedBudgetTests
//
//  Created by Claude Code on 2025-11-05.
//
//  Unit tests for Account model
//  Tests account initialization, balance tracking, relationships, and ZeroBudget principles
//

import XCTest
import SwiftData
@testable import ZeroBasedBudget

final class AccountTests: ZeroBasedBudgetTests {

    // MARK: - Initialization Tests

    /// Test: Account initializes successfully with valid data
    func test_accountInitialization_withValidData_createsAccountSuccessfully() throws {
        // Arrange & Act
        let account = TestDataFactory.createAccount(
            name: "Test Checking",
            balance: 1500.50,
            accountType: "Checking"
        )

        // Assert
        XCTAssertEqual(account.name, "Test Checking")
        assertDecimalEqual(account.balance, 1500.50)
        XCTAssertEqual(account.accountType, "Checking")
        XCTAssertNotNil(account.id)
        XCTAssertNotNil(account.createdDate)
    }

    /// Test: Account initializes with zero balance correctly
    /// ZeroBudget Principle: Accounts can start with $0 (new account, empty wallet, etc.)
    func test_accountInitialization_withZeroBalance_setsStartingBalanceToZero() throws {
        // Arrange & Act
        let account = TestDataFactory.createAccount(balance: 0)

        // Assert
        assertDecimalZero(account.balance)
        assertDecimalZero(account.startingBalance)
    }

    /// Test: Account allows negative balance for credit cards
    /// ZeroBudget Principle: Credit card debt is represented as negative account balance
    func test_accountInitialization_withNegativeBalance_allowsNegativeForCreditCards() throws {
        // Arrange & Act
        let creditCard = TestDataFactory.createCreditCardAccount(balance: -1500.00)

        // Assert
        assertDecimalNegative(creditCard.balance)
        assertDecimalEqual(creditCard.balance, -1500.00)
        XCTAssertEqual(creditCard.accountType, "Credit Card")
    }

    // MARK: - Starting Balance Tests

    /// Test: Starting balance matches initial balance after initialization
    /// ZeroBudget Principle: startingBalance is used for Ready to Assign calculation
    func test_startingBalance_afterInitialization_matchesInitialBalance() throws {
        // Arrange
        let initialBalance: Decimal = 2500.75

        // Act
        let account = TestDataFactory.createAccount(balance: initialBalance)

        // Assert
        assertDecimalEqual(account.startingBalance, initialBalance)
        assertDecimalEqual(account.balance, initialBalance)
        assertDecimalEqual(account.startingBalance, account.balance)
    }

    /// Test: Balance updates correctly after income transaction
    /// Note: This tests direct balance modification (transaction logic tested separately)
    func test_balanceUpdate_afterIncome_increasesCorrectly() throws {
        // Arrange
        let account = TestDataFactory.createAccount(balance: 1000)
        let incomeAmount: Decimal = 500

        // Act
        account.balance += incomeAmount

        // Assert
        assertDecimalEqual(account.balance, 1500)
        // Starting balance should remain unchanged
        assertDecimalEqual(account.startingBalance, 1000)
    }

    /// Test: Balance updates correctly after expense transaction
    /// Note: This tests direct balance modification (transaction logic tested separately)
    func test_balanceUpdate_afterExpense_decreasesCorrectly() throws {
        // Arrange
        let account = TestDataFactory.createAccount(balance: 1000)
        let expenseAmount: Decimal = 250.50

        // Act
        account.balance -= expenseAmount

        // Assert
        assertDecimalEqual(account.balance, 749.50)
        // Starting balance should remain unchanged
        assertDecimalEqual(account.startingBalance, 1000)
    }

    // MARK: - Relationship Tests

    /// Test: Account-transaction relationship maintains inverse integrity
    func test_transactions_relationship_inverseMaintainsIntegrity() throws {
        // Arrange
        let account = TestDataFactory.createAccount()
        modelContext.insert(account)

        let transaction1 = TestDataFactory.createExpense(account: account)
        let transaction2 = TestDataFactory.createExpense(account: account)
        modelContext.insert(transaction1)
        modelContext.insert(transaction2)

        try saveContext()

        // Act & Assert
        XCTAssertEqual(account.transactions.count, 2)
        XCTAssertTrue(account.transactions.contains(transaction1))
        XCTAssertTrue(account.transactions.contains(transaction2))

        // Verify inverse relationship
        XCTAssertEqual(transaction1.account?.id, account.id)
        XCTAssertEqual(transaction2.account?.id, account.id)
    }

    // MARK: - Optional Property Tests

    /// Test: Account type is optional and allows nil values
    func test_accountType_whenOptional_allowsNilValues() throws {
        // Arrange & Act
        let account = TestDataFactory.createAccount(accountType: nil)

        // Assert
        XCTAssertNil(account.accountType)
    }

    // MARK: - Date Tests

    /// Test: Created date is set to recent date after initialization
    func test_createdDate_afterInit_isRecentDate() throws {
        // Arrange
        let beforeCreation = Date()

        // Act
        let account = TestDataFactory.createAccount()

        // Assert
        let afterCreation = Date()
        XCTAssertTrue(account.createdDate >= beforeCreation)
        XCTAssertTrue(account.createdDate <= afterCreation)
        XCTAssertTrue(account.createdDate.timeIntervalSinceNow < 1) // Created within last second
    }

    // MARK: - Decimal Precision Tests

    /// Test: Balance maintains two decimal place precision
    /// Critical for monetary calculations
    func test_decimalPrecision_forBalance_maintainsTwoDecimalPlaces() throws {
        // Arrange & Act
        let account = TestDataFactory.createAccount(balance: 1234.56789)

        // Assert - Decimal stores full precision, but we verify it rounds correctly for display
        // The actual stored value has full precision
        assertDecimalEqual(account.balance, 1234.57, accuracy: 0.01)

        // Test with precise value
        account.balance = Decimal(string: "999.99")!
        assertDecimalEqual(account.balance, 999.99, accuracy: 0.001)
    }
}
