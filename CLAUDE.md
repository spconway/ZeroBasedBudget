# Zero-Based Budget Tracker - iOS App

## Project Status: ✅ Production Ready

**Version**: 1.8.0 (Icon Theming & Navigation Polish)
**Last Updated**: November 6, 2025 (v1.8.0 Complete - 140 Unit Tests)
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

**v1.8.0 (Current - Complete):**
- ✅ Enhancement 9.1: Theme-aware icon system with contextual theming for all SF Symbols
- ✅ Enhancement 9.2: Month navigation moved to navigation bar (< Nov 2025 >)
- ✅ Added: IconTheme.swift utility with 6 icon theming view modifiers
- ✅ Added: Tab bar now uses theme.colors.primary for selected state (.tint())
- ✅ Added: Income/expense icons to transaction rows (arrow.up/down.circle.fill)
- ✅ Improved: All SF Symbols now use contextual theme colors (primary, accent, success, error, warning, neutral)
- ✅ Improved: Vertical whitespace reduced by ~80-100pt in Budget tab
- ✅ Improved: Ready to Assign banner now immediately below navigation bar
- ✅ Removed: Redundant "Budget Planning" title from navigation bar
- ✅ Removed: Standalone month indicator section from view body
- ✅ Updated: 8 view files with themed icons (ContentView, AccountsView, BudgetPlanningView, TransactionLogView, BudgetAnalysisView, ReadyToAssignBanner, ThemePicker, SettingsView)
- ✅ Fixed: ThemeManagerTests.swift Swift 6 concurrency compliance (await mainContext)
- ✅ Complete: Icon theming system with automatic color updates across all three themes

**v1.7.0:**
- ✅ Enhancement 7.1: Replaced relative transaction dates with absolute dates ("Nov 5" instead of "2 days ago")
- ✅ Enhancement 7.2: Added category spending progress indicators with color-coded visual feedback
- ✅ Enhancement 8.1: Theme management infrastructure with SwiftUI Environment integration
- ✅ Enhancement 8.2: Implemented three visual themes (Neon Ledger, Midnight Mint, Ultraviolet Slate)
- ✅ Added: formatTransactionSectionDate() utility function with locale support
- ✅ Added: CategoryProgressBar reusable component with green/yellow/red color coding
- ✅ Added: Progress bars to all category cards in BudgetPlanningView
- ✅ Added: Theme protocol defining complete theme contract (colors, typography, spacing, radius)
- ✅ Added: ThemeManager @Observable class for centralized theme state management
- ✅ Added: ThemeEnvironment for SwiftUI @Environment(\.theme) integration
- ✅ Added: NeonLedgerTheme (cyberpunk with electric teal and magenta accents)
- ✅ Added: MidnightMintTheme as default theme (calm fintech with seafoam mint accents)
- ✅ Added: UltravioletSlateTheme (bold design with deep violet and cyan accents)
- ✅ Added: ThemePicker UI component for Settings with color previews
- ✅ Added: Visual Theme section in Settings view
- ✅ Added: AppSettings.selectedTheme for theme persistence
- ✅ Added: RootView for theme injection at app level
- ✅ Added: 26 unit tests for themes (20 infrastructure + 6 theme-specific tests)
- ✅ Added: 4 unit tests for date formatting (current year, different year, year boundary edge cases)
- ✅ Improved: Transaction list temporal clarity and scannability
- ✅ Improved: Category spending visibility with at-a-glance progress indicators
- ✅ Migrated: All 7 view files systematically migrated to use theme colors (BudgetPlanningView, AccountsView, TransactionLogView, BudgetAnalysisView, SettingsView, AccountRow, CategoryProgressBar)
- ✅ Complete: Full theme system with three selectable visual themes with comprehensive visual impact across entire app

