# Zero-Based Budget Tracker - iOS App

## Project Status: ✅ Production Ready

**Version**: 1.2.0  
**Last Updated**: November 2, 2025  
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
- **Persistence**: SwiftData (local-only storage, NO cloud sync)
- **Pattern**: MVVM (Model-View-ViewModel)
- **Data Type**: Decimal for ALL monetary values (never Double/Float)
- **Charts**: Swift Charts for budget visualization

## Current Project Structure

```
ZeroBasedBudget/
├── Models/
│   ├── BudgetCategory.swift         # Categories with budgeted amounts, due dates
│   ├── Transaction.swift            # Financial transactions (income/expense)
│   └── MonthlyBudget.swift          # Monthly budget with startingBalance
├── Views/
│   ├── BudgetPlanningView.swift     # Ready to Assign, category assignment
│   ├── TransactionLogView.swift     # Transaction log with running balance
│   └── BudgetAnalysisView.swift     # Budget vs actual with Swift Charts
├── Utilities/
│   ├── BudgetCalculations.swift     # Financial aggregation functions
│   ├── ValidationHelpers.swift      # Input validation utilities
│   └── [Other utility files...]
└── Docs/
    ├── TechnicalSpec.md              # Complete technical specification
    └── ClaudeCodeResumption.md       # Session interruption guide
```

## Completed Features Summary

**MVP (v1.0.0):**
- ✅ SwiftData models with proper relationships and indexes
- ✅ Budget Planning, Transaction Log, and Budget Analysis views
- ✅ Local-only storage (no cloud sync)
- ✅ Decimal type for all monetary calculations
- ✅ Currency formatting throughout

**YNAB Refactor (v1.1.0):**
- ✅ Removed "Income" section (violates YNAB principles)
- ✅ Added "Ready to Assign" section with YNAB calculations
- ✅ Income tracked via transactions only
- ✅ Educational helper text explaining YNAB methodology

**Post-MVP Enhancements (v1.1.0):**
- ✅ Month indicator with navigation
- ✅ Due date field for categories (optional)
- ✅ Tap-to-edit transactions (reduced steps)
- ✅ Enhanced Ready to Assign visual hierarchy
- ✅ Quick Assign and Undo functionality
- ✅ Month navigation with carry-forward warnings

## Active Issues & Enhancement Backlog

### 🔴 Priority 1: Critical Bugs (Fix First)

**Bug 1.1: Budget Category Validation - $0 Amount Not Allowed**
- [ ] Current behavior: Categories require amount > $0 to save
- [ ] Expected behavior: Should allow $0 amounts
- [ ] Rationale: YNAB principle - users should track ALL expenses (even unfunded ones)
  - User should be aware of all expenses
  - Should only budget when money becomes available
  - $0 means "I know about this expense but haven't funded it yet"
- [ ] Files to modify:
  - Views/BudgetPlanningView.swift (AddCategorySheet validation)
  - Views/BudgetPlanningView.swift (EditCategorySheet validation)
  - Utilities/ValidationHelpers.swift (if validation is centralized)
- [ ] Test cases:
  - Create new category with $0 amount → Should save successfully
  - Edit existing category to $0 → Should save successfully
  - Display $0 categories correctly in budget list
  - Verify $0 categories included in "Total Assigned" calculation

**Bug 1.2: Transaction Detail Sheet - Blank After App Restart**
- [ ] Current behavior: After adding transaction and restarting app, tapping transaction shows blank sheet
- [ ] Expected behavior: Should display transaction details correctly
- [ ] Investigation needed:
  - Check if transaction data persists correctly (verify in database)
  - Check if EditTransactionSheet properly loads transaction from context
  - Check if SwiftData relationships are loading correctly after restart
  - Review console logs (user reports no errors shown)
  - Test: Add transaction → Close app → Reopen → Tap transaction → Should show details
- [ ] Files to investigate:
  - Views/TransactionLogView.swift (sheet presentation logic)
  - Views/TransactionLogView.swift (EditTransactionSheet)
  - Models/Transaction.swift (verify relationships persist)
