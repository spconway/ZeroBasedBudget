# Zero-Based Budget Tracker - iOS App

## Project Status: ✅ MVP COMPLETE

**Version**: 1.1.0  
**Completion Date**: November 2, 2025  
**Budgeting Methodology**: YNAB-Style Zero-Based Budgeting  
**Technical Specification**: `Docs/TechnicalSpec.md`

## Project Overview

iOS budget tracking app implementing **YNAB-style zero-based budgeting methodology** where you budget only the money you currently have, giving every dollar a specific job. Built with SwiftUI and SwiftData, provides three main views for budget planning, transaction tracking, and budget analysis.

## YNAB-Style Budgeting Methodology

**CRITICAL: This app follows YNAB (You Need A Budget) principles. Understanding this methodology is essential for all development work.**

### Core Principles

#### Rule 1: Give Every Dollar a Job
**Budget only money you have RIGHT NOW, not money you expect to receive.**

- You start with your current account balances (money that exists today)
- You assign ALL of that money to categories until you have $0 unassigned
- Each category represents a "job" for your dollars (rent, groceries, savings, etc.)
- When "Ready to Assign" reaches $0, you've successfully budgeted

#### Rule 2: Income Increases Ready to Assign
**Future income is NOT budgeted until it arrives.**

- When you receive a paycheck (transaction logged as Income)
- It increases your "Ready to Assign" amount
- THEN you assign that new money to categories
- You're always working with money you HAVE, never money you EXPECT

#### Rule 3: The Budget Flow

```
Current Account Balance
    ↓
Ready to Assign (money available to budget)
    ↓
Assign to Categories (give each dollar a job)
    ↓
Ready to Assign = $0 (all money assigned)
    ↓
Income Arrives → Increases Ready to Assign
    ↓
Assign new money to categories → Back to $0
```

### What This Means for the App

**❌ WRONG Approach (Traditional Budgeting):**
- Have "Monthly Income" section where user enters expected salary
- Budget based on money you WILL receive
- Hope the money arrives as expected

**✅ CORRECT Approach (YNAB-Style):**
- Have "Ready to Assign" section showing current available money
- User manually enters their actual account balances RIGHT NOW
- Assign all available money to categories
- When income arrives, log it as a transaction → increases Ready to Assign → assign that money

**Key Distinction:**
- Traditional: "I expect $5,000 next month, so I'll budget $5,000"
- YNAB-Style: "I have $2,000 today, so I'll budget $2,000. When my paycheck arrives, I'll budget that too."

### Example Budget Cycle

**Starting Position:**
```
Checking Account: $2,500
Ready to Assign: $2,500
```

**Assign Money to Categories:**
```
Rent: $1,155
Groceries: $600
Gas: $200
Entertainment: $300
Emergency Fund: $245
---
Total Assigned: $2,500
Ready to Assign: $0 ✅ (Goal achieved!)
```

**Paycheck Arrives (Logged as Income Transaction: $2,812):**
```
Checking Account: $5,312
Ready to Assign: $2,812 (new money to assign!)
```

**Assign New Money:**
```
Add to Rent for next month: $1,155
Add to Groceries: $600
Add to Utilities: $500
Add to Savings: $557
---
Ready to Assign: $0 ✅ (All new money assigned!)
```

### Critical Implementation Note

**Any section labeled "Monthly Income", "Yearly Income", or "Expected Income" is WRONG for YNAB-style budgeting.**

These sections imply budgeting money you don't have yet, which violates the core principle.

The app must ONLY show:
1. **Ready to Assign**: Money available RIGHT NOW
2. **Categories**: Where money is assigned
3. **Income Transactions**: Log income when it arrives (not before)

## Architecture

- **Framework**: SwiftUI for iOS 26
- **Persistence**: SwiftData (local-only storage, NO cloud sync)
- **Pattern**: MVVM (Model-View-ViewModel)
- **Data Type**: Decimal for ALL monetary values (never Double/Float)
- **Charts**: Swift Charts for budget visualization
- **Methodology**: YNAB-Style Zero-Based Budgeting

## MVP Completion Summary

**All Six Implementation Phases Complete:**
- ✅ Phase 1: SwiftData models, ModelContainer, TabView navigation
- ✅ Phase 2: Budget Planning View with income/expense management
- ✅ Phase 3: Transaction Log with running balance
- ✅ Phase 4: Calculation utilities and persistence verification
- ✅ Phase 5: Budget Analysis View with Swift Charts
- ✅ Phase 6: Validation, accessibility, performance documentation

