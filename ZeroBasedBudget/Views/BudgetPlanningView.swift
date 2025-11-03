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
    @Query private var allTransactions: [Transaction]
    @Query private var allMonthlyBudgets: [MonthlyBudget]

    // State for selected month/year
    @State private var selectedMonth: Date = Date()

    // State for YNAB-style "Ready to Assign" - starting balance (money you have RIGHT NOW)
    @State private var startingBalance: Decimal = 0

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
    private func calculateReadyToAssign(for month: Date) -> Decimal {
        let budget = getOrCreateMonthlyBudget(for: month)
        let income = BudgetCalculations.calculateTotalIncome(in: month, from: allTransactions)
        let assigned = allCategories.reduce(0) { $0 + $1.budgetedAmount }
        return (budget.startingBalance + income) - assigned
    }

    /// Get previous month's Ready to Assign for comparison
    private var previousMonthComparison: (month: String, amount: Decimal)? {
        guard let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let monthName = formatter.string(from: prevMonth)

        // Only show if previous month's budget exists
        guard allMonthlyBudgets.contains(where: { normalizeToFirstOfMonth($0.month) == normalizeToFirstOfMonth(prevMonth) }) else {
            return nil
        }

        let prevReadyToAssign = calculateReadyToAssign(for: prevMonth)
        return (monthName, prevReadyToAssign)
    }

    // MARK: - YNAB-Style Computed Properties

    // Total income from transactions for the selected month
    private var totalIncome: Decimal {
        BudgetCalculations.calculateTotalIncome(in: selectedMonth, from: allTransactions)
    }

    // Total amount assigned to all budget categories
    private var totalAssigned: Decimal {
        allCategories.reduce(0) { $0 + $1.budgetedAmount }
    }

    // Ready to Assign = money available to budget (goal: $0)
    // Formula: (Starting Balance + Income This Period) - Total Assigned
    private var readyToAssign: Decimal {
        (startingBalance + totalIncome) - totalAssigned
    }

    // Total available money (for progress indicator)
    private var totalAvailableMoney: Decimal {
        startingBalance + totalIncome
    }

    // Assignment progress (0.0 to 1.0)
    private var assignmentProgress: Double {
        guard totalAvailableMoney > 0 else { return 0 }
        let progress = Double(truncating: totalAssigned as NSDecimalNumber) /
                      Double(truncating: totalAvailableMoney as NSDecimalNumber)
        return min(max(progress, 0), 1.0)
    }

    // Color coding for Ready to Assign
    private var readyToAssignColor: Color {
        if readyToAssign == 0 {
            return .green  // Goal achieved!
        } else if readyToAssign > 0 {
            return .orange  // Money needs to be assigned
        } else {
            return .red  // Over-assigned, need to reduce categories
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

                // YNAB-Style "Ready to Assign" Section
                Section {
                    LabeledContent("Starting Balance") {
                        TextField("Amount", value: $startingBalance, format: .currency(code: "USD"))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .onChange(of: startingBalance) { oldValue, newValue in
                                // Auto-save starting balance changes (Enhancement 3.3)
                                saveCurrentMonthBudget()
                            }
                    }

                    LabeledContent("Total Income (This Period)") {
                        Text(totalIncome, format: .currency(code: "USD"))
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent("Total Assigned") {
                        Text(totalAssigned, format: .currency(code: "USD"))
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    // Prominent Ready to Assign Display (Enhancement 3.1)
                    VStack(spacing: 12) {
                        // Large amount display
                        VStack(spacing: 4) {
                            Text("Ready to Assign")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(readyToAssign, format: .currency(code: "USD"))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(readyToAssignColor)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }

                        // Progress bar
                        VStack(alignment: .leading, spacing: 4) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background track
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 16)

                                    // Progress fill
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(readyToAssign == 0 ? Color.green : Color.blue)
                                        .frame(width: geometry.size.width * assignmentProgress, height: 16)
                                        .animation(.smooth, value: assignmentProgress)
                                }
                            }
                            .frame(height: 16)

                            HStack {
                                Text("\(Int(assignmentProgress * 100))% assigned")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(totalAvailableMoney, format: .currency(code: "USD"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // Assign All Remaining button (Enhancement 3.2)
                        if readyToAssign > 0 && !allCategories.isEmpty {
                            Button(action: assignAllRemaining) {
                                HStack {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.body)
                                    Text("Assign All Remaining Evenly")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Assign all remaining \(readyToAssign, format: .currency(code: "USD")) evenly across all categories")
                        }
                    }
                    .padding(.vertical, 8)
                    .accessibilityLabel("Ready to Assign: \(readyToAssign, format: .currency(code: "USD")). \(readyToAssignStatus)")
                } header: {
                    HStack {
                        Text("Ready to Assign")
                        Spacer()
                        Button(action: { showingReadyToAssignInfo = true }) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                } footer: {
                    Text("Budget only money you have RIGHT NOW. Goal: Assign all money until Ready to Assign = $0.")
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
                            CategoryRow(
                                category: category,
                                readyToAssign: readyToAssign,
                                onEdit: {
                                    editingCategory = category
                                },
                                onQuickAssign: {
                                    quickAssignToCategory(category)
                                }
                            )
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
                            CategoryRow(
                                category: category,
                                readyToAssign: readyToAssign,
                                onEdit: {
                                    editingCategory = category
                                },
                                onQuickAssign: {
                                    quickAssignToCategory(category)
                                }
                            )
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
                            CategoryRow(
                                category: category,
                                readyToAssign: readyToAssign,
                                onEdit: {
                                    editingCategory = category
                                },
                                onQuickAssign: {
                                    quickAssignToCategory(category)
                                }
                            )
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

                // Budget Summary Section
                Section {
                    LabeledContent("Total Assigned") {
                        Text(totalAssigned, format: .currency(code: "USD"))
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent("Ready to Assign") {
                        Text(readyToAssign, format: .currency(code: "USD"))
                            .fontWeight(.bold)
                            .foregroundStyle(readyToAssignColor)
                    }

                    // Previous month comparison (Enhancement 3.3)
                    if let comparison = previousMonthComparison {
                        HStack {
                            Text("Previous Month (\(comparison.month))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            HStack(spacing: 4) {
                                Text(comparison.amount, format: .currency(code: "USD"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                // Show arrow indicator for change
                                if comparison.amount < readyToAssign {
                                    Image(systemName: "arrow.up")
                                        .font(.caption2)
                                        .foregroundStyle(.green)
                                } else if comparison.amount > readyToAssign {
                                    Image(systemName: "arrow.down")
                                        .font(.caption2)
                                        .foregroundStyle(.red)
                                } else {
                                    Image(systemName: "arrow.right")
                                        .font(.caption2)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }

                    Divider()

                    // Goal Status - Visual celebration when Ready to Assign = $0
                    if readyToAssign == 0 {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.title2)
                            Text("Goal Achieved!")
                                .font(.headline)
                                .foregroundStyle(.green)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Color.green.opacity(0.1))
                    } else if readyToAssign > 0 {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.orange)
                                .font(.title3)
                            Text("Assign \(readyToAssign, format: .currency(code: "USD")) to categories")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                                .font(.title3)
                            Text("Over-assigned by \(abs(readyToAssign), format: .currency(code: "USD"))")
                                .font(.subheadline)
                                .foregroundStyle(.red)
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
                            .foregroundStyle(.green)
                    }
                }
            }
            .navigationTitle("Budget Planning")
            .onAppear {
                // Load the current month's budget data when view appears (Enhancement 3.3)
                let budget = getOrCreateMonthlyBudget(for: selectedMonth)
                startingBalance = budget.startingBalance
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategorySheet(categoryType: newCategoryType, onSave: { name, amount, dueDate in
                    saveNewCategory(name: name, amount: amount, type: newCategoryType, dueDate: dueDate)
                })
            }
            .sheet(item: $editingCategory) { category in
                EditCategorySheet(category: category, onSave: { updatedAmount, updatedDueDate, isLastDayOfMonth, notify7Days, notify2Days, notifyOnDate, notifyCustom, customDays in
                    updateCategory(
                        category,
                        amount: updatedAmount,
                        dueDate: updatedDueDate,
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
                    You have \(unassigned.formatted(.currency(code: "USD"))) unassigned in this month.

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
                                .foregroundStyle(.green)
                                .font(.title3)

                            Text(action.actionDescription)
                                .font(.subheadline)
                                .foregroundStyle(.primary)

                            Spacer()

                            Button("Undo") {
                                performUndo()
                            }
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)

                            Button(action: {
                                withAnimation {
                                    showingUndoBanner = false
                                    undoAction = nil
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
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
        let formattedAmount = assignedAmount.formatted(.currency(code: "USD"))
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
        let formattedAmount = assignedTotal.formatted(.currency(code: "USD"))
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
                    customDaysCount: category.customDaysCount
                )
            }
        }
    }

    private func updateCategory(
        _ category: BudgetCategory,
        amount: Decimal,
        dueDate: Date?,
        isLastDayOfMonth: Bool,
        notify7DaysBefore: Bool,
        notify2DaysBefore: Bool,
        notifyOnDueDate: Bool,
        notifyCustomDays: Bool,
        customDaysCount: Int
    ) {
        category.budgetedAmount = amount
        category.dueDate = dueDate
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
                    customDaysCount: customDaysCount
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
    private func saveCurrentMonthBudget() {
        let budget = getOrCreateMonthlyBudget(for: selectedMonth)
        budget.startingBalance = startingBalance
        try? modelContext.save()
    }

    /// Perform the actual month switch and load the new month's data
    private func performMonthSwitch(to newMonth: Date) {
        selectedMonth = newMonth

        // Load the new month's starting balance
        let budget = getOrCreateMonthlyBudget(for: newMonth)
        startingBalance = budget.startingBalance
    }

    /// Carry forward unassigned money to the next month
    private func carryForwardToNextMonth() {
        guard let newMonth = pendingMonth else { return }

        // Get the new month's budget (or create it)
        let nextMonthBudget = getOrCreateMonthlyBudget(for: newMonth)

        // Add current month's unassigned money to next month's starting balance
        nextMonthBudget.startingBalance += readyToAssign
        try? modelContext.save()

        // Now switch to the new month
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
    let category: BudgetCategory
    let readyToAssign: Decimal
    let onEdit: () -> Void
    let onQuickAssign: () -> Void

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

            // Quick Assign button (only show when there's money to assign)
            if readyToAssign > 0 {
                Button(action: onQuickAssign) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Quick assign \(readyToAssign, format: .currency(code: "USD")) to \(category.name)")
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
                    .disabled(categoryName.trimmingCharacters(in: .whitespaces).isEmpty || budgetedAmount < 0)
                }
            }
        }
    }
}

// MARK: - EditCategorySheet
struct EditCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    let category: BudgetCategory
    let onSave: (Decimal, Date?, Bool, Bool, Bool, Bool, Bool, Int) -> Void

    @State private var budgetedAmount: Decimal
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var isLastDayOfMonth: Bool
    @State private var notify7DaysBefore: Bool
    @State private var notify2DaysBefore: Bool
    @State private var notifyOnDueDate: Bool
    @State private var notifyCustomDays: Bool
    @State private var customDaysCount: Int

    init(category: BudgetCategory, onSave: @escaping (Decimal, Date?, Bool, Bool, Bool, Bool, Bool, Int) -> Void) {
        self.category = category
        self.onSave = onSave
        _budgetedAmount = State(initialValue: category.budgetedAmount)
        _hasDueDate = State(initialValue: category.dueDate != nil)
        _dueDate = State(initialValue: category.dueDate ?? Date())
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
            return category.lastDayOfCurrentMonth()
        } else {
            return dueDate
        }
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
                        Toggle("Last day of month", isOn: $isLastDayOfMonth)

                        if !isLastDayOfMonth {
                            DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                        } else {
                            LabeledContent("Effective Date") {
                                Text(displayDate, style: .date)
                                    .foregroundStyle(.secondary)
                            }
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
                            hasDueDate ? dueDate : nil,
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
