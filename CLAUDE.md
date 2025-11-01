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

### ✅ Phase 1: Core Structure & Foundation (CURRENT PHASE)
**Status**: In Progress
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
- [ ] Create Views/ folder and stub view files:
  - [ ] Update ContentView.swift with TabView (3 tabs)
  - [ ] BudgetPlanningView.swift (placeholder with NavigationStack)
  - [ ] TransactionLogView.swift (placeholder with NavigationStack)
  - [ ] BudgetAnalysisView.swift (placeholder with NavigationStack)
- [ ] Verify app builds and runs successfully
- [ ] Update this section upon completion

**Files Created/Modified**:
- CLAUDE.md (created)
- ZeroBasedBudget/Models/BudgetCategory.swift (created)
- ZeroBasedBudget/Models/Transaction.swift (created)
- ZeroBasedBudget/Models/MonthlyBudget.swift (created)
- ZeroBasedBudget/ZeroBasedBudgetApp.swift (modified)

**Git Commits**:
- 78f5c21 - docs: initialize CLAUDE.md with project roadmap and Phase 1 plan (2025-11-01)
- 4e411b8 - feat: add SwiftData models (BudgetCategory, Transaction, MonthlyBudget) (2025-11-01)

**Critical Requirements for Phase 1**:
- ❗ Use Decimal type for all monetary fields
- ❗ Configure cloudKitDatabase: .none (no cloud sync)
- ❗ @Relationship(deleteRule: .cascade) on BudgetCategory → Transaction
- ❗ #Index macros on Transaction.date and Transaction.category
- ❗ All views wrapped in NavigationStack

### ⏳ Phase 2: Budget Planning View (Sheet 1 Replica)
**Status**: Not Started
**Goal**: Implement budget planning form with income, fixed/variable/quarterly expenses, and real-time calculated totals

**Key Components**:
- Form with sections for income and expense categories
- TextField with .currency format for all monetary inputs
- Computed properties for totals (replicating Excel formulas)
- Summary section showing remaining balance

**Reference**: See TechnicalSpec.md section "Implementing Sheet 1: Zero-based budget planning"

### ⏳ Phase 3: Transaction Log View (Sheet 2 Replica)
**Status**: Not Started
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
- **Frequency**: Commit after each logical unit of work (model creation, view setup, feature addition)
- **Format**: Use conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- **Quality**: Ensure code builds successfully before every commit
- **Documentation**: Update this CLAUDE.md after each commit (add to "Git Commits" section)
- **Phase Transitions**: When completing a phase, update status to ✅ and mark next phase as 🔄 CURRENT PHASE

## Current Session Notes
(Add implementation decisions, blockers, discoveries, or important context here during development)

---
