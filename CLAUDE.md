# Zero-Based Budget Tracker - iOS App

## Project Status: ✅ Production Ready

**Version**: 1.6.0 (Comprehensive Unit Testing Suite)
**Last Updated**: November 5, 2025 (v1.6.0 Complete - 110 Unit Tests)
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

**v1.7.0 (Current - In Progress):**
- ✅ Enhancement 7.1: Replaced relative transaction dates with absolute dates ("Nov 5" instead of "2 days ago")
- ✅ Enhancement 7.2: Added category spending progress indicators with color-coded visual feedback
- ✅ Enhancement 8.1: Theme management infrastructure with SwiftUI Environment integration
- ✅ Added: formatTransactionSectionDate() utility function with locale support
- ✅ Added: CategoryProgressBar reusable component with green/yellow/red color coding
- ✅ Added: Progress bars to all category cards in BudgetPlanningView
- ✅ Added: Theme protocol defining complete theme contract (colors, typography, spacing, radius)
- ✅ Added: ThemeManager @Observable class for centralized theme state management
- ✅ Added: ThemeEnvironment for SwiftUI @Environment(\.theme) integration
- ✅ Added: MidnightMintTheme as default theme implementation (from design tokens)
- ✅ Added: ThemePicker UI component for Settings with color previews
- ✅ Added: Visual Theme section in Settings view
- ✅ Added: AppSettings.selectedTheme for theme persistence
- ✅ Added: RootView for theme injection at app level
- ✅ Added: 20 unit tests for ThemeManager (initialization, switching, persistence, registry)
- ✅ Added: 4 unit tests for date formatting (current year, different year, year boundary edge cases)
- ✅ Improved: Transaction list temporal clarity and scannability
- ✅ Improved: Category spending visibility with at-a-glance progress indicators
- ✅ Infrastructure: Foundation ready for Enhancement 8.2 (three visual themes implementation)

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

### 🟡 Priority 2: UX Improvements (v1.7.0 In Progress)

#### Enhancement 7.1: Replace Relative Transaction Dates with Absolute Dates

**Status**: ✅ **COMPLETE** (November 6, 2025)
**Version**: v1.7.0 (UX Polish)
**Commit**: `d408390` - feat: replace relative transaction dates with absolute dates

**Completed**: Replaced relative date labels with absolute date formats in transaction list section headers.

**Implementation Summary**:
- ✅ Added `formatTransactionSectionDate()` to BudgetCalculations.swift
- ✅ Updated TransactionLogView to use absolute dates
- ✅ Removed old `formatSectionDate()` function
- ✅ Added 4 unit tests for date formatting (current year, different year, future year, year boundary)
- ✅ Locale-aware formatting using Date.FormatStyle
- ✅ Year omitted for current calendar year ("Nov 5"), included for other years ("Nov 5, 2025")
- ✅ VoiceOver accessibility maintained

---

#### Enhancement 7.2: Add Category Spending Progress Indicators

**Status**: ✅ **COMPLETE** (November 6, 2025)
**Version**: v1.7.0 (UX Enhancement)
**Commit**: `00042b2` - feat: add category spending progress indicators

**Completed**: Added visual progress bars to all budget category cards with color-coded spending feedback.

**Implementation Summary**:
- ✅ Created CategoryProgressBar reusable SwiftUI component
- ✅ Color-coded progress: Green (0-75%), Yellow (75-100%), Red (>100%)
- ✅ Integrated into all category cards (Fixed, Variable, Quarterly expenses)
- ✅ Uses BudgetCalculations.calculateActualSpending() for accurate data
- ✅ Smooth spring animation for progress updates
- ✅ Edge case handling: $0 budget, negative spending, overspending
- ✅ VoiceOver accessibility with progress announcements
- ✅ Created Views/Components/ directory for reusable UI components
- ✅ Multiple preview scenarios for testing


---

### 🟢 Priority 3: New Features (v1.7.0 Planned)

#### Enhancement 8.1: Theme Management Infrastructure

**Status**: ✅ **COMPLETE** (November 6, 2025)
**Version**: v1.7.0 (Theme System Foundation)
**Commit**: `47700ec` - feat: add theme management infrastructure (Enhancement 8.1)

**Completed**: Created centralized theme management system with SwiftUI Environment integration, enabling dynamic theme switching throughout the app. This infrastructure provides the foundation for the three visual themes (Neon Ledger, Midnight Mint, Ultraviolet Slate).

