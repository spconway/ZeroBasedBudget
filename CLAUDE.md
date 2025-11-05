# Zero-Based Budget Tracker - iOS App

## Project Status: ✅ Production Ready

**Version**: 1.4.0-dev
**Last Updated**: November 5, 2025 (Enhancement 3.3 Complete)  
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

## Active Development

**Current Focus**: 🎉 v1.5.0 Development COMPLETE - Ready for Testing!
**Status**: Ready to commit final enhancement and test in simulator

**Recent Significant Changes** (last 5):
1. [2025-11-05] ✅ **Enhancement 4.1 COMPLETE**: Date-grouped transaction list with relative dates
2. [2025-11-05] ✅ **Bug 1.2 RESOLVED**: Fixed Ready to Assign double-counting (commit: 7154b66)
3. [2025-11-05] ✅ **Bug 1.1 RESOLVED**: Full account-transaction integration (commit: c16fa6c) + Enhancement 4.2
4. [2025-11-05] 📋 **v1.5.0 Planning**: Identified bugs and enhancements for v1.5.0
5. [2025-11-05] ✅ **v1.4.0 RELEASED**: All three enhancements complete (Accounts, Dark Mode, Settings)

**Active Decisions/Blockers**: None

**Next Session Start Here**:
1. **v1.5.0 ALL FEATURES COMPLETE** ✅ 🎉
2. **Bug 1.1 COMPLETE** ✅ - Account-transaction integration (commit: c16fa6c)
3. **Bug 1.2 COMPLETE** ✅ - Ready to Assign double-counting fix (commit: 7154b66)
4. **Enhancement 4.1 COMPLETE** ✅ - Date-grouped transaction list (ready to commit)
5. **Enhancement 4.2 COMPLETE** ✅ - Completed as part of Bug 1.1 resolution
6. **Platform**: iPhone-only, iOS 26+ (no iPad support)
7. Next Steps: Commit Enhancement 4.1 → Test thoroughly in simulator → Release v1.5.0

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