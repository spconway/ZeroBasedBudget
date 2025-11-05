//
//  DataExporter.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//  Enhancement 3.2: Data export functionality
//

import Foundation
import SwiftData

/// Utility for exporting budget data in CSV and JSON formats
struct DataExporter {

    // MARK: - CSV Export

    /// Export budget categories for a specific month to CSV format
    /// - Parameters:
    ///   - categories: Budget categories to export
    ///   - yearMonth: Year-month identifier (e.g., "2025-11")
    /// - Returns: CSV data that can be saved or shared
    static func exportCategoriesCSV(categories: [BudgetCategory], yearMonth: String) -> Data? {
        var csv = "Category,Type,Amount,DueDate,NotificationEnabled\n"

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]

        for category in categories {
            let name = escapeCSV(category.name)
            let type = category.isRecurring ? "Recurring" : "One-time"
            let amount = formatDecimal(category.amount)
            let dueDate = category.dueDate.map { dateFormatter.string(from: $0) } ?? ""
            let notifications = category.notificationEnabled ? "true" : "false"

            csv += "\(name),\(type),\(amount),\(dueDate),\(notifications)\n"
        }

        return csv.data(using: .utf8)
    }

    // MARK: - JSON Export

    /// Export complete budget data to JSON format (full backup)
    /// - Parameters:
    ///   - accounts: All accounts
    ///   - categories: All budget categories
    ///   - transactions: All transactions
    ///   - monthlyBudgets: All monthly budgets
    /// - Returns: JSON data that can be saved or shared
    static func exportFullDataJSON(
        accounts: [Account],
        categories: [BudgetCategory],
        transactions: [Transaction],
        monthlyBudgets: [MonthlyBudget]
    ) -> Data? {
        let export = FullDataExport(
            version: "1.4.0",
            exportDate: Date(),
            accounts: accounts.map(AccountExport.init),
            categories: categories.map(CategoryExport.init),
            transactions: transactions.map(TransactionExport.init),
            monthlyBudgets: monthlyBudgets.map(MonthlyBudgetExport.init)
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        return try? encoder.encode(export)
    }

    // MARK: - Helper Methods

    /// Escape CSV field (wrap in quotes if contains comma, quote, or newline)
    private static func escapeCSV(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }

    /// Format Decimal as string with 2 decimal places
    private static func formatDecimal(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "0.00"
    }
}

// MARK: - Export Data Structures

/// Complete data export structure
struct FullDataExport: Codable {
    let version: String
    let exportDate: Date
    let accounts: [AccountExport]
    let categories: [CategoryExport]
    let transactions: [TransactionExport]
    let monthlyBudgets: [MonthlyBudgetExport]
}

/// Account export structure (Codable version of Account model)
struct AccountExport: Codable {
    let id: UUID
    let name: String
    let balance: Decimal
    let accountType: String?
    let createdDate: Date
    let notes: String?

    init(from account: Account) {
        self.id = account.id
        self.name = account.name
        self.balance = account.balance
        self.accountType = account.accountType
        self.createdDate = account.createdDate
        self.notes = account.notes
    }
}

/// Category export structure (Codable version of BudgetCategory model)
struct CategoryExport: Codable {
    let id: UUID
    let name: String
    let amount: Decimal
    let notes: String?
    let isRecurring: Bool
    let createdDate: Date
    let dueDate: Date?
    let notificationEnabled: Bool
    let notificationSchedule: String?
    let yearMonth: String

    init(from category: BudgetCategory) {
        self.id = category.id
        self.name = category.name
        self.amount = category.amount
        self.notes = category.notes
        self.isRecurring = category.isRecurring
        self.createdDate = category.createdDate
        self.dueDate = category.dueDate
        self.notificationEnabled = category.notificationEnabled
        self.notificationSchedule = category.notificationSchedule
        self.yearMonth = category.yearMonth
    }
}

/// Transaction export structure (Codable version of Transaction model)
struct TransactionExport: Codable {
    let id: UUID
    let amount: Decimal
    let type: String
    let date: Date
    let notes: String?
    let categoryName: String?

    init(from transaction: Transaction) {
        self.id = transaction.id
        self.amount = transaction.amount
        self.type = transaction.type == .income ? "income" : "expense"
        self.date = transaction.date
        self.notes = transaction.notes
        self.categoryName = transaction.category?.name
    }
}

/// Monthly budget export structure (Codable version of MonthlyBudget model)
struct MonthlyBudgetExport: Codable {
    let id: UUID
    let yearMonth: String
    let createdDate: Date

    init(from monthlyBudget: MonthlyBudget) {
        self.id = monthlyBudget.id
        self.yearMonth = monthlyBudget.yearMonth
        self.createdDate = monthlyBudget.createdDate
    }
}
