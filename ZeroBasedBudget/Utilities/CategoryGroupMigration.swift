//
//  CategoryGroupMigration.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-16.
//

import Foundation
import SwiftData

/// Helper for migrating existing categories to user-defined category groups
enum CategoryGroupMigration {

    /// Ensure default category groups exist and migrate existing categories
    /// Call this once during app initialization or first-time setup
    static func ensureDefaultGroupsExist(in context: ModelContext) {
        // Fetch existing groups
        let descriptor = FetchDescriptor<CategoryGroup>()
        let existingGroups = (try? context.fetch(descriptor)) ?? []

        // If we already have groups, assume migration is complete
        guard existingGroups.isEmpty else {
            return
        }

        print("🔄 Creating default category groups...")

        // Create default groups
        let fixedGroup = CategoryGroup(name: "Fixed Expenses", sortOrder: 1)
        let variableGroup = CategoryGroup(name: "Variable Expenses", sortOrder: 2)
        let quarterlyGroup = CategoryGroup(name: "Quarterly Expenses", sortOrder: 3)

        context.insert(fixedGroup)
        context.insert(variableGroup)
        context.insert(quarterlyGroup)

        // Fetch all existing categories
        let categoryDescriptor = FetchDescriptor<BudgetCategory>()
        let categories = (try? context.fetch(categoryDescriptor)) ?? []

        // Migrate categories to appropriate groups
        for category in categories {
            // Skip if already has a group
            if category.categoryGroup != nil {
                continue
            }

            // Assign based on categoryType
            switch category.categoryType {
            case "Fixed":
                category.categoryGroup = fixedGroup
            case "Variable":
                category.categoryGroup = variableGroup
            case "Quarterly":
                category.categoryGroup = quarterlyGroup
            case "Income":
                // Income categories don't belong to expense groups
                // They'll be handled separately in UI
                break
            default:
                // Unknown type - default to Variable
                category.categoryGroup = variableGroup
            }
        }

        // Save changes
        do {
            try context.save()
            print("✅ Category group migration complete")
        } catch {
            print("❌ Failed to save category group migration: \(error)")
        }
    }

    /// Create a new custom category group
    static func createGroup(
        name: String,
        in context: ModelContext
    ) throws -> CategoryGroup {
        // Get next sort order (after existing groups)
        let descriptor = FetchDescriptor<CategoryGroup>(
            sortBy: [SortDescriptor(\.sortOrder, order: .reverse)]
        )
        let existingGroups = (try? context.fetch(descriptor)) ?? []
        let nextSortOrder = (existingGroups.first?.sortOrder ?? 0) + 1

        // Create and insert new group
        let group = CategoryGroup(name: name, sortOrder: nextSortOrder)
        context.insert(group)

        try context.save()

        return group
    }

    /// Delete a category group (moves categories to default group)
    static func deleteGroup(
        _ group: CategoryGroup,
        in context: ModelContext
    ) throws {
        // Find default "Variable Expenses" group as fallback
        let descriptor = FetchDescriptor<CategoryGroup>(
            predicate: #Predicate { $0.name == "Variable Expenses" }
        )
        let fallbackGroup = try context.fetch(descriptor).first

        // Move all categories to fallback group
        for category in group.categories {
            category.categoryGroup = fallbackGroup
        }

        // Delete the group
        context.delete(group)

        try context.save()
    }

    // MARK: - Category Sort Order Migration

    /// Migrate existing categories to have proper sortOrder values
    /// Called once on app launch, checks if migration already done
    /// Assigns sortOrder based on current alphabetical order within each group
    static func migrateCategorySortOrder(in context: ModelContext) {
        let descriptor = FetchDescriptor<CategoryGroup>()
        guard let groups = try? context.fetch(descriptor) else { return }

        var didMigrate = false

        for group in groups {
            // Get expense categories (exclude Income)
            let expenseCategories = group.categories.filter { $0.categoryType != "Income" }

            // Skip empty groups
            guard !expenseCategories.isEmpty else { continue }

            // Check if already migrated: if ANY category has non-zero sortOrder, skip this group
            let needsMigration = expenseCategories.allSatisfy { $0.sortOrder == 0 }
            guard needsMigration else { continue }

            // Assign sortOrder based on current alphabetical order
            let sortedCategories = expenseCategories.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            for (index, category) in sortedCategories.enumerated() {
                category.sortOrder = index
            }

            didMigrate = true
        }

        // Save if any changes were made
        if didMigrate {
            do {
                try context.save()
                print("✅ Category sortOrder migration complete")
            } catch {
                print("❌ Failed to migrate category sortOrder: \(error)")
            }
        }
    }
}
