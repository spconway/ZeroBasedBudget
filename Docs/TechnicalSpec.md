rom iOS 18 to iOS 26 to align all platforms with the 2025-2026 release cycle. This version delivers significant performance improvements including **16x faster list updates** and 6x faster loading for data-heavy views—critical for financial apps with extensive transaction histories. The new SwiftUI Performance Instrument in Xcode 26 enables precise profiling of view updates and rendering performance.

iOS 26 introduces the Liquid Glass design system, featuring translucent, glass-like UI elements with dynamic materials. While apps automatically adopt this aesthetic when recompiled with the iOS 26 SDK, developers can opt out during the one-year transition period if needed. For this budget tracking app, Liquid Glass provides an elegant, modern appearance that e# Technical Specification: Zero-Based Budget Tracker iOS App

**Version**: 1.1.0 (Post-MVP Enhancements Complete)
**Last Updated**: November 2, 2025

**The latest SwiftUI for iOS 26 paired with SwiftData provides native capabilities to replicate Excel's budget tracking functionality while delivering a modern, on-device-only financial management experience.** This specification outlines the complete technical approach for migrating a three-sheet Excel workbook into a fully-functional iOS application with zero-based budgeting, transaction logging, and budget analysis features.

**Version History:**
- **1.0.0** (November 1, 2025): MVP release with core budget, transaction, and analysis features
- **1.1.0** (November 2, 2025): Post-MVP enhancements including Current Available tracking, yearly income, month navigation, due dates, and improved UX

## Context and version clarification

SwiftUI versions are tied to iOS releases rather than having independent version numbers. **The current latest version is SwiftUI for iOS 26**, released September 15, 2025. Apple changed its OS numbering scheme in 2025, jumping fnhances financial data visualization.

## Technical stack and requirements

**SwiftUI for iOS 26** serves as the UI framework, providing declarative views with native form handling, list performance optimizations, and built-in data binding. The minimum device support includes iPhone 11 and later (A13 Bionic or newer).

**SwiftData** handles all data persistence with on-device-only storage. This modern framework, available since iOS 17, uses Swift's macro system for declarative data modeling and provides seamless SwiftUI integration through the `@Query` property wrapper. Unlike Core Data, SwiftData requires significantly less boilerplate code while maintaining robust persistence capabilities.

**Swift Charts** enables native data visualization for budget analysis. The framework supports bar charts for budget vs. actual comparisons and sector marks (pie/donut charts) for category breakdowns. iOS 26 adds 3D chart capabilities, though 2D visualizations may be more appropriate for financial data clarity.

**Foundation framework** provides `Decimal` type for precise financial calculations and `NumberFormatter` for currency display. Using `Decimal` instead of `Double` or `Float` is critical—floating-point arithmetic introduces rounding errors that could cause accounting discrepancies.

## Ensuring data stays on-device only

SwiftData stores data locally by default in the app's Application Support directory as a SQLite database. To explicitly guarantee no cloud syncing occurs, configure the `ModelConfiguration` with `cloudKitDatabase: .none`:

```swift
let configuration = ModelConfiguration(
    schema: Schema([Transaction.self, Category.self]),
    cloudKitDatabase: .none  // Explicitly disables cloud sync
)
let container = try ModelContainer(
    for: Schema([Transaction.self, Category.self]),
    configurations: configuration
)
```

Without CloudKit configuration, data remains entirely local with no network connectivity required. The database files (.store, .store-shm, .store-wal) reside in the app sandbox, accessible only to the app itself.

## Data modeling with SwiftData

The budget tracker requires three primary models: **BudgetCategory**, **Transaction**, and **MonthlyBudget**. SwiftData's `@Model` macro automatically handles persistence, while relationships between models use the `@Relationship` macro with specified delete rules.

**BudgetCategory model** represents expense and income categories with budgeted amounts. Using the `@Attribute(.unique)` macro on the category name prevents duplicate categories. The one-to-many relationship with transactions uses cascade delete rules, meaning deleting a category also removes associated transactions:

