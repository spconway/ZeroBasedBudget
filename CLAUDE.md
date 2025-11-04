# Zero-Based Budget Tracker - iOS App

## Project Status: ✅ Production Ready

**Version**: 1.3.0  
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
- **Notifications**: UNUserNotificationCenter for local push notifications

## Current Project Structure

```
ZeroBasedBudget/
├── Models/
│   ├── BudgetCategory.swift         # Categories with amounts, due dates, notifications
│   ├── Transaction.swift            # Financial transactions (income/expense)
│   └── MonthlyBudget.swift          # Monthly budget with startingBalance, YNAB calcs
├── Views/
│   ├── BudgetPlanningView.swift     # Ready to Assign, category assignment, Quick Assign
│   ├── TransactionLogView.swift     # Transaction log with running balance, tap-to-edit
│   └── BudgetAnalysisView.swift     # Budget vs actual with Swift Charts
├── Utilities/
│   ├── BudgetCalculations.swift     # Financial aggregation functions
│   ├── NotificationManager.swift    # Local push notification scheduling
│   ├── ValidationHelpers.swift      # Input validation utilities
│   └── [Other utility files...]
└── Docs/
    ├── TechnicalSpec.md              # Complete technical specification
    └── ClaudeCodeResumption.md       # Session interruption guide
```

## Recent Version History

**v1.3.0 (Current):**
- ✅ Fixed: $0 category amounts now allowed (YNAB principle)
- ✅ Fixed: Transaction detail sheet works after app restart
- ✅ Added: Push notifications for category due dates
- ✅ Added: Notification frequency settings (7-day, 2-day, on-date, custom)
- ✅ Added: "Last day of month" due date option with smart date calculation

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

### 🟡 Priority 2: UX Improvements

**Enhancement 2.1: YNAB-Style Day-of-Month Due Date Picker**
- [ ] **Current behavior**: Due date uses standard iOS DatePicker (full calendar)
- [ ] **Desired behavior**: Show day-of-month picker (1st, 2nd, 3rd... 31st)
- [ ] **Rationale**: 
  - More YNAB-like approach (bills repeat monthly on same day)
  - User thinks "rent is due on the 15th" not "rent is due November 15, 2025"
  - Reduces cognitive overhead (just pick day number)
  - Aligns with monthly budgeting cycle
- [ ] **Implementation approach**:
  - Replace DatePicker with day-of-month selector
  - Consider using Picker with 1-31 range styled as "1st", "2nd", "3rd", etc.
  - Store as day number (Int) + "isLastDayOfMonth" (Bool)
  - Calculate actual Date based on current month when needed
  - Maintain backward compatibility with existing date-based due dates
- [ ] **UI/UX Design Considerations**:
  - Use ordinal format: "1st", "2nd", "3rd", "4th", "5th", etc.
  - Picker style options:
    - **Option A**: Wheel picker (iOS standard, compact)
    - **Option B**: Segmented grid (easier to scan, but takes space)
    - **Option C**: Dropdown menu with search
  - **Recommendation**: Wheel picker with ordinal formatting (native feel, compact)
  - Add "Last day of month" as special option at end of list
- [ ] **Model changes needed**:
  - Option 1: Add `dueDayOfMonth: Int?` field (1-31), deprecate `dueDate: Date?`
  - Option 2: Keep `dueDate: Date?` but calculate from day-of-month when needed
  - **Recommendation**: Option 1 (cleaner, more explicit)
- [ ] **Migration strategy** (if changing model)**:
  - Keep existing `dueDate` for backward compatibility initially
  - Extract day from existing dates: `Calendar.current.component(.day, from: dueDate)`
  - Phase out old field in future version
- [ ] **Files to modify**:
  - Models/BudgetCategory.swift (add dueDayOfMonth or refactor dueDate)
  - Views/BudgetPlanningView.swift (replace DatePicker with day-of-month picker)
  - Utilities/NotificationManager.swift (calculate notification dates from day-of-month)
- [ ] **Test cases**:
  - Select various days (1st, 15th, 31st, last day)
  - Test in different months (30-day, 31-day, February)
  - Verify notifications still schedule correctly
  - Test month navigation updates due dates properly

**Enhancement 2.2: Remove Excessive Top Whitespace**
- [ ] **Current behavior**: Budget/Transactions/Analysis tabs have too much whitespace at top
- [ ] **Expected behavior**: More compact, efficient use of screen space
- [ ] **Investigation needed**:
  - Check navigation bar configuration in each view
  - Check if navigationTitle is using large display mode unnecessarily
  - Look for extra padding or spacing modifiers
  - Review iOS 26 SwiftUI navigation best practices
