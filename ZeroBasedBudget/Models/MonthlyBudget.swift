//
//  MonthlyBudget.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//

import Foundation
import SwiftData

@Model
final class MonthlyBudget {
    var month: Date  // Store first day of month
    var totalIncome: Decimal
    var fixedExpensesTotal: Decimal
    var variableExpensesTotal: Decimal
    var savingsGoal: Decimal

    @Transient
    var totalBudget: Decimal {
        totalIncome - fixedExpensesTotal - variableExpensesTotal - savingsGoal
    }

    init(month: Date, totalIncome: Decimal) {
        self.month = month
        self.totalIncome = totalIncome
        self.fixedExpensesTotal = 0
        self.variableExpensesTotal = 0
        self.savingsGoal = 0
    }
}
