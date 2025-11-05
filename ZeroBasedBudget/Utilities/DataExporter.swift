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
    /// - Returns: CSV data that can be saved or shared
    static func exportCategoriesCSV(categories: [BudgetCategory]) -> Data? {
        var csv = "Category,Type,Amount,DueDayOfMonth,NotificationsEnabled\n"

        for category in categories {
            let name = escapeCSV(category.name)
            let type = category.categoryType
            let amount = formatDecimal(category.budgetedAmount)
            let dueDayOfMonth = category.dueDayOfMonth.map { String($0) } ?? ""
            let notifications = (category.notify7DaysBefore || category.notify2DaysBefore || category.notifyOnDueDate) ? "true" : "false"

            csv += "\(name),\(type),\(amount),\(dueDayOfMonth),\(notifications)\n"
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

    nonisolated init(from account: Account) {
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
    let name: String
    let budgetedAmount: Decimal
    let categoryType: String
    let colorHex: String
    let dueDate: Date?
    let dueDayOfMonth: Int?
    let isLastDayOfMonth: Bool
    let notify7DaysBefore: Bool
    let notify2DaysBefore: Bool
    let notifyOnDueDate: Bool
    let notifyCustomDays: Bool
    let customDaysCount: Int

    nonisolated init(from category: BudgetCategory) {
        self.name = category.name
        self.budgetedAmount = category.budgetedAmount
        self.categoryType = category.categoryType
        self.colorHex = category.colorHex
        self.dueDate = category.dueDate
        self.dueDayOfMonth = category.dueDayOfMonth
        self.isLastDayOfMonth = category.isLastDayOfMonth
        self.notify7DaysBefore = category.notify7DaysBefore
        self.notify2DaysBefore = category.notify2DaysBefore
        self.notifyOnDueDate = category.notifyOnDueDate
        self.notifyCustomDays = category.notifyCustomDays
        self.customDaysCount = category.customDaysCount
    }
}

/// Transaction export structure (Codable version of Transaction model)
struct TransactionExport: Codable {
    let id: UUID
    let amount: Decimal
    let type: String
    let date: Date
    let transactionDescription: String
    let notes: String?
    let categoryName: String?

    nonisolated init(from transaction: Transaction) {
        self.id = transaction.id
        self.amount = transaction.amount
        self.type = transaction.type == .income ? "income" : "expense"
        self.date = transaction.date
        self.transactionDescription = transaction.transactionDescription
        self.notes = transaction.notes
        self.categoryName = transaction.category?.name
    }
}

/// Monthly budget export structure (Codable version of MonthlyBudget model)
struct MonthlyBudgetExport: Codable {
    let month: Date
    let startingBalance: Decimal
    let notes: String?

    nonisolated init(from monthlyBudget: MonthlyBudget) {
        self.month = monthlyBudget.month
        self.startingBalance = monthlyBudget.startingBalance
        self.notes = monthlyBudget.notes
    }
}
