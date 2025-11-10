//
//  ImportColumnMappingSheet.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/9/25.
//

import SwiftUI
import SwiftData

struct ImportColumnMappingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.modelContext) private var modelContext

    let headers: [String]
    let rows: [[String]]
    let fileURL: URL
    let onDismissAll: () -> Void

    @State private var selectedAccount: Account?
    @State private var showingAccountPicker = false

    // Column mappings (CSV column name -> Transaction field)
    @State private var dateColumn: String = ""
    @State private var descriptionColumn: String = ""
    @State private var debitColumn: String = ""
    @State private var creditColumn: String = ""
    @State private var amountColumn: String = ""
    @State private var notesColumn: String = ""

    @State private var showingResults = false
    @State private var importResult: ImportManager.ImportResult?
    @State private var showingValidationError = false
    @State private var validationErrorMessage = ""

    @Query private var accounts: [Account]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Instructions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Map CSV Columns")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(themeColors.textPrimary)

                        Text("Match your CSV columns to transaction fields. Required fields are marked with *")
                            .font(.subheadline)
                            .foregroundStyle(themeColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Account selection (REQUIRED)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Account")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(themeColors.textPrimary)
                            Text("*")
                                .foregroundStyle(themeColors.error)
                        }

                        Button(action: {
                            showingAccountPicker = true
                        }) {
                            HStack {
                                if let account = selectedAccount {
                                    Image(systemName: "banknote")
                                        .iconPrimary()
                                    Text(account.name)
                                        .foregroundStyle(themeColors.textPrimary)
                                } else {
                                    Text("Select Account")
                                        .foregroundStyle(themeColors.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .iconNeutral()
                            }
                            .padding()
                            .background(themeColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal)

                    Divider()

                    // Column mappings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Column Mappings")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(themeColors.textPrimary)
                            .padding(.horizontal)

                        // Date (required)
                        ColumnMappingRow(
                            label: "Date",
                            required: true,
                            selection: $dateColumn,
                            options: [""] + headers
                        )

                        // Description (required)
                        ColumnMappingRow(
                            label: "Description",
                            required: true,
                            selection: $descriptionColumn,
                            options: [""] + headers
                        )

                        // Amount OR Debit/Credit (at least one required)
                        Text("Amount (choose one approach):")
                            .font(.caption)
                            .foregroundStyle(themeColors.textSecondary)
                            .padding(.horizontal)

                        ColumnMappingRow(
                            label: "Single Amount Column",
                            required: false,
                            selection: $amountColumn,
                            options: [""] + headers
                        )

                        Text("OR")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(themeColors.textSecondary)
                            .padding(.horizontal)

                        ColumnMappingRow(
                            label: "Debit (Expenses)",
                            required: false,
                            selection: $debitColumn,
                            options: [""] + headers
                        )

                        ColumnMappingRow(
                            label: "Credit (Income)",
                            required: false,
                            selection: $creditColumn,
                            options: [""] + headers
                        )

                        Divider()
                            .padding(.horizontal)

                        // Optional fields
                        Text("Optional Fields")
                            .font(.caption)
                            .foregroundStyle(themeColors.textSecondary)
                            .padding(.horizontal)

                        ColumnMappingRow(
                            label: "Notes",
                            required: false,
                            selection: $notesColumn,
                            options: [""] + headers
                        )
                    }

                    Divider()

                    // Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preview (first 3 rows)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(themeColors.textPrimary)
                            .padding(.horizontal)

                        ForEach(Array(rows.prefix(3).enumerated()), id: \.offset) { index, row in
                            PreviewRow(
                                rowNumber: index + 1,
                                row: row,
                                headers: headers,
                                dateColumn: dateColumn,
                                descriptionColumn: descriptionColumn,
                                debitColumn: debitColumn,
                                creditColumn: creditColumn,
                                amountColumn: amountColumn
                            )
                        }
                    }

                    // Import button
                    Button(action: performImport) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import Transactions")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeColors.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
            .background(themeColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundStyle(themeColors.primary)
                }
            }
            .sheet(isPresented: $showingAccountPicker) {
                AccountPickerSheet(selectedAccount: $selectedAccount)
            }
            .sheet(isPresented: $showingResults) {
                if let result = importResult, let account = selectedAccount {
                    ImportResultsSheet(result: result, account: account, onDismissAll: onDismissAll)
                }
            }
            .alert("Invalid Mapping", isPresented: $showingValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationErrorMessage)
            }
            .onAppear {
                applyFuzzyMatching()
                selectDefaultAccount()
            }
        }
    }

    // MARK: - Fuzzy Matching

    private func applyFuzzyMatching() {
        let suggested = ImportManager.suggestColumnMapping(headers: headers)

        dateColumn = suggested.date ?? ""
        descriptionColumn = suggested.description ?? ""
        debitColumn = suggested.debit ?? ""
        creditColumn = suggested.credit ?? ""
        amountColumn = suggested.amount ?? ""
        notesColumn = suggested.notes ?? ""
    }

    private func selectDefaultAccount() {
        // Select first account by default if available
        selectedAccount = accounts.first
    }

    // MARK: - Validation & Import

    private func performImport() {
        // Validate required fields
        guard !dateColumn.isEmpty else {
            validationErrorMessage = "Date column is required"
            showingValidationError = true
            return
        }

        guard !descriptionColumn.isEmpty else {
            validationErrorMessage = "Description column is required"
            showingValidationError = true
            return
        }

        guard !amountColumn.isEmpty || (!debitColumn.isEmpty && !creditColumn.isEmpty) else {
            validationErrorMessage = "You must map either a single Amount column OR both Debit and Credit columns"
            showingValidationError = true
            return
        }

        guard let account = selectedAccount else {
            validationErrorMessage = "Please select an account to import into"
            showingValidationError = true
            return
        }

        // Build column mapping
        let mapping = ImportManager.ColumnMapping(
            date: dateColumn.isEmpty ? nil : dateColumn,
            description: descriptionColumn.isEmpty ? nil : descriptionColumn,
            debit: debitColumn.isEmpty ? nil : debitColumn,
            credit: creditColumn.isEmpty ? nil : creditColumn,
            amount: amountColumn.isEmpty ? nil : amountColumn,
            type: nil,
            notes: notesColumn.isEmpty ? nil : notesColumn
        )

        // Perform import
        let result = ImportManager.convertToTransactions(
            headers: headers,
            rows: rows,
            columnMapping: mapping,
            selectedAccount: account,
            modelContext: modelContext
        )

        importResult = result
        showingResults = true
    }
}

