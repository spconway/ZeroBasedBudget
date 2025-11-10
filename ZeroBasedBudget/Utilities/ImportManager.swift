//
//  ImportManager.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/9/25.
//

import Foundation
import SwiftData

/// Manages CSV transaction import with intelligent column mapping and fuzzy matching
class ImportManager {

    // MARK: - Types

    enum ImportError: LocalizedError {
        case fileReadError
        case invalidCSVFormat
        case missingRequiredColumns([String])
        case invalidDateFormat(row: Int, value: String)
        case invalidAmountFormat(row: Int, value: String)
        case noDataRows

        var errorDescription: String? {
            switch self {
            case .fileReadError:
                return "Unable to read CSV file"
            case .invalidCSVFormat:
                return "Invalid CSV format - unable to parse headers"
            case .missingRequiredColumns(let columns):
                return "Missing required columns: \(columns.joined(separator: ", "))"
            case .invalidDateFormat(let row, let value):
                return "Row \(row): Invalid date format '\(value)'"
            case .invalidAmountFormat(let row, let value):
                return "Row \(row): Invalid amount format '\(value)'"
            case .noDataRows:
                return "CSV file contains no data rows"
            }
        }
    }

    struct ImportResult {
        let successCount: Int
        let failureCount: Int
        let errors: [String]
    }

    struct ColumnMapping {
        let date: String?
        let description: String?
        let debit: String?
        let credit: String?
        let amount: String?
        let type: String?
        let notes: String?

        var isValid: Bool {
            // Must have date and description
            guard date != nil, description != nil else { return false }
            // Must have either amount OR (debit AND credit)
            return amount != nil || (debit != nil && credit != nil)
        }
    }

    // MARK: - CSV Parsing

    /// Parse CSV file into headers and rows
    static func parseCSV(_ fileURL: URL) throws -> (headers: [String], rows: [[String]]) {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            throw ImportError.fileReadError
        }

        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else {
            throw ImportError.invalidCSVFormat
        }

        // Parse headers
        let headers = parseCSVLine(lines[0])

        // Parse data rows
        let rows = lines.dropFirst().map { parseCSVLine($0) }

        guard !rows.isEmpty else {
            throw ImportError.noDataRows
        }

