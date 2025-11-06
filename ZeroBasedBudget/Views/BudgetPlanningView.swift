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
    @Environment(\.theme) private var theme
    @Query private var allCategories: [BudgetCategory]
    @Query private var allTransactions: [Transaction]
    @Query private var allMonthlyBudgets: [MonthlyBudget]
    @Query private var allAccounts: [Account]  // NEW: Query accounts for YNAB-style budgeting
    @Query private var settings: [AppSettings]

    // State for selected month/year
    @State private var selectedMonth: Date = Date()

    // NOTE: startingBalance removed in Enhancement 3.1 - now use Account balances instead

    // State for month navigation (Enhancement 3.3)
    @State private var showingMonthSwitchAlert = false
    @State private var pendingMonth: Date?
    @State private var previousMonthReadyToAssign: Decimal?

    // State for showing add category sheet
    @State private var showingAddCategory = false
    @State private var newCategoryType: String = "Fixed"
    @State private var editingCategory: BudgetCategory?
    @State private var showingReadyToAssignInfo = false

    // State for undo functionality (Enhancement 3.2)
    @State private var undoAction: UndoAction?
    @State private var showingUndoBanner = false

    // Undo action data structure
    struct UndoAction {
        let categoryChanges: [(category: BudgetCategory, previousAmount: Decimal)]
        let actionDescription: String
    }

    // Currency code from settings
    private var currencyCode: String {
        settings.first?.currencyCode ?? "USD"
    }

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
        return "\(formatter.string(from: selectedMonth))"
    }

    // MARK: - Month Management (Enhancement 3.3)

    /// Get the first day of a given month
    private func normalizeToFirstOfMonth(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    /// Get the MonthlyBudget for the currently selected month
    private var currentMonthBudget: MonthlyBudget? {
        let normalizedMonth = normalizeToFirstOfMonth(selectedMonth)
        return allMonthlyBudgets.first { normalizeToFirstOfMonth($0.month) == normalizedMonth }
    }

    /// Get or create a MonthlyBudget for a specific month
    private func getOrCreateMonthlyBudget(for month: Date) -> MonthlyBudget {
        let normalizedMonth = normalizeToFirstOfMonth(month)

        if let existing = allMonthlyBudgets.first(where: { normalizeToFirstOfMonth($0.month) == normalizedMonth }) {
            return existing
        }

        let newBudget = MonthlyBudget(month: normalizedMonth, startingBalance: 0)
        modelContext.insert(newBudget)
        try? modelContext.save()
        return newBudget
    }

    /// Calculate Ready to Assign for a specific month
    /// Calculate Ready to Assign using YNAB methodology
    /// Formula: Starting Balances + All Income - Total Budgeted
    /// This avoids double-counting expenses (which already reduced current balances)
    private func calculateReadyToAssign(for month: Date) -> Decimal {
        let startingBalances = allAccounts.reduce(0) { $0 + $1.startingBalance }
        let totalIncome = allTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let totalBudgeted = allCategories.reduce(0) { $0 + $1.budgetedAmount }

        return startingBalances + totalIncome - totalBudgeted
    }

    /// Get previous month's Ready to Assign for comparison
    /// NOTE: Enhancement 3.1 - DEPRECATED with account-based budgeting
    /// Account balances are global, not per-month, so historical comparisons don't apply
    private var previousMonthComparison: (month: String, amount: Decimal)? {
        // Disabled in Enhancement 3.1 - not compatible with account-based budgeting
        return nil
    }

    // MARK: - YNAB-Style Computed Properties

    // NEW: Total balance across all accounts (source of truth for YNAB budgeting)
    private var totalAccountBalances: Decimal {
        allAccounts.reduce(0) { $0 + $1.balance }
    }

    // Total income from transactions for the selected month (kept for reference/future use)
    private var totalIncome: Decimal {
        BudgetCalculations.calculateTotalIncome(in: selectedMonth, from: allTransactions)
    }

    // Total amount assigned to all budget categories
    private var totalAssigned: Decimal {
        allCategories.reduce(0) { $0 + $1.budgetedAmount }
    }

    // Ready to Assign calculation using YNAB methodology
    // Formula: Starting Balances + All Income - Total Budgeted
    // Avoids double-counting expenses (which already reduced current balances)
    private var readyToAssign: Decimal {
        let startingBalances = allAccounts.reduce(0) { $0 + $1.startingBalance }
        let totalIncome = allTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }

        return startingBalances + totalIncome - totalAssigned
    }

    // Color coding for Ready to Assign
    private var readyToAssignColor: Color {
        if readyToAssign == 0 {
            return theme.colors.success  // Goal achieved!
        } else if readyToAssign > 0 {
            return theme.colors.warning  // Money needs to be assigned
        } else {
            return theme.colors.error  // Over-assigned, need to reduce categories
        }
    }

    // Status message for accessibility
    private var readyToAssignStatus: String {
        if readyToAssign == 0 {
            return "Goal achieved! All money has been assigned."
        } else if readyToAssign > 0 {
            return "You still have money to assign to categories."
        } else {
            return "Warning: You've over-assigned. Reduce category amounts."
        }
    }

    // MARK: - Category Totals

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
                                .foregroundStyle(theme.colors.accent)
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Text(monthYearText)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(theme.colors.textPrimary)

                        Spacer()

                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundStyle(theme.colors.accent)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
                .listRowBackground(theme.colors.surface)

                // NEW: Simple Ready to Assign Banner (Enhancement 3.1)
                Section {
                    ReadyToAssignBanner(
                        amount: readyToAssign,
                        color: readyToAssignColor,
                        currencyCode: currencyCode
                    )
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(theme.colors.surface)

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
                            .foregroundStyle(theme.colors.textSecondary)
                            .italic()
                    } else {
                        ForEach(fixedExpenseCategories) { category in
                            CategoryRow(
                                category: category,
                                readyToAssign: readyToAssign,
                                actualSpent: BudgetCalculations.calculateActualSpending(
                                    for: category,
                                    in: selectedMonth,
                                    from: allTransactions
                                ),
                                onEdit: {
                                    editingCategory = category
                                },
                                onQuickAssign: {
                                    quickAssignToCategory(category)
                                },
                                currencyCode: currencyCode
                            )
                        }
                        .onDelete { indexSet in
                            deleteCategories(at: indexSet, from: fixedExpenseCategories)
                        }

                        LabeledContent("Total Fixed") {
                            Text(totalFixedExpenses, format: .currency(code: currencyCode))
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
                            .foregroundStyle(theme.colors.textSecondary)
                            .italic()
                    } else {
                        ForEach(variableExpenseCategories) { category in
                            CategoryRow(
                                category: category,
                                readyToAssign: readyToAssign,
                                actualSpent: BudgetCalculations.calculateActualSpending(
                                    for: category,
                                    in: selectedMonth,
                                    from: allTransactions
                                ),
                                onEdit: {
                                    editingCategory = category
                                },
                                onQuickAssign: {
                                    quickAssignToCategory(category)
                                },
                                currencyCode: currencyCode
                            )
                        }
                        .onDelete { indexSet in
                            deleteCategories(at: indexSet, from: variableExpenseCategories)
                        }

                        LabeledContent("Total Variable") {
                            Text(totalVariableExpenses, format: .currency(code: currencyCode))
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
                            .foregroundStyle(theme.colors.textSecondary)
                            .italic()
                    } else {
                        ForEach(quarterlyExpenseCategories) { category in
                            CategoryRow(
                                category: category,
                                readyToAssign: readyToAssign,
                                actualSpent: BudgetCalculations.calculateActualSpending(
                                    for: category,
                                    in: selectedMonth,
                                    from: allTransactions
                                ),
                                onEdit: {
                                    editingCategory = category
                                },
                                onQuickAssign: {
                                    quickAssignToCategory(category)
                                },
                                currencyCode: currencyCode
                            )
                        }
                        .onDelete { indexSet in
                            deleteCategories(at: indexSet, from: quarterlyExpenseCategories)
                        }

                        LabeledContent("Total Quarterly") {
                            Text(totalQuarterlyExpenses, format: .currency(code: currencyCode))
                                .fontWeight(.semibold)
                        }
                    }
                }

                // Budget Summary Section
                Section {
                    LabeledContent("Total Assigned") {
                        Text(totalAssigned, format: .currency(code: currencyCode))
                            .foregroundStyle(theme.colors.textSecondary)
                    }

                    LabeledContent("Ready to Assign") {
                        Text(readyToAssign, format: .currency(code: currencyCode))
                            .fontWeight(.bold)
                            .foregroundStyle(readyToAssignColor)
                    }

                    // Previous month comparison (Enhancement 3.3)
                    if let comparison = previousMonthComparison {
                        HStack {
                            Text("Previous Month (\(comparison.month))")
                                .font(.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                            Spacer()
                            HStack(spacing: 4) {
                                Text(comparison.amount, format: .currency(code: currencyCode))
                                    .font(.caption)
                                    .foregroundStyle(theme.colors.textSecondary)

                                // Show arrow indicator for change
                                if comparison.amount < readyToAssign {
                                    Image(systemName: "arrow.up")
                                        .font(.caption2)
                                        .foregroundStyle(theme.colors.success)
                                } else if comparison.amount > readyToAssign {
                                    Image(systemName: "arrow.down")
                                        .font(.caption2)
                                        .foregroundStyle(theme.colors.error)
                                } else {
                                    Image(systemName: "arrow.right")
                                        .font(.caption2)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }
                            }
                        }
                    }

                    Divider()

                    // Goal Status - Visual celebration when Ready to Assign = $0
                    if readyToAssign == 0 {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(theme.colors.success)
                                .font(.title2)
                            Text("Goal Achieved!")
                                .font(.headline)
                                .foregroundStyle(theme.colors.success)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(theme.colors.success.opacity(0.1))
                    } else if readyToAssign > 0 {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(theme.colors.warning)
                                .font(.title3)
                            Text("Assign \(readyToAssign, format: .currency(code: currencyCode)) to categories")
                                .font(.subheadline)
                                .foregroundStyle(theme.colors.warning)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(theme.colors.error)
                                .font(.title3)
                            Text("Over-assigned by \(abs(readyToAssign), format: .currency(code: currencyCode))")
                                .font(.subheadline)
                                .foregroundStyle(theme.colors.error)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Budget Summary")
                } footer: {
                    if readyToAssign == 0 {
                        Text("Perfect! Every dollar has a job. You've successfully budgeted all available money.")
                            .font(.caption)
                            .foregroundStyle(theme.colors.success)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(theme.colors.background)
            .listSectionSpacing(0)
            .navigationTitle("Budget Planning")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(theme.colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                // NOTE: Enhancement 3.1 - Account balances now persist globally, no need to load per-month
                // Budget data still created for month tracking
                _ = getOrCreateMonthlyBudget(for: selectedMonth)
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategorySheet(categoryType: newCategoryType, currencyCode: currencyCode, onSave: { name, amount, dueDayOfMonth, isLastDayOfMonth, notify7Days, notify2Days, notifyOnDate, notifyCustom, customDays in
                    saveNewCategory(
                        name: name,
                        amount: amount,
                        type: newCategoryType,
                        dueDayOfMonth: dueDayOfMonth,
                        isLastDayOfMonth: isLastDayOfMonth,
                        notify7DaysBefore: notify7Days,
                        notify2DaysBefore: notify2Days,
                        notifyOnDueDate: notifyOnDate,
                        notifyCustomDays: notifyCustom,
                        customDaysCount: customDays
                    )
                })
            }
            .sheet(item: $editingCategory) { category in
                EditCategorySheet(category: category, currencyCode: currencyCode, onSave: { updatedAmount, dueDayOfMonth, isLastDayOfMonth, notify7Days, notify2Days, notifyOnDate, notifyCustom, customDays in
                    updateCategory(
                        category,
                        amount: updatedAmount,
                        dueDayOfMonth: dueDayOfMonth,
                        isLastDayOfMonth: isLastDayOfMonth,
                        notify7DaysBefore: notify7Days,
                        notify2DaysBefore: notify2Days,
                        notifyOnDueDate: notifyOnDate,
                        notifyCustomDays: notifyCustom,
                        customDaysCount: customDays
                    )
                })
            }
            .alert("Ready to Assign - YNAB Methodology", isPresented: $showingReadyToAssignInfo) {
                Button("Got It", role: .cancel) { }
            } message: {
                Text("""
                Ready to Assign represents money you have RIGHT NOW.

                • Budget only money that exists, not money you expect
                • When income arrives, log it as a transaction - it will increase your Ready to Assign
                • Your goal: Assign all money until Ready to Assign = $0

                This is the core of YNAB budgeting: Give every dollar a job!
                """)
            }
            .alert("Unassigned Money", isPresented: $showingMonthSwitchAlert) {
                Button("Carry Forward", role: .none) {
                    carryForwardToNextMonth()
                }
                Button("Leave Behind", role: .destructive) {
                    switchWithoutCarryForward()
                }
                Button("Cancel", role: .cancel) {
                    pendingMonth = nil
                    previousMonthReadyToAssign = nil
                }
            } message: {
                if let unassigned = previousMonthReadyToAssign {
                    Text("""
                    You have \(unassigned.formatted(.currency(code: currencyCode))) unassigned in this month.

                    • Carry Forward: Add this money to next month's starting balance
                    • Leave Behind: Keep it in this month (you can assign it later)
                    • Cancel: Stay in this month
                    """)
                }
            }
            .overlay(alignment: .bottom) {
                // Undo banner (Enhancement 3.2)
                if showingUndoBanner, let action = undoAction {
                    VStack(spacing: 0) {
                        Spacer()

                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(theme.colors.success)
                                .font(.title3)

                            Text(action.actionDescription)
                                .font(.subheadline)
                                .foregroundStyle(theme.colors.textPrimary)

                            Spacer()

                            Button("Undo") {
                                performUndo()
                            }
                            .fontWeight(.semibold)
                            .foregroundStyle(theme.colors.accent)

                            Button(action: {
                                withAnimation {
                                    showingUndoBanner = false
                                    undoAction = nil
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                        .padding()
                        .background(theme.colors.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 10)
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func quickAssignToCategory(_ category: BudgetCategory) {
        guard readyToAssign > 0 else { return }

        // Save undo information
        let previousAmount = category.budgetedAmount
        let assignedAmount = readyToAssign

        // Add remaining Ready to Assign to this category
        category.budgetedAmount += readyToAssign
        try? modelContext.save()

        // Set up undo
        let formattedAmount = assignedAmount.formatted(.currency(code: currencyCode))
        undoAction = UndoAction(
            categoryChanges: [(category, previousAmount)],
            actionDescription: "Assigned \(formattedAmount) to \(category.name)"
        )
        showUndoBanner()
    }

    private func assignAllRemaining() {
        guard readyToAssign > 0, !allCategories.isEmpty else { return }

        // Save undo information
        let previousAmounts = allCategories.map { ($0, $0.budgetedAmount) }
        let assignedTotal = readyToAssign

        // Distribute remaining money evenly across all categories
        let amountPerCategory = readyToAssign / Decimal(allCategories.count)

        for category in allCategories {
            category.budgetedAmount += amountPerCategory
        }

        try? modelContext.save()

        // Set up undo
        let formattedAmount = assignedTotal.formatted(.currency(code: currencyCode))
        undoAction = UndoAction(
            categoryChanges: previousAmounts,
            actionDescription: "Assigned \(formattedAmount) evenly"
        )
        showUndoBanner()
    }

    private func showUndoBanner() {
        showingUndoBanner = true

        // Auto-dismiss after 5 seconds
        Task {
            try? await Task.sleep(for: .seconds(5))
            if showingUndoBanner {
                withAnimation {
                    showingUndoBanner = false
                    undoAction = nil
                }
            }
        }
    }

    private func performUndo() {
        guard let action = undoAction else { return }

        // Revert all category changes
        for (category, previousAmount) in action.categoryChanges {
            category.budgetedAmount = previousAmount
        }

        try? modelContext.save()

        // Hide undo banner
        withAnimation {
            showingUndoBanner = false
            undoAction = nil
        }
    }

    private func addCategory(type: String) {
        newCategoryType = type
        showingAddCategory = true
    }

    private func saveNewCategory(name: String, amount: Decimal, type: String, dueDayOfMonth: Int?, isLastDayOfMonth: Bool, notify7DaysBefore: Bool, notify2DaysBefore: Bool, notifyOnDueDate: Bool, notifyCustomDays: Bool, customDaysCount: Int) {
        let category = BudgetCategory(
            name: name,
            budgetedAmount: amount,
            categoryType: type,
            colorHex: generateRandomColor()
        )

        // Set day-of-month and notification preferences from user input
        category.dueDayOfMonth = dueDayOfMonth
        category.isLastDayOfMonth = isLastDayOfMonth
        category.notify7DaysBefore = notify7DaysBefore
        category.notify2DaysBefore = notify2DaysBefore
        category.notifyOnDueDate = notifyOnDueDate
        category.notifyCustomDays = notifyCustomDays
        category.customDaysCount = customDaysCount

        modelContext.insert(category)
        try? modelContext.save()
        showingAddCategory = false

        // Schedule notifications if due date is set
        if let effectiveDate = category.effectiveDueDate {
            Task {
                await NotificationManager.shared.scheduleNotifications(
                    for: category.notificationID,
                    categoryName: category.name,
                    budgetedAmount: category.budgetedAmount,
                    dueDate: effectiveDate,
                    notify7DaysBefore: category.notify7DaysBefore,
                    notify2DaysBefore: category.notify2DaysBefore,
                    notifyOnDueDate: category.notifyOnDueDate,
                    notifyCustomDays: category.notifyCustomDays,
                    customDaysCount: category.customDaysCount,
                    currencyCode: currencyCode
                )
            }
        }
    }

    private func updateCategory(
        _ category: BudgetCategory,
        amount: Decimal,
        dueDayOfMonth: Int?,
        isLastDayOfMonth: Bool,
        notify7DaysBefore: Bool,
        notify2DaysBefore: Bool,
        notifyOnDueDate: Bool,
        notifyCustomDays: Bool,
        customDaysCount: Int
    ) {
        category.budgetedAmount = amount
        category.dueDayOfMonth = dueDayOfMonth
        category.isLastDayOfMonth = isLastDayOfMonth
        category.notify7DaysBefore = notify7DaysBefore
        category.notify2DaysBefore = notify2DaysBefore
        category.notifyOnDueDate = notifyOnDueDate
        category.notifyCustomDays = notifyCustomDays
        category.customDaysCount = customDaysCount
        try? modelContext.save()
        editingCategory = nil

        // Schedule or cancel notifications based on due date
        Task {
            if let effectiveDate = category.effectiveDueDate {
                // Schedule notifications (this will cancel any existing ones first)
                await NotificationManager.shared.scheduleNotifications(
                    for: category.notificationID,
                    categoryName: category.name,
                    budgetedAmount: category.budgetedAmount,
                    dueDate: effectiveDate,
                    notify7DaysBefore: notify7DaysBefore,
                    notify2DaysBefore: notify2DaysBefore,
                    notifyOnDueDate: notifyOnDueDate,
                    notifyCustomDays: notifyCustomDays,
                    customDaysCount: customDaysCount,
                    currencyCode: currencyCode
                )
            } else {
                // Cancel notifications if due date was removed
                await NotificationManager.shared.cancelNotification(for: category.notificationID)
            }
        }
    }

    private func deleteCategories(at offsets: IndexSet, from categories: [BudgetCategory]) {
        for index in offsets {
            let category = categories[index]

            // Cancel notification before deleting category
            Task {
                await NotificationManager.shared.cancelNotification(for: category.notificationID)
            }

            modelContext.delete(category)
        }
        try? modelContext.save()
    }

    private func generateRandomColor() -> String {
        let colors = ["FF6B6B", "4ECDC4", "45B7D1", "FFA07A", "98D8C8", "F7DC6F", "BB8FCE", "85C1E2"]
        return colors.randomElement() ?? "4ECDC4"
    }

    private func previousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
            attemptMonthSwitch(to: newMonth)
        }
    }

    private func nextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
            attemptMonthSwitch(to: newMonth)
        }
    }

    /// Attempt to switch to a new month, checking for unassigned money first
    private func attemptMonthSwitch(to newMonth: Date) {
        // Save current month's starting balance
        saveCurrentMonthBudget()

        // Check if current month has unassigned money
        if readyToAssign > 0 {
            // Store the pending month and show alert
            pendingMonth = newMonth
            previousMonthReadyToAssign = readyToAssign
            showingMonthSwitchAlert = true
        } else {
            // No unassigned money, switch immediately
            performMonthSwitch(to: newMonth)
        }
    }

    /// Save the current month's budget data
    /// NOTE: Enhancement 3.1 - No longer saves startingBalance (using Account balances instead)
    private func saveCurrentMonthBudget() {
        // Method kept for compatibility but no longer saves startingBalance
        // Account balances are now the source of truth and persist globally
        try? modelContext.save()
    }

    /// Perform the actual month switch and load the new month's data
    private func performMonthSwitch(to newMonth: Date) {
        selectedMonth = newMonth

        // NOTE: Enhancement 3.1 - Account balances persist globally, no per-month loading needed
        _ = getOrCreateMonthlyBudget(for: newMonth)
    }

    /// Carry forward unassigned money to the next month
    /// NOTE: Enhancement 3.1 - With account-based budgeting, money automatically carries forward
    /// since account balances persist globally across months
    private func carryForwardToNextMonth() {
        guard let newMonth = pendingMonth else { return }

        // With account-based budgeting, unassigned money is already reflected in account balances
        // No need to manually add to next month's starting balance
        // Simply switch to the new month
        performMonthSwitch(to: newMonth)

        // Clear pending state
        pendingMonth = nil
        previousMonthReadyToAssign = nil
    }

    /// Switch without carrying forward
    private func switchWithoutCarryForward() {
        guard let newMonth = pendingMonth else { return }

        performMonthSwitch(to: newMonth)

        // Clear pending state
        pendingMonth = nil
        previousMonthReadyToAssign = nil
    }
}

// MARK: - CategoryRow View
struct CategoryRow: View {
    @Environment(\.theme) private var theme
    let category: BudgetCategory
    let readyToAssign: Decimal
    let actualSpent: Decimal  // NEW: Enhancement 7.2 - Track actual spending
    let onEdit: () -> Void
    let onQuickAssign: () -> Void
    var currencyCode: String = "USD"

    private var dueDateText: String? {
        guard let effectiveDate = category.effectiveDueDate else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        if category.isLastDayOfMonth {
            return "Last day of month (\(formatter.string(from: effectiveDate)))"
        } else {
            return formatter.string(from: effectiveDate)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onEdit) {
                HStack {
                    Circle()
                        .fill(Color(hex: category.colorHex))
                        .frame(width: 12, height: 12)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .foregroundStyle(theme.colors.textPrimary)

                        if let dueDateText = dueDateText {
                            Text(dueDateText)
                                .font(.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }

                        // NEW: Enhancement 7.2 - Progress bar showing spending
                        CategoryProgressBar(spent: actualSpent, budgeted: category.budgetedAmount)
                            .frame(height: 6)
                    }

                    Spacer()

                    Text(category.budgetedAmount, format: .currency(code: currencyCode))
                        .foregroundStyle(theme.colors.textSecondary)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            // Quick Assign button (only show when there's money to assign)
            if readyToAssign > 0 {
                Button(action: onQuickAssign) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(theme.colors.onPrimary)
                        .frame(width: 28, height: 28)
                        .background(theme.colors.warning)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Quick assign \(readyToAssign, format: .currency(code: currencyCode)) to \(category.name)")
            }
        }
    }
}

// MARK: - AddCategorySheet
struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    let categoryType: String
	var currencyCode: String = "USD"
    let onSave: (String, Decimal, Int?, Bool, Bool, Bool, Bool, Bool, Int) -> Void

    @State private var categoryName: String = ""
    @State private var budgetedAmount: Decimal = 0
    @State private var hasDueDate: Bool = false
    @State private var selectedDay: Int = 15  // Default to 15th of month
    @State private var isLastDayOfMonth: Bool = false
    @State private var notify7DaysBefore: Bool = false
    @State private var notify2DaysBefore: Bool = false
    @State private var notifyOnDueDate: Bool = true  // Default to ON
    @State private var notifyCustomDays: Bool = false
    @State private var customDaysCount: Int = 1

    // Helper to calculate display date for preview
    private var displayDate: Date {
        if isLastDayOfMonth {
            return lastDayOfCurrentMonth()
        } else {
            return dateFromDayOfMonth(selectedDay)
        }
    }

    // Calculate the last day of the current month
    private func lastDayOfCurrentMonth() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)

        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return now
        }

        var lastDayComponents = components
        lastDayComponents.day = range.count
        lastDayComponents.hour = 0
        lastDayComponents.minute = 0
        lastDayComponents.second = 0

        return calendar.date(from: lastDayComponents) ?? now
    }

    // Calculate a Date for the given day-of-month in the current month
    private func dateFromDayOfMonth(_ day: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month], from: now)
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0

        if let date = calendar.date(from: components) {
            return date
        } else {
            return lastDayOfCurrentMonth()
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $categoryName)

                    LabeledContent("Budgeted Amount") {
                        TextField("Amount", value: $budgetedAmount, format: .currency(code: currencyCode))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Due Date (Optional)")) {
                    Toggle("Set Due Date", isOn: $hasDueDate)

                    if hasDueDate {
                        Toggle("Last day of month", isOn: $isLastDayOfMonth)

                        if !isLastDayOfMonth {
                            Picker("Day of Month", selection: $selectedDay) {
                                ForEach(1...31, id: \.self) { day in
                                    Text(ordinalDay(day)).tag(day)
                                }
                            }
                            .pickerStyle(.wheel)
                        }

                        // Show effective date preview
                        LabeledContent("Effective Date") {
                            Text(displayDate, style: .date)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                }

                if hasDueDate {
                    Section(header: Text("Notification Settings"), footer: Text("Choose when to be notified about this budget due date")) {
                        Toggle("Notify 7 days before", isOn: $notify7DaysBefore)
                        Toggle("Notify 2 days before", isOn: $notify2DaysBefore)
                        Toggle("Notify on due date", isOn: $notifyOnDueDate)

                        Toggle("Notify custom days before", isOn: $notifyCustomDays)

                        if notifyCustomDays {
                            Stepper("Notify \(customDaysCount) day\(customDaysCount == 1 ? "" : "s") before", value: $customDaysCount, in: 1...30)
                        }
                    }
                }

                Section {
                    Text("Category Type: \(categoryType)")
                        .foregroundStyle(theme.colors.textSecondary)
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
                        onSave(
                            categoryName,
                            budgetedAmount,
                            hasDueDate ? selectedDay : nil,
                            isLastDayOfMonth,
                            notify7DaysBefore,
                            notify2DaysBefore,
                            notifyOnDueDate,
                            notifyCustomDays,
                            customDaysCount
                        )
                        dismiss()
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespaces).isEmpty || budgetedAmount < 0)
                }
            }
        }
    }
}

