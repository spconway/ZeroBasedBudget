# Zero-Based Budget Tracker - iOS App

## Project Status: ✅ Production Ready

**Version**: 1.5.0 (v1.6.0 testing architecture planned)
**Last Updated**: November 5, 2025 (v1.6.0 Unit Testing Architecture Complete)
**Methodology**: YNAB-Style Zero-Based Budgeting
**Technical Specification**: `Docs/TechnicalSpec.md`

## Project Overview

iOS budget tracking app implementing **YNAB-style zero-based budgeting** where you budget only money you currently have, giving every dollar a specific job. Built with SwiftUI and SwiftData.

**Core YNAB Principle**: Budget only money that exists TODAY, not money you expect to receive.

## YNAB-Style Budgeting Methodology

**CRITICAL: This app follows YNAB (You Need A Budget) principles. Understanding this methodology is essential for all development work.**

### Core Principles

#### Rule 1: Give Every Dollar a Job
**Budget only money you have RIGHT NOW, not money you expect to receive.**

- Start with current account balances (money that exists today)
- Assign ALL of that money to categories until "Ready to Assign" = $0
- Each category represents a "job" for your dollars (rent, groceries, savings, etc.)

#### Rule 2: Income Increases Ready to Assign
**Future income is NOT budgeted until it arrives.**

- When you receive a paycheck → log it as Income transaction
- It increases your "Ready to Assign" amount
- THEN you assign that new money to categories
- You're always working with money you HAVE, never money you EXPECT

#### Rule 3: The Budget Flow

```
Current Account Balance ($2,500)
    ↓
Ready to Assign: $2,500 (money available to budget)
    ↓
Assign to Categories (give each dollar a job)
    ↓
Ready to Assign: $0 ✅ (Goal achieved - all money assigned)
    ↓
Income Arrives → Log transaction → Increases Ready to Assign
    ↓
Assign new money to categories → Back to $0
```

### Key Implementation Rule

**❌ NEVER have "Monthly Income" or "Expected Income" sections**  
**✅ ONLY have "Ready to Assign" showing actual available money**

Income is logged when it ARRIVES via transactions, not pre-budgeted.

## Architecture

- **Framework**: SwiftUI for iOS 26
- **Platform**: iPhone only (iOS 26+) - iPad and other platforms not supported
- **Persistence**: SwiftData (local-only storage, NO cloud sync)
- **Pattern**: MVVM (Model-View-ViewModel)
- **Data Type**: Decimal for ALL monetary values (never Double/Float)
- **Charts**: Swift Charts for budget visualization
- **Notifications**: UNUserNotificationCenter for local push notifications
- **Orientation**: Portrait mode optimized (landscape functional but not primary design)

## Current Project Structure

```
ZeroBasedBudget/
├── Models/
│   ├── Account.swift                # NEW: Financial accounts (checking, savings, cash)
│   ├── AppSettings.swift            # NEW: App settings and preferences (dark mode, etc.)
│   ├── BudgetCategory.swift         # Categories with amounts, due dates, notifications
│   ├── Transaction.swift            # Financial transactions (income/expense)
│   └── MonthlyBudget.swift          # Monthly budget (startingBalance deprecated in v1.4.0)
├── Views/
│   ├── AccountsView.swift           # NEW: Accounts tab with total banner
│   ├── AccountRow.swift             # NEW: Account list row component
│   ├── AddAccountSheet.swift        # NEW: Add account sheet
│   ├── EditAccountSheet.swift       # NEW: Edit account sheet
│   ├── BudgetPlanningView.swift     # Budget tab with Ready to Assign banner
│   ├── ReadyToAssignBanner.swift    # NEW: Compact Ready to Assign banner
│   ├── TransactionLogView.swift     # Transaction log with running balance, tap-to-edit
│   ├── BudgetAnalysisView.swift     # Budget vs actual with Swift Charts
│   └── SettingsView.swift           # NEW: Settings tab (placeholder for Enhancement 3.2)
├── Utilities/
│   ├── AppColors.swift              # NEW: Semantic color system for dark mode
│   ├── BudgetCalculations.swift     # Financial aggregation functions
│   ├── NotificationManager.swift    # Local push notification scheduling
│   ├── ValidationHelpers.swift      # Input validation utilities
│   └── [Other utility files...]
└── Docs/
    ├── TechnicalSpec.md              # Complete technical specification
    └── ClaudeCodeResumption.md       # Session interruption guide
```

## Recent Version History

**v1.4.0-dev (Current):**
- ✅ Enhancement 3.1: YNAB-style Accounts tab with true account-based budgeting
- ✅ New Account model for tracking real money accounts (checking, savings, cash)
- ✅ New Accounts tab (first tab) with total banner and CRUD operations
- ✅ Simplified Budget tab with compact Ready to Assign banner
- ✅ 5-tab structure: Accounts → Budget → Transactions → Analysis → Settings
- ✅ Ready to Assign now calculated as: Sum(accounts) - Sum(categories)
- ✅ Enhancement 3.3: Full dark mode support with manual toggle
- ✅ Semantic color system (appSuccess, appWarning, appError, appAccent)
- ✅ Dark mode toggle in Settings (System / Light / Dark)
- ✅ Enhancement 3.2: Global Settings Tab with comprehensive configuration
- ✅ Data export/import functionality (CSV and JSON formats)
- ✅ Dynamic currency support (USD, EUR, GBP, CAD, AUD, JPY)
- ✅ AppSettings model for persisting user preferences

**v1.3.0:**
- ✅ Fixed: $0 category amounts now allowed (YNAB principle)
- ✅ Fixed: Transaction detail sheet works after app restart
- ✅ Added: Push notifications for category due dates
- ✅ Added: Notification frequency settings (7-day, 2-day, on-date, custom)
- ✅ Added: "Last day of month" due date option with smart date calculation
- ✅ Added: Donut chart visualization for spending distribution in Analysis view

**v1.2.0:**
- ✅ Quick Assign and Undo functionality
- ✅ Month navigation with carry-forward warnings
- ✅ Enhanced Ready to Assign visual hierarchy

**v1.1.0:**
- ✅ Full YNAB methodology refactor (Ready to Assign section)
- ✅ Removed income section (YNAB violation)
- ✅ Income tracked via transactions only

**v1.0.0:**
- ✅ MVP: SwiftData models, three main views, local-only storage

## Active Issues & Enhancement Backlog

### 🔴 Priority 1: Critical Bugs & YNAB Methodology Issues

#### Bug 1.2: Ready to Assign Double-Counting Expenses ✅ COMPLETED

