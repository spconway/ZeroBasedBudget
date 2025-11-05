//
//  AddAccountSheet.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//

import SwiftUI
import SwiftData

/// Sheet for adding a new account
struct AddAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [AppSettings]
    let onSave: (String, Decimal, String?) -> Void

    @State private var accountName = ""
    @State private var accountBalance: Decimal = 0
    @State private var accountType: String? = nil

    /// Currency code from settings
    private var currencyCode: String {
        settings.first?.currencyCode ?? "USD"
    }

    /// Available account types
    private let accountTypes: [String?] = [
        nil,
        "Checking",
        "Savings",
        "Cash",
        "Credit Card",
        "Investment"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Account Name", text: $accountName)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Account Details")
                }

                Section {
                    TextField("Balance", value: $accountBalance, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Current Balance")
                } footer: {
                    Text("Enter your current account balance. Negative balances are allowed (e.g., credit card debt).")
                }

                Section {
                    Picker("Account Type", selection: $accountType) {
                        Text("None").tag(nil as String?)
                        ForEach(accountTypes.compactMap { $0 }, id: \.self) { type in
                            Text(type).tag(type as String?)
                        }
                    }
                } header: {
                    Text("Type (Optional)")
                }

                Section {
                    Button {
                        onSave(accountName, accountBalance, accountType)
                        dismiss()
                    } label: {
                        Text("Save Account")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(accountName.isEmpty)
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddAccountSheet { name, balance, type in
        print("Account: \(name), Balance: \(balance), Type: \(type ?? "None")")
    }
}
