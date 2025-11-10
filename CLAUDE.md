# Zero-Based Budget Tracker - iOS App

## Project Status: ✅ Production Ready

**Version**: 1.11.1 (Ready to Assign Bug Fix)
**Last Updated**: November 9, 2025 (v1.11.1 - Critical YNAB Bug Fix)
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
│   ├── CurrencyFormatHelpers.swift  # NEW: Centralized currency formatting with number format support
│   ├── DateFormatHelpers.swift      # NEW: Centralized date formatting with format preference support
│   ├── NotificationManager.swift    # Local push notification scheduling
│   ├── ValidationHelpers.swift      # Input validation utilities
│   ├── Theme/
│   │   ├── Theme.swift              # Theme protocol and color system
│   │   ├── ThemeManager.swift       # Theme state management
│   │   ├── StandardTheme.swift      # NEW: iOS system colors theme (default)
│   │   ├── MidnightMintTheme.swift  # Calm fintech theme
│   │   ├── NeonLedgerTheme.swift    # Cyberpunk theme
│   │   └── UltravioletSlateTheme.swift  # Bold violet theme
│   └── [Other utility files...]
└── Docs/
    ├── TechnicalSpec.md              # Complete technical specification
    └── ClaudeCodeResumption.md       # Session interruption guide
```

## Recent Version History

**v1.11.1 (Complete):**
- ✅ Bug 14.1: Fixed critical "Ready to Assign" calculation bug
- ✅ Problem: Ready to Assign was using `startingBalance + income - budgeted` instead of `currentBalance - budgeted`
- ✅ Impact: When creating accounts or adding transactions, Ready to Assign showed incorrect amounts
- ✅ Root Cause: Formula was double-counting expenses (expenses already reduced current balance)
- ✅ Fix: Changed to correct YNAB formula: `currentAccountBalances - totalBudgeted`
- ✅ Modified: BudgetPlanningView.swift (readyToAssign computed property and calculateReadyToAssign function)
- ✅ Testing: All 18 smoke tests pass
- ✅ YNAB Compliance: Now correctly reflects that "Ready to Assign = Money you have NOW - Money already assigned"

**v1.11.0 (Complete):**
- ✅ Enhancement 13.2: CSV Transaction Import with fuzzy column mapping
- ✅ Created: ImportManager.swift utility (CSV parser, fuzzy matching, date/amount parsing)
- ✅ Created: ImportTransactionsSheet.swift (file picker with security-scoped resource handling)
- ✅ Created: ImportColumnMappingSheet.swift (dropdown mapping with auto-suggestions and preview)
- ✅ Created: ImportResultsSheet.swift (success/failure summary with error details)
- ✅ Added: Levenshtein distance algorithm for intelligent column header detection
- ✅ Added: Multi-format date support (ISO 8601, MM/DD/YYYY, DD/MM/YYYY)
- ✅ Added: Multi-format number support (1,234.56 / 1.234,56 / 1 234,56)
- ✅ Added: Debit/Credit column OR single Amount column support
- ✅ Added: Duplicate detection (date + amount + description)
- ✅ Added: Import button (download icon) to TransactionLogView toolbar
- ✅ Added: Dismissal callback chain to close all sheets on completion
- ✅ Improved: YNAB compliance - imported transactions have category = nil (user assigns later)
- ✅ Improved: Three-sheet workflow with clear step-by-step progression
- ✅ Improved: Full theme color support across all import views
- ✅ Testing: User-tested with real CSV file (0 errors)

**v1.10.0 (Complete):**
- ✅ Enhancement 13.1: Compact transaction display for improved density and scannability
- ✅ Reduced: TransactionRow height by ~40% (from ~100-120pt to ~60-70pt)
- ✅ Improved: 8-10 transactions now visible per screen (vs previous 5-7)
- ✅ Redesigned: Two-row layout showing icon, description, amount, category badge, net worth
- ✅ Removed: Redundant fields (account name, date, type label) from row display
- ✅ Added: Comprehensive VoiceOver accessibility label with all transaction details
- ✅ Optimized: Spacing and padding for compact display (VStack spacing 4, vertical padding 6)
- ✅ Added: Category badge with 8pt color dot for visual categorization

**v1.9.0 (Complete):**
- ✅ Bug 11.1: Fixed Date Format setting to apply throughout app
- ✅ Bug 11.2: Fixed Number Format setting to apply throughout app
- ✅ Bug 12.1: Added Standard theme with iOS system colors
- ✅ Enhancement 11.1: Made category name editable in Edit Category sheet
- ✅ Created: DateFormatHelpers.swift centralized utility with three format options
- ✅ Created: CurrencyFormatHelpers.swift centralized utility with three number formats
- ✅ Created: StandardTheme.swift with native iOS appearance (Blue, Green, Red, Orange)
- ✅ Added: Support for MM/DD/YYYY, DD/MM/YYYY, YYYY-MM-DD date formats
- ✅ Added: Support for "1,234.56" (US), "1.234,56" (EU), "1 234,56" (space) number formats
- ✅ Added: Standard theme as 4th theme option with iOS system colors
- ✅ Added: Smart year handling (shows year only for non-current year dates)
- ✅ Added: Format-specific section headers (US: "Nov 5", EU: "5 Nov", ISO: "Nov 5")
- ✅ Updated: 30 currency displays across 8 view files to use CurrencyFormatHelpers
- ✅ Updated: Transaction section headers and row dates respect user preference
- ✅ Updated: Budget Planning and Analysis views use DateFormatHelpers
- ✅ Updated: Accessibility labels delegate to DateFormatHelpers (long format for VoiceOver)
- ✅ Updated: Default theme changed from Midnight Mint to Standard for new users
- ✅ Added: TextField for category name (previously read-only text)
- ✅ Added: Validation for empty names and duplicate category names
- ✅ Added: Case-insensitive duplicate detection with clear error messages
- ✅ Added: Automatic whitespace trimming on save
- ✅ Fixed: Compilation errors (dateFormat scope, unused variables)
- ✅ Improved: Date formatting consistency across all tabs
- ✅ Improved: Number formatting consistency across all currency displays
- ✅ Improved: Category management UX - users can rename categories without losing transaction history
- ✅ Improved: App now defaults to familiar iOS look for new users

**v1.8.1 (Complete):**
- ✅ Bug 10.1: Implemented light/dark color variants for all three themes
- ✅ Bug 10.2: Fixed Account tab theme color updates on theme switch
- ✅ Architecture 1: Smoke test strategy for token efficiency (18 tests, ~0.2s runtime)
- ✅ Added: Light mode color palettes for Neon Ledger, Midnight Mint, Ultraviolet Slate themes
- ✅ Added: WCAG AA-compliant contrast ratios for all light mode colors (4.5:1+ for text)
- ✅ Updated: Theme protocol with lightColors/darkColors properties and colors(for:) method
- ✅ Updated: ThemeEnvironment with themeColors computed property for automatic color scheme adaptation
- ✅ Migrated: All 18 view files to use @Environment(\.themeColors) for color-scheme-aware theming
- ✅ Fixed: "Cannot find 'colors' in scope" build errors across 6 files
- ✅ Improved: Theme switching now works correctly in both light and dark modes
- ✅ Improved: Appearance setting (System/Light/Dark) properly adjusts backgrounds and surfaces
- ✅ Improved: Token efficiency - ~70% reduction per test run using smoke tests
- ✅ Complete: Full light/dark theme support with instant switching and no animation lag
- ✅ Test Suite: 158 tests total (140 comprehensive + 18 smoke tests)

**v1.8.0 (Complete):**
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

**v1.6.0 - v1.4.0** (Earlier Releases):
- Comprehensive unit testing suite (158 tests total by v1.8.1)
- YNAB-style Accounts tab with account-based budgeting
- 5-tab structure: Accounts → Budget → Transactions → Analysis → Settings
- Full dark mode support with manual toggle (System / Light / Dark)
- Global Settings Tab with data export/import (CSV and JSON)
- Dynamic currency support (10 currencies)
- Push notifications for category due dates
- Transaction-account integration with automatic balance updates
- Date-grouped transaction list with section headers

**v1.0.0 - v1.3.0** (Foundation):
- MVP: SwiftData models, three main views, local-only storage
- Full YNAB methodology refactor (Ready to Assign section)
- Income tracked via transactions only (YNAB compliance)
- Quick Assign and Undo functionality
- Month navigation with carry-forward warnings
- Donut chart visualization in Analysis view

## Active Issues & Enhancement Backlog

### 🟢 Priority 3 Enhancement Requests

(No active enhancement requests - backlog clear)

---

## Active Development

**Current Focus**: v1.11.1 Complete - Critical YNAB Bug Fix (Ready to Assign)
**Status**: 158 tests passing (140 comprehensive + 18 smoke tests); Bug 14.1 fixed and tested

**Recent Significant Changes** (last 5):
1. [2025-11-09] ✅ **Bug 14.1 COMPLETE**: Fixed critical Ready to Assign calculation (now uses currentBalance not startingBalance)
2. [2025-11-09] ✅ **Enhancement 13.2 COMPLETE**: CSV Transaction Import with fuzzy column mapping (ImportManager + 3 sheets)
3. [2025-11-09] ✅ **Enhancement 13.1 COMPLETE**: Compact transaction display (~40% height reduction, 8-10 visible vs 5-7)
4. [2025-11-09] ✅ **Bug 12.1 COMPLETE**: Added Standard theme with iOS system colors (StandardTheme.swift)
5. [2025-11-09] ✅ **Bug 11.2 COMPLETE**: Fixed Number Format setting to apply throughout app (CurrencyFormatHelpers.swift)

**Active Decisions/Blockers**: None

**Next Session Start Here**:
1. **Current Version**: v1.11.1 (critical YNAB bug fix - Ready to Assign now correct)
2. **Test Suite**: 158 tests passing (140 comprehensive + 18 smoke tests)
3. **Build Status**: ✅ Project builds successfully with 0 errors
4. **Recently Completed**:
   - ✅ Bug 14.1: Fixed critical Ready to Assign calculation (was double-counting expenses)
   - ✅ Formula changed from `startingBalance + income - budgeted` to `currentBalance - budgeted`
   - ✅ All smoke tests pass with corrected formula
5. **Active Backlog**:
   - No active enhancement requests or bugs - backlog clear
6. **Recommended Priority**:
   - User testing of v1.11.1 with real accounts and transactions to verify fix
   - Monitor for any edge cases with account balances and Ready to Assign
   - Consider future enhancements: OFX/QFX file support, automatic category suggestions, bank linking
7. **Test Strategy**: Use smoke tests for UI changes, full suite for model/calculation changes
8. **Platform**: iPhone-only, iOS 26+ (no iPad support)
9. **Ready For**: Production deployment after user testing of Bug 14.1 fix

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
3. Run: Smoke tests only (see Test Execution Strategy below)
4. Start work on highest priority enhancement
```