**Status**: ✅ **RESOLVED** - Fixed double-counting bug in Ready to Assign calculation
**Completed**: November 5, 2025
**Commit**: Pending

**Problem**: Ready to Assign was incorrectly going negative after expense transactions due to double-counting:
1. Expense transactions reduced account.balance automatically
2. Ready to Assign was calculated as: `Sum(current balances) - Sum(budgeted)`
3. This double-counted expenses (once in balance reduction, once in budgeted subtraction)

**Example Bug Scenario**:
- Account starting balance: $2,000
- Budget $1,200 to category → Ready to Assign: $800 ✅
- Spend $1,200 (reduces account to $800)
- Ready to Assign: $800 - $1,200 = **-$400** ❌ (WRONG - should stay $800)

**Root Cause**: Using current account balances (which already reflect spending) instead of starting balances.

**Solution Implemented**:
1. Added `startingBalance: Decimal` field to Account model
2. Set `startingBalance = balance` when account is created
3. Updated Ready to Assign formula:
   ```swift
   // OLD (WRONG):
   Ready to Assign = Sum(account.balance) - Sum(budgeted)

   // NEW (CORRECT):
   Ready to Assign = Sum(account.startingBalance) + Sum(income) - Sum(budgeted)
   ```

**Additional Fix**: Changed transaction list label from "Balance:" to "Net Worth:" and fixed calculation to start from sum of starting balances instead of $0.

**Files Modified**:
- `Models/Account.swift` - Added startingBalance field
- `Views/BudgetPlanningView.swift` - Fixed readyToAssign calculation
- `Views/TransactionLogView.swift` - Fixed transaction balance display

**YNAB Methodology**: ✅ Now correctly follows YNAB principle that Ready to Assign represents unassigned money from your starting balances plus income.

---

#### Bug 1.1: Transaction Running Balance Disconnected from Accounts ✅ COMPLETED

**Status**: ✅ **RESOLVED** - Implemented Option 1 (Full Account-Transaction Integration)
**Completed**: November 5, 2025
**Commit**: Pending

**Resolution Summary**:
- ✅ Added `account: Account?` relationship to Transaction model
- ✅ Added inverse `transactions: [Transaction]` relationship to Account model
- ✅ Updated AddTransactionSheet with account picker and automatic balance updates
- ✅ Updated EditTransactionSheet to handle account changes with proper balance reversals
- ✅ Updated TransactionRow to display account name
- ✅ Updated deleteTransaction() to reverse account balance impact
- ✅ Maintains backward compatibility (account field is optional)
- ✅ Build successful with no errors or warnings

