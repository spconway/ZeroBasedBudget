//
//  CategoryProgressBar.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/8/25.
//  Refined design with smooth animations and elegant styling
//

import SwiftUI

/// Visual progress indicator for category spending with refined styling
///
/// Color-coded based on spending percentage:
/// - Green: 0-75% (healthy spending)
/// - Yellow: 75-100% (nearing budget)
/// - Red: >100% (over budget)
struct CategoryProgressBar: View {
    @Environment(\.themeColors) private var colors

    let spent: Decimal
    let budgeted: Decimal

    /// Calculate progress percentage (clamped to 0-1 for display)
    private var progress: Double {
        guard budgeted > 0 else { return 0 }
        let percentage = Double(truncating: (spent / budgeted) as NSNumber)
        return min(max(percentage, 0), 1.0) // Clamp for visual display
    }

    /// Color based on spending percentage
    private var progressColor: Color {
        let percentage = Double(truncating: (spent / budgeted) as NSNumber)
        if spent > budgeted {
            return colors.progressRed  // Over budget
        } else if percentage >= 0.75 {
            return colors.progressYellow  // Warning (75-100%)
        } else {
            return colors.progressGreen  // Healthy (0-75%)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track (background)
                RoundedRectangle(cornerRadius: 3)
                    .fill(colors.borderSubtle.opacity(0.25))
                    .frame(height: 6)

                // Progress (foreground)
                RoundedRectangle(cornerRadius: 3)
                    .fill(progressColor)
                    .frame(width: geometry.size.width * progress, height: 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    VStack(spacing: 24) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Healthy Spending (50%)")
                .font(.caption)
            CategoryProgressBar(spent: 250, budgeted: 500)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Warning Zone (85%)")
                .font(.caption)
            CategoryProgressBar(spent: 425, budgeted: 500)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Over Budget (120%)")
                .font(.caption)
            CategoryProgressBar(spent: 600, budgeted: 500)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Not Started (0%)")
                .font(.caption)
            CategoryProgressBar(spent: 0, budgeted: 500)
        }
    }
    .padding()
}
