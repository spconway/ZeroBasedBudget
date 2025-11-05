# Zero-Based Budget Tracker - iOS App

## Project Status: ✅ Production Ready

**Version**: 1.4.0-dev
**Last Updated**: November 4, 2025  
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

### 🟢 Priority 3: New Features (v1.4.0)

#### Enhancement 3.1: Financial Summary Card (Quick View) 🟢

**Objective**: Add a quick-access Financial Summary card that displays key budget metrics (Starting Balance, Total Income, Total Assigned) without disrupting the existing TabView navigation structure.

**YNAB Alignment Check**: ✅ Neutral - Provides convenient access to summary metrics while keeping "Ready to Assign" prominently displayed in Budget view. Does not affect core YNAB methodology.

**Implementation Approach**:
- **Keep existing TabView navigation** (Budget, Transactions, Analysis tabs)
- Add a **toolbar button** (info icon, top-right) accessible from all tabs
- Tapping button presents a **sheet** with Financial Summary Card
- Financial Summary Card shows (read-only, auto-updating):
  - Current month display (e.g., "November 2025")
  - Starting Balance
  - Total Income (This Period)
  - Total Assigned
  - Ready to Assign (for context, with color coding)
- Sheet dismisses via swipe-down or close button
- **Add Settings as 4th tab** in TabView for future use

**Why This Approach**:
- ✅ Keeps familiar TabView navigation (no learning curve)
- ✅ iPhone-native pattern (sheet presentation)
- ✅ Non-disruptive - existing views unchanged
- ✅ Quick access from any tab via toolbar button
- ✅ No complex sidebar logic or platform-specific behavior
- ✅ Ready to Assign stays prominent in Budget view

**Files to Create**:
- [ ] `Views/FinancialSummaryCard.swift` - Reusable summary card component
- [ ] `Views/FinancialSummarySheet.swift` - Sheet container for summary card
- [ ] `Views/SettingsView.swift` - Basic settings view (placeholder for Enhancement 3.2)

**Files to Modify**:
- [ ] `ContentView.swift` - Add 4th Settings tab, add @State for sheet presentation
- [ ] `BudgetPlanningView.swift` - Add toolbar with info button, sheet modifier
- [ ] `TransactionLogView.swift` - Add toolbar with info button, sheet modifier
- [ ] `BudgetAnalysisView.swift` - Add toolbar with info button, sheet modifier
- [ ] Extract financial calculation logic to shared utility if not already modular

**UI Design**:
```swift
// Toolbar button in navigation bar (all tabs)
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button {
            showingFinancialSummary = true
        } label: {
            Image(systemName: "info.circle")
        }
    }
}

// Sheet presentation
.sheet(isPresented: $showingFinancialSummary) {
    FinancialSummarySheet(
        month: selectedMonth,
        startingBalance: startingBalance,
        totalIncome: totalIncome,
        totalAssigned: totalAssigned,
        readyToAssign: readyToAssign
    )
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
}

// FinancialSummaryCard component
VStack(spacing: 20) {
    // Month header
    Text(monthYearText)
        .font(.title2)
        .fontWeight(.bold)

    Divider()

    // Financial metrics
    LabeledContent("Starting Balance") {
        Text(startingBalance, format: .currency(code: "USD"))
            .fontWeight(.semibold)
    }

    LabeledContent("Total Income (This Period)") {
        Text(totalIncome, format: .currency(code: "USD"))
            .fontWeight(.semibold)
            .foregroundStyle(.green)
    }

    LabeledContent("Total Assigned") {
        Text(totalAssigned, format: .currency(code: "USD"))
            .fontWeight(.semibold)
    }

    Divider()

    // Ready to Assign (contextual)
    LabeledContent("Ready to Assign") {
        Text(readyToAssign, format: .currency(code: "USD"))
            .fontWeight(.bold)
            .foregroundStyle(readyToAssignColor)
    }
}
.padding()
```

**Design Considerations**:
- Info icon (ℹ️) is universally understood for "more information"
- Sheet with .medium detent shows summary without covering entire screen
- Swipe-down to dismiss follows iOS conventions
- Financial data updates in real-time (passed as @Binding or computed)
- Works identically across all tabs
- No state persistence needed (ephemeral view)

