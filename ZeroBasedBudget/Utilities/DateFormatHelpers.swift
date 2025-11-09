//
//  DateFormatHelpers.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/7/25.
//

import Foundation

/// Centralized date formatting utilities that respect user's date format preference
enum DateFormatHelpers {

    // MARK: - Primary Date Formatting

    /// Formats a date according to user's date format preference
    /// - Parameters:
    ///   - date: The date to format
    ///   - formatPreference: User's date format preference ("MM/DD/YYYY", "DD/MM/YYYY", "YYYY-MM-DD")
    /// - Returns: Formatted date string
    static func formatDate(_ date: Date, using formatPreference: String) -> String {
        let formatter = DateFormatter()

        switch formatPreference {
        case "MM/DD/YYYY":
            formatter.dateFormat = "MM/dd/yyyy"
        case "DD/MM/YYYY":
            formatter.dateFormat = "dd/MM/yyyy"
        case "YYYY-MM-DD":
            formatter.dateFormat = "yyyy-MM-dd"
        default:
            // Fallback to US format
            formatter.dateFormat = "MM/dd/yyyy"
        }

        return formatter.string(from: date)
    }

    /// Formats a date for transaction section headers with smart year handling
    /// Shows abbreviated month and day, includes year only if different from current year
    /// Examples: "Nov 5", "Nov 5, 2024"
    /// - Parameters:
    ///   - date: The date to format
    ///   - formatPreference: User's date format preference ("MM/DD/YYYY", "DD/MM/YYYY", "YYYY-MM-DD")
    /// - Returns: Formatted date string
    static func formatTransactionSectionDate(_ date: Date, using formatPreference: String) -> String {
        let calendar = Calendar.current
        let now = Date()

        // Check if date is in current year
        let dateYear = calendar.component(.year, from: date)
        let currentYear = calendar.component(.year, from: now)
        let includeYear = dateYear != currentYear

        let formatter = DateFormatter()
        formatter.locale = Locale.current

        // Get month and day components
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        // Format based on user preference
        switch formatPreference {
        case "MM/DD/YYYY":
            // US format: "Nov 5" or "Nov 5, 2024"
            formatter.dateFormat = "MMM d"
            let baseString = formatter.string(from: date)
            return includeYear ? "\(baseString), \(dateYear)" : baseString

        case "DD/MM/YYYY":
            // European format: "5 Nov" or "5 Nov 2024"
            formatter.dateFormat = "d MMM"
            let baseString = formatter.string(from: date)
            return includeYear ? "\(baseString) \(dateYear)" : baseString

        case "YYYY-MM-DD":
            // ISO format: "Nov 5" or "2024-Nov-5"
            if includeYear {
                formatter.dateFormat = "yyyy-MMM-d"
                return formatter.string(from: date)
            } else {
                formatter.dateFormat = "MMM d"
                return formatter.string(from: date)
            }

        default:
            // Fallback to US format
            formatter.dateFormat = "MMM d"
            let baseString = formatter.string(from: date)
            return includeYear ? "\(baseString), \(dateYear)" : baseString
        }
    }

    /// Formats a date as month and year for display
    /// Examples: "November 2025", "Nov 2025" (depending on locale)
    /// - Parameters:
    ///   - date: The date to format
    ///   - abbreviated: Whether to use abbreviated month names
    /// - Returns: Formatted month-year string
    static func formatMonthYear(_ date: Date, abbreviated: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = abbreviated ? "MMM yyyy" : "MMMM yyyy"
        return formatter.string(from: date)
    }

    // MARK: - Accessibility Date Formatting

    /// Creates a long-form date string for accessibility (VoiceOver)
    /// Always uses full format regardless of user preference for better accessibility
    /// Example: "November 7, 2025"
    /// - Parameter date: The date to format
    /// - Returns: Long-form date string
    static func accessibilityDateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Creates a month-year string for accessibility (VoiceOver)
    /// Example: "November 2025"
    /// - Parameter date: The date to format
    /// - Returns: Month-year string
    static func accessibilityMonthLabel(for date: Date) -> String {
        return formatMonthYear(date, abbreviated: false)
    }

    // MARK: - Helper Methods

    /// Returns a sample formatted date for display in settings
    /// Uses current date to show user what their format preference looks like
    /// - Parameter formatPreference: User's date format preference
    /// - Returns: Example formatted date
    static func sampleDate(for formatPreference: String) -> String {
        let sampleDate = Date()
        return formatDate(sampleDate, using: formatPreference)
    }
}