**Full Start** (after interruption or major context switch):
```
1. Read CLAUDE.md completely (focus on YNAB methodology if needed)
2. Run: git log --oneline -10 && git status
3. Run: xcodebuild build (verify project compiles)
4. Run: Smoke tests (not full suite unless required)
5. Review "Active Development" section for current state
6. Report findings and proceed with next enhancement
```

**Note**: The "Next Session Start Here" section is specifically designed to give you immediate context without reading the entire file. Use smoke tests by default to conserve tokens unless working on model/YNAB logic changes.

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

**Check Git Status**: `git status`, `git log --oneline -10`

**Test Execution Strategy** (Token Efficiency):

**Run Smoke Tests** (~15-20 tests, <5 seconds) - **USE THIS FOR MOST CHANGES**:
- UI-only changes, icon theming, layout adjustments, color updates
- Documentation updates, minor bug fixes
- Command: `xcodebuild test -scheme ZeroBasedBudget -only-testing:ZeroBasedBudgetTests/SmokeTests -destination 'platform=iOS Simulator,name=iPhone 17'`

**Run Targeted Tests** (specific suite based on change):
- Model changes: `xcodebuild test -only-testing:ZeroBasedBudgetTests/Models -destination 'platform=iOS Simulator,name=iPhone 17'`
- YNAB logic: `xcodebuild test -only-testing:ZeroBasedBudgetTests/YNAB/YNABMethodologyTests -destination 'platform=iOS Simulator,name=iPhone 17'`
- Calculations: `xcodebuild test -only-testing:ZeroBasedBudgetTests/Utilities/BudgetCalculationsTests -destination 'platform=iOS Simulator,name=iPhone 17'`
- Themes: `xcodebuild test -only-testing:ZeroBasedBudgetTests/Utilities/ThemeManagerTests -destination 'platform=iOS Simulator,name=iPhone 17'`

**Run Full Suite** (140 tests, ~30-45 seconds) - **USE SPARINGLY**:
- Version releases, major refactoring, schema changes, explicit user request
- Command: `xcodebuild test -scheme ZeroBasedBudget -destination 'platform=iOS Simulator,name=iPhone 17'`

**Decision Tree for Test Selection**:
1. Changed model schemas or YNAB calculations? → **Full Suite**
2. Changed specific utility functions? → **Run that utility's tests + smoke tests**
3. Only changed UI/colors/layout? → **Smoke tests only**
4. Version release or PR? → **Full suite**
5. User explicitly asked for tests? → **Full suite**
6. Unsure? → **Smoke tests first, then targeted if issues found**

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