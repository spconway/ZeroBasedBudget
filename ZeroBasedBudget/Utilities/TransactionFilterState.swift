//
//  TransactionFilterState.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-25.
//

import Foundation
import SwiftData

/// Represents active transaction filter state
struct TransactionFilterState: Equatable {
    var typeFilter: TransactionTypeFilter = .all
    var selectedAccountID: PersistentIdentifier? = nil  // nil = "All Accounts"
    var selectedCategoryID: PersistentIdentifier? = nil  // nil = "All Categories"
    var filterUncategorized: Bool = false  // true = show only uncategorized expenses
    var dateRangeFilter: DateRangeFilter = .allTime
    var customStartDate: Date? = nil
    var customEndDate: Date? = nil

    /// Check if any filters are active (not default "All")
    var hasActiveFilters: Bool {
        typeFilter != .all ||
        selectedAccountID != nil ||
        selectedCategoryID != nil ||
        filterUncategorized ||
        dateRangeFilter != .allTime
    }

    /// Reset all filters to default "All" state
    mutating func reset() {
        typeFilter = .all
        selectedAccountID = nil
        selectedCategoryID = nil
        filterUncategorized = false
        dateRangeFilter = .allTime
        customStartDate = nil
        customEndDate = nil
    }

    /// Human-readable description of active filters
    func activeFilterDescription() -> String {
        var components: [String] = []

        if typeFilter != .all {
            components.append(typeFilter == .income ? "Income" : "Expense")
        }
        // Note: Actual account/category names will be resolved in view

        if let _ = selectedAccountID {
            components.append("[Account]")
        }
        if let _ = selectedCategoryID {
            components.append("[Category]")
        }
        if filterUncategorized {
            components.append("Uncategorized")
        }
        if dateRangeFilter != .allTime {
            components.append(dateRangeFilter.displayName)
        }

        return components.joined(separator: " • ")
    }
}

/// Transaction type filter options
enum TransactionTypeFilter: String, Codable, CaseIterable {
    case all = "All"
    case income = "Income"
    case expense = "Expense"

    var displayName: String { rawValue }
}

/// Date range filter options
enum DateRangeFilter: String, Codable, CaseIterable {
    case allTime = "All Time"
    case thisMonth = "This Month"
    case last30Days = "Last 30 Days"
    case last90Days = "Last 90 Days"
    case customRange = "Custom Range"

    var displayName: String { rawValue }
}
