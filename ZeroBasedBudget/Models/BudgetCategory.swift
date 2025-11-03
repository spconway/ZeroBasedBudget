//
//  BudgetCategory.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//

import Foundation
import SwiftData

@Model
final class BudgetCategory {
    @Attribute(.unique)
    var name: String
    var budgetedAmount: Decimal
    var categoryType: String  // "Fixed", "Variable", "Quarterly", "Income"
    var colorHex: String
    var dueDate: Date?  // Optional due date for expense tracking
    var notificationID: UUID  // UUID for notification tracking

    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction] = []

    init(name: String, budgetedAmount: Decimal, categoryType: String, colorHex: String, dueDate: Date? = nil) {
        self.name = name
        self.budgetedAmount = budgetedAmount
        self.categoryType = categoryType
        self.colorHex = colorHex
        self.dueDate = dueDate
        self.notificationID = UUID()
    }
}