- [ ] Possible causes:
  - Transaction not being fetched correctly from persistent store
  - Category relationship not loading (if using @Relationship)
  - Sheet state not properly bound to transaction
  - SwiftData context issue after app restart

---

### 🟡 Priority 2: New Feature Enhancements

**Enhancement 2.1: Due Date Push Notifications**
- [ ] Implement local push notifications for categories with due dates
- [ ] Notifications should work when app is closed (use UNUserNotificationCenter)
- [ ] Requirements:
  - Request notification permissions from user
  - Schedule notifications based on due date
  - User-configurable notification timing (see Enhancement 2.2)
  - Notification should display: category name, due date, budgeted amount
  - Tapping notification should open app to Budget tab with that category highlighted
- [ ] Implementation approach:
  - Use UNUserNotificationCenter for local notifications
  - Schedule notifications when due date is set/updated on category
  - Cancel/reschedule when due date changes or category deleted
  - Store notification identifiers with categories for management
- [ ] Files to create/modify:
  - Create Utilities/NotificationManager.swift for centralized notification handling
  - Modify Models/BudgetCategory.swift (may need notification identifier)
  - Modify Views/BudgetPlanningView.swift (schedule on category save)
  - Update ZeroBasedBudgetApp.swift (request permissions on first launch)
- [ ] Testing:
  - Test notification scheduling for categories with due dates
  - Test notification display when app is closed
  - Test deep link to category from notification
  - Test notification cancellation when category deleted/updated

**Enhancement 2.2: Notification Frequency Settings**
- [ ] Allow user to configure when notifications are sent for each category
- [ ] Frequency options:
  - 7 days before due date
  - 2 days before due date  
  - On day of due date
  - Custom (user-specified number of days)
- [ ] Default: All options enabled (3 notifications per due date)
- [ ] Implementation approach:
  - Add notification frequency settings to BudgetCategory model
  - Or create separate NotificationSettings model/utility
  - Create settings UI (possibly in category edit sheet or separate settings view)
  - Update NotificationManager to schedule multiple notifications per category
- [ ] Files to create/modify:
  - Update Models/BudgetCategory.swift or create NotificationSettings model
  - Update Views/BudgetPlanningView.swift (EditCategorySheet with notification settings)
  - Update Utilities/NotificationManager.swift (schedule multiple notifications)
- [ ] UI Considerations:
  - Toggle switches for each frequency option
  - Clear labels: "Notify 7 days before", "Notify 2 days before", "Notify on due date"
  - Preview of when notifications will be sent
  - Option to test notification immediately

**Enhancement 2.3: "Last Day of Month" Due Date Option**
- [ ] Add ability to set due date as "Last Day of Month" (variable based on month)
- [ ] Challenges:
  - Date varies by month (28/29/30/31 days)
  - Need to handle leap years (February 29 vs 28)
  - Need to calculate actual date when scheduling notifications
  - Need to display correctly in UI ("Last day of month" vs "Nov 30")
- [ ] Implementation approach:
  - Add boolean flag `isLastDayOfMonth` to BudgetCategory
  - Add computed property that calculates actual date based on current month
  - Update due date picker UI with "Last Day of Month" toggle
  - Update notification scheduling to use computed date
  - Update month navigation to recalculate dates for new month
- [ ] Files to modify:
  - Models/BudgetCategory.swift (add isLastDayOfMonth property, computed date)
  - Views/BudgetPlanningView.swift (due date picker UI)
  - Utilities/BudgetCalculations.swift (add date calculation utilities)
  - Utilities/NotificationManager.swift (use computed date for notifications)
- [ ] UI Design:
  - Toggle: "Set as last day of month"
  - When toggled on, disable specific date picker
  - Show calculated date as read-only: "Will be: November 30, 2025"
  - Update when month navigation changes
