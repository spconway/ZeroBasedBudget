//
//  ReadyToAssignBanner.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//  Refined design with elegant typography and clean layout
//

import SwiftUI

/// Refined banner showing Ready to Assign amount with minimalist styling
///
/// YNAB Principle: Ready to Assign = Total money in accounts - Money assigned to categories
/// Goal: Get this to $0 (all money has been given a job)
struct ReadyToAssignBanner: View {
    @Environment(\.themeColors) private var colors
    @Environment(\.colorScheme) private var colorScheme

    let amount: Decimal
    let color: Color
    var currencyCode: String = "USD"
    var numberFormat: String = "1,234.56"

    var body: some View {
        RefinedCard(padding: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("READY TO ASSIGN")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(colors.textSecondary)
                        .tracking(0.8)

                    Text(CurrencyFormatHelpers.formatCurrency(amount, currencyCode: currencyCode, numberFormat: numberFormat))
                        .font(.system(size: 32, weight: .light)) // Light weight for elegance
                        .foregroundStyle(color)
                        .monospacedDigit()
                }

                Spacer()

                // Info button for explanation
                Button {
                    // Could show explainer sheet in future
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
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
    .background(Color(hex: "#FAFBFC"))
}
