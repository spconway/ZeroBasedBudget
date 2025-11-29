//
//  MonthlyBudget.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//  Updated for ZeroBudget methodology on 2025-11-02.
//

import Foundation
import SwiftData

/// ZeroBudget-Style Monthly Budget Model
///
/// This model stores the user's starting balance for each month.
/// Following ZeroBudget methodology, this represents the money the user has RIGHT NOW
/// at the beginning of the month, not expected future income.
///
/// Budget calculations (totalIncome, totalAssigned, readyToAssign) are performed
/// in the view layer where access to transactions and categories is available.
///
/// Key ZeroBudget Principles:
/// - startingBalance: Money available at the start of the month (actual, not projected)
/// - Income is tracked through Transaction entries (not stored here)
/// - Category assignments are tracked through BudgetCategory models
/// - Ready to Assign = (startingBalance + income from transactions) - total assigned
@Model
final class MonthlyBudget {
    /// First day of the month this budget represents
    var month: Date

    /// Starting balance - the money available at the beginning of this month
    /// This represents actual money in accounts RIGHT NOW, following ZeroBudget's principle
    /// of "budget only money you currently have"
    var startingBalance: Decimal

    /// Optional notes about this month's budget
    var notes: String?

    init(month: Date, startingBalance: Decimal = 0) {
        self.month = month
        self.startingBalance = startingBalance
        self.notes = nil
    }
}
