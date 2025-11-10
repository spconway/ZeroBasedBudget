//
//  TransactionLogView.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//

import SwiftUI
import SwiftData

struct TransactionLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeColors) private var colors
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    @Query private var categories: [BudgetCategory]
    @Query private var accounts: [Account]
    @Query private var settings: [AppSettings]

    @Binding var selectedTab: Int

    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var showingImportSheet = false
    @State private var transactionToEdit: Transaction?

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

    // Filtered transactions based on search
    private var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return allTransactions
        } else {
            return allTransactions.filter { transaction in
                transaction.transactionDescription.localizedCaseInsensitiveContains(searchText) ||
                transaction.category?.name.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }

    // Transactions with running net worth balance
    // Starts from sum of starting balances, then applies transactions chronologically
    private var transactionsWithBalance: [(Transaction, Decimal)] {
        // Start from total starting balances (before any transactions)
        var runningBalance: Decimal = accounts.reduce(0) { $0 + $1.startingBalance }
        let sortedTransactions = filteredTransactions.sorted(by: { $0.date < $1.date })

        return sortedTransactions.map { transaction in
            if transaction.type == .income {
                runningBalance += transaction.amount
            } else {
                runningBalance -= transaction.amount
            }
            return (transaction, runningBalance)
        }
    }

    // Group transactions by date (newest first)
    private var groupedTransactions: [(Date, [(Transaction, Decimal)])] {
        let grouped = Dictionary(grouping: transactionsWithBalance.reversed()) { transaction in
            Calendar.current.startOfDay(for: transaction.0.date)
        }
        return grouped.sorted { $0.key > $1.key }  // Newest dates first
    }

    // Check if there are any income transactions to show budget reminder
    private var hasIncomeTransactions: Bool {
        allTransactions.contains { $0.type == .income }
    }


    var body: some View {
        NavigationStack {
            List {
                // Quick Assign reminder section (YNAB Enhancement 2.2)
                if hasIncomeTransactions {
                    Section {
                        Button(action: {
                            selectedTab = 0 // Navigate to Budget tab
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Assign Your Income")
                                        .font(.headline)
                                        .foregroundStyle(colors.textPrimary)
                                    Text("Budget your income in the Budget tab")
                                        .font(.caption)
                                        .foregroundStyle(colors.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                    .iconAccent()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Display transactions grouped by date
                ForEach(groupedTransactions, id: \.0) { date, transactions in
                    Section {
                        ForEach(transactions, id: \.0.id) { transaction, balance in
                            TransactionRow(transaction: transaction, runningBalance: balance, currencyCode: currencyCode, dateFormat: dateFormat, numberFormat: numberFormat)
                                .onTapGesture {
                                    transactionToEdit = transaction
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteTransaction(transaction)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    } header: {
                        Text(BudgetCalculations.formatTransactionSectionDate(date, using: dateFormat))
                            .font(.headline)
							.foregroundStyle(colors.textTertiary)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(colors.background)
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text("Transactions")
						.foregroundColor(colors.textPrimary)
				}
			}
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search transactions")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingImportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .iconAccent()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
						Image(systemName: "plus")
							.iconAccent()
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTransactionSheet(categories: categories, currencyCode: currencyCode, numberFormat: numberFormat)
            }
            .sheet(isPresented: $showingImportSheet) {
                ImportTransactionsSheet()
            }
            .sheet(item: $transactionToEdit) { transaction in
                EditTransactionSheet(transaction: transaction, categories: categories, currencyCode: currencyCode, numberFormat: numberFormat)
            }
            .overlay {
                if allTransactions.isEmpty {
                    ContentUnavailableView {
                        Label("No Transactions", systemImage: "list.bullet.rectangle")
                    } description: {
                        Text("Add your first transaction using the + button")
                    }
                }
            }
        }
    }

    private func deleteTransaction(_ transaction: Transaction) {
        // Reverse transaction impact on account balance before deleting
        if let account = transaction.account {
            if transaction.type == .income {
                account.balance -= transaction.amount
            } else {
                account.balance += transaction.amount
            }
        }

        modelContext.delete(transaction)
    }
}

// MARK: - Transaction Row Component

struct TransactionRow: View {
    @Environment(\.themeColors) private var colors
    let transaction: Transaction
    let runningBalance: Decimal
    var currencyCode: String = "USD"
    var dateFormat: String = "MM/DD/YYYY"
    var numberFormat: String = "1,234.56"

    var body: some View {
        VStack(spacing: 4) {
            // Main row: Description and Amount with icon
            HStack(alignment: .center, spacing: 8) {
                // Transaction type icon
                Image(systemName: transaction.type == .income ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.title3)
                    .iconTransactionType(isIncome: transaction.type == .income)

                // Description
                Text(transaction.transactionDescription)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(colors.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 8)

                // Amount
                Text(CurrencyFormatHelpers.formatCurrency(transaction.amount, currencyCode: currencyCode, numberFormat: numberFormat))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(transaction.type == .income ? colors.success : colors.error)
            }

            // Second row: Category badge and Net Worth
            HStack(spacing: 8) {
                // Category badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: transaction.category?.colorHex ?? "999999"))
                        .frame(width: 8, height: 8)
                    Text(transaction.category?.name ?? "Uncategorized")
                        .font(.caption)
                        .foregroundStyle(colors.textSecondary)
                }

                Spacer()

                // Net Worth (compact)
                HStack(spacing: 4) {
                    Text("Net:")
                        .font(.caption2)
                        .foregroundStyle(colors.textTertiary)
                    Text(CurrencyFormatHelpers.formatCurrency(runningBalance, currencyCode: currencyCode, numberFormat: numberFormat))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(runningBalance >= 0 ? colors.success : colors.error)
                }
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    // Accessibility label for VoiceOver - includes all information
    private var accessibilityLabel: String {
        let typeLabel = transaction.type == .income ? "Income" : "Expense"
        let amountText = CurrencyFormatHelpers.formatCurrency(transaction.amount, currencyCode: currencyCode, numberFormat: numberFormat)
        let categoryText = transaction.category?.name ?? "Uncategorized"
        let dateText = DateFormatHelpers.accessibilityDateLabel(for: transaction.date)
        let accountText = transaction.account?.name ?? "No account"
        let netWorthText = CurrencyFormatHelpers.formatCurrency(runningBalance, currencyCode: currencyCode, numberFormat: numberFormat)

        return "\(typeLabel), \(transaction.transactionDescription), \(amountText), Category: \(categoryText), Date: \(dateText), Account: \(accountText), Net worth: \(netWorthText)"
    }
}

// MARK: - Add Transaction Sheet

struct AddTransactionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    @Environment(\.themeColors) private var colors
    @Query private var accounts: [Account]

    let categories: [BudgetCategory]
    var currencyCode: String = "USD"
    var numberFormat: String = "1,234.56"

    @State private var date = Date()
    @State private var description = ""
    @State private var amount = Decimal.zero
    @State private var selectedCategory: BudgetCategory?
    @State private var selectedAccount: Account?
    @State private var transactionType: TransactionType = .expense
    @State private var notes = ""

    private var isValid: Bool {
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        amount > 0 &&
        selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    TextField("Description", text: $description)

                    Picker("Type", selection: $transactionType) {
                        Text("Income").tag(TransactionType.income)
                        Text("Expense").tag(TransactionType.expense)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Amount") {
                    TextField("Amount", value: $amount, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)

                    if amount <= 0 {
                        Text("Amount must be greater than zero")
                            .font(.caption)
                            .foregroundStyle(colors.error)
                    }
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select Category").tag(nil as BudgetCategory?)
                        ForEach(categories.sorted(by: { $0.name < $1.name })) { category in
                            HStack {
                                Circle()
                                    .fill(Color(hex: category.colorHex))
                                    .frame(width: 12, height: 12)
                                Text(category.name)
                            }
                            .tag(category as BudgetCategory?)
                        }
                    }
                    .pickerStyle(.menu)

                    if selectedCategory == nil {
                        Text("Please select a category")
                            .font(.caption)
                            .foregroundStyle(colors.warning)
                    }
                }

                Section("Account") {
                    Picker("Account", selection: $selectedAccount) {
                        Text("Select Account").tag(nil as Account?)
                        ForEach(accounts.sorted(by: { $0.name < $1.name })) { account in
                            Text(account.name).tag(account as Account?)
                        }
                    }
                    .pickerStyle(.menu)

                    if let account = selectedAccount {
                        HStack {
                            Text("Current Balance:")
                                .font(.caption)
                                .foregroundStyle(colors.textSecondary)
                            Spacer()
                            Text(CurrencyFormatHelpers.formatCurrency(account.balance, currencyCode: currencyCode, numberFormat: numberFormat))
                                .font(.caption)
                                .foregroundStyle(account.balance >= 0 ? colors.success : colors.error)
                        }
                    } else {
                        Text("Optional - Select to track account balance")
                            .font(.caption)
                            .foregroundStyle(colors.textSecondary)
                    }
                }

                Section("Notes (Optional)") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollContentBackground(.hidden)
            .background(colors.background)
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(!isValid)
                }
            })
        }
    }

    private func saveTransaction() {
        let newTransaction = Transaction(
            date: date,
            amount: amount,
            description: description,
            type: transactionType,
            category: selectedCategory,
            account: selectedAccount
        )

        if !notes.trimmingCharacters(in: .whitespaces).isEmpty {
            newTransaction.notes = notes
        }

        // Update account balance if account is selected
        if let account = selectedAccount {
            if transactionType == .income {
                account.balance += amount
            } else {
                account.balance -= amount
            }
        }

        modelContext.insert(newTransaction)
        dismiss()
    }
}

// MARK: - Edit Transaction Sheet

struct EditTransactionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    @Environment(\.themeColors) private var colors
    @Query private var accounts: [Account]

    let transaction: Transaction
    let categories: [BudgetCategory]
    var currencyCode: String = "USD"
    var numberFormat: String = "1,234.56"

    @State private var date: Date
    @State private var description: String
    @State private var amount: Decimal
    @State private var selectedCategory: BudgetCategory?
    @State private var selectedAccount: Account?
    @State private var transactionType: TransactionType
    @State private var notes: String

    init(transaction: Transaction, categories: [BudgetCategory], currencyCode: String = "USD", numberFormat: String = "1,234.56") {
        self.transaction = transaction
        self.categories = categories
        self.currencyCode = currencyCode
        self.numberFormat = numberFormat

        // Initialize state from transaction
        _date = State(initialValue: transaction.date)
        _description = State(initialValue: transaction.transactionDescription)
        _amount = State(initialValue: transaction.amount)
        _selectedCategory = State(initialValue: transaction.category)
        _selectedAccount = State(initialValue: transaction.account)
        _transactionType = State(initialValue: transaction.type)
        _notes = State(initialValue: transaction.notes ?? "")
    }

    private var isValid: Bool {
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        amount > 0 &&
        selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    TextField("Description", text: $description)

                    Picker("Type", selection: $transactionType) {
                        Text("Income").tag(TransactionType.income)
                        Text("Expense").tag(TransactionType.expense)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Amount") {
                    TextField("Amount", value: $amount, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)

                    if amount <= 0 {
                        Text("Amount must be greater than zero")
                            .font(.caption)
                            .foregroundStyle(colors.error)
                    }
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select Category").tag(nil as BudgetCategory?)
                        ForEach(categories.sorted(by: { $0.name < $1.name })) { category in
                            HStack {
                                Circle()
                                    .fill(Color(hex: category.colorHex))
                                    .frame(width: 12, height: 12)
                                Text(category.name)
                            }
                            .tag(category as BudgetCategory?)
                        }
                    }
                    .pickerStyle(.menu)

                    if selectedCategory == nil {
                        Text("Please select a category")
                            .font(.caption)
                            .foregroundStyle(colors.warning)
                    }
                }

                Section("Account") {
                    Picker("Account", selection: $selectedAccount) {
                        Text("Select Account").tag(nil as Account?)
                        ForEach(accounts.sorted(by: { $0.name < $1.name })) { account in
                            Text(account.name).tag(account as Account?)
                        }
                    }
                    .pickerStyle(.menu)

                    if let account = selectedAccount {
                        HStack {
                            Text("Current Balance:")
                                .font(.caption)
                                .foregroundStyle(colors.textSecondary)
                            Spacer()
                            Text(CurrencyFormatHelpers.formatCurrency(account.balance, currencyCode: currencyCode, numberFormat: numberFormat))
                                .font(.caption)
                                .foregroundStyle(account.balance >= 0 ? colors.success : colors.error)
                        }
                    } else {
                        Text("Optional - Select to track account balance")
                            .font(.caption)
                            .foregroundStyle(colors.textSecondary)
                    }
                }

                Section("Notes (Optional)") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollContentBackground(.hidden)
            .background(colors.background)
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateTransaction()
                    }
                    .disabled(!isValid)
                }
            })
        }
    }

    private func updateTransaction() {
        // Step 1: Reverse the old transaction's impact on the old account
        if let oldAccount = transaction.account {
            if transaction.type == .income {
                oldAccount.balance -= transaction.amount
            } else {
                oldAccount.balance += transaction.amount
            }
        }

        // Step 2: Apply the new transaction to the new account
        if let newAccount = selectedAccount {
            if transactionType == .income {
                newAccount.balance += amount
            } else {
                newAccount.balance -= amount
            }
        }

        // Step 3: Update transaction properties
        transaction.date = date
        transaction.transactionDescription = description
        transaction.amount = amount
        transaction.category = selectedCategory
        transaction.account = selectedAccount
        transaction.type = transactionType
        transaction.notes = notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes

        dismiss()
    }
}

#Preview {
    @Previewable @State var selectedTab = 1
    TransactionLogView(selectedTab: $selectedTab)
        .modelContainer(for: [Transaction.self, BudgetCategory.self])
}
