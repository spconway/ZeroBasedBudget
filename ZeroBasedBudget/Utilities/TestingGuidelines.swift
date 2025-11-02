//
//  TestingGuidelines.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//
//  Unit testing guidelines and test cases for budget calculations
//

import Foundation

/**
 UNIT TESTING GUIDELINES

 This document provides comprehensive test cases for all critical calculations
 and business logic in the ZeroBasedBudget app.

 ## BudgetCalculations Utility Tests

 ### Date Utility Tests

 **Test: startOfMonth(for:)**
 ```swift
 let date = Date() // 2025-11-15 14:30:00
 let result = BudgetCalculations.startOfMonth(for: date)
 // Expected: 2025-11-01 00:00:00

 // Edge cases:
 // - First day of month: should return same day at 00:00:00
 // - Last day of month: should return first day at 00:00:00
 // - Leap year February: should handle correctly
 ```

 **Test: endOfMonth(for:)**
 ```swift
 let date = Date() // 2025-11-15 14:30:00
 let result = BudgetCalculations.endOfMonth(for: date)
 // Expected: 2025-11-30 23:59:59

 // Edge cases:
 // - January (31 days): returns Jan 31
 // - February (28/29 days): returns Feb 28/29
 // - April (30 days): returns Apr 30
 ```

 **Test: isDate(_:inMonth:)**
 ```swift
 let date1 = Date() // 2025-11-15
 let date2 = Date() // 2025-11-01
 let month = Date() // 2025-11-20

 XCTAssertTrue(BudgetCalculations.isDate(date1, inMonth: month))
 XCTAssertTrue(BudgetCalculations.isDate(date2, inMonth: month))

 let differentMonth = Date() // 2025-12-01
 XCTAssertFalse(BudgetCalculations.isDate(date1, inMonth: differentMonth))
 ```

 ### Transaction Filtering Tests

 **Test: transactions(in:from:)**
 ```swift
 let nov2025 = Date() // 2025-11-01
 let transactions = [
     Transaction(date: nov1, amount: 100, ...), // Nov 1
     Transaction(date: nov15, amount: 200, ...), // Nov 15
     Transaction(date: oct31, amount: 50, ...), // Oct 31
     Transaction(date: dec1, amount: 75, ...) // Dec 1
 ]

 let result = BudgetCalculations.transactions(in: nov2025, from: transactions)
 // Expected: 2 transactions (Nov 1 and Nov 15)
 XCTAssertEqual(result.count, 2)
 ```

 **Test: transactions(for:in:from:)**
 ```swift
 let groceries = BudgetCategory(name: "Groceries", ...)
 let nov2025 = Date()
 let transactions = [
     Transaction(..., category: groceries), // Nov transaction
     Transaction(..., category: groceries), // Oct transaction
     Transaction(..., category: utilities), // Nov transaction (different category)
 ]

 let result = BudgetCalculations.transactions(
     for: groceries,
     in: nov2025,
     from: transactions
 )
 // Expected: 1 transaction (Nov + groceries)
 XCTAssertEqual(result.count, 1)
 ```

 ### Spending Aggregation Tests

 **Test: calculateActualSpending(for:in:from:)**
 ```swift
 let groceries = BudgetCategory(name: "Groceries", budgetedAmount: 500)
 let nov2025 = Date()
 let transactions = [
     Transaction(date: nov5, amount: 100, type: .expense, category: groceries),
     Transaction(date: nov10, amount: 150, type: .expense, category: groceries),
     Transaction(date: nov15, amount: 50, type: .income, category: groceries), // Should be ignored
     Transaction(date: oct30, amount: 200, type: .expense, category: groceries), // Wrong month
 ]

 let result = BudgetCalculations.calculateActualSpending(
     for: groceries,
     in: nov2025,
     from: transactions
 )
 // Expected: 250 (100 + 150, ignoring income and wrong month)
 XCTAssertEqual(result, Decimal(250))
 ```

 **Test: Decimal Precision**
 ```swift
 // Verify no floating-point errors
 let amount1 = Decimal(string: "10.10")!
 let amount2 = Decimal(string: "20.20")!
 let total = amount1 + amount2
 // Expected: exactly 30.30, not 30.29999999
 XCTAssertEqual(total, Decimal(string: "30.30")!)
 ```

 ### Running Balance Tests

 **Test: calculateRunningBalance(for:)**
 ```swift
 let transactions = [
     Transaction(date: Date(), amount: 100, type: .income, ...),
     Transaction(date: Date(), amount: 30, type: .expense, ...),
     Transaction(date: Date(), amount: 50, type: .income, ...),
 ]

 let result = BudgetCalculations.calculateRunningBalance(for: transactions)
 // Expected: [(t1, 100), (t2, 70), (t3, 120)]
 XCTAssertEqual(result[0].1, Decimal(100))
 XCTAssertEqual(result[1].1, Decimal(70))
 XCTAssertEqual(result[2].1, Decimal(120))
 ```

 ### Category Comparison Tests

 **Test: generateCategoryComparisons(...)**
 ```swift
 let groceries = BudgetCategory(name: "Groceries", budgetedAmount: 500, ...)
 let utilities = BudgetCategory(name: "Utilities", budgetedAmount: 200, ...)
 let categories = [groceries, utilities]

 let transactions = [
     Transaction(amount: 300, type: .expense, category: groceries),
     Transaction(amount: 150, type: .expense, category: utilities),
 ]

 let result = BudgetCalculations.generateCategoryComparisons(
     categories: categories,
     month: Date(),
     transactions: transactions
 )

 XCTAssertEqual(result.count, 2)

 // Groceries: 500 budgeted, 300 actual
 let groceriesComparison = result.first { $0.categoryName == "Groceries" }!
 XCTAssertEqual(groceriesComparison.budgeted, Decimal(500))
 XCTAssertEqual(groceriesComparison.actual, Decimal(300))
 XCTAssertEqual(groceriesComparison.difference, Decimal(200)) // 500 - 300
 XCTAssertFalse(groceriesComparison.isOverBudget)
 XCTAssertEqual(groceriesComparison.percentageUsed, 0.6, accuracy: 0.01)
 ```

 ## ValidationHelpers Tests

 **Test: isValidCategoryName(_:)**
 ```swift
 XCTAssertTrue(ValidationHelpers.isValidCategoryName("Groceries"))
 XCTAssertTrue(ValidationHelpers.isValidCategoryName("  Groceries  ")) // Trimmed
 XCTAssertFalse(ValidationHelpers.isValidCategoryName(""))
 XCTAssertFalse(ValidationHelpers.isValidCategoryName("   "))
 XCTAssertFalse(ValidationHelpers.isValidCategoryName(String(repeating: "a", count: 51)))
 ```

 **Test: isValidAmount(_:)**
 ```swift
 XCTAssertTrue(ValidationHelpers.isValidAmount(Decimal(1)))
 XCTAssertTrue(ValidationHelpers.isValidAmount(Decimal(0.01)))
 XCTAssertFalse(ValidationHelpers.isValidAmount(Decimal(0)))
 XCTAssertFalse(ValidationHelpers.isValidAmount(Decimal(-1)))
 ```

 **Test: amountError(for:)**
 ```swift
 XCTAssertNil(ValidationHelpers.amountError(for: Decimal(100)))
 XCTAssertEqual(
     ValidationHelpers.amountError(for: Decimal(0)),
     "Amount must be greater than zero"
 )
 XCTAssertEqual(
     ValidationHelpers.amountError(for: Decimal(-10)),
     "Amount must be greater than zero"
 )
 ```

 ## CategoryComparison Tests

 **Test: Computed Properties**
 ```swift
 let comparison = CategoryComparison(
     categoryName: "Groceries",
     categoryColor: "#FF0000",
     budgeted: Decimal(500),
     actual: Decimal(300)
 )

 // Difference
 XCTAssertEqual(comparison.difference, Decimal(200)) // 500 - 300

 // Percentage used
 XCTAssertEqual(comparison.percentageUsed, 0.6, accuracy: 0.01) // 300/500

 // Is over budget
 XCTAssertFalse(comparison.isOverBudget)

 // Percentage remaining
 XCTAssertEqual(comparison.percentageRemaining, 0.4, accuracy: 0.01)

 // Formatted percentage
 XCTAssertEqual(comparison.percentageUsedFormatted, "60.0%")
 ```

 **Test: Over Budget Scenario**
 ```swift
 let comparison = CategoryComparison(
     categoryName: "Dining",
     categoryColor: "#00FF00",
     budgeted: Decimal(200),
     actual: Decimal(250)
 )

 XCTAssertEqual(comparison.difference, Decimal(-50)) // 200 - 250
 XCTAssertTrue(comparison.isOverBudget)
 XCTAssertEqual(comparison.percentageUsed, 1.25, accuracy: 0.01) // 250/200
 ```

 ## Integration Tests

 **Test: Full Budget Workflow**
 ```swift
 // 1. Create categories
 let groceries = BudgetCategory(name: "Groceries", budgetedAmount: 500, ...)

 // 2. Add transactions
 let t1 = Transaction(amount: 100, type: .expense, category: groceries, ...)
 let t2 = Transaction(amount: 150, type: .expense, category: groceries, ...)

 // 3. Calculate actual spending
 let actual = BudgetCalculations.calculateActualSpending(
     for: groceries,
     in: Date(),
     from: [t1, t2]
 )
 XCTAssertEqual(actual, Decimal(250))

 // 4. Generate comparison
 let comparison = CategoryComparison(
     categoryName: groceries.name,
     categoryColor: groceries.colorHex,
     budgeted: groceries.budgetedAmount,
     actual: actual
 )

 // 5. Verify results
 XCTAssertEqual(comparison.difference, Decimal(250)) // 500 - 250
 XCTAssertFalse(comparison.isOverBudget)
 ```

 ## Manual Testing Checklist

 ### Budget Planning View
 - [ ] Add category with valid name and amount
 - [ ] Try to add empty category name (should prevent)
 - [ ] Try to add $0 budgeted amount (should prevent)
 - [ ] Delete category (should cascade delete transactions)
 - [ ] Edit category name and amount
 - [ ] Verify totals recalculate in real-time

 ### Transaction Log View
 - [ ] Add transaction with all fields
 - [ ] Try to add transaction with empty description (should prevent)
 - [ ] Try to add transaction with $0 amount (should prevent)
 - [ ] Try to add transaction without category (should prevent)
 - [ ] Delete transaction
 - [ ] Edit transaction
 - [ ] Verify running balance updates correctly
 - [ ] Search for transactions by description and category

 ### Budget Analysis View
 - [ ] Navigate between months
 - [ ] Verify chart updates when month changes
 - [ ] Add transactions and verify actual amounts update
 - [ ] Check color coding (green = under, red = over)
 - [ ] Verify percentage calculations
 - [ ] Test with empty categories (should show empty state)

 ### Accessibility Testing
 - [ ] Enable VoiceOver
 - [ ] Navigate through all views
 - [ ] Verify transaction rows are readable
 - [ ] Verify category rows are readable
 - [ ] Verify chart elements are accessible
 - [ ] Test swipe actions with VoiceOver
 - [ ] Verify currency amounts are spoken correctly

 ### Performance Testing
 - [ ] Add 100 transactions
 - [ ] Scroll transaction list smoothly
 - [ ] Navigate between tabs
 - [ ] Change months in analysis view
 - [ ] Verify no lag or frame drops
 - [ ] Check memory usage in Xcode debugger

 ## Conclusion

 All critical calculations have defined test cases.
 Manual testing checklist ensures full coverage of user workflows.
 Accessibility testing verifies VoiceOver support.
 Performance testing ensures smooth operation with large datasets.
 */

// This file is for documentation purposes only and contains test case specifications.
// To implement actual unit tests, create XCTest target and add test methods.