// MARK: - Column Mapping Row

struct ColumnMappingRow: View {
    @Environment(\.themeColors) private var themeColors

    let label: String
    let required: Bool
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(themeColors.textPrimary)
                if required {
                    Text("*")
                        .foregroundStyle(themeColors.error)
                }
            }

            Picker(label, selection: $selection) {
                Text("(not mapped)").tag("")
                ForEach(options.filter { !$0.isEmpty }, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .padding(10)
            .background(themeColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview Row

struct PreviewRow: View {
    @Environment(\.themeColors) private var themeColors

    let rowNumber: Int
    let row: [String]
    let headers: [String]
    let dateColumn: String
    let descriptionColumn: String
    let debitColumn: String
    let creditColumn: String
    let amountColumn: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Row \(rowNumber)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(themeColors.textSecondary)

            VStack(alignment: .leading, spacing: 4) {
                if let dateIndex = headers.firstIndex(of: dateColumn),
                   row.indices.contains(dateIndex) {
                    HStack {
                        Text("Date:")
                            .font(.caption)
                            .foregroundStyle(themeColors.textSecondary)
                        Text(row[dateIndex])
                            .font(.caption)
                            .foregroundStyle(themeColors.textPrimary)
                    }
                }

                if let descIndex = headers.firstIndex(of: descriptionColumn),
                   row.indices.contains(descIndex) {
                    HStack {
                        Text("Description:")
                            .font(.caption)
                            .foregroundStyle(themeColors.textSecondary)
                        Text(row[descIndex])
                            .font(.caption)
                            .foregroundStyle(themeColors.textPrimary)
                            .lineLimit(1)
                    }
                }

                // Show amount from either single column or debit/credit
                if !amountColumn.isEmpty,
                   let amountIndex = headers.firstIndex(of: amountColumn),
                   row.indices.contains(amountIndex) {
                    HStack {
                        Text("Amount:")
                            .font(.caption)
                            .foregroundStyle(themeColors.textSecondary)
                        Text(row[amountIndex])
                            .font(.caption)
                            .foregroundStyle(themeColors.textPrimary)
                    }
                } else {
                    if !debitColumn.isEmpty,
                       let debitIndex = headers.firstIndex(of: debitColumn),
                       row.indices.contains(debitIndex),
                       !row[debitIndex].isEmpty {
                        HStack {
                            Text("Debit:")
                                .font(.caption)
                                .foregroundStyle(themeColors.textSecondary)
                            Text(row[debitIndex])
                                .font(.caption)
                                .foregroundStyle(themeColors.error)
                        }
                    }

                    if !creditColumn.isEmpty,
                       let creditIndex = headers.firstIndex(of: creditColumn),
                       row.indices.contains(creditIndex),
                       !row[creditIndex].isEmpty {
                        HStack {
                            Text("Credit:")
                                .font(.caption)
                                .foregroundStyle(themeColors.textSecondary)
                            Text(row[creditIndex])
                                .font(.caption)
                                .foregroundStyle(themeColors.success)
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}

// MARK: - Account Picker Sheet

struct AccountPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Query private var accounts: [Account]

    @Binding var selectedAccount: Account?

    var body: some View {
        NavigationStack {
            List {
                ForEach(accounts) { account in
                    Button(action: {
                        selectedAccount = account
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "banknote")
                                .iconPrimary()
                            Text(account.name)
                                .foregroundStyle(themeColors.textPrimary)
                            Spacer()
                            if selectedAccount?.id == account.id {
                                Image(systemName: "checkmark")
                                    .iconSuccess()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(themeColors.primary)
                }
            }
        }
    }
}

#Preview {
    let sampleHeaders = ["Date", "Description", "Debit", "Credit", "Account Number"]
    let sampleRows = [
        ["2025-11-07", "L A FITNESS 9492558100", "10", "", "8247596915"],
        ["2025-11-06", "AMAZON.COM", "45.99", "", "8247596915"],
        ["2025-11-05", "PAYCHECK DEPOSIT", "", "2500", "8247596915"]
    ]

    return ImportColumnMappingSheet(
        headers: sampleHeaders,
        rows: sampleRows,
        fileURL: URL(fileURLWithPath: "/tmp/test.csv"),
        onDismissAll: {}
    )
    .modelContainer(for: [Transaction.self, BudgetCategory.self, MonthlyBudget.self, Account.self], inMemory: true)
    .environment(ThemeManager())
}
