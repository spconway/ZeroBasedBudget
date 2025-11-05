//
//  ZeroBasedBudgetTests.swift
//  ZeroBasedBudgetTests
//
//  Created by Claude Code on 2025-11-05.
//
//  Base test class providing infrastructure for all unit tests.
//  Includes:
//  - In-memory SwiftData container for isolated testing
//  - Custom assertions for Decimal precision testing
//  - Setup/teardown for test isolation
//

import XCTest
import SwiftData
@testable import ZeroBasedBudget

/// Base test class for ZeroBasedBudget unit tests
///
/// Provides:
/// - In-memory SwiftData ModelContainer for test isolation
/// - Custom Decimal equality assertions for financial calculations
/// - Setup/teardown ensuring no test contamination
class ZeroBasedBudgetTests: XCTestCase {

    // MARK: - Properties

    /// In-memory model container for isolated testing (no persistent storage)
    var modelContainer: ModelContainer!

    /// Model context for interacting with SwiftData in tests
    var modelContext: ModelContext!

    // MARK: - Setup & Teardown

    /// Set up test environment before each test
    /// Creates fresh in-memory SwiftData container and context
    override func setUpWithError() throws {
        try super.setUpWithError()

        // Define schema with all model types
        let schema = Schema([
            Account.self,
            Transaction.self,
            BudgetCategory.self,
            MonthlyBudget.self,
            AppSettings.self
        ])

        // Configure in-memory storage (critical for test isolation)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,  // Key: prevents test data persistence
            cloudKitDatabase: .none       // Required: no cloud sync
        )

        // Create container and context
        modelContainer = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        modelContext = ModelContext(modelContainer)
    }

    /// Clean up test environment after each test
    /// Ensures complete test isolation (no shared state)
    override func tearDownWithError() throws {
        // Release references to force deallocation
        modelContext = nil
        modelContainer = nil

        try super.tearDownWithError()
    }

    // MARK: - Custom Assertions

    /// Assert two Decimal values are equal within specified precision
    ///
    /// Use this for all monetary value comparisons to handle floating-point precision issues.
    ///
    /// - Parameters:
    ///   - actual: The actual Decimal value from test execution
    ///   - expected: The expected Decimal value
    ///   - accuracy: Acceptable difference (default: 0.01 for 2 decimal places)
    ///   - message: Optional custom error message
    ///   - file: Source file (auto-populated)
    ///   - line: Source line (auto-populated)
    ///
    /// Example:
    /// ```swift
    /// assertDecimalEqual(account.balance, 1000.50, accuracy: 0.01)
    /// ```
    func assertDecimalEqual(
        _ actual: Decimal,
        _ expected: Decimal,
        accuracy: Decimal = 0.01,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let difference = abs(actual - expected)
        let errorMessage = message.isEmpty
            ? "Expected \(expected), got \(actual) (difference: \(difference))"
            : message

        XCTAssertLessThanOrEqual(
            difference,
            accuracy,
            errorMessage,
            file: file,
            line: line
        )
    }

    /// Assert a Decimal value is zero within specified precision
    ///
    /// - Parameters:
    ///   - value: The Decimal value to test
    ///   - accuracy: Acceptable difference from zero (default: 0.01)
    ///   - message: Optional custom error message
    ///   - file: Source file (auto-populated)
    ///   - line: Source line (auto-populated)
    func assertDecimalZero(
        _ value: Decimal,
        accuracy: Decimal = 0.01,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        assertDecimalEqual(
            value,
            0,
            accuracy: accuracy,
            message.isEmpty ? "Expected zero, got \(value)" : message,
            file: file,
            line: line
        )
    }

    /// Assert a Decimal value is positive
    ///
    /// - Parameters:
    ///   - value: The Decimal value to test
    ///   - message: Optional custom error message
    ///   - file: Source file (auto-populated)
    ///   - line: Source line (auto-populated)
    func assertDecimalPositive(
        _ value: Decimal,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertGreaterThan(
            value,
            0,
            message.isEmpty ? "Expected positive value, got \(value)" : message,
            file: file,
            line: line
        )
    }

    /// Assert a Decimal value is negative
    ///
    /// - Parameters:
    ///   - value: The Decimal value to test
    ///   - message: Optional custom error message
    ///   - file: Source file (auto-populated)
    ///   - line: Source line (auto-populated)
    func assertDecimalNegative(
        _ value: Decimal,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertLessThan(
            value,
            0,
            message.isEmpty ? "Expected negative value, got \(value)" : message,
            file: file,
            line: line
        )
    }

    // MARK: - Helper Methods

    /// Save changes to model context and handle errors
    ///
    /// - Throws: Error if save fails
    func saveContext() throws {
        try modelContext.save()
    }

    /// Delete all data from model context (useful for test cleanup)
    func deleteAllData() throws {
        // Fetch and delete all accounts
        let accountDescriptor = FetchDescriptor<Account>()
        let accounts = try modelContext.fetch(accountDescriptor)
        accounts.forEach { modelContext.delete($0) }

        // Fetch and delete all transactions
        let transactionDescriptor = FetchDescriptor<Transaction>()
        let transactions = try modelContext.fetch(transactionDescriptor)
        transactions.forEach { modelContext.delete($0) }

        // Fetch and delete all budget categories
        let categoryDescriptor = FetchDescriptor<BudgetCategory>()
        let categories = try modelContext.fetch(categoryDescriptor)
        categories.forEach { modelContext.delete($0) }

        // Fetch and delete all monthly budgets
        let budgetDescriptor = FetchDescriptor<MonthlyBudget>()
        let budgets = try modelContext.fetch(budgetDescriptor)
        budgets.forEach { modelContext.delete($0) }

        // Fetch and delete all app settings
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let settings = try modelContext.fetch(settingsDescriptor)
        settings.forEach { modelContext.delete($0) }

        try saveContext()
    }

    // MARK: - Sample Test (Delete this after Enhancement 5.2)

    /// Sample test to verify test infrastructure works
    /// This test will be replaced by comprehensive test suite in Enhancement 5.2
    func testInfrastructure_whenSetup_thenContainerExists() throws {
        // Verify model container was created
        XCTAssertNotNil(modelContainer, "Model container should be initialized")
        XCTAssertNotNil(modelContext, "Model context should be initialized")

        // Verify we can create and save a test account
        let account = TestDataFactory.createAccount()
        modelContext.insert(account)
        try saveContext()

        // Verify we can fetch the account
        let descriptor = FetchDescriptor<Account>()
        let accounts = try modelContext.fetch(descriptor)
        XCTAssertEqual(accounts.count, 1, "Should have one account")

        // Verify custom assertions work
        assertDecimalEqual(account.balance, 1000)
        assertDecimalPositive(account.balance)
    }

    /// Sample YNAB test to verify methodology validation works
    func testYNAB_readyToAssign_calculatesCorrectly() throws {
        // Arrange: Create YNAB scenario
        let (account, categories, expectedReadyToAssign) = try TestScenarios.createYNABScenario(in: modelContext)

        // Act: Calculate Ready to Assign
        let accounts = [account]
        let transactions: [Transaction] = [] // No income yet
        let actualReadyToAssign = YNABTestHelpers.calculateExpectedReadyToAssign(
            accounts: accounts,
            transactions: transactions,
            categories: categories
        )

        // Assert: Ready to Assign matches expected
        assertDecimalEqual(
            actualReadyToAssign,
            expectedReadyToAssign,
            "Ready to Assign should equal starting balance minus budgeted amounts"
        )

        // Verify it's $700 (1000 - 200 - 100)
        assertDecimalEqual(actualReadyToAssign, 700)
    }
}
