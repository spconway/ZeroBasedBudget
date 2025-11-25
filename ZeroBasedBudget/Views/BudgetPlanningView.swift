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
    @Environment(\.themeColors) private var colors
    @Query private var allCategories: [BudgetCategory]
    @Query private var allTransactions: [Transaction]
    @Query private var allMonthlyBudgets: [MonthlyBudget]
    @Query private var allCategoryMonthlyBudgets: [CategoryMonthlyBudget]
    @Query private var allAccounts: [Account]  // NEW: Query accounts for YNAB-style budgeting
    @Query(sort: \CategoryGroup.sortOrder) private var categoryGroups: [CategoryGroup]
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
    @State private var newCategoryType: String = "Fixed"  // For AddCategorySheet compatibility
    @State private var newCategoryGroup: CategoryGroup?  // Track which group to add category to
    @State private var editingCategory: BudgetCategory?
    @State private var showingReadyToAssignInfo = false
    @State private var showingAddCategoryGroup = false  // For creating new category groups

    // State for editing category group
    @State private var editingGroup: CategoryGroup?

    // State for undo functionality (Enhancement 3.2)
    @State private var undoAction: UndoAction?
    @State private var showingUndoBanner = false

    // Undo action data structure
    struct UndoAction {
        let monthlyBudgetChanges: [(monthlyBudget: CategoryMonthlyBudget, previousAmount: Decimal)]
        let actionDescription: String
    }

    // Currency code from settings
    private var currencyCode: String {
        settings.first?.currencyCode ?? "USD"
    }

    // Date format from settings
    private var dateFormat: String {
        settings.first?.dateFormat ?? "MM/DD/YYYY"
    }

    // Number format from settings
    private var numberFormat: String {
        settings.first?.numberFormat ?? "1,234.56"
    }

    // MARK: - Category Group Helpers

    /// Get categories for a specific group (excluding Income categories)
    private func categories(for group: CategoryGroup) -> [BudgetCategory] {
        group.categories.filter { $0.categoryType != "Income" }.sorted { $0.name < $1.name }
    }

    /// Calculate total budgeted for a category group in the selected month
    private func totalBudgeted(for group: CategoryGroup) -> Decimal {
        let normalizedMonth = normalizeToFirstOfMonth(selectedMonth)
        let groupCategoryNames = Set(group.categories.map { $0.name })
        return allCategoryMonthlyBudgets
            .filter { $0.isForMonth(normalizedMonth) && groupCategoryNames.contains($0.category.name) }
            .reduce(0) { $0 + $1.budgetedAmount }
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

    // MARK: - Category Monthly Budget Helpers

    /// Get the monthly budget for a category in the selected month
    /// Creates one if it doesn't exist (with proper carry-forward)
    private func getMonthlyBudget(for category: BudgetCategory) -> CategoryMonthlyBudget {
        return CategoryMigrationHelper.getOrCreateMonthlyBudget(
            for: category,
            month: selectedMonth,
            allTransactions: allTransactions,
            in: modelContext
        )
    }

    /// Get the available balance for a category in the selected month
    /// Formula: budgetedAmount + availableFromPrevious - actualSpent
    private func getAvailableBalance(for category: BudgetCategory) -> Decimal {
        let monthlyBudget = getMonthlyBudget(for: category)
        let actualSpent = BudgetCalculations.calculateActualSpending(
            for: category,
            in: selectedMonth,
            from: allTransactions
        )
        return monthlyBudget.totalAvailable(actualSpent: actualSpent)
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

    // Total amount assigned to all budget categories THIS MONTH
    // Uses CategoryMonthlyBudget query to get per-month budgeted amounts
    // NOTE: Uses query directly to avoid creating duplicate monthly budgets
    private var totalAssigned: Decimal {
        let normalizedMonth = normalizeToFirstOfMonth(selectedMonth)
        return allCategoryMonthlyBudgets
            .filter { $0.isForMonth(normalizedMonth) }
            .reduce(0) { $0 + $1.budgetedAmount }
    }

    // Ready to Assign calculation using YNAB methodology
    // Formula: (Current Account Balances + Total Expenses) - Total Budgeted
    // Equivalent to: (Starting Balance + Income) - Total Budgeted
    //
    // Why we add expenses back:
    // - Account balances are ALREADY reduced by expenses
    // - We need to calculate money available to budget BEFORE expenses
    // - This prevents double-counting expenses (once in reduced balance, once in budgeted)
    private var readyToAssign: Decimal {
        let currentBalances = allAccounts.reduce(0) { $0 + $1.balance }
        let totalExpenses = BudgetCalculations.calculateTotalExpenses(
            in: selectedMonth,
            from: allTransactions
        )

        // Money available to budget = current balance + expenses (what we started with)
        // This represents: Starting Balance + Income
        let moneyAvailableToBudget = currentBalances + totalExpenses

        return moneyAvailableToBudget - totalAssigned
    }

    // Color coding for Ready to Assign
    private var readyToAssignColor: Color {
        if readyToAssign == 0 {
            return colors.success  // Goal achieved!
        } else if readyToAssign > 0 {
            return colors.warning  // Money needs to be assigned
        } else {
            return colors.error  // Over-assigned, need to reduce categories
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

    // MARK: - Category Totals (using monthly budgets)

    /// Total budgeted across all category groups in selected month
    private var totalExpenses: Decimal {
        categoryGroups.reduce(Decimal.zero) { $0 + totalBudgeted(for: $1) }
    }

    // MARK: - Overspending Detection

    /// Calculate total overspending across all categories
    /// Returns the sum of negative available balances (as a positive number)
    private var totalOverspent: Decimal {
        var overspent: Decimal = 0
        for category in allCategories {
            let available = getAvailableBalance(for: category)
            if available < 0 {
                overspent += abs(available)
            }
        }
        return overspent
    }

    /// Get list of overspent categories with their amounts
    private var overspentCategories: [(category: BudgetCategory, amount: Decimal)] {
        allCategories.compactMap { category in
            let available = getAvailableBalance(for: category)
            if available < 0 {
                return (category, abs(available))
            }
            return nil
        }
    }

    // MARK: - View Sections

    private var readyToAssignSection: some View {
        Section {
            ReadyToAssignBanner(
                amount: readyToAssign,
                color: readyToAssignColor,
                currencyCode: currencyCode,
                numberFormat: numberFormat
            )
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(colors.surface)
    }

    /// Warning section shown when categories are overspent
    @ViewBuilder
    private var overspendWarningSection: some View {
        if totalOverspent > 0 {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title3)
                            .foregroundStyle(colors.error)
                        Text("Overspending Alert")
                            .font(.headline)
                            .foregroundStyle(colors.error)
                        Spacer()
                    }

                    Text("You've spent \(CurrencyFormatHelpers.formatCurrency(totalOverspent, currencyCode: currencyCode, numberFormat: numberFormat)) more than budgeted. Cover this by moving money from Ready to Assign or other categories.")
                        .font(.subheadline)
                        .foregroundStyle(colors.textSecondary)

                    // List overspent categories
                    ForEach(overspentCategories, id: \.category.id) { item in
                        HStack {
                            Circle()
                                .fill(Color(hex: item.category.colorHex))
                                .frame(width: 8, height: 8)
                            Text(item.category.name)
                                .font(.subheadline)
                                .foregroundStyle(colors.textPrimary)
                            Spacer()
                            Text("-\(CurrencyFormatHelpers.formatCurrency(item.amount, currencyCode: currencyCode, numberFormat: numberFormat))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(colors.error)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(colors.error.opacity(0.1))
        }
    }

    /// Section for creating new category groups
    private var createCategoryGroupSection: some View {
		Section(header: EmptyView()) {
            Button(action: { showingAddCategoryGroup = true }) {
                HStack {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 20))
                        .iconAccent()
                    Text("Create Category Group")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(colors.textPrimary)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
			.buttonStyle(.plain)
        }
		.listRowBackground(Color.clear)
    }

    /// Dynamic section builder for category groups
    @ViewBuilder
    private func categoryGroupSection(for group: CategoryGroup) -> some View {
        let groupCategories = categories(for: group)

        Section(header: HStack {
            // Tappable group name to edit
            Button(action: { editingGroup = group }) {
                Text(group.name.uppercased())
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(colors.textSecondary)
            }
            .buttonStyle(.plain)

            Spacer()

            // Add category button
            Button(action: { addCategoryToGroup(group) }) {
                Image(systemName: "plus.circle.fill")
                    .iconAccent()
            }
        }) {
            if groupCategories.isEmpty {
                Text("No categories yet. Tap + to add.")
                    .foregroundStyle(colors.textSecondary)
                    .italic()
            } else {
                ForEach(groupCategories) { category in
                    let monthlyBudget = getMonthlyBudget(for: category)
                    let actualSpent = BudgetCalculations.calculateActualSpending(
                        for: category,
                        in: selectedMonth,
                        from: allTransactions
                    )
                    CategoryRow(
                        category: category,
                        budgetedThisMonth: monthlyBudget.budgetedAmount,
                        availableBalance: monthlyBudget.totalAvailable(actualSpent: actualSpent),
                        readyToAssign: readyToAssign,
                        actualSpent: actualSpent,
                        onEdit: {
                            editingCategory = category
                        },
                        onQuickAssign: {
                            quickAssignToCategory(category)
                        },
                        currencyCode: currencyCode,
                        numberFormat: numberFormat
                    )
                }
                .onDelete { indexSet in
                    deleteCategories(at: indexSet, from: groupCategories)
                }

                LabeledContent("Total \(group.name)") {
                    Text(CurrencyFormatHelpers.formatCurrency(totalBudgeted(for: group), currencyCode: currencyCode, numberFormat: numberFormat))
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var budgetSummarySection: some View {
        Section {
            LabeledContent("Total Assigned") {
                Text(CurrencyFormatHelpers.formatCurrency(totalAssigned, currencyCode: currencyCode, numberFormat: numberFormat))
                    .foregroundStyle(colors.textSecondary)
            }

            LabeledContent("Ready to Assign") {
                Text(CurrencyFormatHelpers.formatCurrency(readyToAssign, currencyCode: currencyCode, numberFormat: numberFormat))
                    .fontWeight(.bold)
                    .foregroundStyle(readyToAssignColor)
            }

            // Goal Status - Visual celebration when Ready to Assign = $0
            if readyToAssign == 0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .iconSuccess()
                        .font(.title2)
                    Text("Goal Achieved!")
                        .font(.headline)
                        .foregroundStyle(colors.success)
                    Spacer()
                }
                .padding(.vertical, 8)
                .listRowBackground(colors.success.opacity(0.1))
            } else if readyToAssign > 0 {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .iconWarning()
                        .font(.title3)
                    Text("Assign \(CurrencyFormatHelpers.formatCurrency(readyToAssign, currencyCode: currencyCode, numberFormat: numberFormat)) to categories")
                        .font(.subheadline)
                        .foregroundStyle(colors.warning)
                    Spacer()
                }
                .padding(.vertical, 4)
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .iconError()
                        .font(.title3)
                    Text("Over-assigned by \(CurrencyFormatHelpers.formatCurrency(abs(readyToAssign), currencyCode: currencyCode, numberFormat: numberFormat))")
                        .font(.subheadline)
                        .foregroundStyle(colors.error)
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("BUDGET SUMMARY")
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.8)
        } footer: {
            if readyToAssign == 0 {
                Text("Perfect! Every dollar has a job. You've successfully budgeted all available money.")
                    .font(.caption)
                    .foregroundStyle(colors.success)
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                readyToAssignSection

                overspendWarningSection

                createCategoryGroupSection

                // Dynamic category group sections
                ForEach(categoryGroups) { group in
                    categoryGroupSection(for: group)
                }

                budgetSummarySection
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(colors.background)
            .listSectionSpacing(10)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                // Previous month button (leading)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .iconAccent()
                            .frame(minWidth: 44, minHeight: 44)
                    }
                }

                // Month/Year display (center)
                ToolbarItem(placement: .principal) {
                    Text(monthYearText)
                        .font(theme.typography.headline)
						.foregroundStyle(colors.textPrimary)
                }

                // Next month button (trailing)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .iconAccent()
                            .frame(minWidth: 44, minHeight: 44)
                    }
                }
            }
            .onAppear {
                // NOTE: Enhancement 3.1 - Account balances now persist globally, no need to load per-month
                // Budget data still created for month tracking
                _ = getOrCreateMonthlyBudget(for: selectedMonth)
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategorySheet(categoryType: newCategoryType, currencyCode: currencyCode, dateFormat: dateFormat, onSave: { name, amount, dueDayOfMonth, isLastDayOfMonth, notify7Days, notify2Days, notifyOnDate, notifyCustom, customDays, timeHour, timeMinute in
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
                        customDaysCount: customDays,
                        notificationTimeHour: timeHour,
                        notificationTimeMinute: timeMinute
                    )
                })
            }
            .sheet(item: $editingCategory) { category in
                let monthlyBudget = getMonthlyBudget(for: category)
                EditCategorySheet(category: category, initialAmount: monthlyBudget.budgetedAmount, currencyCode: currencyCode, dateFormat: dateFormat, onSave: { updatedName, updatedAmount, dueDayOfMonth, isLastDayOfMonth, notify7Days, notify2Days, notifyOnDate, notifyCustom, customDays, timeHour, timeMinute in
                    updateCategory(
                        category,
                        name: updatedName,
                        amount: updatedAmount,
                        dueDayOfMonth: dueDayOfMonth,
                        isLastDayOfMonth: isLastDayOfMonth,
                        notify7DaysBefore: notify7Days,
                        notify2DaysBefore: notify2Days,
                        notifyOnDueDate: notifyOnDate,
                        notifyCustomDays: notifyCustom,
                        customDaysCount: customDays,
                        notificationTimeHour: timeHour,
                        notificationTimeMinute: timeMinute
                    )
                })
            }
            .sheet(isPresented: $showingAddCategoryGroup) {
                AddCategoryGroupSheet()
            }
            .sheet(item: $editingGroup) { group in
                EditCategoryGroupSheet(group: group)
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
                                .iconSuccess()
                                .font(.title3)

                            Text(action.actionDescription)
                                .font(.subheadline)
                                .foregroundStyle(colors.textPrimary)

                            Spacer()

                            Button("Undo") {
                                performUndo()
                            }
                            .fontWeight(.semibold)
                            .foregroundStyle(colors.accent)

                            Button(action: {
                                withAnimation {
                                    showingUndoBanner = false
                                    undoAction = nil
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                    .iconNeutral()
                            }
                        }
                        .padding()
                        .background(colors.surfaceElevated)
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

        // Get the monthly budget for current month
        let monthlyBudget = getMonthlyBudget(for: category)

        // Save undo information
        let previousAmount = monthlyBudget.budgetedAmount
        let assignedAmount = readyToAssign

        // Add remaining Ready to Assign to this category's monthly budget
        monthlyBudget.budgetedAmount += readyToAssign
        try? modelContext.save()

        // Set up undo
        let formattedAmount = assignedAmount.formatted(.currency(code: currencyCode))
        undoAction = UndoAction(
            monthlyBudgetChanges: [(monthlyBudget, previousAmount)],
            actionDescription: "Assigned \(formattedAmount) to \(category.name)"
        )
        showUndoBanner()
    }

    private func assignAllRemaining() {
        guard readyToAssign > 0, !allCategories.isEmpty else { return }

        // Get monthly budgets for all categories
        let monthlyBudgetsWithPrevious = allCategories.map { category -> (CategoryMonthlyBudget, Decimal) in
            let monthlyBudget = getMonthlyBudget(for: category)
            return (monthlyBudget, monthlyBudget.budgetedAmount)
        }

        let assignedTotal = readyToAssign

        // Distribute remaining money evenly across all categories
        let amountPerCategory = readyToAssign / Decimal(allCategories.count)

        for (monthlyBudget, _) in monthlyBudgetsWithPrevious {
            monthlyBudget.budgetedAmount += amountPerCategory
        }

        try? modelContext.save()

        // Set up undo
        let formattedAmount = assignedTotal.formatted(.currency(code: currencyCode))
        undoAction = UndoAction(
            monthlyBudgetChanges: monthlyBudgetsWithPrevious,
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

        // Revert all monthly budget changes
        for (monthlyBudget, previousAmount) in action.monthlyBudgetChanges {
            monthlyBudget.budgetedAmount = previousAmount
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

    /// Add category to a specific group
    private func addCategoryToGroup(_ group: CategoryGroup) {
        newCategoryGroup = group
        // Use the group's first category's type for compatibility, or default to "Fixed"
        newCategoryType = group.categories.first?.categoryType ?? "Fixed"
        showingAddCategory = true
    }

    private func saveNewCategory(name: String, amount: Decimal, type: String, dueDayOfMonth: Int?, isLastDayOfMonth: Bool, notify7DaysBefore: Bool, notify2DaysBefore: Bool, notifyOnDueDate: Bool, notifyCustomDays: Bool, customDaysCount: Int, notificationTimeHour: Int?, notificationTimeMinute: Int?) {
        let category = BudgetCategory(
            name: name,
            budgetedAmount: 0,  // Set to 0, use monthly budgets instead
            categoryType: type,
            colorHex: generateRandomColor(),
            categoryGroup: newCategoryGroup  // Assign to selected group
        )

        // Set day-of-month and notification preferences from user input
        category.dueDayOfMonth = dueDayOfMonth
        category.isLastDayOfMonth = isLastDayOfMonth
        category.notify7DaysBefore = notify7DaysBefore
        category.notify2DaysBefore = notify2DaysBefore
        category.notifyOnDueDate = notifyOnDueDate
        category.notifyCustomDays = notifyCustomDays
        category.customDaysCount = customDaysCount
        category.notificationTimeHour = notificationTimeHour
        category.notificationTimeMinute = notificationTimeMinute

        modelContext.insert(category)

        // Clear the group selection after saving
        newCategoryGroup = nil

        // Create monthly budget for current month with the budgeted amount
        let monthlyBudget = CategoryMonthlyBudget(
            category: category,
            month: selectedMonth,
            budgetedAmount: amount,
            availableFromPrevious: 0  // New category has no carry-forward
        )
        modelContext.insert(monthlyBudget)

        try? modelContext.save()
        showingAddCategory = false

        // Schedule notifications if due date is set
        if let effectiveDate = category.effectiveDueDate {
            Task {
                await NotificationManager.shared.scheduleNotifications(
                    for: category.notificationID,
                    categoryName: category.name,
                    budgetedAmount: amount,  // Use the monthly budgeted amount
                    dueDate: effectiveDate,
                    notify7DaysBefore: category.notify7DaysBefore,
                    notify2DaysBefore: category.notify2DaysBefore,
                    notifyOnDueDate: category.notifyOnDueDate,
                    notifyCustomDays: category.notifyCustomDays,
                    customDaysCount: category.customDaysCount,
                    currencyCode: currencyCode,
                    notificationTimeHour: category.notificationTimeHour ?? settings.first?.notificationTimeHour ?? 9,
                    notificationTimeMinute: category.notificationTimeMinute ?? settings.first?.notificationTimeMinute ?? 0
                )
            }
        }
    }

    private func updateCategory(
        _ category: BudgetCategory,
        name: String,
        amount: Decimal,
        dueDayOfMonth: Int?,
        isLastDayOfMonth: Bool,
        notify7DaysBefore: Bool,
        notify2DaysBefore: Bool,
        notifyOnDueDate: Bool,
        notifyCustomDays: Bool,
        customDaysCount: Int,
        notificationTimeHour: Int?,
        notificationTimeMinute: Int?
    ) {
        category.name = name
        // Don't update category.budgetedAmount - use monthly budget instead
        category.dueDayOfMonth = dueDayOfMonth
        category.isLastDayOfMonth = isLastDayOfMonth
        category.notify7DaysBefore = notify7DaysBefore
        category.notify2DaysBefore = notify2DaysBefore
        category.notifyOnDueDate = notifyOnDueDate
        category.notifyCustomDays = notifyCustomDays
        category.customDaysCount = customDaysCount
        category.notificationTimeHour = notificationTimeHour
        category.notificationTimeMinute = notificationTimeMinute

        // Update monthly budget for current month
        let monthlyBudget = getMonthlyBudget(for: category)
        monthlyBudget.budgetedAmount = amount

        try? modelContext.save()
        editingCategory = nil

        // Schedule or cancel notifications based on due date
        Task {
            if let effectiveDate = category.effectiveDueDate {
                // Schedule notifications (this will cancel any existing ones first)
                await NotificationManager.shared.scheduleNotifications(
                    for: category.notificationID,
                    categoryName: category.name,
                    budgetedAmount: amount,  // Use the updated monthly amount
                    dueDate: effectiveDate,
                    notify7DaysBefore: notify7DaysBefore,
                    notify2DaysBefore: notify2DaysBefore,
                    notifyOnDueDate: notifyOnDueDate,
                    notifyCustomDays: notifyCustomDays,
                    customDaysCount: customDaysCount,
                    currencyCode: currencyCode,
                    notificationTimeHour: category.notificationTimeHour ?? settings.first?.notificationTimeHour ?? 9,
                    notificationTimeMinute: category.notificationTimeMinute ?? settings.first?.notificationTimeMinute ?? 0
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

        // Ensure all categories have CategoryMonthlyBudget records for the new month
        // This handles carry-forward logic and creates budgets for any new categories
        CategoryMigrationHelper.migrateAllCategories(
            allCategories,
            forMonth: newMonth,
            allTransactions: allTransactions,
            in: modelContext
        )
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
    @Environment(\.themeColors) private var colors
    let category: BudgetCategory
    let budgetedThisMonth: Decimal  // Amount budgeted THIS month only
    let availableBalance: Decimal  // Total available (budgeted + carried - spent)
    let readyToAssign: Decimal
    let actualSpent: Decimal  // NEW: Enhancement 7.2 - Track actual spending
    let onEdit: () -> Void
    let onQuickAssign: () -> Void
    var currencyCode: String = "USD"
    var numberFormat: String = "1,234.56"

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
				VStack {
					HStack {
						Circle()
							.fill(Color(hex: category.colorHex))
							.frame(width: 12, height: 12)
						
						VStack(alignment: .leading, spacing: 4) {
							Text(category.name)
								.foregroundStyle(colors.textPrimary)
							
							if let dueDateText = dueDateText {
								Text(dueDateText)
									.font(.caption)
									.foregroundStyle(colors.textSecondary)
							}
						}
						
						Spacer()

						Text(CurrencyFormatHelpers.formatCurrency(availableBalance, currencyCode: currencyCode, numberFormat: numberFormat))
							.font(.system(size: 17, weight: .light))  // Light weight for amounts
							.monospacedDigit()
							.foregroundStyle(availableBalance >= 0 ? colors.textSecondary : colors.error)

						Image(systemName: "chevron.right")
							.font(.caption)
							.iconNeutral()
					}

					// NEW: Enhancement 7.2 - Progress bar showing spending vs available
					// Total available includes budgeted this month + carried from previous - spent
					CategoryProgressBar(spent: actualSpent, budgeted: availableBalance + actualSpent)
						.frame(height: 6)
				}
            }

            // Quick Assign button (only show when there's money to assign)
            if readyToAssign > 0 {
                Button(action: onQuickAssign) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(colors.onPrimary)
                        .frame(width: 28, height: 28)
                        .background(colors.warning)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Quick assign \(CurrencyFormatHelpers.formatCurrency(readyToAssign, currencyCode: currencyCode, numberFormat: numberFormat)) to \(category.name)")
            }
        }
    }
}

// MARK: - AddCategorySheet
struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    @Environment(\.themeColors) private var colors
    let categoryType: String
	var currencyCode: String = "USD"
    var dateFormat: String = "MM/DD/YYYY"
    let onSave: (String, Decimal, Int?, Bool, Bool, Bool, Bool, Bool, Int, Int?, Int?) -> Void

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
    @State private var hasCustomNotificationTime: Bool = false
    @State private var notificationTimeHour: Int = 9
    @State private var notificationTimeMinute: Int = 0

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
                Section {
                    TextField("Category Name", text: $categoryName)

                    LabeledContent("Budgeted Amount") {
                        TextField("Amount", value: $budgetedAmount, format: .currency(code: currencyCode))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                } header: {
                    Text("CATEGORY DETAILS")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
                }

                Section {
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
                            Text(DateFormatHelpers.formatDate(displayDate, using: dateFormat))
                                .foregroundStyle(colors.textSecondary)
                        }
                    }
                } header: {
                    Text("DUE DATE (OPTIONAL)")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
                }

                if hasDueDate {
                    Section {
                        Toggle("Notify 7 days before", isOn: $notify7DaysBefore)
                        Toggle("Notify 2 days before", isOn: $notify2DaysBefore)
                        Toggle("Notify on due date", isOn: $notifyOnDueDate)

                        Toggle("Notify custom days before", isOn: $notifyCustomDays)

                        if notifyCustomDays {
                            Stepper("Notify \(customDaysCount) day\(customDaysCount == 1 ? "" : "s") before", value: $customDaysCount, in: 1...30)
                        }
                    } header: {
                        Text("NOTIFICATION SETTINGS")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(colors.textSecondary)
                    } footer: {
                        Text("Choose when to be notified about this budget due date")
                    }

                    Section {
                        Toggle("Custom notification time", isOn: $hasCustomNotificationTime)

                        if hasCustomNotificationTime {
                            DatePicker(
                                "Notification Time",
                                selection: Binding(
                                    get: {
                                        Calendar.current.date(from: DateComponents(
                                            hour: notificationTimeHour,
                                            minute: notificationTimeMinute
                                        )) ?? Date()
                                    },
                                    set: { newDate in
                                        let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                        notificationTimeHour = components.hour ?? 9
                                        notificationTimeMinute = components.minute ?? 0
                                    }
                                ),
                                displayedComponents: .hourAndMinute
                            )

                            Text("This category will be notified at this specific time")
                                .font(.caption)
                                .foregroundStyle(colors.textSecondary)
                        }
                    } header: {
                        Text("CUSTOM NOTIFICATION TIME")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(colors.textSecondary)
                    } footer: {
                        if !hasCustomNotificationTime {
                            Text("Using global notification time from Settings")
                        }
                    }
                }

                Section {
                    Text("Category Type: \(categoryType)")
                        .foregroundStyle(colors.textSecondary)
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
                            customDaysCount,
                            hasCustomNotificationTime ? notificationTimeHour : nil,
                            hasCustomNotificationTime ? notificationTimeMinute : nil
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
    @Environment(\.themeColors) private var colors
    @Query private var allCategories: [BudgetCategory]

    let category: BudgetCategory
    let initialAmount: Decimal  // Monthly budgeted amount for current month
    let onSave: (String, Decimal, Int?, Bool, Bool, Bool, Bool, Bool, Int, Int?, Int?) -> Void
    var currencyCode: String = "USD"
    var dateFormat: String = "MM/DD/YYYY"

    @State private var categoryName: String
    @State private var budgetedAmount: Decimal
    @State private var hasDueDate: Bool
    @State private var selectedDay: Int
    @State private var isLastDayOfMonth: Bool
    @State private var notify7DaysBefore: Bool
    @State private var notify2DaysBefore: Bool
    @State private var notifyOnDueDate: Bool
    @State private var notifyCustomDays: Bool
    @State private var customDaysCount: Int
    @State private var hasCustomNotificationTime: Bool
    @State private var notificationTimeHour: Int
    @State private var notificationTimeMinute: Int
    @State private var showingNameError: Bool = false
    @State private var nameErrorMessage: String = ""

    init(category: BudgetCategory, initialAmount: Decimal, currencyCode: String = "USD", dateFormat: String = "MM/DD/YYYY", onSave: @escaping (String, Decimal, Int?, Bool, Bool, Bool, Bool, Bool, Int, Int?, Int?) -> Void) {
        self.category = category
        self.initialAmount = initialAmount
        self.currencyCode = currencyCode
        self.dateFormat = dateFormat
        self.onSave = onSave
        _categoryName = State(initialValue: category.name)
        _budgetedAmount = State(initialValue: initialAmount)

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

        // Initialize custom notification time from category
        if let hour = category.notificationTimeHour, let minute = category.notificationTimeMinute {
            _hasCustomNotificationTime = State(initialValue: true)
            _notificationTimeHour = State(initialValue: hour)
            _notificationTimeMinute = State(initialValue: minute)
        } else {
            _hasCustomNotificationTime = State(initialValue: false)
            _notificationTimeHour = State(initialValue: 9)
            _notificationTimeMinute = State(initialValue: 0)
        }
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
                Section {
                    LabeledContent("Name") {
                        TextField("Category Name", text: $categoryName)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                    }

                    if showingNameError {
                        Text(nameErrorMessage)
                            .font(.caption)
                            .foregroundStyle(colors.error)
                    }

                    LabeledContent("Type") {
                        Text(category.categoryType)
                            .foregroundStyle(colors.textSecondary)
                    }

                    LabeledContent("Budgeted Amount") {
                        TextField("Amount", value: $budgetedAmount, format: .currency(code: currencyCode))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                } header: {
                    Text("CATEGORY DETAILS")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
                }

                Section {
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
                            Text(DateFormatHelpers.formatDate(displayDate, using: dateFormat))
                                .foregroundStyle(colors.textSecondary)
                        }
                    }
                } header: {
                    Text("DUE DATE (OPTIONAL)")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
                }

                if hasDueDate {
                    Section {
                        Toggle("Notify 7 days before", isOn: $notify7DaysBefore)
                        Toggle("Notify 2 days before", isOn: $notify2DaysBefore)
                        Toggle("Notify on due date", isOn: $notifyOnDueDate)

                        Toggle("Notify custom days before", isOn: $notifyCustomDays)

                        if notifyCustomDays {
                            Stepper("Notify \(customDaysCount) day\(customDaysCount == 1 ? "" : "s") before", value: $customDaysCount, in: 1...30)
                        }
                    } header: {
                        Text("NOTIFICATION SETTINGS")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(colors.textSecondary)
                    } footer: {
                        Text("Choose when to be notified about this budget due date")
                    }

                    Section {
                        Toggle("Custom notification time", isOn: $hasCustomNotificationTime)

                        if hasCustomNotificationTime {
                            DatePicker(
                                "Notification Time",
                                selection: Binding(
                                    get: {
                                        Calendar.current.date(from: DateComponents(
                                            hour: notificationTimeHour,
                                            minute: notificationTimeMinute
                                        )) ?? Date()
                                    },
                                    set: { newDate in
                                        let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                        notificationTimeHour = components.hour ?? 9
                                        notificationTimeMinute = components.minute ?? 0
                                    }
                                ),
                                displayedComponents: .hourAndMinute
                            )

                            Text("This category will be notified at this specific time")
                                .font(.caption)
                                .foregroundStyle(colors.textSecondary)
                        }
                    } header: {
                        Text("CUSTOM NOTIFICATION TIME")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(colors.textSecondary)
                    } footer: {
                        if !hasCustomNotificationTime {
                            Text("Using global notification time from Settings")
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
                        if validateName() {
                            onSave(
                                categoryName.trimmingCharacters(in: .whitespaces),
                                budgetedAmount,
                                hasDueDate ? selectedDay : nil,
                                isLastDayOfMonth,
                                notify7DaysBefore,
                                notify2DaysBefore,
                                notifyOnDueDate,
                                notifyCustomDays,
                                customDaysCount,
                                hasCustomNotificationTime ? notificationTimeHour : nil,
                                hasCustomNotificationTime ? notificationTimeMinute : nil
                            )
                        }
                    }
                    .disabled(budgetedAmount < 0)
                }
            }
        }
    }

    // MARK: - Validation

    /// Validates the category name
    /// Returns true if valid, false if invalid (shows error message)
    private func validateName() -> Bool {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespaces)

        // Check for empty name
        if trimmedName.isEmpty {
            showingNameError = true
            nameErrorMessage = "Category name cannot be empty"
            return false
        }

        // Check for duplicate name (only if name changed)
        if trimmedName != category.name {
            let isDuplicate = allCategories.contains { existingCategory in
                existingCategory.name.lowercased() == trimmedName.lowercased() &&
                existingCategory.id != category.id
            }

            if isDuplicate {
                showingNameError = true
                nameErrorMessage = "A category with this name already exists"
                return false
            }
        }

        // Name is valid
        showingNameError = false
        nameErrorMessage = ""
        return true
    }
}

// MARK: - Ordinal Formatter Helper

/// Formats a day number as an ordinal string (1 → "1st", 2 → "2nd", etc.)
func ordinalDay(_ day: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(from: NSNumber(value: day)) ?? "\(day)"
}

#Preview {
    BudgetPlanningView()
        .modelContainer(for: [BudgetCategory.self, Transaction.self, MonthlyBudget.self])
}