// MARK: - EditCategorySheet
struct EditCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    let category: BudgetCategory
    let onSave: (Decimal, Int?, Bool, Bool, Bool, Bool, Bool, Int) -> Void
    var currencyCode: String = "USD"

    @State private var budgetedAmount: Decimal
    @State private var hasDueDate: Bool
    @State private var selectedDay: Int
    @State private var isLastDayOfMonth: Bool
    @State private var notify7DaysBefore: Bool
    @State private var notify2DaysBefore: Bool
    @State private var notifyOnDueDate: Bool
    @State private var notifyCustomDays: Bool
    @State private var customDaysCount: Int

    init(category: BudgetCategory, currencyCode: String = "USD", onSave: @escaping (Decimal, Int?, Bool, Bool, Bool, Bool, Bool, Int) -> Void) {
        self.category = category
        self.currencyCode = currencyCode
        self.onSave = onSave
        _budgetedAmount = State(initialValue: category.budgetedAmount)

        // Extract day from dueDayOfMonth or legacy dueDate
        let hasDate = category.dueDayOfMonth != nil || category.dueDate != nil
        _hasDueDate = State(initialValue: hasDate)

        if let dayOfMonth = category.dueDayOfMonth {
            _selectedDay = State(initialValue: dayOfMonth)
        } else if let legacyDate = category.dueDate {
            let day = Calendar.current.component(.day, from: legacyDate)
            _selectedDay = State(initialValue: day)
        } else {
            _selectedDay = State(initialValue: 15)  // Default
        }

        _isLastDayOfMonth = State(initialValue: category.isLastDayOfMonth)
        _notify7DaysBefore = State(initialValue: category.notify7DaysBefore)
        _notify2DaysBefore = State(initialValue: category.notify2DaysBefore)
        _notifyOnDueDate = State(initialValue: category.notifyOnDueDate)
        _notifyCustomDays = State(initialValue: category.notifyCustomDays)
        _customDaysCount = State(initialValue: category.customDaysCount)
    }

    // Helper computed property to show the effective date
    private var displayDate: Date {
        if isLastDayOfMonth {
            return lastDayOfCurrentMonth()
        } else {
            return dateFromDayOfMonth(selectedDay)
        }
    }

    // Calculate the last day of the current month
    private func lastDayOfCurrentMonth() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)

        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return now
        }

        var lastDayComponents = components
        lastDayComponents.day = range.count
        lastDayComponents.hour = 0
        lastDayComponents.minute = 0
        lastDayComponents.second = 0

        return calendar.date(from: lastDayComponents) ?? now
    }

    // Calculate a Date for the given day-of-month in the current month
    private func dateFromDayOfMonth(_ day: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month], from: now)
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0

        if let date = calendar.date(from: components) {
            return date
        } else {
            return lastDayOfCurrentMonth()
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Category Details")) {
                    LabeledContent("Name") {
                        Text(category.name)
                            .foregroundStyle(theme.colors.textSecondary)
                    }

                    LabeledContent("Type") {
                        Text(category.categoryType)
                            .foregroundStyle(theme.colors.textSecondary)
                    }

                    LabeledContent("Budgeted Amount") {
                        TextField("Amount", value: $budgetedAmount, format: .currency(code: currencyCode))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Due Date (Optional)")) {
                    Toggle("Set Due Date", isOn: $hasDueDate)

                    if hasDueDate {
                        Toggle("Last day of month", isOn: $isLastDayOfMonth)

                        if !isLastDayOfMonth {
                            Picker("Day of Month", selection: $selectedDay) {
                                ForEach(1...31, id: \.self) { day in
                                    Text(ordinalDay(day)).tag(day)
                                }
                            }
                            .pickerStyle(.wheel)
                        }

                        // Show effective date preview
                        LabeledContent("Effective Date") {
                            Text(displayDate, style: .date)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                }

                if hasDueDate {
                    Section(header: Text("Notification Settings"), footer: Text("Choose when to be notified about this budget due date")) {
                        Toggle("Notify 7 days before", isOn: $notify7DaysBefore)
                        Toggle("Notify 2 days before", isOn: $notify2DaysBefore)
                        Toggle("Notify on due date", isOn: $notifyOnDueDate)

                        Toggle("Notify custom days before", isOn: $notifyCustomDays)

                        if notifyCustomDays {
                            Stepper("Notify \(customDaysCount) day\(customDaysCount == 1 ? "" : "s") before", value: $customDaysCount, in: 1...30)
                        }
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
                        onSave(
                            budgetedAmount,
                            hasDueDate ? selectedDay : nil,
                            isLastDayOfMonth,
                            notify7DaysBefore,
                            notify2DaysBefore,
                            notifyOnDueDate,
                            notifyCustomDays,
                            customDaysCount
                        )
                    }
                    .disabled(budgetedAmount < 0)
                }
            }
        }
    }
}

// MARK: - Ordinal Formatter Helper

/// Formats a day number as an ordinal string (1 → "1st", 2 → "2nd", etc.)
func ordinalDay(_ day: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(from: NSNumber(value: day)) ?? "\(day)"
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
