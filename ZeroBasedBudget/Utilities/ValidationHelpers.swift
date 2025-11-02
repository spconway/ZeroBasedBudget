//
//  ValidationHelpers.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//

import Foundation

/// Validation utilities for user input
enum ValidationHelpers {

    // MARK: - Text Validation

    /// Validates that a string is not empty after trimming whitespace
    static func isValidName(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Validates category name (not empty, reasonable length)
    static func isValidCategoryName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.count <= 50
    }

    /// Validates transaction description (not empty, reasonable length)
    static func isValidDescription(_ description: String) -> Bool {
        let trimmed = description.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.count <= 200
    }

    // MARK: - Monetary Validation

    /// Validates that a monetary amount is positive
    static func isValidAmount(_ amount: Decimal) -> Bool {
        amount > 0
    }

    /// Validates that a monetary amount is non-negative (allows zero)
    static func isValidNonNegativeAmount(_ amount: Decimal) -> Bool {
        amount >= 0
    }

    /// Validates that a monetary amount is within a reasonable range
    static func isReasonableAmount(_ amount: Decimal) -> Bool {
        amount >= 0 && amount <= 1_000_000_000 // Up to 1 billion
    }

    // MARK: - Error Messages

    /// Returns user-friendly error message for invalid category name
    static func categoryNameError(for name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return "Category name cannot be empty"
        }
        if trimmed.count > 50 {
            return "Category name must be 50 characters or less"
        }
        return nil
    }

    /// Returns user-friendly error message for invalid description
    static func descriptionError(for description: String) -> String? {
        let trimmed = description.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return "Description cannot be empty"
        }
        if trimmed.count > 200 {
            return "Description must be 200 characters or less"
        }
        return nil
    }

    /// Returns user-friendly error message for invalid amount
    static func amountError(for amount: Decimal) -> String? {
        if amount <= 0 {
            return "Amount must be greater than zero"
        }
        if amount > 1_000_000_000 {
            return "Amount exceeds maximum allowed value"
        }
        return nil
    }

    // MARK: - Formatting Helpers

    /// Formats Decimal for display with 2 decimal places
    static func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }

    /// Formats percentage for display
    static func formatPercentage(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "0.0%"
    }
}

// MARK: - Custom Errors

/// Domain-specific errors for the budget app
enum BudgetError: LocalizedError {
    case invalidCategoryName(String)
    case invalidAmount(String)
    case invalidDescription(String)
    case duplicateCategory(String)
    case categoryNotFound
    case transactionNotFound
    case persistenceError(String)

    var errorDescription: String? {
        switch self {
        case .invalidCategoryName(let message):
            return message
        case .invalidAmount(let message):
            return message
        case .invalidDescription(let message):
            return message
        case .duplicateCategory(let name):
            return "A category named '\(name)' already exists"
        case .categoryNotFound:
            return "Category not found"
        case .transactionNotFound:
            return "Transaction not found"
        case .persistenceError(let message):
            return "Failed to save data: \(message)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidCategoryName:
            return "Please enter a valid category name (1-50 characters)"
        case .invalidAmount:
            return "Please enter a positive amount"
        case .invalidDescription:
            return "Please enter a valid description (1-200 characters)"
        case .duplicateCategory:
            return "Please choose a different name for this category"
        case .categoryNotFound, .transactionNotFound:
            return "Please try refreshing the view"
        case .persistenceError:
            return "Please try again or restart the app"
        }
    }
}