**Key Deliverables**:
- 3 SwiftData models (BudgetCategory, Transaction, MonthlyBudget)
- 3 complete views (BudgetPlanningView, TransactionLogView, BudgetAnalysisView)
- 7 utility files (calculations, validation, accessibility, documentation)
- 2,500+ lines of production Swift code
- Comprehensive testing and performance guidelines

**Critical Requirements Met**:
- ✅ Decimal type for all monetary values (no floating-point errors)
- ✅ Local-only storage (cloudKitDatabase: .none verified)
- ✅ Cascade delete relationships on BudgetCategory → Transaction
- ✅ Indexed queries (#Index on Transaction.date and category)
- ✅ Currency formatting throughout (.currency(code: "USD"))
- ✅ Accessibility support (VoiceOver labels)
- ✅ Form validation and error handling

## Current Project Structure

```
ZeroBasedBudget/
├── ZeroBasedBudgetApp.swift         # App entry, ModelContainer config
├── ContentView.swift                 # TabView navigation
├── Models/
│   ├── BudgetCategory.swift         # Expense/income categories
│   ├── Transaction.swift            # Financial transactions
│   └── MonthlyBudget.swift          # Monthly budget parameters
├── Views/
│   ├── BudgetPlanningView.swift     # Budget planning (Sheet 1)
│   ├── TransactionLogView.swift     # Transaction log (Sheet 2)
│   └── BudgetAnalysisView.swift     # Budget analysis (Sheet 3)
├── Utilities/
│   ├── CategoryComparison.swift     # Budget vs actual model
│   ├── BudgetCalculations.swift     # Financial aggregation functions
│   ├── ValidationHelpers.swift      # Input validation utilities
│   ├── AccessibilityHelpers.swift   # VoiceOver support
│   ├── CalculationVerification.swift # Calculation documentation
│   ├── PerformanceGuidelines.swift  # Performance optimization docs
│   └── TestingGuidelines.swift      # Test case specifications
└── Docs/
    ├── TechnicalSpec.md              # Complete technical specification
    ├── ClaudeCodeResumption.md       # Session interruption guide
    └── UserTestingGuide.md           # Comprehensive testing scenarios
```

## Post-MVP Enhancement Backlog

### ⚠️ CRITICAL: YNAB-Style Refactor Required

**Current State Problem:**
The app currently has "Yearly Income" and "Current Available" sections that were built before understanding true YNAB methodology. These sections imply budgeting future income, which violates YNAB principles.

**Required Changes:**
The Budget Planning View must be completely refactored to follow YNAB-style methodology.

---

### 🔥 Priority 1: YNAB-Style Budget Refactor (CRITICAL)

**Enhancement 1.1: Remove Income Section** ✅ COMPLETE
- [x] Remove "Yearly Income" section entirely from BudgetPlanningView
- [x] Remove "Annual Salary" field
- [x] Remove "Other Income" field
- [x] Remove related state variables (yearlySalary, otherIncome)
- [x] Remove totalIncome computed property from view
- [x] Remove Summary section (will be rebuilt in Enhancement 1.3)
- Note: MonthlyBudget.totalIncome property will be addressed in Enhancement 1.4

**Rationale**: In YNAB-style budgeting, you don't budget expected income. You only budget money you currently have. Income is logged when received via transactions.

**Enhancement 1.2: Create "Ready to Assign" Section** ✅ COMPLETE
- [x] Add new section at TOP of BudgetPlanningView titled "Ready to Assign"
- [x] Add "Starting Balance" input field (Decimal type)
  - Purpose: User enters their current checking/savings account balances
  - This is money that exists RIGHT NOW
- [x] Add "Total Income (This Period)" read-only field
  - Calculate: Sum of all income transactions for selected month using BudgetCalculations
  - Shows money that arrived this period
- [x] Add "Total Assigned" read-only field
  - Calculate: Sum of all budgeted amounts across all categories
  - Shows how much money has been given jobs
- [x] Add "Ready to Assign" read-only field (PROMINENT)
  - Calculate: (Starting Balance + Total Income) - Total Assigned
  - This is the money still available to assign to categories
  - Color: Orange if positive, Green when = $0 ✅, Red if negative
  - Goal: This should be $0 (all money assigned)
- [x] Add info button (ⓘ) with YNAB methodology explanation alert
- [x] Add accessibility labels for VoiceOver support
- [x] Add footer text explaining YNAB principle

**Formula:**
```swift
let startingBalance: Decimal = // User input
let totalIncome: Decimal = // Sum of income transactions for month
let totalAssigned: Decimal = // Sum of all category budgets
let readyToAssign: Decimal = (startingBalance + totalIncome) - totalAssigned
```

**Enhancement 1.3: Update Budget Summary** ✅ COMPLETE
- [x] Remove "Monthly Income" from summary section (already removed in 1.1)
- [x] Update summary to show:
  - "Ready to Assign": Calculated value (from Enhancement 1.2)
  - "Total Assigned": Sum of all category budgets
  - "Goal Status": Three-state visual indicator based on Ready to Assign
- [x] Add visual celebration when Ready to Assign reaches $0
  - Green checkmark icon + "Goal Achieved!" message
  - Green background tint (opacity 0.1)
  - Celebratory footer text: "Perfect! Every dollar has a job."
- [x] Add orange warning when Ready to Assign > $0 (money needs assigning)
- [x] Add red warning when Ready to Assign < $0 (over-assigned)

**Enhancement 1.4: Update MonthlyBudget Model** ✅ COMPLETE
- [x] Add `startingBalance` property (Decimal)
- [x] Remove `totalIncome` stored property - income comes from transactions only
- [x] Remove old non-YNAB properties (fixedExpensesTotal, variableExpensesTotal, savingsGoal)
- [x] Add comprehensive documentation explaining YNAB methodology
- [x] Update initializer to accept startingBalance
- [x] Add optional notes property

**Architecture Decision:**
Computed properties (totalIncome, totalAssigned, readyToAssign) are intentionally
kept in the view layer (BudgetPlanningView) where @Query access to transactions
and categories is available. SwiftData models cannot directly query other models
without complex relationships. The current architecture with calculations in the
view layer is the correct pattern and already implemented in Enhancement 1.2.

MonthlyBudget is now a lightweight settings model that stores user input
(startingBalance) per month, following YNAB principles.

**Enhancement 1.5: Add Educational Helper Text** ✅ COMPLETE (Implemented in 1.2)
- [x] Add info button (ⓘ) next to "Ready to Assign" section title
- [x] On tap, show alert/popover explaining YNAB methodology:
  - "Ready to Assign represents money you have RIGHT NOW"
  - "Budget only money that exists, not money you expect"
  - "When income arrives, log it as a transaction - it will increase your Ready to Assign"
  - "Your goal: Assign all money until Ready to Assign = $0"
- [x] Budget Summary provides tips/guidance based on Ready to Assign status (orange/green/red)

---

### 🔄 Priority 2: Transaction Integration Improvements

**Enhancement 2.1: Income Transaction Impact** ✅ VERIFIED & COMPLETE
- [x] Verify income transactions automatically update "Total Income (This Period)"
  - **Verified**: BudgetPlanningView uses @Query for allTransactions (line 14)
  - totalIncome computed property calls BudgetCalculations.calculateTotalIncome()
  - SwiftData @Query automatically observes changes and triggers view updates
- [x] Verify "Ready to Assign" updates when income transaction is added
  - **Verified**: readyToAssign depends on totalIncome via computed property chain
  - When transaction inserted (TransactionLogView:260), SwiftData notifies all @Query observers
  - View automatically refreshes, recomputing totalIncome → readyToAssign
- [x] Visual feedback when income increases Ready to Assign
  - **Already implemented**: Color-coded Ready to Assign (orange/green/red)
  - Budget Summary provides contextual status messages
  - Additional banners deemed unnecessary - automatic updates are clear and immediate
- [x] Banner "You received income! Assign this money to categories."
  - **Not needed**: Budget Summary already shows orange warning with specific amount
  - Message: "Assign $X.XX to categories" provides same guidance

**Technical Verification:**
SwiftData's @Query property wrapper provides automatic reactive updates:
1. Transaction inserted via modelContext.insert() in TransactionLogView
2. @Query in BudgetPlanningView detects change
3. View body re-evaluated
4. totalIncome recomputed from updated allTransactions
5. readyToAssign recomputed from updated totalIncome
6. Color coding and Budget Summary update to reflect new state

No code changes required - existing implementation already provides correct behavior!

**Enhancement 2.2: Quick Assign from Transactions** ✅ COMPLETE
- [x] Add "Assign Your Income" button when viewing income transactions
  - Button appears at top of transaction list when hasIncomeTransactions = true
  - Headline: "Assign Your Income"
  - Subtitle: "Budget your income in the Budget tab"
  - Blue arrow icon for clear call-to-action
- [x] Tapping "Assign" navigates to Budget tab (sets selectedTab = 0)
  - ContentView passes selectedTab binding to TransactionLogView
  - Navigation is immediate and smooth
- [x] Helps user remember to budget new income immediately
  - Reminder appears persistently when income transactions exist
  - Reinforces YNAB principle: "Give every dollar a job"

---

### 🔄 Priority 3: Budget Tab Polish

**Enhancement 3.1: Visual Hierarchy**
- [ ] Make "Ready to Assign" section most prominent (top of view, distinct styling)
- [ ] Use color coding:
  - Green: Ready to Assign > 0 (money needs to be assigned)
  - Bold Green with ✅: Ready to Assign = $0 (goal achieved!)
  - Red: Ready to Assign < 0 (over-assigned, need to reduce categories)
- [ ] Add large, clear typography for Ready to Assign amount
- [ ] Consider progress indicator showing assigned vs total available

**Enhancement 3.2: Category Assignment UX**
- [ ] Add "Quick Assign" button next to each category
  - On tap, assigns remaining Ready to Assign to that category
  - Useful for "Emergency Fund" or "Next Month's Rent" categories
- [ ] Add "Assign All Remaining" button that distributes remaining money
- [ ] Show real-time Ready to Assign calculation as user edits categories
- [ ] Add undo functionality for assignments

**Enhancement 3.3: Month Navigation Context**
- [ ] When changing months, show message if previous month has unassigned money
- [ ] Allow carrying forward unassigned money to next month
- [ ] Show month-to-month Ready to Assign changes

---

### 🔄 Priority 4: Testing & Validation

**Enhancement 4.1: YNAB Methodology Testing**
- [ ] Create test scenarios validating YNAB principles:
  - [ ] Test: Starting balance + income - assigned = Ready to Assign
  - [ ] Test: Ready to Assign updates when income transaction added
  - [ ] Test: Cannot assign more than available (Ready to Assign >= 0)
  - [ ] Test: Visual indicators when Ready to Assign = $0
  - [ ] Test: Over-assignment warning when Ready to Assign < 0
- [ ] Add validation preventing negative Ready to Assign
- [ ] Add alerts/warnings when user tries to over-assign

**Enhancement 4.2: Documentation Updates**
- [ ] Update TechnicalSpec.md with YNAB methodology section
- [ ] Document "Ready to Assign" calculation formulas
- [ ] Create user guide explaining YNAB budgeting flow
- [ ] Update UserTestingGuide.md with YNAB-specific test cases
- [ ] Add inline code comments explaining YNAB principles

---

### ✅ Completed Enhancements (Keep for Reference)

**Enhancement 2.1: Add Month Indicator** ✅ (Completed 2025-11-02)
- Month display with navigation implemented

**Enhancement 2.2: Add Due Date to Expenses** ✅ (Completed 2025-11-02)
- Due date field added to categories with optional display

**Enhancement 3.1: Make Transactions Tap-able** ✅ (Completed 2025-11-02)
- Tap-to-edit transaction flow implemented

---

## Active Development

**Current Focus**: ✅ Priority 2 COMPLETE! Ready for Priority 3 (Optional)
**Status**: 🎉 Priority 1 Complete + Priority 2 Complete (Transaction Integration)

**Achievement Summary:**
Priority 1 YNAB refactor is complete! Priority 2 (Transaction Integration Improvements) is also complete with Enhancement 2.1 verification and Enhancement 2.2 navigation implementation. The app now has seamless integration between income tracking and budget assignment.

**Recent Significant Changes** (last 5):
1. [2025-11-02] ✅ Completed Enhancement 2.2 - Added Quick Assign navigation from Transactions to Budget
2. [2025-11-02] ✅ Verified Enhancement 2.1 - Income transactions automatically update Ready to Assign
3. [2025-11-02] ✅ Completed Enhancement 1.4 - Refactored MonthlyBudget model for YNAB methodology
4. [2025-11-02] ✅ Completed Enhancement 1.3 - Added Budget Summary with goal status visualization
5. [2025-11-02] ✅ Completed Enhancement 1.2 - Added Ready to Assign section with YNAB calculations

**Active Decisions/Blockers**: None

**Next Session Start Here**:
Priority 1 & 2 complete! Optional next steps:
1. Priority 3: Budget Tab Polish (Quick Assign buttons next to categories, real-time updates, month navigation)
2. Priority 4: Testing & Validation (YNAB methodology testing, validation rules)
Or: Begin new feature development outside the YNAB refactor backlog

**Implementation Order:**
1. Enhancement 1.1 → Remove income section
2. Enhancement 1.2 → Add "Ready to Assign" section
3. Enhancement 1.3 → Update budget summary
4. Enhancement 1.4 → Update MonthlyBudget model
5. Enhancement 1.5 → Add educational helper text

## Git Commit Strategy

**Commit Frequency**: After each logical unit of work (feature addition, bug fix, refactor)

**Commit Message Format**: Conventional Commits
```
<type>: <description>

Examples:
refactor: remove income section from budget view (YNAB methodology)
feat: add Ready to Assign section with YNAB calculations
fix: correct Ready to Assign formula to include starting balance
docs: add YNAB methodology section to CLAUDE.md
test: add YNAB principle validation tests
```

**Commit Types**:
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code restructuring without behavior change
- `docs:` - Documentation updates
- `test:` - Test additions/modifications
- `perf:` - Performance improvements
- `style:` - Code style/formatting changes

**Requirements**:
- Code must build successfully before committing
- Update CLAUDE.md "Recent Significant Changes" after important commits
- Keep commit messages clear and descriptive
- Reference "YNAB methodology" in commits related to budgeting refactor

## Session Continuity Guide

### Starting a New Session

**Minimal Start** (same-day continuation):
```
Read CLAUDE.md "Active Development" section and continue with current focus.
```

**Standard Start** (after gap or new enhancement):
```
1. Read CLAUDE.md "Active Development" section
2. Review "YNAB-Style Budgeting Methodology" section
3. Check "Post-MVP Enhancement Backlog" for current priority
4. Review git log --oneline -5 to see recent work
5. Continue with next unchecked task
```

**Full Start** (after interruption or uncertainty):
```
1. Read CLAUDE.md completely (especially YNAB methodology section)
2. Run: git log --oneline -10
3. Run: git status (check for uncommitted work)
4. Build project to verify working state
5. Report current status and next steps
```

### During Development

**Update "Active Development" section**:
- Change "Current Focus" when starting new enhancement
- Add to "Recent Significant Changes" (keep last 5 only) when:
  - Completing an enhancement
  - Major refactoring (especially YNAB refactor)
  - Significant bug fix
  - Model schema changes
- Update "Active Decisions/Blockers" if blocked or decision needed
- Update "Next Session Start Here" at end of session

**Do NOT**:
- Add blow-by-blow task details to session notes
- List every file changed (git handles that)
- Create session logs with timestamps (git log handles that)
- Keep old session notes (archive or delete after work is complete)

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

8. **Income Tracking**: Income should ONLY come from transactions, never pre-budgeted
   ```swift
   // ✅ CORRECT - Calculate from actual transactions
   var totalIncome: Decimal {
       transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
   }
   
   // ❌ WRONG - Storing expected income
   var monthlyIncome: Decimal = 5000
   ```

## Feature Request Management

**Adding New Feature Requests**:
1. Add to "Post-MVP Enhancement Backlog" with appropriate priority
2. Create subsections for related features
3. Use task checkboxes [ ] for tracking
4. Include clear acceptance criteria
5. Reference related models/views if applicable
6. **Verify it aligns with YNAB methodology** (critical!)

**Completing Enhancements**:
1. Check off all related tasks [x]
2. Commit with descriptive feat: message
3. Add entry to "Recent Significant Changes"
4. Update "Next Session Start Here" if needed
5. Move to next priority enhancement
6. Test that YNAB principles are maintained

## Quick Reference

**Build Project**: `Cmd+B` in Xcode

**Check Git Status**: `git status`, `git log --oneline -10`

**Key Files to Review When Starting**:
- This file (CLAUDE.md) - current state, YNAB methodology, next tasks
- Docs/TechnicalSpec.md - implementation patterns and best practices
- Docs/ClaudeCodeResumption.md - recovery from interruptions

**YNAB Methodology Quick Check**:
- ✅ Are we budgeting only money that exists today?
- ✅ Does income arrive via transactions (not pre-budgeted)?
- ✅ Is "Ready to Assign" prominently displayed?
- ✅ Is the goal to reach Ready to Assign = $0?