**Implementation Summary**:
- ✅ Created Theme protocol with colors, typography, spacing, radius definitions
- ✅ Created ThemeManager @Observable class for centralized theme state management
- ✅ Created ThemeEnvironment for SwiftUI @Environment(\.theme) integration
- ✅ Implemented MidnightMintTheme as default theme (from Designs/MidnightMint/tokens.json)
- ✅ Created ThemePicker UI component with color previews and descriptions
- ✅ Added Visual Theme section to SettingsView
- ✅ Added AppSettings.selectedTheme property for persistence
- ✅ Created RootView for theme injection at app level
- ✅ Added 20 unit tests for ThemeManager (initialization, switching, persistence, registry)
- ✅ Theme switching with smooth animations
- ✅ Theme persistence across app restarts
- ✅ Color hex initialization helper for design token integration
- ✅ Fallback to default theme for invalid identifiers

**Files Created**:
- ZeroBasedBudget/Utilities/Theme/Theme.swift (212 lines)
- ZeroBasedBudget/Utilities/Theme/ThemeManager.swift (131 lines)
- ZeroBasedBudget/Utilities/Theme/ThemeEnvironment.swift (44 lines)
- ZeroBasedBudget/Utilities/Theme/MidnightMintTheme.swift (77 lines)
- ZeroBasedBudget/Views/Components/ThemePicker.swift (98 lines)
- ZeroBasedBudgetTests/Utilities/ThemeManagerTests.swift (256 lines)

**Files Modified**:
- ZeroBasedBudget/Models/AppSettings.swift (added selectedTheme property)
- ZeroBasedBudget/Views/SettingsView.swift (added Visual Theme section)
- ZeroBasedBudget/ZeroBasedBudgetApp.swift (added RootView for theme injection)

**Foundation ready for Enhancement 8.2 (implement three visual themes).**

---

#### Enhancement 8.2: Implement Three Visual Themes from Design Assets

**Status**: 🔄 **PENDING**
**Version**: v1.7.0 (Theme System Implementation)
**Priority**: High (Completes theme system)
**Planned Start**: After Enhancement 8.1

**Objective**: Implement the three complete visual themes (Neon Ledger, Midnight Mint, Ultraviolet Slate) from the `Designs/` folder, making them selectable in the Settings tab. Each theme provides a distinct aesthetic while maintaining YNAB principles and WCAG AA accessibility standards.

**YNAB Alignment Check**: ✅ **Compliant** - All three themes maintain prominent "Ready to Assign" banner, proper visual hierarchy, and YNAB-first design principles. Color coding for income/expenses preserved across all themes.

**Design Assets Available**:
All three themes have complete design tokens and mockups in `Designs/` folder:

1. **Neon Ledger** (`Designs/NeonLedger/`)
   - Personality: Cyberpunk financial ledger with neon accents
   - Colors: Pure black base (#0A0A0A), electric teal primary (#00E5CC), magenta accent (#FF006E)
   - Features: Neon glows, high contrast, futuristic aesthetic
   - Complete SwiftUI implementation already available in `Theme.swift`
   - WCAG AA compliant contrast ratios validated

2. **Midnight Mint** (`Designs/MidnightMint/`)
   - Personality: Calm, professional modern fintech
   - Colors: Blue-tinted black base (#0B0E11), seafoam mint primary (#3BFFB4), soft teal accent (#14B8A6)
   - Features: Restrained gradients, subtle elevations, trustworthy feel
   - WCAG AA compliant, design tokens available

3. **Ultraviolet Slate** (`Designs/UltravioletSlate/`)
   - Personality: Bold, energetic with saturated colors
   - Colors: Charcoal base (#1A1A1F), deep violet primary (#6366F1), vivid cyan accent (#22D3EE)
   - Features: Thin hairline borders, geometric structure, high energy
   - WCAG AA compliant, design tokens available

**Implementation Approach**:

**Phase 1: Implement Neon Ledger Theme**
1. Create `NeonLedgerTheme.swift` conforming to `Theme` protocol
2. Import color values from `Designs/NeonLedger/tokens.json`
3. Use existing `Designs/NeonLedger/Theme.swift` as reference
4. Define all required colors, typography, spacing, radius
5. Add neon glow effects using `.shadow()` modifiers
6. Test with all app views (Accounts, Budget, Transactions, Analysis, Settings)
7. Verify WCAG AA contrast compliance

**Phase 2: Implement Midnight Mint Theme**
1. Create `MidnightMintTheme.swift` conforming to `Theme` protocol
2. Import color values from `Designs/MidnightMint/tokens.json`
3. Define all required colors, typography, spacing, radius
4. Implement subtle gradients for Ready to Assign banner
5. Test with all app views
6. Verify WCAG AA contrast compliance

**Phase 3: Implement Ultraviolet Slate Theme**
1. Create `UltravioletSlateTheme.swift` conforming to `Theme` protocol
2. Import color values from `Designs/UltravioletSlate/tokens.json`
3. Define all required colors, typography, spacing, radius
4. Implement thin hairline borders (1px) on cards
5. Test with all app views
6. Verify WCAG AA contrast compliance

**Phase 4: Update ThemeManager**
1. Register all three themes with ThemeManager
2. Create theme enum: `case neonLedger, midnightMint, ultravioletSlate`
3. Update theme picker to show all three options with previews
4. Add theme descriptions and personality traits to UI
5. Test theme switching between all three themes

**Phase 5: Apply Themes to All Views**
1. Update all views to use `@Environment(\.theme)` instead of hardcoded colors
2. Replace `AppColors` references with `theme.colors`
3. Test each view with all three themes
4. Ensure Ready to Assign banner prominence in all themes
5. Verify income/expense color coding consistency

**Files to Create**:
- `ZeroBasedBudget/Utilities/Theme/NeonLedgerTheme.swift` - Neon Ledger theme implementation
- `ZeroBasedBudget/Utilities/Theme/MidnightMintTheme.swift` - Midnight Mint theme implementation
- `ZeroBasedBudget/Utilities/Theme/UltravioletSlateTheme.swift` - Ultraviolet Slate theme implementation
- `ZeroBasedBudgetTests/Utilities/NeonLedgerThemeTests.swift` - Unit tests for Neon Ledger theme
- `ZeroBasedBudgetTests/Utilities/MidnightMintThemeTests.swift` - Unit tests for Midnight Mint theme
- `ZeroBasedBudgetTests/Utilities/UltravioletSlateThemeTests.swift` - Unit tests for Ultraviolet Slate theme

**Files to Modify**:
- `ZeroBasedBudget/Utilities/Theme/ThemeManager.swift` - Register all three themes
- `ZeroBasedBudget/Views/SettingsView.swift` - Update theme picker with all themes
- **ALL VIEW FILES** - Replace hardcoded colors with `@Environment(\.theme)`:
  - `AccountsView.swift`
  - `BudgetPlanningView.swift`
  - `ReadyToAssignBanner.swift`
  - `TransactionLogView.swift`
  - `BudgetAnalysisView.swift`
  - `SettingsView.swift`
  - All component views (AccountRow, TransactionRow, etc.)

**Design Considerations**:
1. **Color Mapping**: Map design token colors to Theme protocol properties semantically
2. **Consistency**: Ensure each theme maintains visual consistency across all views
3. **Accessibility**: All themes must pass WCAG AA contrast requirements (verified in design docs)
4. **YNAB Principles**: Ready to Assign banner must be prominent in all themes
5. **Performance**: Theme switching should be instant with no lag
6. **Testing**: Test all themes with real user data (transactions, categories, accounts)
7. **Default**: Set Midnight Mint as default theme (broadest appeal, professional)
8. **Documentation**: Document color usage patterns for each theme

**Color Mapping Example**:
```swift
// MidnightMintTheme.swift
struct MidnightMintTheme: Theme {
    let name = "Midnight Mint"

    let colors = ThemeColors(
        background: Color(hex: "0B0E11"),           // Near-black with blue tint
        surface: Color(hex: "14181C"),              // Elevated surface
        surfaceElevated: Color(hex: "1C2128"),      // Further elevated
        primary: Color(hex: "3BFFB4"),              // Seafoam mint
        onPrimary: Color(hex: "0B0E11"),            // Dark text on mint
        accent: Color(hex: "14B8A6"),               // Soft teal
        success: Color(hex: "10B981"),              // Pine green (income)
        warning: Color(hex: "F59E0B"),              // Warm orange
        error: Color(hex: "EF4444"),                // Coral red (expenses)
        textPrimary: Color(hex: "FFFFFF"),          // White text
        textSecondary: Color(hex: "9CA3AF"),        // Gray text
        border: Color(hex: "2A3138"),               // Subtle borders
        readyToAssignBackground: Color(hex: "3BFFB4"), // Mint banner
        readyToAssignText: Color(hex: "0B0E11")     // Dark text on mint
    )

    let typography = ThemeTypography(
        largeTitle: .system(size: 34, weight: .bold, design: .default),
        title: .system(size: 28, weight: .bold, design: .default),
        headline: .system(size: 17, weight: .semibold, design: .default),
        body: .system(size: 17, weight: .regular, design: .default),
        caption: .system(size: 12, weight: .regular, design: .default)
    )

    let spacing = ThemeSpacing(
        xs: 4,
        sm: 8,
        md: 16,
        lg: 24,
        xl: 32
    )

    let radius = ThemeRadius(
        sm: 8,
        md: 12,
        lg: 20,
        xl: 28
    )
}

// Extension for hex color support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        r = Double((int >> 16) & 0xFF) / 255.0
        g = Double((int >> 8) & 0xFF) / 255.0
        b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
```

**Theme Picker UI Example**:
```swift
// In SettingsView.swift - Theme Section
Section("Theme") {
    ForEach([ThemeType.neonLedger, .midnightMint, .ultravioletSlate], id: \.self) { themeType in
        Button(action: {
            themeManager.setTheme(themeType.theme)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(themeType.theme.name)
                        .font(.headline)
                    Text(themeType.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Color preview swatches
                HStack(spacing: 4) {
                    Circle()
                        .fill(themeType.theme.colors.primary)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(themeType.theme.colors.accent)
                        .frame(width: 20, height: 20)
                }

                // Checkmark if selected
                if themeManager.currentTheme.name == themeType.theme.name {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

enum ThemeType {
    case neonLedger
    case midnightMint
    case ultravioletSlate

    var theme: Theme {
        switch self {
        case .neonLedger: return NeonLedgerTheme()
        case .midnightMint: return MidnightMintTheme()
        case .ultravioletSlate: return UltravioletSlateTheme()
        }
    }

    var description: String {
        switch self {
        case .neonLedger: return "Cyberpunk with neon accents"
        case .midnightMint: return "Calm, professional fintech"
        case .ultravioletSlate: return "Bold, energetic design"
        }
    }
}
```

**Testing Checklist**:
- [ ] Neon Ledger theme implemented with all colors from design tokens
- [ ] Midnight Mint theme implemented with all colors from design tokens
- [ ] Ultraviolet Slate theme implemented with all colors from design tokens
- [ ] All three themes registered with ThemeManager
- [ ] Theme picker displays all three themes with previews
- [ ] Theme switching works instantly between all themes
- [ ] Ready to Assign banner prominent in all three themes
- [ ] Income/expense color coding consistent across themes
- [ ] All views updated to use `@Environment(\.theme)`
- [ ] WCAG AA contrast compliance verified for all themes
- [ ] Neon glow effects work in Neon Ledger theme
- [ ] Hairline borders work in Ultraviolet Slate theme
- [ ] Theme selection persists across app restarts
- [ ] No color bleeding or visual artifacts during theme switching
- [ ] VoiceOver announces theme names correctly
- [ ] All 110 unit tests still pass with theme system
- [ ] Performance: Theme switching completes in < 100ms

**Acceptance Criteria**:
- All three themes (Neon Ledger, Midnight Mint, Ultraviolet Slate) fully implemented
- Each theme conforms to Theme protocol with complete color/typography definitions
- Theme picker in Settings tab displays all three themes with descriptions and previews
- User can select any theme and selection persists across app restarts
- All app views use theme colors via `@Environment(\.theme)` (no hardcoded colors)
- YNAB principles maintained: Ready to Assign banner prominent in all themes
- WCAG AA accessibility compliance verified for all three themes
- Theme switching is instant with smooth visual transitions
- Color coding for income/expenses consistent across all themes
- All existing functionality works with all three themes
- All 110 unit tests pass
- Performance meets requirements (< 100ms theme switch)
- Documentation updated with theme usage examples

**Estimated Complexity**: Very High (12-16 hours - three complete theme implementations, view migration, testing across all themes)

**Dependencies**:
- **REQUIRED**: Enhancement 8.1 (Theme Management Infrastructure) must be completed first
- Design assets in `Designs/` folder (already available)

**Version Planning**:
- **v1.7.0**: Complete theme system with all three visual themes
- Provides foundation for future theme additions
- Significantly enhances user experience and app appeal

---

## Active Development

**Current Focus**: v1.7.0 Development - UX Improvements & Theme Management
**Status**: v1.7.0 in progress; Enhancements 7.1, 7.2, 8.1 complete; 134 unit tests passing (114 existing + 20 theme tests)

**Recent Significant Changes** (last 5):
1. [2025-11-06] ✅ **Enhancement 8.1 COMPLETE**: Theme management infrastructure with SwiftUI Environment integration (v1.7.0)
2. [2025-11-06] ✅ **Enhancement 7.2 COMPLETE**: Category spending progress indicators (v1.7.0)
3. [2025-11-06] ✅ **Enhancement 7.1 COMPLETE**: Absolute transaction dates with locale support (v1.7.0)
4. [2025-11-05] ✅ **v1.6.0 COMPLETE**: Comprehensive unit testing suite (110 tests across 10 files, 5 domains)
5. [2025-11-05] ✅ **Three Design Themes Created**: Neon Ledger, Midnight Mint, Ultraviolet Slate (16 design files)

**Active Decisions/Blockers**: None

**Next Session Start Here**:
1. **Test Suite Status**: ✅ All 134 tests passing (114 existing + 20 theme tests, verified November 6, 2025)
2. **Theme Infrastructure**: ✅ Theme management system complete (Enhancement 8.1)
3. **Design Assets**: ✅ Three complete visual themes available in Designs/ folder
4. **Current Priority**: Continue v1.7.0 enhancements - Next: Enhancement 8.2 (Implement Three Visual Themes)
5. **Platform**: iPhone-only, iOS 26+ (no iPad support)

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