```swift
@Model
final class BudgetCategory {
    @Attribute(.unique)
    var name: String
    var budgetedAmount: Decimal
    var categoryType: String  // "Fixed", "Variable", "Quarterly", "Income"
    var colorHex: String
    var dueDate: Date?  // Optional due date for expense tracking (v1.1.0)

    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction] = []

    init(name: String, budgetedAmount: Decimal, categoryType: String, colorHex: String, dueDate: Date? = nil) {
        self.name = name
        self.budgetedAmount = budgetedAmount
        self.categoryType = categoryType
        self.colorHex = colorHex
        self.dueDate = dueDate
    }
}
```

**Transaction model** stores individual financial transactions with date, amount, description, and category reference. The `#Index` macro (iOS 18+) dramatically improves query performance on frequently-filtered fields like date and category. For receipt photos, the `@Attribute(.externalStorage)` macro stores large binary data separately from the main database:

```swift
@Model
final class Transaction {
    #Index<Transaction>([\\.date], [\\.amount], [\\.date, \\.category])
    
    var id: UUID
    var date: Date
    var amount: Decimal
    var transactionDescription: String
    var notes: String?
    var type: TransactionType  // enum: .income or .expense
    var category: BudgetCategory?
    
    @Attribute(.externalStorage)
    var receiptImageData: Data?
    
    init(date: Date, amount: Decimal, description: String, type: TransactionType, category: BudgetCategory?) {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.transactionDescription = description
        self.type = type
        self.category = category
    }
}
```

**MonthlyBudget model** tracks overall budget parameters for each month, storing the first day of the month as the identifier. Quarterly expenses should be converted to monthly equivalents during budget setup:

```swift
@Model
final class MonthlyBudget {
    var month: Date  // Store first day of month
    var totalIncome: Decimal
    var fixedExpensesTotal: Decimal
    var variableExpensesTotal: Decimal
    var savingsGoal: Decimal
    
    var totalBudget: Decimal {
        totalIncome - fixedExpensesTotal - variableExpensesTotal - savingsGoal
    }
    
    init(month: Date, totalIncome: Decimal) {
        self.month = month
        self.totalIncome = totalIncome
        self.fixedExpensesTotal = 0
        self.variableExpensesTotal = 0
        self.savingsGoal = 0
    }
}
```

The `@Transient` macro marks computed properties that shouldn't be persisted. Use this for calculated totals and derived values that can be recomputed from stored data.

## Querying and filtering financial data

SwiftUI's `@Query` property wrapper automatically fetches data and updates views when underlying data changes. For the transaction log, querying with date sorting is straightforward:

```swift
@Query(sort: \\.date, order: .reverse) 
private var transactions: [Transaction]
```

Complex filtering requires the `#Predicate` macro for type-safe queries. For monthly transaction filtering:

```swift
init(month: Date) {
    let calendar = Calendar.current
    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
    let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
    
    _transactions = Query(
        filter: #Predicate<Transaction> { transaction in
            transaction.date >= startOfMonth && transaction.date <= endOfMonth
        },
        sort: \\.date,
        order: .reverse
    )
}
```

For performance with large datasets, use `FetchDescriptor` with `propertiesToFetch` to load only required fields, and `relationshipKeyPathsForPrefetching` to avoid N+1 query problems when accessing related categories.

## Architecture pattern: MVVM with SwiftUI

**MVVM (Model-View-ViewModel) is the recommended architecture** for SwiftUI apps, providing native integration with SwiftUI's property wrappers and declarative nature. The pattern separates UI (Views) from business logic (ViewModels) while Models represent data structures.

**Models** use SwiftData's `@Model` macro and represent persisted data entities (Transaction, BudgetCategory, MonthlyBudget).

**ViewModels** inherit from `ObservableObject` and use `@Published` properties to notify views of changes. ViewModels contain business logic, calculations, and data transformations:

```swift
@MainActor
class BudgetViewModel: ObservableObject {
    @Published var currentMonthBudget: MonthlyBudget?
    @Published var categories: [BudgetCategory] = []
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func calculateRemainingBudget() -> Decimal {
        guard let budget = currentMonthBudget else { return 0 }
        return budget.totalBudget
    }
    
    func addCategory(_ category: BudgetCategory) {
        modelContext.insert(category)
        try? modelContext.save()
    }
}
```

**Views** use SwiftUI's declarative syntax and access ViewModels via `@StateObject` (when the view owns the ViewModel) or `@ObservedObject` (when passed from a parent). Views should contain minimal logic—primarily UI layout and data binding.

## State management strategy

SwiftUI provides multiple property wrappers for state management, each with specific use cases:

**@State** manages simple, view-owned state for UI concerns like text input, toggle states, or temporary selections. Always mark as `private` and use only within the owning view.

**@StateObject** creates and owns `ObservableObject` instances (ViewModels). The view maintains the object's lifetime across view updates. Use this when the view creates its own ViewModel.

**@ObservedObject** references `ObservableObject` instances owned by parent views. Use this for ViewModels passed down the view hierarchy.

**@EnvironmentObject** shares state across the entire app hierarchy. Ideal for user session, app settings, or the ModelContext for SwiftData access.

**@Binding** creates two-way connections between parent and child views, allowing children to mutate parent-owned state.

**@Query** (SwiftData-specific) automatically fetches and observes database records, updating views when data changes.

For this budget app, use `@StateObject` for view-owned ViewModels, `@EnvironmentObject` for shared ModelContext, and `@Query` for direct database access in simple views.

## Implementing Sheet 1: Zero-based budget planning

The budget planning view replicates Excel's Sheet 1, allowing users to input income, fixed expenses, variable expenses, and quarterly expenses (converted to monthly). The view uses SwiftUI's `Form` container for grouped input fields with automatic platform styling.

**Form structure** organizes budget categories into sections with headers. Each category uses `TextField` with currency formatting for amount input. The `.currency` format style automatically handles locale-specific currency display and provides the correct decimal keyboard:

```swift
Form {
    Section(header: Text("Monthly Income")) {
        TextField("Salary", value: $monthlySalary, format: .currency(code: "USD"))
        TextField("Other Income", value: $otherIncome, format: .currency(code: "USD"))
    }
    
    Section(header: Text("Fixed Expenses")) {
        ForEach($fixedExpenseCategories) { $category in
            LabeledContent(category.name) {
                TextField("Amount", value: $category.budgetedAmount, format: .currency(code: "USD"))
            }
        }
    }
    
    Section(header: Text("Variable Expenses")) {
        ForEach($variableExpenseCategories) { $category in
            LabeledContent(category.name) {
                TextField("Amount", value: $category.budgetedAmount, format: .currency(code: "USD"))
            }
        }
    }
    
    Section(header: Text("Quarterly Expenses (Monthly Equivalent)")) {
        ForEach($quarterlyExpenseCategories) { $category in
            LabeledContent(category.name) {
                TextField("Amount", value: $category.budgetedAmount, format: .currency(code: "USD"))
            }
        }
    }
    
    Section(header: Text("Summary")) {
        LabeledContent("Total Income", value: totalIncome, format: .currency(code: "USD"))
        LabeledContent("Total Expenses", value: totalExpenses, format: .currency(code: "USD"))
        LabeledContent("Remaining Balance", value: remainingBalance, format: .currency(code: "USD"))
            .foregroundColor(remainingBalance >= 0 ? .green : .red)
            .fontWeight(.bold)
    }
}
```

**Computed properties** replicate Excel formulas. Use computed properties rather than storing calculated values to ensure totals stay synchronized with input changes:

```swift
var totalIncome: Decimal {
    monthlySalary + otherIncome
}

var totalExpenses: Decimal {
    fixedExpenseCategories.reduce(0) { $0 + $1.budgetedAmount } +
    variableExpenseCategories.reduce(0) { $0 + $1.budgetedAmount } +
    quarterlyExpenseCategories.reduce(0) { $0 + $1.budgetedAmount }
}

var remainingBalance: Decimal {
    totalIncome - totalExpenses
}
```

SwiftUI automatically updates the Summary section whenever any input changes, providing the same instant recalculation as Excel formulas.

## Implementing Sheet 2: Transaction log

The transaction log replicates Excel's Sheet 2, displaying a chronological list of transactions with date, description, category, amount, and type (Income/Expense). SwiftUI's `List` component provides efficient rendering even with thousands of transactions.

**List with ForEach** displays transactions sorted by date (newest first). Each transaction row shows key information in a horizontal layout:

```swift
List {
    ForEach(transactions) { transaction in
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.transactionDescription)
                    .font(.headline)
                Text(transaction.category?.name ?? "Uncategorized")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.amount, format: .currency(code: "USD"))
                    .font(.body.bold())
                    .foregroundColor(transaction.type == .income ? .green : .red)
                Text(transaction.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                deleteTransaction(transaction)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                editTransaction(transaction)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}
.searchable(text: $searchText, prompt: "Search transactions")
```