**v1.6.0:**
- ✅ Added: Comprehensive unit testing suite (110 tests across 10 files)
- ✅ Added: XCTest framework infrastructure with in-memory SwiftData testing
- ✅ Added: TestDataFactory for consistent test data creation
- ✅ Added: YNAB methodology validation tests (12 critical tests)
- ✅ Added: Model tests (48 tests) for all SwiftData models
- ✅ Added: Utility function tests (32 tests) for calculations and validation
- ✅ Added: Edge case and boundary tests (10 tests)
- ✅ Added: SwiftData persistence tests (8 tests)
- ✅ Test coverage: Models, utilities, YNAB principles, edge cases, persistence

**v1.5.0:**
- ✅ Fixed: Ready to Assign double-counting bug (startingBalance field added to Account)
- ✅ Fixed: Transaction-account integration with automatic balance updates
- ✅ Added: Date-grouped transaction list with section headers
- ✅ Added: Account picker in transaction Add/Edit sheets
- ✅ Added: Account name display in transaction rows
- ✅ Improved: Transaction list readability with relative dates ("Today", "Yesterday")

**v1.4.0:**
- ✅ YNAB-style Accounts tab with true account-based budgeting
- ✅ Account model for tracking real money accounts (checking, savings, cash)
- ✅ 5-tab structure: Accounts → Budget → Transactions → Analysis → Settings
- ✅ Full dark mode support with manual toggle (System / Light / Dark)
- ✅ Global Settings Tab with data export/import (CSV and JSON)
- ✅ Dynamic currency support (USD, EUR, GBP, CAD, AUD, JPY)
- ✅ Semantic color system (appSuccess, appWarning, appError, appAccent)

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

**No active enhancements**. All planned features for v1.8.0 have been completed.

---

## Active Development

**Current Focus**: v1.8.0 Complete - Icon Theming & Navigation Polish
**Status**: v1.8.0 complete (140 tests passing); project ready for release or new enhancements

**Recent Significant Changes** (last 5):
1. [2025-11-06] ✅ **Enhancement 9.2 COMPLETE**: Month navigation moved to navigation bar (v1.8.0)
2. [2025-11-06] ✅ **Enhancement 9.1 COMPLETE**: Theme-aware icon system with contextual theming (v1.8.0)
3. [2025-11-06] ✅ **v1.7.0 COMPLETE**: Full theme system with three visual themes
4. [2025-11-06] ✅ **Theme Migration COMPLETE**: All views systematically migrated to use theme colors
5. [2025-11-06] ✅ **Three Themes Implemented**: Neon Ledger, Midnight Mint, Ultraviolet Slate

**Active Decisions/Blockers**: None

**Next Session Start Here**:
1. **Current Version**: v1.8.0 complete and stable (140 tests passing)
2. **Project Status**: Production ready with full theme system and icon theming
3. **Recent Enhancements**: Icon theming (9.1), navigation bar month selector (9.2)
4. **Test Suite**: 140 tests passing (114 original + 26 theme tests)
5. **Build Status**: ✅ Project builds successfully
6. **Available Actions**: Consider releasing v1.8.0 or planning new enhancements
7. **Platform**: iPhone-only, iOS 26+ (no iPad support)

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

**Quick Start** (continuing recent work):
```
1. Read CLAUDE.md "Next Session Start Here" section
2. Continue with current enhancement or start next one
```

**Standard Start** (after gap or new context):
```
1. Read CLAUDE.md "Active Development" + "Enhancement Backlog"
2. Run: git log --oneline -5
3. Run: xcodebuild test (verify 140 tests passing)
4. Start work on highest priority enhancement
```

**Full Start** (after interruption or major context switch):
```
1. Read CLAUDE.md completely (focus on YNAB methodology if needed)
2. Run: git log --online -10 && git status
3. Run: xcodebuild build (verify project compiles)
4. Run: xcodebuild test (verify all tests passing)
5. Review "Active Development" section for current state
6. Report findings and proceed with next enhancement
```

**Note**: The "Next Session Start Here" section is specifically designed to give you immediate context without reading the entire file.

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

**Build Project**: `Cmd+B` in Xcode or `xcodebuild -project ZeroBasedBudget.xcodeproj -scheme ZeroBasedBudget build`

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