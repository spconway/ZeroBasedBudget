//
//  AccountRow.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//

import SwiftUI

/// Reusable row component for displaying account information in a list
struct AccountRow: View {
    let account: Account

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.headline)

                if let accountType = account.accountType {
                    Text(accountType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(account.balance, format: .currency(code: "USD"))
                .font(.body.monospacedDigit())
                .foregroundStyle(account.balance >= 0 ? .primary : .red)
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