**Adding transactions** requires a form sheet with date picker, text fields, and pickers for category and type:

```swift
Form {
    DatePicker("Date", selection: $transactionDate, displayedComponents: .date)
    
    TextField("Description", text: $description)
    
    Picker("Category", selection: $selectedCategory) {
        ForEach(categories) { category in
            Text(category.name).tag(category)
        }
    }
    .pickerStyle(.menu)
    
    TextField("Amount", value: $amount, format: .currency(code: "USD"))
        .keyboardType(.decimalPad)
    
    Picker("Type", selection: $transactionType) {
        Text("Income").tag(TransactionType.income)
        Text("Expense").tag(TransactionType.expense)
    }
    .pickerStyle(.segmented)
    
    Button("Save Transaction") {
        saveTransaction()
    }
    .disabled(!isValid)
}
```

**Running balance calculation** replicates Excel's cumulative balance formula. Use a computed property that maps transactions to transaction-balance pairs:

```swift
var transactionsWithBalance: [(Transaction, Decimal)] {
    var runningBalance: Decimal = 0
    return transactions.sorted(by: { $0.date < $1.date }).map { transaction in
        if transaction.type == .income {
            runningBalance += transaction.amount
        } else {
            runningBalance -= transaction.amount
        }
        return (transaction, runningBalance)
    }
}
```

**Validation** prevents invalid transactions. Check that amount is positive, description is non-empty, and category is selected. Use a computed `isValid` property to disable the Save button when validation fails.

## Implementing Sheet 3: Budget vs actual comparison

The budget vs. actual view replicates Excel's Sheet 3, showing budgeted amounts, actual spending, difference, and percentage used for each category. **Swift Charts** provides native visualization capabilities ideal for this comparison.

**Grouped bar chart** displays budgeted vs. actual side-by-side for each category:

```swift
import Charts

Chart {
    ForEach(categoryComparisons) { comparison in
        BarMark(
            x: .value("Category", comparison.categoryName),
            y: .value("Amount", comparison.budgeted)
        )
        .foregroundStyle(.blue)
        .position(by: .value("Type", "Budgeted"))
        
        BarMark(
            x: .value("Category", comparison.categoryName),
            y: .value("Amount", comparison.actual)
        )
        .foregroundStyle(comparison.actual > comparison.budgeted ? .red : .green)
        .position(by: .value("Type", "Actual"))
    }
}
.chartLegend(position: .bottom)
.chartYAxis {
    AxisMarks(position: .leading)
}
.frame(height: 300)
```

**Detailed list view** provides numerical comparison below the chart:

```swift
List(categoryComparisons) { comparison in
    VStack(alignment: .leading, spacing: 8) {
        HStack {
            Text(comparison.categoryName)
                .font(.headline)
            Spacer()
            Image(systemName: comparison.isOverBudget ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundColor(comparison.isOverBudget ? .red : .green)
        }
        
        HStack {
            VStack(alignment: .leading) {
                Text("Budgeted")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(comparison.budgeted, format: .currency(code: "USD"))
                    .font(.body)
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Actual")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(comparison.actual, format: .currency(code: "USD"))
                    .font(.body)
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Difference")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(comparison.difference, format: .currency(code: "USD"))
                    .font(.body)
                    .foregroundColor(comparison.difference >= 0 ? .green : .red)
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("% Used")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(comparison.percentageUsed, format: .percent)
                    .font(.body)
                    .foregroundColor(comparison.percentageUsed > 1.0 ? .red : .primary)
            }
        }
    }
    .padding(.vertical, 4)
}
```

**CategoryComparison model** aggregates data for display:

```swift
struct CategoryComparison: Identifiable {
    let id = UUID()
    let categoryName: String
    let budgeted: Decimal
    let actual: Decimal
    
    var difference: Decimal {
        budgeted - actual
    }
    
    var percentageUsed: Double {
        guard budgeted > 0 else { return 0 }
        return Double(truncating: (actual / budgeted) as NSDecimalNumber)
    }
    
    var isOverBudget: Bool {
        actual > budgeted
    }
}
```

**Computing actual spending** requires aggregating transactions by category for the current month:

```swift
func calculateActualSpending(for category: BudgetCategory, in month: Date) -> Decimal {
    let calendar = Calendar.current
    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
    let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
    
    let categoryTransactions = category.transactions.filter { 
        $0.date >= startOfMonth && $0.date <= endOfMonth && $0.type == .expense
    }
    
    return categoryTransactions.reduce(0) { $0 + $1.amount }
}
```

## Navigation structure with TabView

The app uses `TabView` to replicate the three-sheet Excel structure, providing bottom navigation between Budget, Transactions, and Analysis views:

```swift
TabView(selection: $selectedTab) {
    BudgetPlanningView()
        .tabItem {
            Label("Budget", systemImage: "dollarsign.circle")
        }
        .tag(0)
    
    TransactionLogView()
        .tabItem {
            Label("Transactions", systemImage: "list.bullet")
        }
        .tag(1)
    
    BudgetAnalysisView()
        .tabItem {
            Label("Analysis", systemImage: "chart.bar")
        }
        .tag(2)
}
```

For drill-down navigation (viewing transaction details, editing categories), use `NavigationStack` within each tab:

```swift
NavigationStack {
    List(transactions) { transaction in
        NavigationLink(value: transaction) {
            TransactionRow(transaction: transaction)
        }
    }
    .navigationTitle("Transactions")
    .navigationDestination(for: Transaction.self) { transaction in
        TransactionDetailView(transaction: transaction)
    }
}
```

## Form validation and data integrity

**Real-time validation** provides immediate feedback. Use `.onChange(of:)` to validate as users type:

```swift
TextField("Amount", text: $amountText)
    .onChange(of: amountText) { newValue in
        if let decimal = Decimal(string: newValue), decimal > 0 {
            validationError = nil
        } else {
            validationError = "Amount must be greater than 0"
        }
    }

if let error = validationError {
    Text(error)
        .foregroundColor(.red)
        .font(.caption)
}
```

**ViewModel-based validation** centralizes validation logic:

```swift
class TransactionFormViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var description: String = ""
    @Published var amountError: String?
    @Published var descriptionError: String?
    
    var isValid: Bool {
        validateAmount() && validateDescription()
    }
    
    private func validateAmount() -> Bool {
        guard let decimal = Decimal(string: amount), decimal > 0 else {
            amountError = "Amount must be greater than 0"
            return false
        }
        amountError = nil
        return true
    }
    
    private func validateDescription() -> Bool {
        guard !description.trimmingCharacters(in: .whitespaces).isEmpty else {
            descriptionError = "Description is required"
            return false
        }
        descriptionError = nil
        return true
    }
}
```

**Currency input validation** restricts input to valid decimal numbers. Using `TextField` with `Decimal` binding and `.currency` format automatically provides proper validation.

## Currency formatting and decimal precision

**Always use Decimal type** for monetary values. Never use `Double` or `Float`—floating-point arithmetic introduces rounding errors that accumulate over time, causing accounting discrepancies. The `Decimal` type provides exact decimal arithmetic:

```swift
struct Transaction {
    var amount: Decimal  // NOT Double or Float
}
```

**Currency formatting** uses `NumberFormatter` for custom control or SwiftUI's `.currency` format style for simplicity:

```swift
// NumberFormatter approach
let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    return formatter
}()

Text(currencyFormatter.string(from: amount as NSDecimalNumber) ?? "$0.00")

// Format style approach (iOS 15+)
Text(amount, format: .currency(code: "USD"))
TextField("Amount", value: $amount, format: .currency(code: "USD"))
```

**Rounding for display** should round to two decimal places for currency:

```swift
extension Decimal {
    var roundedForCurrency: Decimal {
        var rounded = self
        var result: Decimal = 0
        NSDecimalRound(&result, &rounded, 2, .plain)
        return result
    }
}
```

**Locale-aware formatting** automatically adjusts currency symbols and decimal separators based on user locale. Use `Locale.current.currencyCode` to get the user's currency, or allow manual selection if supporting multiple currencies.

## Performance optimization strategies

**List performance** in iOS 26 is dramatically improved (up to 16x faster for updates), but large transaction histories still benefit from optimization. Use **lazy loading** by fetching only visible date ranges initially, then loading more as users scroll.

**Index critical fields** using SwiftData's `#Index` macro on date and category fields. This dramatically speeds up common queries like "show all transactions in March" or "show all grocery expenses."

