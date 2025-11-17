//
//  AccountRow.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//  Refined design with icon badges and elegant typography
//

import SwiftUI

/// Reusable row component for displaying account information with refined styling
struct AccountRow: View {
    @Environment(\.themeColors) private var colors
    @Environment(\.colorScheme) private var colorScheme

    let account: Account
    var currencyCode: String = "USD"
    var numberFormat: String = "1,234.56"

    var body: some View {
        RefinedListRow(height: 80) {
            HStack(spacing: 16) {
                // Icon badge with account type icon
                RefinedIconBadge(
                    systemName: iconForAccountType(account.accountType),
                    color: colors.primary,
                    size: 44
                )

                // Account info
                VStack(alignment: .leading, spacing: 4) {
                    Text(account.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(colors.textPrimary)

                    if let accountType = account.accountType {
                        Text(accountType)
                            .font(.system(size: 13))
                            .foregroundStyle(colors.textSecondary)
                    }
                }

                Spacer()

                // Balance with light weight for refinement
                Text(CurrencyFormatHelpers.formatCurrency(account.balance, currencyCode: currencyCode, numberFormat: numberFormat))
                    .font(.system(size: 20, weight: .light)) // Light weight for large amounts
                    .monospacedDigit()
                    .foregroundStyle(account.balance >= 0 ? colors.textPrimary : colors.error)
            }
        }
    }

    /// Get appropriate SF Symbol for account type
    private func iconForAccountType(_ type: String?) -> String {
        guard let type = type?.lowercased() else { return "banknote" }

        if type.contains("check") {
            return "building.columns"
        } else if type.contains("sav") {
            return "dollarsign.circle"
        } else if type.contains("credit") || type.contains("card") {
            return "creditcard"
        } else if type.contains("cash") {
            return "banknote"
        } else if type.contains("invest") {
            return "chart.line.uptrend.xyaxis"
        } else {
            return "wallet.pass"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        AccountRow(account: Account(name: "Chase Checking", balance: 2500.00, accountType: "Checking"))
        AccountRow(account: Account(name: "Savings", balance: 10000.50, accountType: "Savings"))
        AccountRow(account: Account(name: "Credit Card", balance: -450.00, accountType: "Credit Card"))
        AccountRow(account: Account(name: "Cash", balance: 85.00, accountType: "Cash"))
    }
    .padding()
}
