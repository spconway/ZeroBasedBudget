//
//  BudgetPlanningView.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//

import SwiftUI
import SwiftData

struct BudgetPlanningView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allCategories: [BudgetCategory]

    // State for selected month/year
    @State private var selectedMonth: Date = Date()

    // State for current available funds
    @State private var currentAvailableAccounts: Decimal = 0

    // State for showing add category sheet
    @State private var showingAddCategory = false
    @State private var newCategoryType: String = "Fixed"
    @State private var editingCategory: BudgetCategory?

    // Computed property to filter categories by type
    private var fixedExpenseCategories: [BudgetCategory] {
        allCategories.filter { $0.categoryType == "Fixed" }
    }

    private var variableExpenseCategories: [BudgetCategory] {
        allCategories.filter { $0.categoryType == "Variable" }
    }

    private var quarterlyExpenseCategories: [BudgetCategory] {
        allCategories.filter { $0.categoryType == "Quarterly" }
    }

    // Computed property for month/year display
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return "Budgeting for: \(formatter.string(from: selectedMonth))"
    }

    // Computed properties for totals (replicating Excel formulas)
    private var totalAvailable: Decimal {
        currentAvailableAccounts
    }

    private var totalFixedExpenses: Decimal {
        fixedExpenseCategories.reduce(0) { $0 + $1.budgetedAmount }
    }

    private var totalVariableExpenses: Decimal {
        variableExpenseCategories.reduce(0) { $0 + $1.budgetedAmount }
    }

    private var totalQuarterlyExpenses: Decimal {
        quarterlyExpenseCategories.reduce(0) { $0 + $1.budgetedAmount }
    }

    private var totalExpenses: Decimal {
        totalFixedExpenses + totalVariableExpenses + totalQuarterlyExpenses
    }

    var body: some View {
        NavigationStack {
            Form {
                // Month Indicator Section
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

                // Current Available Section
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

                // Fixed Expenses Section
                Section(header: HStack {
                    Text("Fixed Expenses")
                    Spacer()
                    Button(action: { addCategory(type: "Fixed") }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }) {
                    if fixedExpenseCategories.isEmpty {
                        Text("No fixed expenses yet. Tap + to add.")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(fixedExpenseCategories) { category in
                            CategoryRow(category: category, onEdit: {
                                editingCategory = category
                            })
                        }
                        .onDelete { indexSet in
                            deleteCategories(at: indexSet, from: fixedExpenseCategories)
                        }

                        LabeledContent("Total Fixed") {
                            Text(totalFixedExpenses, format: .currency(code: "USD"))
                                .fontWeight(.semibold)
                        }
                    }
                }

                // Variable Expenses Section
                Section(header: HStack {
                    Text("Variable Expenses")
                    Spacer()
                    Button(action: { addCategory(type: "Variable") }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }) {
                    if variableExpenseCategories.isEmpty {
                        Text("No variable expenses yet. Tap + to add.")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(variableExpenseCategories) { category in
                            CategoryRow(category: category, onEdit: {
                                editingCategory = category
                            })
                        }
                        .onDelete { indexSet in
                            deleteCategories(at: indexSet, from: variableExpenseCategories)
                        }

                        LabeledContent("Total Variable") {
                            Text(totalVariableExpenses, format: .currency(code: "USD"))
                                .fontWeight(.semibold)
                        }
                    }
                }

                // Quarterly Expenses Section (shown as monthly equivalent)
                Section(header: HStack {
                    Text("Quarterly Expenses (Monthly)")
                    Spacer()
                    Button(action: { addCategory(type: "Quarterly") }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }) {
                    if quarterlyExpenseCategories.isEmpty {
                        Text("No quarterly expenses yet. Tap + to add.")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(quarterlyExpenseCategories) { category in
                            CategoryRow(category: category, onEdit: {
                                editingCategory = category
                            })
                        }
                        .onDelete { indexSet in
                            deleteCategories(at: indexSet, from: quarterlyExpenseCategories)
                        }

                        LabeledContent("Total Quarterly") {
                            Text(totalQuarterlyExpenses, format: .currency(code: "USD"))
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Budget Planning")
            .sheet(isPresented: $showingAddCategory) {
                AddCategorySheet(categoryType: newCategoryType, onSave: { name, amount, dueDate in
                    saveNewCategory(name: name, amount: amount, type: newCategoryType, dueDate: dueDate)
                })
            }
            .sheet(item: $editingCategory) { category in
                EditCategorySheet(category: category, onSave: { updatedAmount, updatedDueDate in
                    updateCategory(category, amount: updatedAmount, dueDate: updatedDueDate)
                })
            }
        }
    }

    // MARK: - Helper Functions

    private func addCategory(type: String) {
        newCategoryType = type
        showingAddCategory = true
    }

    private func saveNewCategory(name: String, amount: Decimal, type: String, dueDate: Date?) {
        let category = BudgetCategory(
            name: name,
            budgetedAmount: amount,
            categoryType: type,
            colorHex: generateRandomColor(),
            dueDate: dueDate
        )
        modelContext.insert(category)
        try? modelContext.save()
        showingAddCategory = false
    }

    private func updateCategory(_ category: BudgetCategory, amount: Decimal, dueDate: Date?) {
        category.budgetedAmount = amount
        category.dueDate = dueDate
        try? modelContext.save()
        editingCategory = nil
    }

    private func deleteCategories(at offsets: IndexSet, from categories: [BudgetCategory]) {
        for index in offsets {
            modelContext.delete(categories[index])
        }
        try? modelContext.save()
    }

    private func generateRandomColor() -> String {
        let colors = ["FF6B6B", "4ECDC4", "45B7D1", "FFA07A", "98D8C8", "F7DC6F", "BB8FCE", "85C1E2"]
        return colors.randomElement() ?? "4ECDC4"
    }

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
}

// MARK: - CategoryRow View
struct CategoryRow: View {
    let category: BudgetCategory
    let onEdit: () -> Void

    private var dueDateText: String? {
        guard let dueDate = category.dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
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

// MARK: - AddCategorySheet
struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    let categoryType: String
    let onSave: (String, Decimal, Date?) -> Void

    @State private var categoryName: String = ""
    @State private var budgetedAmount: Decimal = 0
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $categoryName)

                    LabeledContent("Budgeted Amount") {
                        TextField("Amount", value: $budgetedAmount, format: .currency(code: "USD"))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Due Date (Optional)")) {
                    Toggle("Set Due Date", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }
                }

                Section {
                    Text("Category Type: \(categoryType)")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add \(categoryType) Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(categoryName, budgetedAmount, hasDueDate ? dueDate : nil)
                        dismiss()
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespaces).isEmpty || budgetedAmount <= 0)
                }
            }
        }
    }
}

// MARK: - EditCategorySheet
struct EditCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    let category: BudgetCategory
    let onSave: (Decimal, Date?) -> Void

    @State private var budgetedAmount: Decimal
    @State private var hasDueDate: Bool
    @State private var dueDate: Date

    init(category: BudgetCategory, onSave: @escaping (Decimal, Date?) -> Void) {
        self.category = category
        self.onSave = onSave
        _budgetedAmount = State(initialValue: category.budgetedAmount)
        _hasDueDate = State(initialValue: category.dueDate != nil)
        _dueDate = State(initialValue: category.dueDate ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Category Details")) {
                    LabeledContent("Name") {
                        Text(category.name)
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent("Type") {
                        Text(category.categoryType)
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent("Budgeted Amount") {
                        TextField("Amount", value: $budgetedAmount, format: .currency(code: "USD"))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Due Date (Optional)")) {
                    Toggle("Set Due Date", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(budgetedAmount, hasDueDate ? dueDate : nil)
                    }
                    .disabled(budgetedAmount <= 0)
                }
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    BudgetPlanningView()
        .modelContainer(for: [BudgetCategory.self, Transaction.self, MonthlyBudget.self])
}