**Prefetch relationships** when displaying transactions with categories to avoid N+1 query problems:

```swift
var descriptor = FetchDescriptor<Transaction>()
descriptor.relationshipKeyPathsForPrefetching = [\\.category]
let transactions = try modelContext.fetch(descriptor)
```

**Computed properties vs stored calculations**: Never store calculated values like totals or percentages. Always compute them from source data to ensure consistency. SwiftUI's efficient diffing and iOS 26's performance improvements make real-time calculation performant even with hundreds of transactions.

**Profile with Instruments**: Use Xcode 26's new SwiftUI Performance Instrument to identify view update bottlenecks. The tool identifies long view body updates and unnecessary redraws.

## Migration and schema evolution

**Version your schema from day one** to enable future data migrations. SwiftData's `VersionedSchema` protocol defines schema versions:

```swift
enum BudgetSchemaV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Transaction.self, BudgetCategory.self, MonthlyBudget.self]
    }
    
    @Model
    final class Transaction {
        // Initial schema
    }
}
```

**Lightweight migrations** handle simple changes automatically: adding properties with default values, deleting properties, or renaming with `@Attribute(originalName:)`. For complex transformations like data deduplication or computation, use custom migrations with the `MigrationStage.custom` API.

**Initial data seeding** populates default categories from the existing Excel workbook. Create seed data on first launch by checking for empty database and inserting predefined categories.

## Testing strategy

**Unit test ViewModels** to verify business logic and calculations:

```swift
class BudgetViewModelTests: XCTestCase {
    func testRemainingBalanceCalculation() {
        let viewModel = BudgetViewModel()
        viewModel.totalIncome = 5000
        viewModel.totalExpenses = 3000
        XCTAssertEqual(viewModel.remainingBalance, 2000)
    }
    
    func testDecimalPrecision() {
        let amount1: Decimal = 0.1
        let amount2: Decimal = 0.2
        let sum = amount1 + amount2
        XCTAssertEqual(sum, 0.3)  // Exact decimal arithmetic
    }
}
```

**UI tests** verify critical user flows like adding transactions, viewing summaries, and editing budgets. Use XCTest framework's UI testing capabilities to simulate user interactions.

**Integration tests** verify SwiftData persistence by creating test transactions, saving them, and verifying they persist across app launches.

## Error handling patterns

**Domain-specific errors** provide clear error messages:

```swift
enum BudgetError: LocalizedError {
    case invalidAmount
    case missingCategory
    case insufficientFunds
    case databaseError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Please enter a valid amount greater than 0"
        case .missingCategory:
            return "Please select a category"
        case .insufficientFunds:
            return "Transaction exceeds remaining budget"
        case .databaseError(let error):
            return "Database error: \\(error.localizedDescription)"
        }
    }
}
```

**Alert presentation** shows errors to users:

```swift
.alert("Error", isPresented: $showError) {
    Button("OK", role: .cancel) { }
} message: {
    Text(errorMessage)
}
```

**Graceful degradation** handles missing data by displaying empty states rather than crashing, and provides clear messaging when data is unavailable.

## Implementation roadmap

**Phase 1** establishes core structure: Set up SwiftData models, create TabView navigation, and implement ModelContainer with local-only configuration. Build basic UI shells for all three views.

**Phase 2** implements budget planning (Sheet 1): Create Form with sections for income and expenses, implement computed properties for totals, and enable adding/editing categories with persistence.

**Phase 3** builds transaction logging (Sheet 2): Implement List with @Query, create transaction entry form with DatePicker and Pickers, add swipe actions for delete/edit, and implement search functionality.

**Phase 4** adds calculations and persistence: Implement running balance calculation, create category aggregation logic, verify all data persists correctly, and test with larger datasets.

**Phase 5** delivers budget analysis (Sheet 3): Integrate Swift Charts for budget vs. actual visualization, implement category comparison calculations, create detailed list view with percentage calculations.

**Phase 6** provides polish and optimization: Add form validation throughout, implement error handling, test on various device sizes, profile performance with Instruments, and add accessibility labels.

## Post-MVP Enhancements (Version 1.1.0)

Following the MVP release (v1.0.0), several user-requested enhancements were implemented to improve the budgeting experience and user interface. These enhancements maintain all critical implementation rules while adding new capabilities for tracking available funds, planning annual income, and streamlining interactions.

