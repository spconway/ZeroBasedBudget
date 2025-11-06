//
//  ReadyToAssignBanner.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//

import SwiftUI

/// Simple, compact banner showing Ready to Assign amount
///
/// YNAB Principle: Ready to Assign = Total money in accounts - Money assigned to categories
/// Goal: Get this to $0 (all money has been given a job)
struct ReadyToAssignBanner: View {
    @Environment(\.theme) private var theme

    let amount: Decimal
    let color: Color
    var currencyCode: String = "USD"

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Ready to Assign")
                    .font(.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)

                Text(amount, format: .currency(code: currencyCode))
                    .font(.title2.bold())
                    .foregroundStyle(color)
            }

            Spacer()

            // Info button for explanation (optional)
            Button {
                // Could show explainer sheet in future
            } label: {
                Image(systemName: "info.circle")
                    .iconNeutral()
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(theme.colors.readyToAssignBackground)
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Zero balance (goal state)
        ReadyToAssignBanner(amount: 0, color: .green)

        // Positive balance (needs assignment)
        ReadyToAssignBanner(amount: 1500.50, color: .orange)

        // Negative balance (over-assigned)
        ReadyToAssignBanner(amount: -250.00, color: .red)
    }
    .padding()
}
