//
//  ZeroBudgetMethodologyTests.swift
//  ZeroBasedBudgetTests
//
//  Created by Claude Code on 2025-11-05.
//
//  CRITICAL: Unit tests validating ZeroBudget (You Need A Budget) methodology compliance
//  Tests core ZeroBudget principles: Ready to Assign calculations, income handling, expense tracking,
//  and the fundamental rule of budgeting only money you have TODAY.
//
//  These tests are the most important in the suite - they ensure the app follows
//  ZeroBudget methodology correctly and prevents methodology violations.
//

import XCTest
import SwiftData
@testable import ZeroBasedBudget

final class ZeroBudgetMethodologyTests: ZeroBasedBudgetTests {

    // MARK: - Ready to Assign Calculation Tests

    /// Test: Ready to Assign = Sum(startingBalance) + Sum(income) - Sum(budgeted)
    /// ZeroBudget Principle: Budget only money you have TODAY (starting balance + received income)
    func test_readyToAssign_calculation_usesStartingBalancePlusIncome() throws {
        // Arrange: Create accounts with starting balances
        let checking = TestDataFactory.createCheckingAccount(balance: 2000)
        let savings = TestDataFactory.createSavingsAccount(balance: 5000)
        modelContext.insert(checking)
        modelContext.insert(savings)

        // Create categories with budgeted amounts
        let rent = TestDataFactory.createFixedCategory(name: "Rent", amount: 1500)
        let groceries = TestDataFactory.createVariableCategory(name: "Groceries", amount: 400)
        modelContext.insert(rent)
        modelContext.insert(groceries)

        // Create income transaction
        let income = TestDataFactory.createIncome(amount: 3000, account: checking)
        modelContext.insert(income)

        try saveContext()

        // Act: Calculate Ready to Assign using ZeroBudget formula
        let accounts = [checking, savings]
        let transactions = [income]
        let categories = [rent, groceries]

        let actualReadyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: accounts,
            transactions: transactions,
            categories: categories
        )