### Enhancement 1.1: Yearly Income Display

**Purpose**: Change income tracking from monthly to yearly for better annual salary representation.

**Implementation**: The "Monthly Income" section was refactored to "Yearly Income" with the "Salary" field relabeled to "Annual Salary." An explanatory footer text clarifies this is for reference and planning purposes.

```swift
// Updated income section in BudgetPlanningView
Section {
    LabeledContent("Annual Salary") {
        TextField("Amount", value: $yearlySalary, format: .currency(code: "USD"))
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
    }

    LabeledContent("Other Income") {
        TextField("Amount", value: $otherIncome, format: .currency(code: "USD"))
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
    }

    LabeledContent("Total Income") {
        Text(totalIncome, format: .currency(code: "USD"))
            .fontWeight(.semibold)
    }
} header: {
    Text("Yearly Income")
} footer: {
    Text("Enter your annual salary for reference and planning purposes.")
        .font(.caption)
        .foregroundStyle(.secondary)
}
```

**State management**: Changed from `monthlySalary` to `yearlySalary` state variable while maintaining Decimal type for precision.

### Enhancement 1.2: Current Available Funds Tracking

**Purpose**: Add "Current Available" section to track money ready to be assigned to budget categories, supporting the zero-based budgeting principle.

**Implementation**: A new section appears at the top of Budget Planning View with an "Accounts" input field and a "Total" display field.

```swift
// Current Available section (first section in BudgetPlanningView)
@State private var currentAvailableAccounts: Decimal = 0

private var totalAvailable: Decimal {
    currentAvailableAccounts  // Currently single account, extensible for multiple accounts
}

Section {
    LabeledContent("Accounts") {
        TextField("Amount", value: $currentAvailableAccounts, format: .currency(code: "USD"))
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
    }

    LabeledContent("Total") {
        Text(totalAvailable, format: .currency(code: "USD"))
            .fontWeight(.semibold)
    }
} header: {
    Text("Current Available")
} footer: {
    Text("Enter the total of all available money ready to be assigned to budget categories.")
        .font(.caption)
        .foregroundStyle(.secondary)
}
```

**Calculation logic**: `totalAvailable` computed property currently returns the single accounts value but is structured to support future expansion to multiple account types (checking, savings, etc.). The design allows summing multiple account balances when that feature is added.

**Zero-based budgeting principle**: This section represents the "ready to spend" money that should be fully allocated to budget categories, leaving zero unassigned dollars.

### Enhancement 2.1: Month Indicator with Navigation

**Purpose**: Add prominent month/year display with navigation arrows to clearly indicate which month is being budgeted.

**Implementation**: A dedicated section at the very top of Budget Planning View displays the current month in large, bold text with left/right navigation arrows.

```swift
// Month indicator state
@State private var selectedMonth: Date = Date()

// Formatted month/year text
private var monthYearText: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return "Budgeting for: \(formatter.string(from: selectedMonth))"
}

// Month indicator section
Section {
    HStack {
        Button(action: previousMonth) {
            Image(systemName: "chevron.left")
                .font(.title3)
                .foregroundStyle(.blue)
        }
        .buttonStyle(.plain)

        Spacer()

        Text(monthYearText)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.primary)

        Spacer()

        Button(action: nextMonth) {
            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundStyle(.blue)
        }
        .buttonStyle(.plain)
    }
    .padding(.vertical, 8)
    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
}
.listRowBackground(Color.clear)

// Navigation functions
private func previousMonth() {
    if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
        selectedMonth = newMonth
    }
}

private func nextMonth() {
    if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
        selectedMonth = newMonth
    }
}
```

**Design considerations**: The month indicator uses `.listRowBackground(Color.clear)` for visual separation from other form sections. Bold title2 font ensures high visibility. Blue chevron arrows follow iOS design conventions.

**Date arithmetic**: Uses `Calendar.current.date(byAdding:)` for proper month navigation, correctly handling year boundaries (e.g., December → January).

### Enhancement 2.2: Due Date Field for Expenses

**Purpose**: Track when expense payments are due to help with payment planning and cash flow management.

**Implementation**: Added optional `dueDate` field to BudgetCategory model and updated Add/Edit sheets to include due date picker with toggle control.

**Model update**: Added `dueDate: Date?` property to BudgetCategory (see updated model schema above).

