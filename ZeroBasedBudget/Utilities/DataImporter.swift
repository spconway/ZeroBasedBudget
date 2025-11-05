//
//  DataImporter.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//  Enhancement 3.2: Data import functionality
//

import Foundation
import SwiftData

/// Utility for importing budget data from JSON format
struct DataImporter {

    // MARK: - Import Errors

    enum ImportError: LocalizedError {
        case invalidJSON
        case unsupportedVersion
        case missingRequiredFields
        case invalidDataFormat

        var errorDescription: String? {
            switch self {
            case .invalidJSON:
                return "The file is not valid JSON or is corrupted."
            case .unsupportedVersion:
                return "This file was created with an incompatible version of the app."
            case .missingRequiredFields:
                return "The file is missing required data fields."
            case .invalidDataFormat:
                return "The data format is invalid or corrupted."
            }
        }
    }

    // MARK: - Import Methods

    /// Import complete budget data from JSON
    /// - Parameters:
    ///   - data: JSON data to import
    ///   - modelContext: SwiftData model context to insert data into
    /// - Throws: ImportError if validation fails
    /// - Returns: Summary of imported data counts
    static func importFullDataJSON(
        data: Data,
        into modelContext: ModelContext
    ) throws -> ImportSummary {
        // Decode JSON
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let export: FullDataExport
        do {
            export = try decoder.decode(FullDataExport.self, from: data)
        } catch {
            throw ImportError.invalidJSON
        }

        // Validate version (accept 1.x.x versions)
        guard export.version.hasPrefix("1.") else {
            throw ImportError.unsupportedVersion
        }

        // Import accounts
        var accountMap: [UUID: Account] = [:]
        for accountExport in export.accounts {
            let account = Account(
                name: accountExport.name,
                balance: accountExport.balance,
                accountType: accountExport.accountType
            )
            account.id = accountExport.id
            account.createdDate = accountExport.createdDate
            account.notes = accountExport.notes

            modelContext.insert(account)
            accountMap[account.id] = account
        }

        // Import monthly budgets
        for budgetExport in export.monthlyBudgets {
            let monthlyBudget = MonthlyBudget(month: budgetExport.month, startingBalance: budgetExport.startingBalance)
            monthlyBudget.notes = budgetExport.notes

            modelContext.insert(monthlyBudget)
        }

        // Import categories
        var categoryMap: [String: BudgetCategory] = [:]
        for categoryExport in export.categories {
            let category = BudgetCategory(
                name: categoryExport.name,
                budgetedAmount: categoryExport.budgetedAmount,
                categoryType: categoryExport.categoryType,
                colorHex: categoryExport.colorHex,
                dueDate: categoryExport.dueDate
            )
            category.dueDayOfMonth = categoryExport.dueDayOfMonth
            category.isLastDayOfMonth = categoryExport.isLastDayOfMonth
            category.notify7DaysBefore = categoryExport.notify7DaysBefore
            category.notify2DaysBefore = categoryExport.notify2DaysBefore
            category.notifyOnDueDate = categoryExport.notifyOnDueDate
            category.notifyCustomDays = categoryExport.notifyCustomDays
            category.customDaysCount = categoryExport.customDaysCount

            modelContext.insert(category)
            categoryMap[category.name] = category
        }

        // Import transactions
        for transactionExport in export.transactions {
            // Find category if exists
            var category: BudgetCategory? = nil
            if let categoryName = transactionExport.categoryName {
                category = categoryMap[categoryName]
            }

            let transaction = Transaction(
                date: transactionExport.date,
                amount: transactionExport.amount,
                description: transactionExport.transactionDescription,
                type: transactionExport.type == "income" ? .income : .expense,
                category: category
            )
            transaction.id = transactionExport.id
            transaction.notes = transactionExport.notes

            modelContext.insert(transaction)
        }

        // Save context
        try modelContext.save()

        return ImportSummary(
            accountCount: export.accounts.count,
            categoryCount: export.categories.count,
            transactionCount: export.transactions.count,
            monthlyBudgetCount: export.monthlyBudgets.count
        )
    }

    /// Validate JSON data without importing
    /// - Parameter data: JSON data to validate
    /// - Returns: True if data is valid and can be imported
    static func validateJSON(data: Data) -> Bool {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let export = try decoder.decode(FullDataExport.self, from: data)
            return export.version.hasPrefix("1.")
        } catch {
            return false
        }
    }
}

// MARK: - Import Summary

/// Summary of imported data
struct ImportSummary {
    let accountCount: Int
    let categoryCount: Int
    let transactionCount: Int
    let monthlyBudgetCount: Int

    var description: String {
        """
        Successfully imported:
        • \(accountCount) accounts
        • \(categoryCount) categories
        • \(transactionCount) transactions
        • \(monthlyBudgetCount) monthly budgets
        """
    }
}
