# Zero-Based Budget Tracker - iOS App

## Project Overview
iOS budget tracking app built with SwiftUI and SwiftData. Migrates Excel-based zero-based budgeting system to native iOS with three main views replicating the original Excel workbook sheets.

**Technical Specification**: See `Docs/TechnicalSpec.md` for complete implementation details.

## Architecture
- **Framework**: SwiftUI for iOS 26
- **Persistence**: SwiftData (local-only storage, NO cloud sync)
- **Pattern**: MVVM (Model-View-ViewModel)
- **Data Type**: Decimal for ALL monetary values (never Double/Float)

## Implementation Roadmap

### ✅ Phase 1: Core Structure & Foundation
**Status**: ✅ Completed (2025-11-01)
**Goal**: Establish SwiftData models, configure ModelContainer with local-only storage, create basic TabView navigation

**Detailed Tasks**:
- [x] Create CLAUDE.md with full roadmap
- [x] Read and understand Docs/TechnicalSpec.md thoroughly
- [x] Create Models/ folder and SwiftData model files:
  - [x] BudgetCategory.swift (with @Model, @Attribute(.unique), @Relationship)
  - [x] Transaction.swift (with @Model, #Index macros, TransactionType enum)
  - [x] MonthlyBudget.swift (with @Model, computed properties)
- [x] Update ZeroBasedBudgetApp.swift:
  - [x] Configure ModelContainer with cloudKitDatabase: .none
  - [x] Add proper schema configuration
  - [x] Add .modelContainer modifier
- [x] Create Views/ folder and stub view files:
  - [x] Update ContentView.swift with TabView (3 tabs)
  - [x] BudgetPlanningView.swift (placeholder with NavigationStack)
  - [x] TransactionLogView.swift (placeholder with NavigationStack)
  - [x] BudgetAnalysisView.swift (placeholder with NavigationStack)
- [x] Verify app builds and runs successfully
- [x] Update this section upon completion

**Files Created/Modified**:
- CLAUDE.md (created)
- ZeroBasedBudget/Models/BudgetCategory.swift (created)
- ZeroBasedBudget/Models/Transaction.swift (created)
- ZeroBasedBudget/Models/MonthlyBudget.swift (created)
- ZeroBasedBudget/ZeroBasedBudgetApp.swift (modified)
- ZeroBasedBudget/ContentView.swift (modified)
- ZeroBasedBudget/Views/BudgetPlanningView.swift (created)
- ZeroBasedBudget/Views/TransactionLogView.swift (created)
- ZeroBasedBudget/Views/BudgetAnalysisView.swift (created)

**Git Commits**:
- 78f5c21 - docs: initialize CLAUDE.md with project roadmap and Phase 1 plan (2025-11-01)
- 4e411b8 - feat: add SwiftData models (BudgetCategory, Transaction, MonthlyBudget) (2025-11-01)
- be10d68 - feat: configure SwiftData with local-only storage (no cloud sync) (2025-11-01)
- 38304ba - feat: implement TabView navigation with three stub views (2025-11-01)

**Critical Requirements for Phase 1**:
- ❗ Use Decimal type for all monetary fields
- ❗ Configure cloudKitDatabase: .none (no cloud sync)
- ❗ @Relationship(deleteRule: .cascade) on BudgetCategory → Transaction
- ❗ #Index macros on Transaction.date and Transaction.category
- ❗ All views wrapped in NavigationStack

### ✅ Phase 2: Budget Planning View (Sheet 1 Replica)
**Status**: ✅ Completed (2025-11-01)
**Goal**: Implement budget planning form with income, fixed/variable/quarterly expenses, and real-time calculated totals

**Detailed Tasks**:
- [x] Implement Form with sections for income, fixed, variable, and quarterly expenses
- [x] Add TextField with .currency format for all monetary inputs
- [x] Create computed properties for all totals (replicating Excel formulas)
- [x] Implement Summary section with remaining balance (green/red color coding)
- [x] Add @Query to fetch categories from SwiftData
- [x] Create AddCategorySheet for adding new expense categories
- [x] Create EditCategorySheet for editing existing categories
- [x] Implement delete functionality with swipe actions
- [x] Add color indicators for each category
- [x] Verify build succeeds

**Files Modified**:
- ZeroBasedBudget/Views/BudgetPlanningView.swift (fully implemented)

**Key Features Implemented**:
- Monthly Income section with Salary and Other Income inputs
- Fixed Expenses section with dynamic category list
- Variable Expenses section with dynamic category list
- Quarterly Expenses section (monthly equivalent display)
- Real-time calculated totals for each section
- Summary section showing Total Income, Total Expenses, and Remaining Balance
- Add/Edit/Delete functionality for all expense categories
- Color-coded categories with visual indicators
- Form validation (positive amounts, non-empty names)
- All monetary values use Decimal type
- Currency formatting throughout (.currency(code: "USD"))

**Reference**: See TechnicalSpec.md section "Implementing Sheet 1: Zero-based budget planning"

### 🔄 Phase 3: Transaction Log View (Sheet 2 Replica) - CURRENT PHASE
**Status**: Ready to Begin
**Goal**: Transaction list with @Query, entry form with date/category/amount inputs, running balance calculation

**Key Components**:
- List with @Query sorted by date (descending)
- Transaction entry form (DatePicker, Picker for category, TextField for amount)
- Swipe actions (delete/edit)
- Running balance computation
- Search functionality

**Reference**: See TechnicalSpec.md section "Implementing Sheet 2: Transaction log"

### ⏳ Phase 4: Calculations & Persistence
**Status**: Not Started
**Goal**: Implement running balance calculation, category aggregation logic, verify data persistence and integrity

**Key Components**:
- Running balance computed property using Decimal arithmetic
- Category spending aggregation by month
- Data validation and integrity checks
- Test persistence across app launches

**Reference**: See TechnicalSpec.md sections on "Querying and filtering financial data"

### ⏳ Phase 5: Budget Analysis View (Sheet 3 Replica)
**Status**: Not Started
**Goal**: Budget vs actual comparison with Swift Charts visualization, showing budgeted/actual/difference/percentage for each category

**Key Components**:
- Swift Charts grouped bar chart (budgeted vs actual)
- CategoryComparison model with calculations
- Detailed list view with all metrics
- Color coding for over/under budget

**Reference**: See TechnicalSpec.md section "Implementing Sheet 3: Budget vs actual comparison"

### ⏳ Phase 6: Polish & Optimization
**Status**: Not Started
**Goal**: Form validation, error handling, performance profiling, accessibility, final testing

**Key Components**:
- Real-time form validation with error messages
- Domain-specific error types and alert presentation
- Performance profiling with Instruments
- Accessibility labels and VoiceOver support
- Unit tests for calculations

**Reference**: See TechnicalSpec.md sections on "Form validation", "Error handling", "Performance optimization"

## Critical Requirements (ALL PHASES)
These requirements apply to EVERY phase and must NEVER be violated:

- ❗ **DECIMAL TYPE ONLY**: Use Decimal (never Double/Float) for ALL monetary values
- ❗ **LOCAL STORAGE ONLY**: ModelContainer configured with cloudKitDatabase: .none
- ❗ **CASCADE DELETES**: Proper @Relationship(deleteRule: .cascade) where appropriate
- ❗ **INDEXED QUERIES**: #Index macros on Transaction date and category fields
- ❗ **COMPUTED PROPERTIES**: ALL calculations use computed properties (never store derived values)
- ❗ **CURRENCY FORMATTING**: Use .currency(code: "USD") format style throughout

## Project File Structure
```
ZeroBasedBudget/
├── ZeroBasedBudgetApp.swift    # App entry point with ModelContainer
├── ContentView.swift            # Main TabView navigation
├── Models/                      # SwiftData models (@Model classes)
│   ├── BudgetCategory.swift
│   ├── Transaction.swift
│   └── MonthlyBudget.swift
├── Views/                       # SwiftUI views
│   ├── BudgetPlanningView.swift
│   ├── TransactionLogView.swift
│   └── BudgetAnalysisView.swift
├── ViewModels/                  # ObservableObject ViewModels (future phases)
├── Utilities/                   # Helpers, extensions, formatters (future phases)
└── Docs/
    └── TechnicalSpec.md         # Complete technical specification
```

## Git Commit Strategy
- **Frequency**: Commit frequently so git log becomes a reliable timeline
- **Format**: Use conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- **Quality**: Ensure code builds successfully before every commit
- **Documentation**: Update this CLAUDE.md after each commit (add to "Git Commits" section)
- **Phase Transitions**: When completing a phase, update status to ✅ and mark next phase as 🔄 CURRENT PHASE

```bash
git log --oneline -20
```
Should show a clear progression of work. This makes git history a trustworthy verification tool.


## Current Session Notes

### Phase 1 Completion (2025-11-01)
**✅ Phase 1 Successfully Completed**

All Phase 1 objectives achieved:
- ✅ Created comprehensive CLAUDE.md project documentation
- ✅ Read and understood complete TechnicalSpec.md
- ✅ Created all three SwiftData models with proper macros:
  - BudgetCategory (with @Attribute(.unique) and @Relationship cascade delete)
  - Transaction (with #Index macros on date, amount, and category fields)
  - MonthlyBudget (with @Transient computed property for totalBudget)
- ✅ Configured ModelContainer with cloudKitDatabase: .none (local-only storage verified)
- ✅ Updated ZeroBasedBudgetApp.swift with proper schema and ModelContainer
- ✅ Created TabView navigation with three tabs in ContentView.swift
- ✅ Created all three stub views with NavigationStack wrappers:
  - BudgetPlanningView.swift
  - TransactionLogView.swift
  - BudgetAnalysisView.swift
- ✅ Build succeeded without errors (verified with xcodebuild)
- ✅ All critical requirements met (Decimal types, local storage, cascade deletes, indexes)

**Build Verification**: Successfully built for iOS Simulator (iPhone 17, iOS 26.0) with no compilation errors.

**Next Steps**: Ready to begin Phase 2 - implementing the Budget Planning View with income/expense form and calculated totals.

### Phase 2 Completion (2025-11-01)
**✅ Phase 2 Successfully Completed**

All Phase 2 objectives achieved:
- ✅ Implemented comprehensive Budget Planning View (400+ lines)
- ✅ Created Form with 5 sections: Income, Fixed, Variable, Quarterly, Summary
- ✅ Added TextField inputs with .currency(code: "USD") format throughout
- ✅ Implemented computed properties for all totals (replicating Excel formulas):
  - totalIncome, totalFixedExpenses, totalVariableExpenses
  - totalQuarterlyExpenses, totalExpenses, remainingBalance
- ✅ Created AddCategorySheet with form validation
- ✅ Created EditCategorySheet for modifying existing categories
- ✅ Implemented CategoryRow component with color indicators
- ✅ Added delete functionality with swipe actions
- ✅ Color-coded remaining balance (green if positive, red if negative)
- ✅ All monetary values use Decimal type (never Double/Float)
- ✅ Build succeeded without errors

**Implementation Highlights**:
- Uses @Query to fetch categories from SwiftData
- Filters categories by type (Fixed, Variable, Quarterly)
- Real-time calculation updates as user types
- Sheet presentations for add/edit operations
- Form validation (non-empty names, positive amounts)
- Random color assignment for new categories
- Hex color extension for visual category indicators

**Code Quality**: Clean separation of concerns with helper views (CategoryRow, AddCategorySheet, EditCategorySheet) and reusable Color extension.

**Next Steps**: Ready to begin Phase 3 - implementing the Transaction Log View with list, entry form, and running balance calculation.

---