**Add/Edit sheet integration**:
```swift
// AddCategorySheet and EditCategorySheet
@State private var hasDueDate: Bool = false
@State private var dueDate: Date = Date()

Section(header: Text("Due Date (Optional)")) {
    Toggle("Set Due Date", isOn: $hasDueDate)

    if hasDueDate {
        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
    }
}

// Save with optional due date
onSave(categoryName, budgetedAmount, hasDueDate ? dueDate : nil)
```

**Display in category list**: CategoryRow component shows due date below category name in compact format.

```swift
struct CategoryRow: View {
    let category: BudgetCategory
    let onEdit: () -> Void

    private var dueDateText: String? {
        guard let dueDate = category.dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"  // Compact format: "Nov 1", "Dec 15"
        return formatter.string(from: dueDate)
    }

    var body: some View {
        Button(action: onEdit) {
            HStack {
                Circle()
                    .fill(Color(hex: category.colorHex))
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .foregroundStyle(.primary)

                    if let dueDateText = dueDateText {
                        Text(dueDateText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(category.budgetedAmount, format: .currency(code: "USD"))
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
```

**Date format rationale**: The "MMM d" format (e.g., "Nov 1") provides compact display while remaining clear. Full date format would take too much space in the category list.

**Toggle control design**: Using a toggle to enable/disable due date (rather than always showing the picker) keeps the interface clean and makes the optional nature of the field explicit.

### Enhancement 3.1: Tap-to-Edit Transactions

**Purpose**: Simplify transaction editing by making rows directly tap-able instead of requiring swipe-then-tap interaction.

**Implementation**: Removed the blue "Edit" button from swipe actions and added `onTapGesture` directly to transaction rows. Swipe-to-delete was preserved.

**Before (MVP)**:
```swift
// Old implementation with swipe-to-edit
.swipeActions(edge: .trailing) {
    Button(role: .destructive) {
        deleteTransaction(transaction)
    } label: {
        Label("Delete", systemImage: "trash")
    }

    Button {
        transactionToEdit = transaction
        showingEditSheet = true
    } label: {
        Label("Edit", systemImage: "pencil")
    }
    .tint(.blue)
}
```

**After (v1.1.0)**:
```swift
// New implementation with tap-to-edit
TransactionRow(transaction: transaction, runningBalance: balance)
    .onTapGesture {
        transactionToEdit = transaction
        showingEditSheet = true
    }
    .swipeActions(edge: .trailing) {
        Button(role: .destructive) {
            deleteTransaction(transaction)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
```

**Interaction improvement**: Reduced user actions from 2 (swipe left → tap edit button) to 1 (tap row). This follows iOS conventions where tapping performs the primary action and swiping performs destructive/secondary actions.

**Preserved functionality**: Swipe-to-delete remains for the destructive action (deleting transactions), maintaining the safety of requiring swipe for deletion rather than accidental taps.

### Post-MVP Summary

**Version 1.1.0 additions**:
1. Yearly income tracking instead of monthly
2. Current Available funds section for zero-based budgeting
3. Month/year indicator with navigation
4. Optional due dates for expense categories
5. Tap-to-edit transactions (improved UX)

**Lines of code added**: ~150 lines across BudgetCategory model and BudgetPlanningView/TransactionLogView
**Build status**: All changes compile successfully with zero errors
**Testing**: Comprehensive user testing guide created (Docs/UserTestingGuide.md)
**Critical rules maintained**: All enhancements follow Decimal type usage, local-only storage, and SwiftUI best practices

## Critical best practices summary

Always use **Decimal for financial calculations**—never Double or Float. Use **@Query for database access** in views for automatic updates. Store data in **BudgetCategory and Transaction models** rather than duplicating in ViewModels. Implement **computed properties for all calculations** instead of storing derived values. Use **cascade delete rules** carefully to prevent orphaned transactions. Enable **index macros on date fields** for optimal query performance. Test **currency precision** thoroughly with unit tests. Keep data **local-only** by explicitly setting `cloudKitDatabase: .none`. Profile with the **SwiftUI Performance Instrument** in Xcode 26 to identify bottlenecks.

This specification provides complete technical guidance for building a production-ready iOS budget tracking app that delivers all functionality of the Excel workbook while leveraging native iOS capabilities for superior user experience.