- [ ] Test Cases:
  - Test with 30-day month (November)
  - Test with 31-day month (December)
  - Test with 28-day month (February non-leap)
  - Test with 29-day month (February leap year)
  - Test notification scheduling with variable dates
  - Test month navigation updates the displayed date

---

## Active Development

**Current Focus**: 🔴 Fix Critical Bugs (Priority 1)  
**Status**: Ready to begin Bug 1.1 - Budget category $0 validation

**Why Priority 1 Bugs Are Critical:**
1. **Bug 1.1** violates YNAB principle of tracking all expenses
2. **Bug 1.2** breaks core transaction editing functionality after app restart

**Recent Significant Changes** (last 5):
1. [2025-11-02] ✅ Completed Priority 3 - Month Navigation Context (carry-forward, month comparison)
2. [2025-11-02] ✅ Completed Priority 2 - Transaction Integration & Quick Assign
3. [2025-11-02] ✅ Completed Priority 1 - Full YNAB methodology refactor
4. [2025-11-01] ✅ Completed MVP - all 6 phases delivered
5. [2025-11-01] ✅ Phase 6 complete - validation, accessibility, testing docs

**Active Decisions/Blockers**: None

**Next Session Start Here**:
1. Read this CLAUDE.md file (especially YNAB Methodology section)
2. Begin Bug 1.1: Allow $0 amounts for budget categories
3. File to modify: Views/BudgetPlanningView.swift (validation in AddCategorySheet and EditCategorySheet)

**Implementation Priority Order:**
1. Bug 1.1 → Allow $0 category amounts
2. Bug 1.2 → Fix transaction detail sheet after restart
3. Enhancement 2.1 → Due date push notifications
4. Enhancement 2.2 → Notification frequency settings
5. Enhancement 2.3 → Last day of month due date option

## Git Commit Strategy

**Commit Frequency**: After each logical unit of work (bug fix, feature addition, refactor)

**Commit Message Format**: Conventional Commits
```
<type>: <description>

Examples:
fix: allow $0 amounts for budget categories (YNAB principle)
fix: resolve blank transaction detail sheet after app restart
feat: add push notifications for category due dates
feat: add notification frequency settings for due dates
feat: add last day of month option for due dates
docs: update CLAUDE.md with new bugs and enhancements
```

**Commit Types**:
- `fix:` - Bug fix (use for Priority 1 bugs)
- `feat:` - New feature (use for Priority 2 enhancements)
- `refactor:` - Code restructuring without behavior change
- `docs:` - Documentation updates
- `test:` - Test additions/modifications
- `perf:` - Performance improvements

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
1. Read CLAUDE.md completely (especially YNAB methodology)
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
- Update "Active Decisions/Blockers" if blocked or decision needed
- Update "Next Session Start Here" at end of session

**Do NOT**:
- Add blow-by-blow implementation details to session notes
- List every file changed (git handles that)
- Create detailed session logs with timestamps (git log handles that)
- Keep old session notes (delete after work complete)

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
   
   // ❌ WRONG - Requiring amount > 0
   if amount > 0 { /* Valid */ }
   ```

10. **Notifications**: Use UNUserNotificationCenter for local notifications
    ```swift
    // ✅ CORRECT - Local notifications that work when app closed
    UNUserNotificationCenter.current().add(request)
    ```

## Issue & Enhancement Management

**Adding New Issues**:
1. Add to "Active Issues & Enhancement Backlog" with appropriate priority
2. Use 🔴 for critical bugs (Priority 1), 🟡 for features (Priority 2)
3. Use task checkboxes [ ] for tracking
4. Include clear acceptance criteria and test cases
5. Reference files to modify
6. **Verify it aligns with YNAB methodology**

**Completing Issues/Enhancements**:
1. Check off all related tasks [x]
2. Commit with descriptive fix:/feat: message
3. Add entry to "Recent Significant Changes"
4. Update "Next Session Start Here" if needed
5. Test thoroughly before marking complete
6. Verify YNAB principles maintained (if applicable)

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