**Testing Checklist**:
- [ ] Test on iPhone SE (smallest screen, sheet sizes appropriately)
- [ ] Test on iPhone 15 Pro (standard size)
- [ ] Test on iPhone 15 Pro Max (largest screen)
- [ ] Verify financial calculations update instantly when sheet is open
- [ ] Test toolbar button visible on all three main tabs
- [ ] Verify sheet dismissal (swipe down, close button, tap outside)
- [ ] Test with different month selections (month navigation)
- [ ] Verify accessibility (VoiceOver reads all values correctly)
- [ ] Test with Dynamic Type (text scales appropriately)
- [ ] Verify color coding for Ready to Assign works in sheet

**Acceptance Criteria**:
- ✅ Toolbar button (info icon) appears in all tabs
- ✅ Tapping button presents Financial Summary sheet
- ✅ Sheet displays: Starting Balance, Total Income, Total Assigned, Ready to Assign
- ✅ Sheet shows current month clearly
- ✅ All financial data updates in real-time
- ✅ Sheet dismisses via swipe-down or close button
- ✅ TabView navigation unchanged (Budget, Transactions, Analysis, Settings)
- ✅ No regressions in existing functionality
- ✅ Settings tab added for future use

---

#### Enhancement 3.2: Global Settings Tab 🟢

**Objective**: Add comprehensive settings view for app configuration, data management, and user preferences.

**YNAB Alignment Check**: ✅ Neutral - settings don't affect core YNAB methodology.

**Settings Categories** (organized by importance):

1. **Appearance**
   - Dark mode: System / Light / Dark (see Enhancement 3.3)
   - Color scheme: Default / Custom (future enhancement)
   - Font size: System / Custom (future enhancement)

2. **Currency & Formatting**
   - Currency selection (currently hardcoded to USD)
     - Support: USD, EUR, GBP, CAD, AUD, JPY, etc.
   - Date format: MM/DD/YYYY, DD/MM/YYYY, YYYY-MM-DD
   - Number format: 1,234.56 vs 1.234,56 vs 1 234,56

3. **Budget Behavior**
   - Month start date: 1st-31st (currently hardcoded to 1st)
     - Use case: Some users get paid mid-month
   - Default notification frequency for new categories
   - Allow negative category amounts: Yes / No (currently allowed)

4. **Notifications**
   - Enable notifications: On / Off (master switch)
   - Default notification schedule: 7-day, 2-day, on-date, custom
   - Notification sound: Default / Silent / Custom

5. **Data Management**
   - Export budget data (CSV format)
   - Export budget data (JSON format - full backup)
   - Import budget data (JSON)
   - Clear all data (with confirmation + warning)
   - Storage location info (local-only, no cloud)

6. **About**
   - App version & build number
   - YNAB Methodology explanation (educational)
   - Privacy policy (emphasize local-only storage)
   - Feedback / GitHub link
   - Acknowledgments

**Files to Create**:
- [ ] `Views/SettingsView.swift` - Main settings container with List of sections
- [ ] `Views/Settings/AppearanceSettingsView.swift` - Dark mode, colors, fonts
- [ ] `Views/Settings/CurrencySettingsView.swift` - Currency and number format
- [ ] `Views/Settings/BudgetBehaviorSettingsView.swift` - Month start, defaults
- [ ] `Views/Settings/NotificationSettingsView.swift` - Notification preferences
- [ ] `Views/Settings/DataManagementView.swift` - Export, import, clear data
- [ ] `Views/Settings/AboutView.swift` - Version, methodology, links
- [ ] `Models/AppSettings.swift` - SwiftData model for persisting settings
- [ ] `Utilities/DataExporter.swift` - CSV/JSON export functionality
- [ ] `Utilities/DataImporter.swift` - JSON import with validation

**Files to Modify**:
- [ ] `ContentView.swift` - Add Settings to navigation (tab or sidebar item)
- [ ] All views using hardcoded "USD" - Make currency dynamic via AppSettings
- [ ] `NotificationManager.swift` - Respect global notification settings
- [ ] `BudgetPlanningView.swift` - Use dynamic month start date from settings

**Implementation Notes**:
- Use `@AppStorage` for simple preferences (dark mode, date format)
- Use SwiftData `AppSettings` model for complex preferences (currency, custom notifications)
- Implement settings schema versioning for future migrations
- All settings must have sensible defaults (current behavior)
- Settings changes apply immediately (no "Save" button needed)