- [ ] **Files to investigate**:
  - Views/BudgetPlanningView.swift
  - Views/TransactionLogView.swift
  - Views/BudgetAnalysisView.swift
  - ContentView.swift (TabView configuration)
- [ ] **Possible solutions**:
  - Use `.navigationBarTitleDisplayMode(.inline)` instead of `.large`
  - Remove unnecessary top padding
  - Adjust Form/List inset behavior
  - Use `listStyle(.plain)` if lists have extra insets
- [ ] **Implementation approach**:
  - Test different navigationBarTitleDisplayMode options
  - Remove any explicit spacers or padding at top of views
  - Consider custom toolbar/header if needed for compact display
  - Ensure consistent across all three tabs
- [ ] **Test cases**:
  - Visual comparison before/after on various device sizes
  - Ensure scrolling behavior still works correctly
  - Verify content is still accessible (not cut off)
  - Test on iPhone SE (small screen) and iPhone Pro Max (large screen)

**Enhancement 2.3: Improve Analysis View with Pie Chart**
- [ ] **Current behavior**: 
  - Analysis view uses grouped bar chart (budgeted vs actual)
  - With many categories, becomes difficult to read
  - Summary cards show totals but visual is crowded
- [ ] **Desired behavior**: 
  - Add pie chart showing spending distribution
  - Easier to see proportions at a glance
  - More user-friendly with many categories
- [ ] **Implementation approach**:
  - Add toggle or tabs to switch between bar chart and pie chart views
  - Pie chart shows actual spending by category (color-coded)
  - Consider showing only top N categories + "Other" for clarity
  - Use Swift Charts SectorMark for pie/donut chart
- [ ] **Design considerations**:
  - **Chart type**: Pie chart or donut chart?
    - Donut chart preferred (modern, cleaner, can show total in center)
  - **Data**: Show actual spending only (not budgeted on pie chart)
  - **Colors**: Use consistent category colors from budget view
  - **Labels**: Category names + amounts/percentages
  - **Interaction**: Tap segment to see details or filter
  - **Limit categories**: If >10 categories, group smallest into "Other"
- [ ] **Files to modify**:
  - Views/BudgetAnalysisView.swift (add pie chart view, toggle/tabs)
  - May need to refactor chart into separate components
- [ ] **SwiftUI/Swift Charts reference**:
  - Use `SectorMark` for pie/donut charts
  - `.foregroundStyle(by: .value("Category", category))` for colors
  - `.annotation(position: .overlay)` for labels
- [ ] **Test cases**:
  - Test with few categories (3-5)
  - Test with many categories (15+)
  - Verify "Other" grouping works correctly
  - Test month navigation updates chart
  - Verify colors match budget view

---

## Active Development

**Current Focus**: 🟡 UX Improvements (Enhancement backlog)
**Status**: All Priority 1 bugs fixed! Ready for UX enhancements

**Recent Significant Changes** (last 5):
1. [2025-11-03] ✅ Fixed notification settings visibility during expense creation
2. [2025-11-03] ✅ Fixed CoreData errors on startup by pre-creating store directory
3. [2025-11-02] ✅ v1.3.0 Released - Last day of month due dates implemented
4. [2025-11-02] ✅ Notification frequency settings complete (7-day, 2-day, custom)
5. [2025-11-02] ✅ Push notifications for due dates implemented

**Active Decisions/Blockers**: None

**Next Session Start Here**:
1. Read this CLAUDE.md file (especially Enhancement backlog)
2. All Priority 1 critical bugs are now fixed
3. Ready to work on Priority 2 UX improvements
4. Recommended next: Enhancement 2.1 (YNAB-style day-of-month picker)

**Implementation Priority Order:**
1. Enhancement 2.1 → YNAB-style day-of-month due date picker
2. Enhancement 2.2 → Remove excessive top whitespace
3. Enhancement 2.3 → Add pie chart to Analysis view

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

**Adding New Issues**:
1. Add to "Active Issues & Enhancement Backlog" with appropriate priority
2. Use 🔴 for critical bugs (Priority 1), 🟡 for UX improvements (Priority 2)
3. Use task checkboxes [ ] for tracking
4. Include clear acceptance criteria and test cases
5. Reference files to modify/investigate
6. Add implementation approaches and design considerations
7. **Verify it aligns with YNAB methodology**

**Completing Issues/Enhancements**:
1. Check off all related tasks [x]
2. Commit with descriptive fix:/feat: message
3. Add entry to "Recent Significant Changes"
4. Move completed item to version history (brief summary)
5. Update "Next Session Start Here" if needed
6. Test thoroughly before marking complete
7. Verify YNAB principles maintained (if applicable)

**Moving to Version History**:
- When bug/enhancement is complete, remove detailed tasks
- Add brief one-line summary to version history
- Keep backlog focused on ACTIVE work only

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