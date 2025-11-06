//
//  AccountRow.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//

import SwiftUI

/// Reusable row component for displaying account information in a list
struct AccountRow: View {
    @Environment(\.theme) private var theme
    let account: Account
    var currencyCode: String = "USD"

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.headline)
                    .foregroundStyle(theme.colors.textPrimary)

                if let accountType = account.accountType {
                    Text(accountType)
                        .font(.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            Spacer()

            Text(account.balance, format: .currency(code: currencyCode))
                .font(.body.monospacedDigit())
                .foregroundStyle(account.balance >= 0 ? theme.colors.textPrimary : theme.colors.error)
        }
    }
}

#Preview {
    List {
        AccountRow(account: Account(name: "Chase Checking", balance: 2500.00, accountType: "Checking"))
        AccountRow(account: Account(name: "Savings", balance: 10000.50, accountType: "Savings"))
        AccountRow(account: Account(name: "Credit Card", balance: -450.00, accountType: "Credit Card"))
        AccountRow(account: Account(name: "Cash", balance: 85.00, accountType: "Cash"))
    }
}