**Data Export Format (CSV)**:
```csv
Category,Type,Amount,DueDate,NotificationEnabled
Rent,Fixed,1500.00,2025-12-01,true
Groceries,Variable,600.00,,false
```

**Data Export Format (JSON)** - Full backup:
```json
{
  "version": "1.4.0",
  "exportDate": "2025-11-04T12:00:00Z",
  "monthlyBudgets": [...],
  "categories": [...],
  "transactions": [...]
}
```

**Testing Checklist**:
- [ ] Each setting persists across app restarts
- [ ] Currency changes update all currency displays immediately
- [ ] Export CSV produces valid, importable file
- [ ] Export JSON contains complete data
- [ ] Import JSON validates schema and restores data correctly
- [ ] Import JSON shows error for invalid files
- [ ] Clear data requires confirmation and works completely
- [ ] About section displays correct version info

**Acceptance Criteria**:
- ✅ Settings tab/view accessible from navigation
- ✅ All settings categories implemented
- ✅ Settings persist across app launches
- ✅ Currency selection updates all views
- ✅ Export/import functionality works correctly
- ✅ Clear data functionality has proper safeguards
- ✅ About section contains accurate information

---

#### Enhancement 3.3: Dark Mode Support 🟢

**Objective**: Full dark mode support with automatic system theme detection and manual override option.

**YNAB Alignment Check**: ✅ Neutral - visual enhancement, doesn't affect methodology.

**Implementation Phases**:

**Phase 1: Audit Current UI** ✅ (Non-breaking, exploratory)
- [ ] Test app in dark mode (iOS Settings > Display > Dark)
- [ ] Document all views and identify hardcoded colors
- [ ] Test Swift Charts in dark mode
- [ ] Check SF Symbols (most auto-adapt, verify custom symbols)
- [ ] Identify contrast/readability issues

**Phase 2: Fix Color Issues** 🎨
- [ ] Replace hardcoded colors with semantic colors:
  - `.black` → `.primary`
  - `.gray` → `.secondary`
  - `.white` → `.background`
  - Hardcoded hex colors → semantic or Color asset
- [ ] Create Color Set in `Assets.xcassets`:
  - `AccentColor` (light: blue, dark: light blue)
  - `SuccessColor` (light: green, dark: light green)
  - `WarningColor` (light: orange, dark: amber)
  - `ErrorColor` (light: red, dark: light red)
  - `ChartColor1-5` (light/dark variants)
- [ ] Update chart colors for dark mode:
  - Bar charts: Use semantic colors
  - Line charts: Increase line width for dark mode readability
  - Donut chart: Ensure sufficient contrast between segments
- [ ] Test color contrast ratios (WCAG AA: 4.5:1 for text)

**Phase 3: Manual Toggle** ⚙️
- [ ] Add toggle in Settings: "Appearance" section
  - Options: System (default), Light, Dark
- [ ] Implement via `.preferredColorScheme()` on ContentView
- [ ] Persist preference in AppSettings
- [ ] Update immediately when changed (no app restart)

**Files to Modify**:
- [ ] `BudgetPlanningView.swift` - Audit/fix colors, check progress bar
- [ ] `TransactionLogView.swift` - Audit/fix colors, check row backgrounds
- [ ] `BudgetAnalysisView.swift` - Update chart colors for dark mode
- [ ] `ContentView.swift` - Apply `.preferredColorScheme()` from settings
- [ ] `Assets.xcassets` - Add color sets with light/dark variants
- [ ] `SettingsView.swift` - Add Appearance section with dark mode toggle

**Color Audit Checklist**:
- [ ] Background colors (Form, List, Section backgrounds)
- [ ] Text colors (primary, secondary, disabled)
- [ ] Chart colors (bar, line, donut - all 5+ colors)
- [ ] Button colors (primary, secondary, destructive)
- [ ] Progress bar colors (Ready to Assign: green/orange/red)
- [ ] Section headers and footers
- [ ] List row backgrounds and separators
- [ ] Navigation bar and tab bar
- [ ] Sheet and alert backgrounds