**Implementation Details**:
This implementation provides full YNAB-correct account-transaction integration where:
- Every transaction can be linked to a specific account
- Account balances automatically update when transactions are created/edited/deleted
- Transaction edits properly handle account switching (reverse old, apply new)
- Account deletion nullifies transaction references (doesn't cascade delete)
- Running balance display now shows accurate account state

**Files Modified**:
- `Models/Transaction.swift` - Added account relationship and updated initializer
- `Models/Account.swift` - Added transactions relationship
- `Views/TransactionLogView.swift` - Complete transaction management overhaul:
  - AddTransactionSheet: Account picker + automatic balance updates
  - EditTransactionSheet: Account picker + balance reversal logic
  - TransactionRow: Display account name
  - deleteTransaction: Reverse balance impact

**Note**: This implementation also completes **Enhancement 4.2** (Account-Linked Transactions).

---

### 🟢 Priority 3: New Features (v1.5.0 Planned)

#### Enhancement 4.1: Date-Grouped Transaction List ✅ COMPLETED

**Status**: ✅ **COMPLETED** - Implemented November 5, 2025
**Commit**: Pending

**Objective**: Improve transaction readability by grouping transactions into date sections with clear visual separation.

**Implementation Summary**:
- ✅ Transactions grouped by date using `Dictionary(grouping:)`
- ✅ Section headers with relative date formatting ("Today", "Yesterday", "3 days ago")
- ✅ Preserves all existing functionality (search, edit, delete, swipe actions)
- ✅ Clean visual hierarchy with date sections

**Proposed Design**:
```
Transactions
├─ November 5, 2025 (Section Header)
│  ├─ Grocery Store - $45.23
│  └─ Gas Station - $52.00
├─ November 4, 2025 (Section Header)
│  ├─ Paycheck (Income) - $2,500.00
│  └─ Electric Bill - $125.00
└─ November 3, 2025 (Section Header)
   └─ Coffee Shop - $5.75
```

**YNAB Alignment Check**: ✅ Neutral - pure UX improvement, no methodology impact.

**Implementation Approach**:
1. **Data Grouping**: Group `transactionsWithBalance` by date using `Dictionary(grouping:)`
2. **Section Headers**: Use `ForEach` with date keys as section identifiers
3. **Date Formatting**: Show relative dates ("Today", "Yesterday") for recent transactions
4. **Summary Info**: Optional daily total in section header

**Files to Modify**:
- `Views/TransactionLogView.swift:88-94` - Replace flat list with sectioned list

**Implementation Details**:
```swift
// Group transactions by date
private var groupedTransactions: [(Date, [(Transaction, Decimal)])] {
    let grouped = Dictionary(grouping: transactionsWithBalance.reversed()) { transaction in
        Calendar.current.startOfDay(for: transaction.0.date)
    }
    return grouped.sorted { $0.key > $1.key }  // Newest first
}

// In body:
ForEach(groupedTransactions, id: \.0) { date, transactions in
    Section {
        ForEach(transactions, id: \.0.id) { transaction, balance in
            TransactionRow(transaction: transaction, runningBalance: balance)
        }
    } header: {
        Text(date, format: .dateTime.month().day().year())
            .font(.headline)
    }
}
```

**Design Considerations**:
- Use relative date formatting for last 7 days ("Today", "Yesterday", "5 days ago")
- Consider adding daily spending totals in section headers
- Maintain existing search/filter functionality across sections
- Preserve swipe-to-delete and tap-to-edit gestures

**Testing Checklist**:
- [ ] Transactions grouped correctly by calendar date
- [ ] Section headers display properly formatted dates
- [ ] Search functionality works across all sections
- [ ] Swipe-to-delete works within sections
- [ ] Tap-to-edit opens correct transaction
- [ ] Empty sections don't appear
- [ ] Performance acceptable with 100+ transactions
- [ ] Dark mode styling correct for headers

**Acceptance Criteria**:
- Transactions visually separated by date with section headers
- Date headers show human-readable format (e.g., "November 5, 2025")
- All existing functionality (search, edit, delete) preserved
- No performance degradation with large transaction lists

**Estimated Complexity**: Low (2-3 hours)

---

#### Enhancement 4.2: Account-Linked Transactions ✅ COMPLETED

**Status**: ✅ **COMPLETED** - Implemented as part of Bug 1.1 Resolution (Option 1)
**Completed**: November 5, 2025
**Commit**: Pending

**Objective**: Link transactions to specific accounts and automatically update account balances when transactions are created, edited, or deleted. This completes the YNAB account-based budgeting implementation.

**Resolution**: This enhancement was fully implemented as part of Bug 1.1 resolution. All planned features have been completed:
- ✅ Transaction-Account relationship established
- ✅ Automatic balance updates on transaction create/edit/delete
- ✅ Account picker in Add/Edit sheets
- ✅ Account name display in transaction list
- ✅ Proper balance reversal logic

See **Bug 1.1** above for complete implementation details.

**Original Implementation Plan** (for reference):

**Phase 1: Model Changes**
1. Add `account` relationship to Transaction model:
```swift
@Model
final class Transaction {
    // ... existing properties ...
    var account: Account?  // NEW: Link to account

    init(date: Date, amount: Decimal, description: String,
         type: TransactionType, category: BudgetCategory?,
         account: Account?) {  // NEW parameter
        // ... existing init ...
        self.account = account
    }
}
```

2. Add `transactions` relationship to Account model:
```swift
@Model
final class Account {
    // ... existing properties ...

    @Relationship(deleteRule: .nullify, inverse: \Transaction.account)
    var transactions: [Transaction] = []  // NEW: Track account transactions

    // NEW: Computed balance from transactions
    var calculatedBalance: Decimal {
        transactions.reduce(balance) { total, transaction in
            transaction.type == .income ? total + transaction.amount : total - transaction.amount
        }
    }
}
```

**Phase 2: UI Changes**
1. **Add Account Picker** to `AddTransactionSheet` (after Category section):
```swift
Section("Account") {
    Picker("Account", selection: $selectedAccount) {
        Text("Select Account").tag(nil as Account?)
        ForEach(accounts) { account in
            Text(account.name).tag(account as Account?)
        }
    }
    .pickerStyle(.menu)

    if let account = selectedAccount {
        HStack {
            Text("Current Balance:")
            Spacer()
            Text(account.balance, format: .currency(code: currencyCode))
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
```

2. **Update `EditTransactionSheet`** with account picker (allow changing account)

3. **Transaction Row Enhancement**: Show account name in TransactionRow
```swift
Text(transaction.account?.name ?? "No Account")
    .font(.caption)
    .foregroundStyle(.secondary)
```

**Phase 3: Balance Automation**
1. **Update `saveTransaction()` in AddTransactionSheet**:
```swift
private func saveTransaction() {
    let newTransaction = Transaction(
        date: date,
        amount: amount,
        description: description,
        type: transactionType,
        category: selectedCategory,
        account: selectedAccount  // NEW
    )

    // Update account balance
    if let account = selectedAccount {
        if transactionType == .income {
            account.balance += amount
        } else {
            account.balance -= amount
        }
    }

    modelContext.insert(newTransaction)
    dismiss()
}
```

2. **Update `saveChanges()` in EditTransactionSheet**:
```swift
// Handle account change and balance adjustments
if let oldAccount = transaction.account, oldAccount != selectedAccount {
    // Reverse old transaction on old account
    if transaction.type == .income {
        oldAccount.balance -= transaction.amount
    } else {
        oldAccount.balance += transaction.amount
    }
}

// Apply new transaction to new account
if let newAccount = selectedAccount {
    if transactionType == .income {
        newAccount.balance += amount
    } else {
        newAccount.balance -= amount
    }
}
```

3. **Update `deleteTransaction()` in TransactionLogView**:
```swift
private func deleteTransaction(_ transaction: Transaction) {
    // Reverse transaction impact on account
    if let account = transaction.account {
        if transaction.type == .income {
            account.balance -= transaction.amount
        } else {
            account.balance += transaction.amount
        }
    }
    modelContext.delete(transaction)
}
```

**Files to Create**: None

**Files to Modify**:
- `Models/Transaction.swift` - Add account relationship
- `Models/Account.swift` - Add transactions relationship and calculatedBalance
- `Views/TransactionLogView.swift` - Add account name display, update delete logic
- `Views/TransactionLogView.swift` (AddTransactionSheet) - Add account picker and balance update
- `Views/TransactionLogView.swift` (EditTransactionSheet) - Add account picker and balance update logic
- `ZeroBasedBudgetApp.swift` - Update schema version if needed

**Design Considerations**:
- **Optional vs Required**: Make account optional initially (allow transactions without accounts for backward compatibility)
- **Default Account**: Consider adding "Default Account" setting in AppSettings
- **Validation**: Warn if creating transaction without account selected
- **Migration**: Existing transactions will have `account = nil` (handle gracefully)
- **Multi-Account UX**: Show current account balance when selecting account in picker
- **Balance Integrity**: Add validation to prevent account balance desync

**Testing Checklist**:
- [ ] New transaction updates linked account balance correctly
- [ ] Income increases account balance
- [ ] Expense decreases account balance
- [ ] Editing transaction reverses old account impact and applies new
- [ ] Changing transaction account updates both old and new accounts
- [ ] Deleting transaction reverses account balance impact
- [ ] Transaction without account doesn't crash app
- [ ] Account balance matches sum of transactions
- [ ] Ready to Assign calculation still correct
- [ ] Account deletion handles linked transactions (nullify relationship)
- [ ] Export/import includes account data
- [ ] Dark mode styling correct for account picker

**Acceptance Criteria**:
- Transactions can be linked to accounts via picker in Add/Edit sheets
- Account balances automatically update when transactions are created/edited/deleted
- Transaction list shows account name for each transaction
- Account balance remains consistent with transaction history
- Editing transaction account properly updates both old and new account balances
- Deleting transaction properly reverses its impact on account balance
- No crashes or data corruption with account-linked transactions

**Estimated Complexity**: High (8-12 hours - model migration + UI + balance logic + testing)

**Implementation Priority**: **High** - This completes the YNAB account-based budgeting system. Consider implementing immediately after v1.4.0 release.

---


### Implementation Priority Order (v1.5.0 Planned)

**Recommended sequence:**

1. **Bug 1.1 Resolution (Transaction-Account Integration)** - Do first ⭐ **REQUIRED**
   - Reason: Critical YNAB methodology gap
   - Affects architecture of all future transaction features
   - Resolves both Bug 1.1 and Enhancement 4.2 simultaneously
   - Must be decided before other v1.5.0 features
   - Estimated: 8-12 hours (if Option 1 selected) or 1 hour (if Option 2 selected)
   - **Decision needed**: User must select Option 1, 2, or 3

2. **Enhancement 4.1 (Date-Grouped Transactions)** - Do second
   - Reason: Pure UX improvement, no dependencies
   - Low complexity, high user value
   - Benefits from Bug 1.1 resolution (can show account in sections)
   - Can be implemented independently if Bug 1.1 Option 2 chosen
   - Estimated: 2-3 hours

**Recommended Approach**:
- If **Bug 1.1 Option 1** selected → Enhancement 4.2 is completed as part of bug fix → Only Enhancement 4.1 remains
- If **Bug 1.1 Option 2** selected → Implement Enhancement 4.1 first (quick win) → Then Enhancement 4.2 later
- If **Bug 1.1 Option 3** selected → Implement in sequence: Bug 1.1 fix → Enhancement 4.1 → Enhancement 4.2

**Version Planning**:
- **v1.4.1** (if Option 2): Quick bug fix release with date grouping
- **v1.5.0** (if Option 1 or 3): Major release with full account-transaction integration

---

### 🟢 Priority 3: Testing & Quality Assurance (v1.6.0 Planned)

#### Enhancement 5.1: Add XCTest Framework for Unit Testing

**Status**: 📋 **PLANNED** - Not yet started
**Version**: v1.6.0 (Testing Infrastructure)
**Priority**: High (Foundation for quality assurance)

**Objective**: Establish comprehensive unit testing infrastructure using XCTest to ensure code quality, prevent regressions, and validate YNAB methodology compliance.

**YNAB Alignment Check**: ✅ **Critical** - Tests will validate YNAB calculations (Ready to Assign, account balances, transaction flows) to prevent methodology violations.

**Implementation Approach**:

**Phase 1: Test Target Setup**
1. Add XCTest test target to Xcode project
2. Configure test target with access to main app code
3. Set up test bundle structure following iOS best practices
4. Configure SwiftData in-memory test container for isolated testing

**Phase 2: Test Infrastructure**
1. Create base test classes with common setup/teardown
2. Implement test data factory helpers for models
3. Set up mock ModelContext for SwiftData testing
4. Create test fixtures with known data scenarios

**Phase 3: CI/CD Integration** (Future)
1. Configure Xcode test schemes for automated testing
2. Set up GitHub Actions for PR test validation (optional)
3. Add test coverage reporting

**Files to Create**:
- `ZeroBasedBudgetTests/` (New test target directory)
  - `ZeroBasedBudgetTests.swift` - Main test file with infrastructure
  - `Helpers/TestDataFactory.swift` - Test data generation helpers
  - `Helpers/TestHelpers.swift` - Common test utilities
  - `Models/` - Model test files (see Enhancement 5.2)
  - `Utilities/` - Utility test files (see Enhancement 5.2)
  - `YNAB/` - YNAB methodology test files (see Enhancement 5.2)

**Files to Modify**:
- `ZeroBasedBudget.xcodeproj` - Add test target configuration
- `ZeroBasedBudgetApp.swift` - Add test-friendly ModelContainer initialization

**Design Considerations**:
1. **Test Isolation**: Use in-memory SwiftData container to prevent test pollution
2. **Decimal Testing**: Create custom XCTest assertions for Decimal equality with precision
3. **Date Testing**: Use fixed dates in tests to avoid time-dependent failures
4. **YNAB Validation**: Every financial calculation test must validate YNAB methodology
5. **Test Naming**: Use descriptive names following pattern: `test_whatIsBeingTested_whenCondition_thenExpectedResult()`
6. **Test Organization**: Group tests by domain (Models, Utilities, YNAB, Edge Cases)
7. **Performance Testing**: Include performance tests for transaction-heavy operations
8. **Accessibility Testing**: Validate accessibility labels and traits (future)

**Test Infrastructure Code Example**:
```swift
// ZeroBasedBudgetTests.swift
import XCTest
import SwiftData
@testable import ZeroBasedBudget

class ZeroBasedBudgetTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        // Create in-memory container for isolated testing
        let schema = Schema([
            Account.self,
            Transaction.self,
            BudgetCategory.self,
            MonthlyBudget.self,
            AppSettings.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,  // Key: isolated test data
            cloudKitDatabase: .none
        )

        modelContainer = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        modelContext = ModelContext(modelContainer)
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - Custom Assertions

    /// Assert Decimal values are equal with 2 decimal place precision
    func assertDecimalEqual(
        _ actual: Decimal,
        _ expected: Decimal,
        accuracy: Decimal = 0.01,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let difference = abs(actual - expected)
        XCTAssertLessThanOrEqual(
            difference,
            accuracy,
            "Expected \(expected), got \(actual) (difference: \(difference))",
            file: file,
            line: line
        )
    }
}

// TestDataFactory.swift
enum TestDataFactory {
    /// Create test account with default values
    static func createAccount(
        name: String = "Test Account",
        balance: Decimal = 1000,
        accountType: String? = "Checking"
    ) -> Account {
        Account(name: name, balance: balance, accountType: accountType)
    }

    /// Create test transaction with default values
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

    /// Create test budget category with default values
    static func createCategory(
        name: String = "Test Category",
        budgetedAmount: Decimal = 200,
        categoryType: String = "Variable",
        colorHex: String = "#FF0000"
    ) -> BudgetCategory {
        BudgetCategory(
            name: name,
            budgetedAmount: budgetedAmount,
            categoryType: categoryType,
            colorHex: colorHex
        )
    }
}
```

**Testing Checklist**:
- [ ] Test target builds successfully
- [ ] Tests can import main app code
- [ ] In-memory SwiftData container works correctly
- [ ] Test data factories create valid models
- [ ] Custom Decimal assertions work correctly
- [ ] Tests run in isolation (no cross-contamination)
- [ ] All tests pass on fresh project clone
- [ ] Test execution time is reasonable (< 30 seconds for full suite)

**Acceptance Criteria**:
- XCTest target added to project and builds successfully
- Test infrastructure supports in-memory SwiftData testing
- Test data factories simplify test case creation
- Custom Decimal assertion helpers available for financial tests
- All created tests pass without errors
- Tests run in complete isolation (no shared state between tests)
- Test naming convention documented and followed
- Foundation ready for comprehensive test suite (Enhancement 5.2)

**Estimated Complexity**: Medium (4-6 hours - Xcode configuration + infrastructure code)

**Dependencies**: None (independent infrastructure work)

**Next Enhancement**: Enhancement 5.2 (Comprehensive Test Suite Implementation)

---

#### Enhancement 5.2: Comprehensive Test Suite Implementation

**Status**: 📋 **PLANNED** - Not yet started (requires Enhancement 5.1 first)
**Version**: v1.6.0 (Testing Infrastructure)
**Priority**: High (Prevents regressions and validates YNAB methodology)

**Objective**: Implement comprehensive unit test coverage across all models, utilities, and YNAB business logic to ensure code correctness, prevent regressions, and validate methodology compliance.

**YNAB Alignment Check**: ✅ **Critical** - Dedicated test category validates all YNAB calculations and principles.

**Test Organization Strategy**:
Tests are organized into 7 domains, each implemented as a separate test file:

```
ZeroBasedBudgetTests/
├── Models/
│   ├── AccountTests.swift          # Account model tests (10 tests)
│   ├── TransactionTests.swift      # Transaction model tests (12 tests)
│   ├── BudgetCategoryTests.swift   # Category model tests (15 tests)
│   ├── MonthlyBudgetTests.swift    # Monthly budget tests (5 tests)
│   └── AppSettingsTests.swift      # Settings model tests (6 tests)
├── Utilities/
│   ├── BudgetCalculationsTests.swift   # Calculation utility tests (18 tests)
│   └── ValidationHelpersTests.swift    # Validation utility tests (14 tests)
├── YNAB/
│   └── YNABMethodologyTests.swift      # YNAB principle tests (12 tests)
├── EdgeCases/
│   └── EdgeCaseTests.swift             # Edge case and boundary tests (10 tests)
└── Persistence/
    └── SwiftDataPersistenceTests.swift # Data persistence tests (8 tests)

Total: 110 individual unit tests across 10 test files
```

**Implementation Approach**: Implement test files incrementally, one domain at a time, in the order listed below. Each test file should be committed independently after verification.

---

### Domain 1: Model Tests (48 tests across 5 files)

**File: `Models/AccountTests.swift` (10 tests)**
- [ ] `test_accountInitialization_withValidData_createsAccountSuccessfully()`
- [ ] `test_accountInitialization_withZeroBalance_setsStartingBalanceToZero()`
- [ ] `test_accountInitialization_withNegativeBalance_allowsNegativeForCreditCards()`
- [ ] `test_startingBalance_afterInitialization_matchesInitialBalance()`
- [ ] `test_balanceUpdate_afterIncome_increasesCorrectly()`
- [ ] `test_balanceUpdate_afterExpense_decreasesCorrectly()`
- [ ] `test_transactions_relationship_inverseMaintainsIntegrity()`
- [ ] `test_accountType_whenOptional_allowsNilValues()`
- [ ] `test_createdDate_afterInit_isRecentDate()`
- [ ] `test_decimalPrecision_forBalance_maintainsTwoDecimalPlaces()`

**File: `Models/TransactionTests.swift` (12 tests)**
- [ ] `test_transactionInitialization_withValidData_createsSuccessfully()`
- [ ] `test_transactionAmount_withDecimal_maintainsPrecision()`
- [ ] `test_transactionType_income_createdCorrectly()`
- [ ] `test_transactionType_expense_createdCorrectly()`
- [ ] `test_categoryRelationship_whenOptional_allowsNil()`
- [ ] `test_categoryRelationship_whenSet_linksCorrectly()`
- [ ] `test_accountRelationship_whenOptional_allowsNil()`
- [ ] `test_accountRelationship_whenSet_linksCorrectly()`
- [ ] `test_receiptImageData_whenOptional_allowsNilAndData()`
- [ ] `test_transactionDescription_whenValid_storesCorrectly()`
- [ ] `test_transactionDate_withSpecificDate_storesExactTime()`
- [ ] `test_idUniqueness_forMultipleTransactions_generatesUniqueIDs()`

**File: `Models/BudgetCategoryTests.swift` (15 tests)**
- [ ] `test_categoryInitialization_withValidData_createsSuccessfully()`
- [ ] `test_budgetedAmount_withZero_allowsYNABPrinciple()`
- [ ] `test_budgetedAmount_withDecimal_maintainsPrecision()`
- [ ] `test_uniqueName_constraint_preventsDuplicates()`
- [ ] `test_categoryType_withValidTypes_storesCorrectly()`
- [ ] `test_dueDayOfMonth_whenSet_calculatesEffectiveDueDate()`
- [ ] `test_dueDayOfMonth_whenInvalid_clampsToLastDayOfMonth()`
- [ ] `test_isLastDayOfMonth_whenTrue_calculatesLastDay()`
- [ ] `test_effectiveDueDate_withDueDayOfMonth_calculatesCurrentMonth()`
- [ ] `test_effectiveDueDate_withLegacyDueDate_extractsDay()`
- [ ] `test_effectiveDueDate_whenNone_returnsNil()`
- [ ] `test_notificationSettings_defaultValues_setCorrectly()`
- [ ] `test_notificationID_afterInit_isUnique()`
- [ ] `test_transactions_cascadeDelete_deletesChildTransactions()`
- [ ] `test_lastDayOfCurrentMonth_forFebruary_calculatesCorrectly()`

**File: `Models/MonthlyBudgetTests.swift` (5 tests)**
- [ ] `test_monthlyBudgetInit_withValidData_createsSuccessfully()`
- [ ] `test_startingBalance_withDecimal_maintainsPrecision()`
- [ ] `test_startingBalance_withZero_allowsYNABStartingPoint()`
- [ ] `test_month_storesFirstDayOfMonth_correctly()`
- [ ] `test_notes_whenOptional_allowsNilAndStrings()`

**File: `Models/AppSettingsTests.swift` (6 tests)**
- [ ] `test_appSettingsInit_withDefaults_createsCorrectly()`
- [ ] `test_colorSchemePreference_validValues_storesCorrectly()`
- [ ] `test_currencyCode_multipleFormats_storesAllSupported()`
- [ ] `test_monthStartDate_validRange_clampsBetween1And31()`
- [ ] `test_notificationsEnabled_toggle_updatesCorrectly()`
- [ ] `test_lastModifiedDate_afterUpdate_updatesTimestamp()`

---

### Domain 2: Utility Tests (32 tests across 2 files)

**File: `Utilities/BudgetCalculationsTests.swift` (18 tests)**
- [ ] `test_startOfMonth_forAnyDate_returnsFirstDayAtMidnight()`
- [ ] `test_endOfMonth_forAnyDate_returnsLastDayOfMonth()`
- [ ] `test_endOfMonth_february_handlesLeapYears()`
- [ ] `test_isDate_inMonth_whenSameMonth_returnsTrue()`
- [ ] `test_isDate_inMonth_whenDifferentMonth_returnsFalse()`
- [ ] `test_transactionsInMonth_filtersCorrectly_forGivenMonth()`
- [ ] `test_transactionsInMonth_excludes_transactionsOutsideMonth()`
- [ ] `test_transactionsForCategory_filtersCorrectly_byCategory()`
- [ ] `test_calculateActualSpending_sumExpenses_excludesIncome()`
- [ ] `test_calculateActualSpending_withNoTransactions_returnsZero()`
- [ ] `test_calculateTotalIncome_sumIncome_excludesExpenses()`
- [ ] `test_calculateTotalIncome_withNoIncome_returnsZero()`
- [ ] `test_calculateTotalExpenses_sumExpenses_excludesIncome()`
- [ ] `test_generateCategoryComparisons_createsComparisons_forAllCategories()`
- [ ] `test_generateCategoryComparisons_filtersByCategoryType_correctly()`
- [ ] `test_totalBudgeted_sumsBudgetedAmounts_forCategoryType()`
- [ ] `test_totalActual_sumsActualSpending_forCategoryType()`
- [ ] `test_calculateRunningBalance_withMixedTransactions_calculatesCorrectly()`

**File: `Utilities/ValidationHelpersTests.swift` (14 tests)**
- [ ] `test_isValidName_withEmptyString_returnsFalse()`
- [ ] `test_isValidName_withWhitespaceOnly_returnsFalse()`
- [ ] `test_isValidName_withValidName_returnsTrue()`
- [ ] `test_isValidCategoryName_withTooLong_returnsFalse()`
- [ ] `test_isValidCategoryName_withValid_returnsTrue()`
- [ ] `test_isValidDescription_withTooLong_returnsFalse()`
- [ ] `test_isValidDescription_withValid_returnsTrue()`
- [ ] `test_isValidAmount_withPositive_returnsTrue()`
- [ ] `test_isValidAmount_withZero_returnsFalse()`
- [ ] `test_isValidNonNegativeAmount_withZero_returnsTrue()`
- [ ] `test_isReasonableAmount_withinRange_returnsTrue()`
- [ ] `test_isReasonableAmount_exceedsMax_returnsFalse()`
- [ ] `test_formatCurrency_withDecimal_formatsCorrectly()`
- [ ] `test_formatPercentage_withDouble_formatsCorrectly()`

---

### Domain 3: YNAB Methodology Tests (12 tests in 1 file)

**File: `YNAB/YNABMethodologyTests.swift` (12 tests)**

**Critical YNAB Principles to Validate:**
- [ ] `test_readyToAssign_calculation_usesStartingBalancePlusIncome()`
      - Validates: Ready to Assign = Sum(startingBalance) + Sum(income) - Sum(budgeted)
      - Ensures no double-counting of expenses
- [ ] `test_readyToAssign_afterExpense_remainsUnchanged()`
      - Validates: Spending doesn't reduce Ready to Assign (only budgeting does)
- [ ] `test_readyToAssign_afterIncome_increases()`
      - Validates: Income increases Ready to Assign for assignment
- [ ] `test_readyToAssign_afterBudgeting_decreases()`
      - Validates: Assigning money reduces Ready to Assign
- [ ] `test_accountBalance_afterExpense_decreasesCorrectly()`
      - Validates: Expenses reduce account balance (separate from budgeting)
- [ ] `test_accountBalance_afterIncome_increasesCorrectly()`
      - Validates: Income increases account balance
- [ ] `test_zeroBudgetedCategory_allowed_followsYNAB()`
      - Validates: Categories can have $0 budgeted (tracked but unfunded)
- [ ] `test_incomeThroughTransactions_notPreBudgeted_followsYNAB()`
      - Validates: Income logged via transactions, not pre-budgeted
- [ ] `test_budgetOnlyAvailableMoney_notFutureIncome_followsYNAB()`
      - Validates: Only budget money that exists today
- [ ] `test_transactionAccountLink_updatesBalance_maintainsIntegrity()`
      - Validates: Transaction-account relationship maintains balance integrity
- [ ] `test_multipleAccounts_totalBalance_sumsCorrectly()`
      - Validates: Sum of all accounts = total available money
- [ ] `test_categorySpending_doesNotAffectReadyToAssign_onlyBudgeting()`
      - Validates: Spending from category doesn't change Ready to Assign

---

### Domain 4: Edge Case & Boundary Tests (10 tests in 1 file)

**File: `EdgeCases/EdgeCaseTests.swift` (10 tests)**
- [ ] `test_decimalPrecision_verySmallAmounts_maintainsAccuracy()`
- [ ] `test_decimalPrecision_veryLargeAmounts_noOverflow()`
- [ ] `test_decimalArithmetic_repeatedOperations_noRoundingErrors()`
- [ ] `test_dateCalculation_monthBoundary_handlesCorrectly()`
- [ ] `test_dateCalculation_yearBoundary_handlesCorrectly()`
- [ ] `test_negativeBalance_creditCards_allowsAndCalculates()`
- [ ] `test_zeroTransaction_allowed_handlesGracefully()`
- [ ] `test_massiveTransactionCount_performance_acceptable()`
- [ ] `test_categoryDueDate_february29_handlesLeapYear()`
- [ ] `test_categoryDueDate_day31_in30DayMonth_clampsCorrectly()`

---

### Domain 5: Data Persistence Tests (8 tests in 1 file)

**File: `Persistence/SwiftDataPersistenceTests.swift` (8 tests)**
- [ ] `test_accountCRUD_createReadUpdateDelete_worksCorrectly()`
- [ ] `test_transactionCRUD_createReadUpdateDelete_worksCorrectly()`
- [ ] `test_categoryCRUD_createReadUpdateDelete_worksCorrectly()`
- [ ] `test_cascadeDelete_category_deletesChildTransactions()`
- [ ] `test_nullifyDelete_account_nullifiesTransactionReferences()`
- [ ] `test_uniqueConstraint_categoryName_preventsDuplicates()`
- [ ] `test_relationships_accountTransaction_maintainsIntegrity()`
- [ ] `test_inMemoryContainer_isolation_preventsTestContamination()`

---

**Files to Create**:
All 10 test files listed above (110 individual tests total)

**Files to Modify**:
None (tests are isolated in test target)

**Design Considerations**:
1. **Test Naming**: Follow Given-When-Then pattern: `test_whatIsBeingTested_whenCondition_thenExpectedResult()`
2. **Test Independence**: Each test must run in isolation, no shared state between tests
3. **Decimal Precision**: Use custom `assertDecimalEqual()` helper for all monetary comparisons
4. **Fixed Dates**: Use fixed dates in tests (e.g., `Date(timeIntervalSince1970: 1699200000)`) to avoid time-dependent failures
5. **YNAB Validation**: Every financial test must include comment explaining YNAB principle being validated
6. **Test Data**: Use TestDataFactory helpers for consistent test data creation
7. **Arrange-Act-Assert**: Structure all tests with clear AAA pattern
8. **Performance**: Mark performance-critical tests with `measure` blocks
9. **Edge Cases**: Explicitly test boundary conditions (zero, negative, very large values)
10. **Documentation**: Each test file should have header comment explaining domain coverage

**Testing Checklist**:
- [ ] All 110 tests implemented and passing
- [ ] All tests follow naming convention
- [ ] All tests use TestDataFactory for data creation
- [ ] All monetary tests use assertDecimalEqual()
- [ ] All YNAB tests include methodology validation comments
- [ ] No test interdependencies (all tests run in isolation)
- [ ] All edge cases covered (boundaries, negative values, etc.)
- [ ] Performance tests for transaction-heavy operations
- [ ] SwiftData persistence tests verify CRUD operations
- [ ] Full test suite runs in < 30 seconds
- [ ] Code coverage report shows >80% coverage for models and utilities
- [ ] All tests pass on CI/CD (if configured)

**Acceptance Criteria**:
- All 110 unit tests implemented across 10 test files
- All tests pass without errors or failures
- Test suite provides comprehensive coverage of:
  - All 5 SwiftData models (Account, Transaction, BudgetCategory, MonthlyBudget, AppSettings)
  - All 2 utility classes (BudgetCalculations, ValidationHelpers)
  - All YNAB methodology calculations and principles
  - Edge cases and boundary conditions
  - SwiftData persistence operations
- Test suite runs in reasonable time (< 30 seconds)
- Test code follows FIRST principles (Fast, Independent, Repeatable, Self-validating, Timely)
- Each test has clear, descriptive name following convention
- All financial calculations validated against YNAB methodology
- Code coverage >80% for models and utilities
- Documentation added to CLAUDE.md for running tests

**Estimated Complexity**: High (20-25 hours - 110 tests across 10 files, ~12 minutes per test including validation)

**Dependencies**:
- **REQUIRED**: Enhancement 5.1 (XCTest Framework) must be completed first
- Infrastructure code (TestDataFactory, base test class, custom assertions) needed

**Implementation Strategy**:
Implement incrementally in domain order:
1. Domain 1: Models (48 tests) - Start here, foundational
2. Domain 2: Utilities (32 tests) - Build on model tests
3. Domain 3: YNAB (12 tests) - Validate methodology (most critical)
4. Domain 4: Edge Cases (10 tests) - Catch boundary issues
5. Domain 5: Persistence (8 tests) - Validate SwiftData operations

**Commit after each domain** with descriptive message:
```
test: add comprehensive model tests (48 tests)
test: add utility function tests (32 tests)
test: add YNAB methodology validation tests (12 tests)
test: add edge case and boundary tests (10 tests)
test: add SwiftData persistence tests (8 tests)
```

**Version Planning**:
- **v1.6.0**: Complete test infrastructure and comprehensive test suite
- Provides foundation for TDD (Test-Driven Development) in future features
- Enables confident refactoring with regression protection

---

## Active Development

**Current Focus**: 📋 v1.6.0 Planning COMPLETE - Unit Testing Architecture Designed
**Status**: v1.5.0 ready for testing; v1.6.0 comprehensive test suite fully planned

**Recent Significant Changes** (last 5):
1. [2025-11-05] 📋 **v1.6.0 PLANNING COMPLETE**: Comprehensive unit testing architecture designed (110 tests across 10 files)
2. [2025-11-05] ✅ **Enhancement 4.1 COMPLETE**: Date-grouped transaction list (commit: b2cc82b)
3. [2025-11-05] ✅ **Bug 1.2 RESOLVED**: Fixed Ready to Assign double-counting (commit: 7154b66)
4. [2025-11-05] ✅ **Bug 1.1 RESOLVED**: Full account-transaction integration (commit: c16fa6c) + Enhancement 4.2
5. [2025-11-05] ✅ **v1.4.0 RELEASED**: All three enhancements complete (Accounts, Dark Mode, Settings)

**Active Decisions/Blockers**: None

**Next Session Start Here**:
1. **v1.5.0 STATUS**: ✅ All features complete and committed (3 commits ahead of origin/main)
   - Bug 1.1 (Account-transaction integration) - commit: c16fa6c
   - Bug 1.2 (Ready to Assign fix) - commit: 7154b66
   - Enhancement 4.1 (Date-grouped transactions) - commit: b2cc82b
2. **v1.6.0 PLANNING**: ✅ Comprehensive unit testing architecture fully designed
   - Enhancement 5.1: XCTest Framework setup (4-6 hours)
   - Enhancement 5.2: 110 unit tests across 10 files (20-25 hours)
   - Organized by domain: Models, Utilities, YNAB, Edge Cases, Persistence
3. **Platform**: iPhone-only, iOS 26+ (no iPad support)
4. **Next Steps Options**:
   - Option A: Test v1.5.0 in simulator → Push to origin → Release
   - Option B: Begin v1.6.0 implementation (Enhancement 5.1: XCTest Framework)
   - Option C: User provides new requirements/priorities

## Git Commit Strategy

**Commit Frequency**: After each logical unit of work (bug fix, feature addition, refactor)

**Commit Message Format**: Conventional Commits
```
<type>: <description>

Examples:
fix: resolve CoreData errors on app startup
fix: show notification settings immediately on due date toggle
feat: add YNAB-style day-of-month due date picker
feat: reduce top whitespace across all tabs
feat: add pie chart visualization to Analysis view
refactor: extract chart components for better organization
```

**Commit Types**:
- `fix:` - Bug fix
- `feat:` - New feature
- `refactor:` - Code restructuring without behavior change
- `docs:` - Documentation updates
- `test:` - Test additions/modifications
- `perf:` - Performance improvements
- `style:` - UI/UX styling changes

**Requirements**:
- Code must build successfully before committing
- Test the fix/feature manually before committing
- Update CLAUDE.md "Recent Significant Changes" after important commits
- Keep commit messages clear and descriptive

## Session Continuity Guide

### Starting a New Session

**Minimal Start** (same-day continuation):
```
Read CLAUDE.md "Active Development" section and continue with current focus.
```

**Standard Start** (after gap or new work):
```
1. Read CLAUDE.md "Active Development" section
2. Review "Active Issues & Enhancement Backlog" for current priority
3. Review git log --oneline -5 to see recent work
4. Continue with next unchecked task
```

**Full Start** (after interruption or uncertainty):
```
1. Read CLAUDE.md completely (especially YNAB methodology and active bugs)
2. Run: git log --oneline -10
3. Run: git status (check for uncommitted work)
4. Build project to verify working state
5. Report current status and next steps
```

### During Development

**Update "Active Development" section**:
- Change "Current Focus" when starting new bug/enhancement
- Add to "Recent Significant Changes" (keep last 5 only) when:
  - Fixing critical bugs
  - Completing enhancements
  - Major refactoring
  - Model schema changes
  - Version releases
- Update "Active Decisions/Blockers" if blocked or decision needed
- Update "Next Session Start Here" at end of session

**Do NOT**:
- Add blow-by-blow implementation details to session notes
- List every file changed (git handles that)
- Create detailed session logs with timestamps (git log handles that)
- Keep completed items in backlog (move to version history)

### After Interruption

Follow `Docs/ClaudeCodeResumption.md` for step-by-step recovery process.

## Critical Implementation Rules

**These rules apply to ALL development:**

1. **YNAB Methodology**: ALWAYS follow YNAB principles
   ```swift
   // ❌ WRONG - Budgeting expected income
   let monthlyIncome: Decimal = 5000
   
   // ✅ CORRECT - Budget only available money
   let readyToAssign: Decimal = (startingBalance + actualIncome) - totalAssigned
   ```

2. **Monetary Values**: Always use `Decimal` type (never Double or Float)
   ```swift
   var amount: Decimal  // ✅ Correct
   var amount: Double   // ❌ Wrong - causes rounding errors
   ```

3. **Local Storage**: All data stored on-device only
   ```swift
   ModelConfiguration(cloudKitDatabase: .none)  // ✅ Required
   ```

4. **Currency Formatting**: Use .currency format style consistently
   ```swift
   Text(amount, format: .currency(code: "USD"))  // ✅ Correct
   ```

5. **Relationships**: Cascade deletes where appropriate
   ```swift
   @Relationship(deleteRule: .cascade) var transactions: [Transaction]
   ```

6. **Query Optimization**: Use #Index on frequently queried fields
   ```swift
   #Index<Transaction>([\.date], [\.category])
   ```

7. **Computed Properties**: Never store calculated values
   ```swift
   var total: Decimal { categories.reduce(0) { $0 + $1.amount } }  // ✅
   ```

8. **Income Tracking**: Income ONLY from transactions, never pre-budgeted
   ```swift
   // ✅ CORRECT - Calculate from actual transactions
   var totalIncome: Decimal {
       transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
   }
   ```

9. **Zero Amounts Allowed**: Categories can have $0 budgeted (YNAB principle)
   ```swift
   // ✅ CORRECT - Allow $0 for unfunded but tracked expenses
   if amount >= 0 { /* Valid */ }
   ```

10. **Notifications**: Use UNUserNotificationCenter for local notifications
    ```swift
    // ✅ CORRECT - Local notifications that work when app closed
    UNUserNotificationCenter.current().add(request)
    ```

11. **SwiftData Best Practices**: Follow iOS 26 SwiftData patterns
    ```swift
    // ✅ CORRECT - Explicit schema and configuration
    let schema = Schema([Transaction.self, BudgetCategory.self, MonthlyBudget.self])
    let config = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
    let container = try ModelContainer(for: schema, configurations: [config])
    ```

## Issue & Enhancement Management

**Priority Levels**:
- 🔴 **Priority 1**: Critical bugs (app crashes, data loss, core functionality broken)
- 🟡 **Priority 2**: UX improvements (usability issues, polish, refinements)
- 🟢 **Priority 3**: New features (enhancements, additional functionality)

**Adding New Issues/Enhancements**:
1. Add to "Active Issues & Enhancement Backlog" with appropriate priority emoji
2. Use comprehensive format for Priority 3 features:
   - Objective (clear goal statement)
   - YNAB Alignment Check (ensure methodology compliance)
   - Implementation Approach (technical strategy)
   - Files to Create/Modify (specific file paths)
   - Design Considerations (UX/architecture decisions)
   - Testing Checklist (comprehensive test cases)
   - Acceptance Criteria (definition of done)
3. Use task checkboxes [ ] for all actionable items
4. Include code examples where helpful
5. Reference specific file paths with line numbers if applicable
6. **Always verify alignment with YNAB methodology**

**Completing Issues/Enhancements**:
1. Check off all related tasks [x] as you complete them
2. Commit after each logical unit with descriptive fix:/feat: message
3. Add entry to "Recent Significant Changes" (keep last 5)
4. Move completed item to version history (brief one-line summary)
5. Update "Next Session Start Here" for continuity
6. Test thoroughly before marking complete (follow testing checklist)
7. Verify YNAB principles maintained (if applicable)
8. Update version number if releasing (x.y.z format)

**Moving to Version History**:
- When enhancement is complete, remove detailed specifications
- Add brief one-line summary to appropriate version section
- Keep backlog focused on ACTIVE work only
- Archive detailed specs if needed for future reference

## Quick Reference

**Build Project**: `Cmd+B` in Xcode

**Run Tests** (after v1.6.0): `Cmd+U` in Xcode or `xcodebuild test -scheme ZeroBasedBudget -destination 'platform=iOS Simulator,name=iPhone 17'`

**Check Git Status**: `git status`, `git log --oneline -10`

**Key Files to Review When Starting**:
- This file (CLAUDE.md) - current state, YNAB methodology, active issues
- Docs/TechnicalSpec.md - implementation patterns and best practices
- Docs/ClaudeCodeResumption.md - recovery from interruptions

**YNAB Methodology Quick Check**:
- ✅ Budgeting only money that exists today (not future income)?
- ✅ Income arrives via transactions (not pre-budgeted)?
- ✅ "Ready to Assign" prominently displayed?
- ✅ Goal to reach Ready to Assign = $0?
- ✅ Categories can be $0 (tracked but unfunded)?

**Common SwiftUI Debugging**:
- Console errors? Check error messages for root cause
- UI not updating? Verify @State/@Published property wrappers
- Sheet not appearing? Check binding and presentation logic
- Chart not rendering? Verify data structure and mark types