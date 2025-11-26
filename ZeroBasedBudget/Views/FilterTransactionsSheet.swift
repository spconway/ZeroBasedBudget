//
//  FilterTransactionsSheet.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-25.
//

import SwiftUI
import SwiftData

/// Full-screen sheet for filtering transactions by type, account, category, and date range
struct FilterTransactionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var colors

    /// Callback to apply filters when user taps "Apply"
    let onApply: (TransactionFilterState) -> Void

    /// Available categories for picker
    let categories: [BudgetCategory]

    /// Available accounts for picker
    let accounts: [Account]

    /// Working copy of filter state (modified locally, only applied on "Apply")
    @State private var workingFilterState: TransactionFilterState

    /// Selected account name (for picker)
    @State private var selectedAccountName: String

    /// Selected category name (for picker)
    @State private var selectedCategoryName: String

    /// Initialize with current filter state
    init(filterState: TransactionFilterState, categories: [BudgetCategory], accounts: [Account], onApply: @escaping (TransactionFilterState) -> Void) {
        self.categories = categories
        self.accounts = accounts
        self.onApply = onApply
        // Create working copy
        self._workingFilterState = State(initialValue: filterState)

        // Initialize name-based selections from IDs
        if let accountID = filterState.selectedAccountID,
           let account = accounts.first(where: { $0.persistentModelID == accountID }) {
            self._selectedAccountName = State(initialValue: account.name)
        } else {
            self._selectedAccountName = State(initialValue: "All Accounts")
        }

        if filterState.filterUncategorized {
            self._selectedCategoryName = State(initialValue: "Uncategorized")
        } else if let categoryID = filterState.selectedCategoryID,
                  let category = categories.first(where: { $0.persistentModelID == categoryID }) {
            self._selectedCategoryName = State(initialValue: category.name)
        } else {
            self._selectedCategoryName = State(initialValue: "All Categories")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Type Section
                Section {
                    Picker("Transaction Type", selection: $workingFilterState.typeFilter) {
                        ForEach(TransactionTypeFilter.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("TYPE")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
                }

                // MARK: - Account Section
                Section {
                    Picker("Account", selection: $selectedAccountName) {
                        Text("All Accounts").tag("All Accounts")
                        ForEach(accounts.sorted(by: { $0.name < $1.name })) { account in
                            Text(account.name).tag(account.name)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("ACCOUNT")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
                }

                // MARK: - Category Section
                Section {
                    Picker("Category", selection: $selectedCategoryName) {
                        Text("All Categories").tag("All Categories")
                        Text("Uncategorized").tag("Uncategorized")
                        ForEach(categories.sorted(by: { $0.name < $1.name })) { category in
                            HStack {
                                Circle()
                                    .fill(Color(hex: category.colorHex))
                                    .frame(width: 12, height: 12)
                                Text(category.name)
                            }
                            .tag(category.name)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("CATEGORY")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
                } footer: {
                    Text("'Uncategorized' shows expense transactions without a category. Income transactions are excluded as they flow to 'Ready to Assign' per YNAB principles.")
                        .foregroundStyle(colors.textSecondary)
                }

                // MARK: - Date Range Section
                Section {
                    Picker("Date Range", selection: $workingFilterState.dateRangeFilter) {
                        ForEach(DateRangeFilter.allCases, id: \.self) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    .pickerStyle(.menu)

                    // Custom date pickers (only shown when Custom Range selected)
                    if workingFilterState.dateRangeFilter == .customRange {
                        DatePicker("From", selection: Binding(
                            get: { workingFilterState.customStartDate ?? Date() },
                            set: { workingFilterState.customStartDate = $0 }
                        ), displayedComponents: .date)

                        DatePicker("To", selection: Binding(
                            get: { workingFilterState.customEndDate ?? Date() },
                            set: { workingFilterState.customEndDate = $0 }
                        ), displayedComponents: .date)
                    }
                } header: {
                    Text("DATE RANGE")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
                }

                // MARK: - Actions Section (only show Reset when filters active)
                if workingFilterState.hasActiveFilters {
                    Section {
                        Button("Reset All Filters") {
                            workingFilterState.reset()
                            selectedAccountName = "All Accounts"
                            selectedCategoryName = "All Categories"
                        }
                        .foregroundStyle(colors.error)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(colors.background)
            .navigationTitle("Filter Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyFiltersAndDismiss()
                    }
                }
            }
        }
    }

    private func applyFiltersAndDismiss() {
        // Convert name-based selections back to PersistentIdentifier
        if selectedAccountName == "All Accounts" {
            workingFilterState.selectedAccountID = nil
        } else if let account = accounts.first(where: { $0.name == selectedAccountName }) {
            workingFilterState.selectedAccountID = account.persistentModelID
        }

        if selectedCategoryName == "All Categories" {
            workingFilterState.selectedCategoryID = nil
            workingFilterState.filterUncategorized = false
        } else if selectedCategoryName == "Uncategorized" {
            workingFilterState.selectedCategoryID = nil
            workingFilterState.filterUncategorized = true
        } else if let category = categories.first(where: { $0.name == selectedCategoryName }) {
            workingFilterState.selectedCategoryID = category.persistentModelID
            workingFilterState.filterUncategorized = false
        }

        onApply(workingFilterState)
        dismiss()
    }
}
