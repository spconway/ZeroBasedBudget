//
//  CategoryComparison.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//

import Foundation

/// Model for comparing budgeted amounts vs actual spending for a category
struct CategoryComparison: Identifiable {
    let id = UUID()
    let categoryName: String
    let categoryColor: String
    let budgeted: Decimal
    let actual: Decimal

    /// Difference between budgeted and actual (positive means under budget)
    var difference: Decimal {
        budgeted - actual
    }

    /// Percentage of budget used (0.0 to 1.0+)
    var percentageUsed: Double {
        guard budgeted > 0 else { return 0 }
        return Double(truncating: (actual / budgeted) as NSDecimalNumber)
    }

    /// Whether spending exceeds budget
    var isOverBudget: Bool {
        actual > budgeted
    }

    /// Percentage remaining (can be negative if over budget)
    var percentageRemaining: Double {
        1.0 - percentageUsed
    }

    /// Formatted percentage used as string
    var percentageUsedFormatted: String {
        let percentage = percentageUsed * 100
        return String(format: "%.1f%%", percentage)
    }
}
