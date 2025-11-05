//
//  Account.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//

import Foundation
import SwiftData

/// Represents a real-world financial account (checking, savings, cash, credit card)
///
/// YNAB Principle: Accounts represent actual money that exists TODAY.
/// The sum of all account balances = total money available to budget.
@Model
final class Account {
    /// Unique identifier
    var id: UUID

    /// Account name (e.g., "Chase Checking", "Savings", "Cash")
    var name: String

    /// Current account balance (use Decimal for monetary precision)
    /// Can be negative (overdraft, credit card debt)
    var balance: Decimal

    /// Optional account type for categorization
    /// Examples: "Checking", "Savings", "Cash", "Credit Card"
    var accountType: String?

    /// Date account was created in app
    var createdDate: Date

    /// Optional notes (account number, bank name, etc.)
    var notes: String?

    /// Transactions associated with this account
    @Relationship(deleteRule: .nullify, inverse: \Transaction.account)
    var transactions: [Transaction] = []

    /// Initialize a new Account
    /// - Parameters:
    ///   - name: Account name (e.g., "Chase Checking")
    ///   - balance: Initial balance (defaults to 0)
    ///   - accountType: Optional type (e.g., "Checking")
    init(name: String, balance: Decimal = 0, accountType: String? = nil) {
        self.id = UUID()
        self.name = name
        self.balance = balance
        self.accountType = accountType
        self.createdDate = Date()
        self.notes = nil
    }
}
