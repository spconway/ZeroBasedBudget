//
//  AccountsView.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//

import SwiftUI
import SwiftData

/// Main view for managing financial accounts
///
/// YNAB Principle: Accounts represent real money that exists today.
/// The sum of all account balances = total money available to budget.
struct AccountsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.theme) private var theme
    @Query(sort: \Account.createdDate, order: .forward) private var allAccounts: [Account]
    @Query private var settings: [AppSettings]

    @State private var showingAddSheet = false
    @State private var editingAccount: Account?

    /// Currency code from settings
    private var currencyCode: String {
        settings.first?.currencyCode ?? "USD"
    }

    /// Calculate total across all accounts
    private var totalAccountBalances: Decimal {
        allAccounts.reduce(0) { $0 + $1.balance }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top banner with total
                VStack(spacing: 8) {
                    Text("Total Across All Accounts")
                        .font(.subheadline)
                        .foregroundStyle(theme.colors.textSecondary)

                    Text(totalAccountBalances, format: .currency(code: currencyCode))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.colors.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(theme.colors.background)

                // Accounts list
                if allAccounts.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "banknote")
                            .font(.system(size: 60))
                            .foregroundStyle(theme.colors.textSecondary)

                        Text("No Accounts Yet")
                            .font(.title2.bold())

                        Text("Add your first account to start budgeting with the YNAB method.")
                            .font(.body)
                            .foregroundStyle(theme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button {
                            showingAddSheet = true
                        } label: {
                            Label("Add Account", systemImage: "plus.circle.fill")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                    }
                    .frame(maxHeight: .infinity)
                    .padding()
                } else {
                    // Accounts list
                    List {
                        ForEach(allAccounts) { account in
                            AccountRow(account: account, currencyCode: currencyCode)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingAccount = account
                                }
                        }
                        .onDelete(perform: deleteAccounts)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddAccountSheet { name, balance, type in
                    addAccount(name: name, balance: balance, accountType: type)
                }
            }
            .sheet(item: $editingAccount) { account in
                EditAccountSheet(account: account)
            }
        }
    }

    // MARK: - Actions

    /// Add a new account
    private func addAccount(name: String, balance: Decimal, accountType: String?) {
        let newAccount = Account(name: name, balance: balance, accountType: accountType)
        modelContext.insert(newAccount)
    }

    /// Delete accounts at specified offsets
    private func deleteAccounts(at offsets: IndexSet) {
        for index in offsets {
            let account = allAccounts[index]

            // Warn if deleting account with non-zero balance
            if account.balance != 0 {
                print("⚠️ Warning: Deleting account '\(account.name)' with balance \(account.balance)")
            }

            modelContext.delete(account)
        }
    }
}

#Preview {
    AccountsView()
        .modelContainer(for: Account.self, inMemory: true)
}
