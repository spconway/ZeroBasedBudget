//
//  EditAccountSheet.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//

import SwiftUI

/// Sheet for editing an existing account
struct EditAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var account: Account

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
                    TextField("Account Name", text: $account.name)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Account Details")
                }

                Section {
                    TextField("Balance", value: $account.balance, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Current Balance")
                } footer: {
                    Text("Enter your current account balance. Negative balances are allowed (e.g., credit card debt).")
                }

                Section {
                    Picker("Account Type", selection: $account.accountType) {
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
                        dismiss()
                    } label: {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(account.name.isEmpty)
                }
            }
            .navigationTitle("Edit Account")
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
    EditAccountSheet(account: Account(name: "Chase Checking", balance: 2500.00, accountType: "Checking"))
}