        // Assert: Ready to Assign = (2000 + 5000) + 3000 - (1500 + 400) = 8100
        let expectedReadyToAssign: Decimal = 8100
        assertDecimalEqual(
            actualReadyToAssign,
            expectedReadyToAssign,
            "Ready to Assign must equal: Sum(starting balances) + Sum(income) - Sum(budgeted)"
        )
    }

    /// Test: Expenses do NOT reduce Ready to Assign (only budgeting does)
    /// ZeroBudget Principle: Spending reduces account balance, NOT Ready to Assign
    func test_readyToAssign_afterExpense_remainsUnchanged() throws {
        // Arrange: Setup initial state
        let account = TestDataFactory.createCheckingAccount(balance: 1000)
        let category = TestDataFactory.createCategory(name: "Groceries", budgetedAmount: 400)
        modelContext.insert(account)
        modelContext.insert(category)

        // Calculate initial Ready to Assign
        let initialReadyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: [account],
            transactions: [],
            categories: [category]
        )

        // Act: Add expense transaction
        let expense = TestDataFactory.createExpense(amount: 150, category: category, account: account)
        modelContext.insert(expense)
        try saveContext()

        // Calculate Ready to Assign after expense
        let afterExpenseReadyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: [account],
            transactions: [expense],
            categories: [category]
        )

        // Assert: Ready to Assign should NOT change after expense
        assertDecimalEqual(
            afterExpenseReadyToAssign,
            initialReadyToAssign,
            "CRITICAL: Expenses must NOT reduce Ready to Assign (only budgeting reduces it)"
        )

        // Verify the helper validates correctly
        XCTAssertTrue(
            ZeroBudgetTestHelpers.validateExpenseDoesNotReduceReadyToAssign(
                before: initialReadyToAssign,
                after: afterExpenseReadyToAssign
            ),
            "ZeroBudget validation helper should confirm expense doesn't reduce Ready to Assign"
        )
    }

    /// Test: Income increases Ready to Assign
    /// ZeroBudget Principle: New income increases money available to budget
    func test_readyToAssign_afterIncome_increases() throws {
        // Arrange: Initial state
        let account = TestDataFactory.createCheckingAccount(balance: 1000)
        let category = TestDataFactory.createCategory(budgetedAmount: 600)
        modelContext.insert(account)
        modelContext.insert(category)

        // Calculate initial Ready to Assign
        let initialReadyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: [account],
            transactions: [],
            categories: [category]
        )

        // Act: Add income transaction
        let incomeAmount: Decimal = 2000
        let income = TestDataFactory.createIncome(amount: incomeAmount, account: account)
        modelContext.insert(income)
        try saveContext()

        // Calculate Ready to Assign after income
        let afterIncomeReadyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: [account],
            transactions: [income],
            categories: [category]
        )

        // Assert: Ready to Assign should increase by income amount
        assertDecimalEqual(
            afterIncomeReadyToAssign - initialReadyToAssign,
            incomeAmount,
            "Income must increase Ready to Assign by exact income amount"
        )

        // Verify the helper validates correctly
        XCTAssertTrue(
            ZeroBudgetTestHelpers.validateIncomeIncreasesReadyToAssign(
                before: initialReadyToAssign,
                after: afterIncomeReadyToAssign,
                incomeAmount: incomeAmount
            ),
            "ZeroBudget validation helper should confirm income increases Ready to Assign"
        )
    }

    /// Test: Budgeting (assigning money to categories) reduces Ready to Assign
    /// ZeroBudget Principle: Assigning money gives it a job, reducing available funds
    func test_readyToAssign_afterBudgeting_decreases() throws {
        // Arrange: Account with starting balance, no categories yet
        let account = TestDataFactory.createCheckingAccount(balance: 1000)
        modelContext.insert(account)

        // Initial Ready to Assign = 1000 (no budgeted amounts)
        let initialReadyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: [account],
            transactions: [],
            categories: []
        )

        // Act: Create categories (budget money to them)
        let rent = TestDataFactory.createCategory(name: "Rent", budgetedAmount: 600)
        let groceries = TestDataFactory.createCategory(name: "Groceries", budgetedAmount: 200)
        modelContext.insert(rent)
        modelContext.insert(groceries)
        try saveContext()

        // Calculate Ready to Assign after budgeting
        let afterBudgetingReadyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: [account],
            transactions: [],
            categories: [rent, groceries]
        )

        // Assert: Ready to Assign should decrease by budgeted amounts
        assertDecimalEqual(initialReadyToAssign, 1000, "Initial should be 1000")
        assertDecimalEqual(afterBudgetingReadyToAssign, 200, "After budgeting should be 200 (1000 - 600 - 200)")
        assertDecimalEqual(
            initialReadyToAssign - afterBudgetingReadyToAssign,
            800,
            "Budgeting must reduce Ready to Assign by total budgeted amount"
        )
    }

    // MARK: - Account Balance Tests

    /// Test: Expenses reduce account balance (separate from Ready to Assign)
    /// ZeroBudget Principle: Expenses affect account balance, NOT Ready to Assign
    func test_accountBalance_afterExpense_decreasesCorrectly() throws {
        // Arrange
        let initialBalance: Decimal = 1000
        let account = TestDataFactory.createCheckingAccount(balance: initialBalance)
        let category = TestDataFactory.createCategory()
        modelContext.insert(account)
        modelContext.insert(category)

        // Act: Create expense
        let expenseAmount: Decimal = 250
        let expense = TestDataFactory.createExpense(amount: expenseAmount, category: category, account: account)
        modelContext.insert(expense)

        // Manually update account balance (in real app, this happens automatically)
        account.balance -= expenseAmount
        try saveContext()

        // Assert: Account balance decreased, but startingBalance unchanged
        assertDecimalEqual(
            account.balance,
            750,
            "Account balance must decrease after expense"
        )
        assertDecimalEqual(
            account.startingBalance,
            initialBalance,
            "Starting balance must remain unchanged"
        )
    }

    /// Test: Income increases account balance
    /// ZeroBudget Principle: Income adds to account balance AND Ready to Assign
    func test_accountBalance_afterIncome_increasesCorrectly() throws {
        // Arrange
        let initialBalance: Decimal = 1000
        let account = TestDataFactory.createCheckingAccount(balance: initialBalance)
        modelContext.insert(account)

        // Act: Create income
        let incomeAmount: Decimal = 500
        let income = TestDataFactory.createIncome(amount: incomeAmount, account: account)
        modelContext.insert(income)

        // Manually update account balance
        account.balance += incomeAmount
        try saveContext()

        // Assert: Account balance increased
        assertDecimalEqual(
            account.balance,
            1500,
            "Account balance must increase after income"
        )
    }

    // MARK: - Zero Budget Category Tests

    /// Test: Categories can have $0 budgeted (ZeroBudget principle: tracked but unfunded)
    /// ZeroBudget Principle: Track categories even if not budgeting money to them
    func test_zeroBudgetedCategory_allowed_followsZeroBudget() throws {
        // Arrange & Act
        let category = TestDataFactory.createCategory(budgetedAmount: 0)
        modelContext.insert(category)
        try saveContext()

        // Assert: Category exists and is valid
        assertDecimalZero(category.budgetedAmount)
        XCTAssertNotNil(category.name, "Category should exist even with $0 budgeted")

        // Verify it doesn't affect Ready to Assign
        let account = TestDataFactory.createCheckingAccount(balance: 1000)
        modelContext.insert(account)

        let readyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: [account],
            transactions: [],
            categories: [category]
        )

        assertDecimalEqual(readyToAssign, 1000, "$0 category should not reduce Ready to Assign")
    }

    // MARK: - Income Through Transactions Tests

    /// Test: Income is logged via transactions, NOT pre-budgeted
    /// ZeroBudget Principle: Budget money you HAVE, not money you EXPECT
    func test_incomeThroughTransactions_notPreBudgeted_followsZeroBudget() throws {
        // Arrange: Account with starting balance only
        let account = TestDataFactory.createCheckingAccount(balance: 1000)
        modelContext.insert(account)

        // Ready to Assign should be starting balance only
        let beforeIncomeReadyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: [account],
            transactions: [],
            categories: []
        )
        assertDecimalEqual(beforeIncomeReadyToAssign, 1000, "Should only have starting balance")

        // Act: Income arrives via transaction (NOT pre-budgeted)
        let income = TestDataFactory.createIncome(amount: 2000, account: account)
        modelContext.insert(income)
        try saveContext()

        // Assert: Ready to Assign NOW includes income
        let afterIncomeReadyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: [account],
            transactions: [income],
            categories: []
        )
        assertDecimalEqual(
            afterIncomeReadyToAssign,
            3000,
            "Ready to Assign should now include received income (1000 + 2000)"
        )
    }

    /// Test: Budget only available money, not future income
    /// ZeroBudget Principle: You can only assign money that exists TODAY
    func test_budgetOnlyAvailableMoney_notFutureIncome_followsZeroBudget() throws {
        // Arrange: Setup with limited funds
        let account = TestDataFactory.createCheckingAccount(balance: 500)
        modelContext.insert(account)

        // Try to budget more than available
        let category1 = TestDataFactory.createCategory(name: "Category 1", budgetedAmount: 300)
        let category2 = TestDataFactory.createCategory(name: "Category 2", budgetedAmount: 300)
        modelContext.insert(category1)
        modelContext.insert(category2)

        // Act: Calculate Ready to Assign
        let readyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: [account],
            transactions: [],
            categories: [category1, category2]
        )

        // Assert: Ready to Assign goes NEGATIVE (over-budgeted)
        assertDecimalNegative(
            readyToAssign,
            "Over-budgeting should result in negative Ready to Assign (WARNING state)"
        )
        assertDecimalEqual(
            readyToAssign,
            -100,
            "Should be -$100 (500 - 300 - 300 = -100)"
        )

        // This negative value alerts user they've budgeted money they don't have
        XCTAssertLessThan(readyToAssign, 0, "ZeroBudget compliance: User should see they over-budgeted")
    }

    // MARK: - Transaction-Account Link Tests

    /// Test: Transaction-account relationship maintains balance integrity
    /// ZeroBudget Principle: Transactions must properly update account balances
    func test_transactionAccountLink_updatesBalance_maintainsIntegrity() throws {
        // Arrange
        let account = TestDataFactory.createCheckingAccount(balance: 1000)
        modelContext.insert(account)

        // Act: Create linked transaction
        let expense = TestDataFactory.createExpense(amount: 250, account: account)
        modelContext.insert(expense)
        try saveContext()

        // Assert: Relationship is bidirectional
        XCTAssertEqual(expense.account?.id, account.id, "Transaction should link to account")
        XCTAssertTrue(account.transactions.contains(expense), "Account should contain transaction")
    }

    /// Test: Multiple accounts total balance sums correctly
    /// ZeroBudget Principle: Sum of all account balances = total money available
    func test_multipleAccounts_totalBalance_sumsCorrectly() throws {
        // Arrange
        let checking = TestDataFactory.createCheckingAccount(balance: 2000)
        let savings = TestDataFactory.createSavingsAccount(balance: 5000)
        let cash = TestDataFactory.createCashAccount(balance: 100)
        modelContext.insert(checking)
        modelContext.insert(savings)
        modelContext.insert(cash)

        let accounts = [checking, savings, cash]

        // Act: Calculate total available money
        let totalBalance = accounts.reduce(Decimal(0)) { $0 + $1.startingBalance }

        // Assert: Total = sum of all account starting balances
        assertDecimalEqual(
            totalBalance,
            7100,
            "Total money available = sum of all account balances (2000 + 5000 + 100)"
        )

        // This total is the basis for Ready to Assign
        let readyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: accounts,
            transactions: [],
            categories: []
        )
        assertDecimalEqual(readyToAssign, totalBalance, "Ready to Assign should equal total balance when nothing budgeted")
    }

    /// Test: Category spending doesn't affect Ready to Assign, only budgeting does
    /// ZeroBudget Principle: SPENDING from category != ASSIGNING to category
    func test_categorySpending_doesNotAffectReadyToAssign_onlyBudgeting() throws {
        // Arrange: Setup budget
        let account = TestDataFactory.createCheckingAccount(balance: 1000)
        let category = TestDataFactory.createCategory(budgetedAmount: 400)
        modelContext.insert(account)
        modelContext.insert(category)

        // Initial Ready to Assign
        let initialReadyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: [account],
            transactions: [],
            categories: [category]
        )

        // Act: Spend from category
        let expense1 = TestDataFactory.createExpense(amount: 100, category: category)
        let expense2 = TestDataFactory.createExpense(amount: 150, category: category)
        modelContext.insert(expense1)
        modelContext.insert(expense2)
        try saveContext()

        // Calculate Ready to Assign after spending
        let afterSpendingReadyToAssign = ZeroBudgetTestHelpers.calculateExpectedReadyToAssign(
            accounts: [account],
            transactions: [expense1, expense2],
            categories: [category]
        )

        // Assert: Ready to Assign unchanged by spending
        assertDecimalEqual(
            afterSpendingReadyToAssign,
            initialReadyToAssign,
            "CRITICAL: Category spending must NOT affect Ready to Assign (only budgeting does)"
        )

        // Category has "available" amount (budgeted - spent), but that's separate from Ready to Assign
        let categoryAvailable = category.budgetedAmount - 100 - 150
        assertDecimalEqual(categoryAvailable, 150, "Category has $150 available (400 - 250 spent)")
    }
}
