//
//  EditAccountSheet.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//

import SwiftUI
import SwiftData

/// Sheet for editing an existing account
struct EditAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var colors
    @Query private var settings: [AppSettings]
    @Bindable var account: Account

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
                    TextField("Account Name", text: $account.name)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("ACCOUNT DETAILS")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
                }

                Section {
                    TextField("Balance", value: $account.balance, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                } header: {
                    Text("CURRENT BALANCE")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
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
                    Text("TYPE (OPTIONAL)")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
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
            .scrollContentBackground(.hidden)
            .background(colors.background)
            .navigationTitle("Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
