//
//  Transaction.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-01.
//

import Foundation
import SwiftData

enum TransactionType: String, Codable {
    case income
    case expense
}

@Model
final class Transaction {
    #Index<Transaction>([\.date], [\.amount], [\.date, \.category])

    var id: UUID
    var date: Date
    var amount: Decimal
    var transactionDescription: String
    var notes: String?
    var type: TransactionType
    var category: BudgetCategory?
    var account: Account?  // Link to account for balance tracking

    @Attribute(.externalStorage)
    var receiptImageData: Data?

    init(date: Date, amount: Decimal, description: String, type: TransactionType, category: BudgetCategory?, account: Account? = nil) {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.transactionDescription = description
        self.type = type
        self.category = category
        self.account = account
    }
}