**Testing Checklist**:
- [ ] Test in iOS Settings dark mode (automatic)
- [ ] Test manual toggle in Settings (System/Light/Dark)
- [ ] Test all 3 main views in both modes
- [ ] Test all charts readable in dark mode
- [ ] Test Ready to Assign colors work in dark mode
- [ ] Test notification settings UI in dark mode
- [ ] Test month picker in dark mode
- [ ] Verify accessibility: VoiceOver, contrast ratios
- [ ] Test on OLED display (true black or dark gray?)
- [ ] Test dynamic type (larger text) in both modes

**Design Decisions**:
- True black (#000000) vs dark gray (#1C1C1E)?
  - Recommendation: Dark gray (matches iOS system apps)
- Chart colors: Saturated or muted in dark mode?
  - Recommendation: Slightly desaturated for less eye strain
- Progress bar: Keep bright green for goal achievement?
  - Recommendation: Yes, but use lighter shade

**Acceptance Criteria**:
- ✅ App supports iOS system dark mode automatically
- ✅ All views render correctly in dark mode
- ✅ All charts readable with good contrast
- ✅ Manual dark mode toggle in Settings works
- ✅ Color contrast meets WCAG AA standards
- ✅ No visual glitches during theme transitions
- ✅ Settings persist across app launches

---

### Implementation Priority Order (v1.4.0)

**Recommended sequence (revised for iPhone-only focus):**

1. **Enhancement 3.1 (Financial Summary Card)** - Do first ⭐ *Complexity reduced*
   - Reason: Now very simple - just add toolbar button + sheet
   - No architectural changes (TabView stays)
   - Creates Settings tab for future use
   - Can be implemented in ~1-2 hours
   - Good foundation for other enhancements

2. **Enhancement 3.3 (Dark Mode)** - Do second
   - Reason: Least disruptive, mostly visual changes
   - Will inform color choices for Financial Summary Card
   - Can be tested incrementally (view by view)
   - Phase 1 audit is non-breaking
   - Tests Financial Summary sheet in both modes

3. **Enhancement 3.2 (Settings)** - Do last
   - Reason: Most complex with many sub-features
   - Required for dark mode toggle (Phase 3 of Enhancement 3.3)
   - Creates infrastructure for future preferences
   - Establishes data export patterns for future features
   - Benefits from Settings tab already existing (from Enhancement 3.1)

**Estimated Complexity** (updated):
- Enhancement 3.1: **Low** ⬇️ (simple sheet presentation, no architectural changes)
- Enhancement 3.3: Medium (color audit tedious but straightforward)
- Enhancement 3.2: High (many sub-features, export/import logic)

---

## Active Development

**Current Focus**: 🚀 v1.4.0 Feature Development - Three major enhancements planned
**Status**: Enhancement specifications complete, ready to begin implementation

**Recent Significant Changes** (last 5):
1. [2025-11-04] 🎯 **Revised Enhancement 3.1**: iPhone-only focus - Financial Summary sheet (not sidebar)
2. [2025-11-04] 📱 Updated platform requirements: iPhone-only, iOS 26+ (no iPad support)
3. [2025-11-04] 📋 Specified v1.4.0 enhancements: Financial Summary, Settings, Dark mode
4. [2025-11-03] ✅ Added donut chart visualization to Analysis view
5. [2025-11-03] ✅ Removed excessive top whitespace (inline navigation mode)

**Active Decisions/Blockers**: None

**Next Session Start Here**:
1. Read CLAUDE.md "Active Issues & Enhancement Backlog" section
2. Review recommended implementation order: 3.1 (Financial Summary) → 3.3 (Dark Mode) → 3.2 (Settings)
3. **NEW**: Enhancement 3.1 simplified for iPhone-only (no sidebar, just sheet + Settings tab)
4. **Platform**: iPhone-only, iOS 26+ (no iPad support)
5. Start with Enhancement 3.1: Financial Summary Card (Low complexity, ~1-2 hours)

**Implementation Priority Order:**
1. **Enhancement 3.1** (Financial Summary Card) - **Start here**: Simple sheet, no architectural changes
2. **Enhancement 3.3** (Dark Mode) - Second: Visual changes, test new summary sheet
3. **Enhancement 3.2** (Settings) - Last: Most complex, needs Settings tab from 3.1

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