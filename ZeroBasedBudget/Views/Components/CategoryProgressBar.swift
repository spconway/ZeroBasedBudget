//
//  CategoryProgressBar.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-06.
//  Enhancement 7.2: Visual progress indicator for category spending
//

import SwiftUI

/// Visual progress bar showing spending against budgeted amount
/// Color-coded: Green (0-75%), Yellow (75-100%), Red (>100%)
struct CategoryProgressBar: View {
    @Environment(.theme) private var theme
    let spent: Decimal
    let budgeted: Decimal

    /// Calculate progress percentage, clamping negative values to 0
    /// For display purposes, clamp at 100% (overflow handled by color)
    private var percentage: Double {
        guard budgeted > 0 else { return 0 }
        let value = Double(truncating: (spent / budgeted) as NSNumber)
        return min(max(value, 0), 1.0) // Clamp between 0 and 1 for visual display
    }

    /// Determine progress bar color based on spending percentage
    /// - Green (0-75%): Healthy spending within budget
    /// - Yellow (75-100%): Approaching limit, caution advised
    /// - Red (>100%): Overspent, exceeds budget
    private var progressColor: Color {
        let rawPercentage = budgeted > 0 ? Double(truncating: (spent / budgeted) as NSNumber) : 0

        if rawPercentage >= 1.0 {
            return theme.colors.error // Overspent (red)
        } else if rawPercentage >= 0.75 {
            return theme.colors.warning // Approaching limit (yellow/orange)
        } else {
            return theme.colors.success // Healthy (green)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(theme.colors.borderSubtle.opacity(0.3))
                    .frame(height: 6)

                // Progress fill with smooth animation
                RoundedRectangle(cornerRadius: 4)
                    .fill(progressColor)
                    .frame(width: geometry.size.width * percentage, height: 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: percentage)
            }
        }
        .frame(height: 6)
        .accessibilityLabel("Spending progress")
        .accessibilityValue("\(Int(percentage * 100))% of budget used")
    }
}

// MARK: - Preview

#Preview("No Spending") {
    VStack(spacing: 20) {
        VStack(alignment: .leading) {
            Text("No Spending (0%)")
                .font(.caption)
            CategoryProgressBar(spent: 0, budgeted: 500)
        }
        .padding()
    }
}

#Preview("Partial Spending") {
    VStack(spacing: 20) {
        VStack(alignment: .leading) {
            Text("25% Spent")
                .font(.caption)
            CategoryProgressBar(spent: 125, budgeted: 500)
        }

        VStack(alignment: .leading) {
            Text("50% Spent")
                .font(.caption)
            CategoryProgressBar(spent: 250, budgeted: 500)
        }

        VStack(alignment: .leading) {
            Text("75% Spent (Warning Threshold)")
                .font(.caption)
            CategoryProgressBar(spent: 375, budgeted: 500)
        }
        .padding()
    }
}

#Preview("Full and Overspending") {
    VStack(spacing: 20) {
        VStack(alignment: .leading) {
            Text("90% Spent (Yellow)")
                .font(.caption)
            CategoryProgressBar(spent: 450, budgeted: 500)
        }

        VStack(alignment: .leading) {
            Text("100% Spent")
                .font(.caption)
            CategoryProgressBar(spent: 500, budgeted: 500)
        }

        VStack(alignment: .leading) {
            Text("125% Spent (Overspent - Red)")
                .font(.caption)
            CategoryProgressBar(spent: 625, budgeted: 500)
        }
        .padding()
    }
}

#Preview("Edge Cases") {
    VStack(spacing: 20) {
        VStack(alignment: .leading) {
            Text("Zero Budget (YNAB allows this)")
                .font(.caption)
            CategoryProgressBar(spent: 100, budgeted: 0)
        }

        VStack(alignment: .leading) {
            Text("Negative Spending (Refund)")
                .font(.caption)
            CategoryProgressBar(spent: -50, budgeted: 500)
        }

        VStack(alignment: .leading) {
            Text("Large Overspending (200%)")
                .font(.caption)
            CategoryProgressBar(spent: 1000, budgeted: 500)
        }
        .padding()
    }
}
