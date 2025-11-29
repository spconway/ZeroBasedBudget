//
//  CategoryGroup.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-16.
//

import Foundation
import SwiftData

@Model
final class CategoryGroup {
    @Attribute(.unique)
    var name: String

    /// Sort order for displaying groups (lower values appear first)
    var sortOrder: Int

    /// Color hex for visual identification (optional)
    var colorHex: String?

    /// Sort option for categories within this group: "manual", "name", "dueDate"
    /// Optional for backwards compatibility with existing records (defaults to "manual" when nil)
    var categorySortOption: String?

    @Relationship(deleteRule: .nullify, inverse: \BudgetCategory.categoryGroup)
    var categories: [BudgetCategory] = []

    init(name: String, sortOrder: Int, colorHex: String? = nil) {
        self.name = name
        self.sortOrder = sortOrder
        self.colorHex = colorHex
    }

    /// Returns non-Income categories for this group (for display in Budget Planning)
    var expenseCategories: [BudgetCategory] {
        categories.filter { $0.categoryType != "Income" }
    }
}