        return (headers, rows)
    }

    /// Parse a single CSV line, handling quoted fields with commas
    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                fields.append(currentField.trimmingCharacters(in: .whitespaces))
                currentField = ""
            } else {
                currentField.append(char)
            }
        }

        // Add last field
        fields.append(currentField.trimmingCharacters(in: .whitespaces))

        return fields
    }

    // MARK: - Fuzzy Matching

    /// Suggest column mappings based on fuzzy matching
    static func suggestColumnMapping(headers: [String]) -> ColumnMapping {
        let targetFields = ["date", "description", "debit", "credit", "amount", "type", "notes"]
        var mapping: [String: String?] = [:]

        for target in targetFields {
            mapping[target] = fuzzyMatch(csvHeaders: headers, targetField: target)
        }

        return ColumnMapping(
            date: mapping["date"] ?? nil,
            description: mapping["description"] ?? nil,
            debit: mapping["debit"] ?? nil,
            credit: mapping["credit"] ?? nil,
            amount: mapping["amount"] ?? nil,
            type: mapping["type"] ?? nil,
            notes: mapping["notes"] ?? nil
        )
    }

    /// Fuzzy match CSV headers to target field using substring matching and Levenshtein distance
    private static func fuzzyMatch(csvHeaders: [String], targetField: String) -> String? {
        let patterns: [String: [String]] = [
            "date": ["date", "posted", "transaction date", "trans date", "trans. date"],
            "description": ["description", "memo", "merchant", "payee", "details", "transaction description"],
            "debit": ["debit", "withdrawal", "withdrawals", "amount out", "payments"],
            "credit": ["credit", "deposit", "deposits", "amount in", "income"],
            "amount": ["amount", "total", "value"],
            "type": ["type", "transaction type", "trans type", "category"],
            "notes": ["notes", "comment", "remarks"]
        ]

        guard let targetPatterns = patterns[targetField] else { return nil }

        var bestMatch: String?
        var bestScore = 0.0

        for header in csvHeaders {
            let headerLower = header.lowercased()

            for pattern in targetPatterns {
                let patternLower = pattern.lowercased()

                // Exact match (highest score)
                if headerLower == patternLower {
                    return header
                }

                // Substring match
                if headerLower.contains(patternLower) || patternLower.contains(headerLower) {
                    let score = 0.8
                    if score > bestScore {
                        bestScore = score
                        bestMatch = header
                    }
                }

                // Levenshtein distance (for typos)
                let distance = levenshteinDistance(headerLower, patternLower)
                let maxLength = max(headerLower.count, patternLower.count)
                let similarity = 1.0 - Double(distance) / Double(maxLength)

                if similarity > 0.6 && similarity > bestScore {
                    bestScore = similarity
                    bestMatch = header
                }
            }
        }

        return bestMatch
    }

    /// Calculate Levenshtein distance between two strings
    private static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let m = s1Array.count
        let n = s2Array.count

        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m {
            matrix[i][0] = i
        }

        for j in 0...n {
            matrix[0][j] = j
        }

        for i in 1...m {
            for j in 1...n {
                if s1Array[i - 1] == s2Array[j - 1] {
                    matrix[i][j] = matrix[i - 1][j - 1]
                } else {
                    matrix[i][j] = min(
                        matrix[i - 1][j] + 1,     // deletion
                        matrix[i][j - 1] + 1,     // insertion
                        matrix[i - 1][j - 1] + 1  // substitution
                    )
                }
            }
        }

        return matrix[m][n]
    }

    // MARK: - Date Parsing

    /// Parse date with multiple format support
    static func parseDate(_ dateString: String) -> Date? {
        let formatters = [
            "yyyy-MM-dd",      // ISO 8601 (2025-11-07)
            "MM/dd/yyyy",      // US format (11/07/2025)
            "dd/MM/yyyy",      // EU format (07/11/2025)
            "M/d/yyyy",        // US single digit (11/7/2025)
            "d/M/yyyy",        // EU single digit (7/11/2025)
            "yyyy/MM/dd"       // Alternative ISO (2025/11/07)
        ]

        for formatString in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = formatString
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current

            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        return nil
    }

    // MARK: - Amount Parsing

    /// Parse amount string to Decimal, handling various number formats
    static func parseAmount(_ amountString: String) -> Decimal? {
        // Remove currency symbols and whitespace
        var cleaned = amountString
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: "£", with: "")
            .trimmingCharacters(in: .whitespaces)

        // Check if negative (for single amount column)
        let isNegative = cleaned.hasPrefix("-")
        if isNegative {
            cleaned = String(cleaned.dropFirst())
        }

        // Detect format based on decimal separator position
        // 1,234.56 (US) vs 1.234,56 (EU) vs 1 234,56 (space)
        let hasCommaDecimal = cleaned.contains(",") && !cleaned.contains(".")
        let hasDotDecimal = cleaned.contains(".") && !cleaned.contains(",")
        let hasBoth = cleaned.contains(",") && cleaned.contains(".")

        if hasCommaDecimal {
            // EU format: 1.234,56 or 1 234,56
            cleaned = cleaned
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ",", with: ".")
        } else if hasBoth {
            // Determine which is thousands separator
            let commaIndex = cleaned.lastIndex(of: ",")!
            let dotIndex = cleaned.lastIndex(of: ".")!

            if dotIndex > commaIndex {
                // US format: 1,234.56
                cleaned = cleaned.replacingOccurrences(of: ",", with: "")
            } else {
                // EU format: 1.234,56
                cleaned = cleaned
                    .replacingOccurrences(of: ".", with: "")
                    .replacingOccurrences(of: ",", with: ".")
            }
        } else if cleaned.contains(" ") {
            // Space separator: 1 234.56 or 1 234,56
            cleaned = cleaned.replacingOccurrences(of: " ", with: "")
            if cleaned.contains(",") {
                cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
            }
        }

        // Convert to Decimal
        guard var decimal = Decimal(string: cleaned) else {
            return nil
        }

        if isNegative {
            decimal = -decimal
        }

        return decimal
    }

    // MARK: - Transaction Conversion

    /// Convert CSV rows to Transaction objects
    static func convertToTransactions(
        headers: [String],
        rows: [[String]],
        columnMapping: ColumnMapping,
        selectedAccount: Account,
        modelContext: ModelContext
    ) -> ImportResult {
        var successCount = 0
        var failureCount = 0
        var errors: [String] = []

        // Get column indices
        guard let dateIndex = headers.firstIndex(where: { $0 == columnMapping.date }),
              let descIndex = headers.firstIndex(where: { $0 == columnMapping.description }) else {
            return ImportResult(successCount: 0, failureCount: rows.count, errors: ["Missing required column mappings"])
        }

        let debitIndex = columnMapping.debit.flatMap { headers.firstIndex(of: $0) }
        let creditIndex = columnMapping.credit.flatMap { headers.firstIndex(of: $0) }
        let amountIndex = columnMapping.amount.flatMap { headers.firstIndex(of: $0) }
        let notesIndex = columnMapping.notes.flatMap { headers.firstIndex(of: $0) }

        // Process each row
        for (rowNum, row) in rows.enumerated() {
            let rowNumber = rowNum + 2 // +2 because header is row 1, data starts at row 2

            // Ensure row has enough columns
            guard row.count > dateIndex && row.count > descIndex else {
                failureCount += 1
                errors.append("Row \(rowNumber): Insufficient columns")
                continue
            }

            // Parse date
            guard let date = parseDate(row[dateIndex]) else {
                failureCount += 1
                errors.append("Row \(rowNumber): Invalid date '\(row[dateIndex])'")
                continue
            }

            // Get description
            let description = row[descIndex]
            guard !description.isEmpty else {
                failureCount += 1
                errors.append("Row \(rowNumber): Empty description")
                continue
            }

            // Parse amount and determine type
            var amount: Decimal?
            var type: TransactionType?

            if let amountIndex = amountIndex, row.count > amountIndex {
                // Single amount column
                if let parsedAmount = parseAmount(row[amountIndex]) {
                    amount = abs(parsedAmount)
                    type = parsedAmount < 0 ? .expense : .income
                }
            } else if let debitIndex = debitIndex, let creditIndex = creditIndex {
                // Debit/Credit columns
                let debitValue = row.count > debitIndex ? row[debitIndex] : ""
                let creditValue = row.count > creditIndex ? row[creditIndex] : ""

                if !debitValue.isEmpty, let parsedDebit = parseAmount(debitValue) {
                    amount = parsedDebit
                    type = .expense
                } else if !creditValue.isEmpty, let parsedCredit = parseAmount(creditValue) {
                    amount = parsedCredit
                    type = .income
                }
            }

            guard let finalAmount = amount, let finalType = type else {
                failureCount += 1
                errors.append("Row \(rowNumber): Invalid or missing amount")
                continue
            }

            // Get optional notes
            let notes = notesIndex.flatMap { row.count > $0 ? row[$0] : nil }

            // Check for duplicates (same date + amount + description)
            let existingTransactions = (try? modelContext.fetch(FetchDescriptor<Transaction>())) ?? []
            let isDuplicate = existingTransactions.contains { transaction in
                transaction.date == date &&
                transaction.amount == finalAmount &&
                transaction.transactionDescription == description &&
                transaction.account?.id == selectedAccount.id
            }

            if isDuplicate {
                failureCount += 1
                errors.append("Row \(rowNumber): Duplicate transaction (same date, amount, description)")
                continue
            }

            // Create transaction
            let transaction = Transaction(
                date: date,
                amount: finalAmount,
                description: description,
                type: finalType,
                category: nil, // User must assign category later (YNAB principle)
                account: selectedAccount
            )

            // Set optional notes if available
            if let notes = notes, !notes.isEmpty {
                transaction.notes = notes
            }

            modelContext.insert(transaction)
            successCount += 1
        }

        // Save context if any successful imports
        if successCount > 0 {
            try? modelContext.save()
        }

        return ImportResult(
            successCount: successCount,
            failureCount: failureCount,
            errors: errors
        )
    }
}
