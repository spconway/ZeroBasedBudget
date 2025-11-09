//
//  CurrencyFormatHelpers.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/7/25.
//

import Foundation

/// Centralized currency formatting utilities that respect user's number format preference
enum CurrencyFormatHelpers {

    // MARK: - Primary Currency Formatting

    /// Formats a currency amount according to user's number format preference
    /// - Parameters:
    ///   - amount: The decimal amount to format
    ///   - currencyCode: The ISO currency code (e.g., "USD", "EUR", "GBP")
    ///   - numberFormat: User's number format preference ("1,234.56", "1.234,56", "1 234,56")
    /// - Returns: Formatted currency string
    static func formatCurrency(_ amount: Decimal, currencyCode: String, numberFormat: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode

        // Configure separators based on user preference
        switch numberFormat {
        case "1,234.56":
            // US format: comma for thousands, period for decimal
            formatter.currencyDecimalSeparator = "."
            formatter.currencyGroupingSeparator = ","

        case "1.234,56":
            // European format: period for thousands, comma for decimal
            formatter.currencyDecimalSeparator = ","
            formatter.currencyGroupingSeparator = "."

        case "1 234,56":
            // Space format: space for thousands, comma for decimal
            formatter.currencyDecimalSeparator = ","
            formatter.currencyGroupingSeparator = " "

        default:
            // Fallback to US format
            formatter.currencyDecimalSeparator = "."
            formatter.currencyGroupingSeparator = ","
        }

        // Format the amount
        return formatter.string(from: amount as NSDecimalNumber) ?? formatFallback(amount, currencyCode: currencyCode)
    }

    // MARK: - Helper Methods

    /// Returns the decimal separator for a given number format
    /// - Parameter numberFormat: User's number format preference
    /// - Returns: Decimal separator character ("." or ",")
    static func decimalSeparator(for numberFormat: String) -> String {
        switch numberFormat {
        case "1,234.56":
            return "."
        case "1.234,56", "1 234,56":
            return ","
        default:
            return "."
        }
    }

    /// Returns the grouping separator for a given number format
    /// - Parameter numberFormat: User's number format preference
    /// - Returns: Grouping separator character (",", ".", or " ")
    static func groupingSeparator(for numberFormat: String) -> String {
        switch numberFormat {
        case "1,234.56":
            return ","
        case "1.234,56":
            return "."
        case "1 234,56":
            return " "
        default:
            return ","
        }
    }

    /// Fallback formatting if NumberFormatter fails
    /// - Parameters:
    ///   - amount: The decimal amount
    ///   - currencyCode: The currency code
    /// - Returns: Simple formatted string
    private static func formatFallback(_ amount: Decimal, currencyCode: String) -> String {
        let symbol = currencySymbol(for: currencyCode)
        return "\(symbol)\(amount)"
    }

    /// Returns the currency symbol for a given currency code
    /// - Parameter currencyCode: The ISO currency code
    /// - Returns: Currency symbol (e.g., "$", "€", "£")
    private static func currencySymbol(for currencyCode: String) -> String {
        let locale = NSLocale(localeIdentifier: currencyCode)
        return locale.displayName(forKey: .currencySymbol, value: currencyCode) ?? currencyCode
    }

    // MARK: - Sample/Preview Helpers

    /// Returns a sample formatted currency for display in settings
    /// Uses a standard amount to show user what their format preference looks like
    /// - Parameters:
    ///   - numberFormat: User's number format preference
    ///   - currencyCode: The currency code to use
    /// - Returns: Example formatted currency
    static func sampleCurrency(for numberFormat: String, currencyCode: String = "USD") -> String {
        let sampleAmount: Decimal = 1234.56
        return formatCurrency(sampleAmount, currencyCode: currencyCode, numberFormat: numberFormat)
    }
}
