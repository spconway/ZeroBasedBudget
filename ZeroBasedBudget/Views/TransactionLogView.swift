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
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    @Query private var categories: [BudgetCategory]

    @Binding var selectedTab: Int

    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var transactionToEdit: Transaction?

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

    // Transactions with running balance (sorted oldest to newest for calculation)
    private var transactionsWithBalance: [(Transaction, Decimal)] {
        var runningBalance: Decimal = 0
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
                                        .foregroundStyle(.primary)
                                    Text("Budget your income in the Budget tab")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.appAccent)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Display transactions in reverse chronological order with running balance
                ForEach(transactionsWithBalance.reversed(), id: \.0.id) { (transaction, balance) in
                    TransactionRow(transaction: transaction, runningBalance: balance)
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
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search transactions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add Transaction", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTransactionSheet(categories: categories)
            }
            .sheet(item: $transactionToEdit) { transaction in
                EditTransactionSheet(transaction: transaction, categories: categories)
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
        modelContext.delete(transaction)
    }
}

// MARK: - Transaction Row Component

struct TransactionRow: View {
    let transaction: Transaction
    let runningBalance: Decimal

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.transactionDescription)
                        .font(.headline)

                    Text(transaction.category?.name ?? "Uncategorized")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(transaction.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(transaction.amount, format: .currency(code: "USD"))
                        .font(.body.bold())
                        .foregroundStyle(transaction.type == .income ? .appSuccess : .appError)

                    Text(transaction.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Running balance display
            HStack {
                Text("Balance:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(runningBalance, format: .currency(code: "USD"))
                    .font(.caption.bold())
                    .foregroundStyle(runningBalance >= 0 ? .appSuccess : .appError)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Transaction Sheet

struct AddTransactionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let categories: [BudgetCategory]

    @State private var date = Date()
    @State private var description = ""
    @State private var amount = Decimal.zero
    @State private var selectedCategory: BudgetCategory?
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
                    TextField("Amount", value: $amount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)

                    if amount <= 0 {
                        Text("Amount must be greater than zero")
                            .font(.caption)
                            .foregroundStyle(.appError)
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
                            .foregroundStyle(.appWarning)
                    }
                }

                Section("Notes (Optional)") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
            }
        }
    }

    private func saveTransaction() {
        let newTransaction = Transaction(
            date: date,
            amount: amount,
            description: description,
            type: transactionType,
            category: selectedCategory
        )

        if !notes.trimmingCharacters(in: .whitespaces).isEmpty {
            newTransaction.notes = notes
        }

        modelContext.insert(newTransaction)
        dismiss()
    }
}

// MARK: - Edit Transaction Sheet

struct EditTransactionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let transaction: Transaction
    let categories: [BudgetCategory]

    @State private var date: Date
    @State private var description: String
    @State private var amount: Decimal
    @State private var selectedCategory: BudgetCategory?
    @State private var transactionType: TransactionType
    @State private var notes: String

    init(transaction: Transaction, categories: [BudgetCategory]) {
        self.transaction = transaction
        self.categories = categories

        // Initialize state from transaction
        _date = State(initialValue: transaction.date)
        _description = State(initialValue: transaction.transactionDescription)
        _amount = State(initialValue: transaction.amount)
        _selectedCategory = State(initialValue: transaction.category)
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
                    TextField("Amount", value: $amount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)

                    if amount <= 0 {
                        Text("Amount must be greater than zero")
                            .font(.caption)
                            .foregroundStyle(.appError)
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
                            .foregroundStyle(.appWarning)
                    }
                }

                Section("Notes (Optional)") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
            }
        }
    }

    private func updateTransaction() {
        transaction.date = date
        transaction.transactionDescription = description
        transaction.amount = amount
        transaction.category = selectedCategory
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
