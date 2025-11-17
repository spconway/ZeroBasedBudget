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
    @Environment(\.themeColors) private var colors
    @Query(sort: \Account.createdDate, order: .forward) private var allAccounts: [Account]
    @Query private var settings: [AppSettings]

    @State private var showingAddSheet = false
    @State private var editingAccount: Account?

    /// Currency code from settings
    private var currencyCode: String {
        settings.first?.currencyCode ?? "USD"
    }

    /// Number format from settings
    private var numberFormat: String {
        settings.first?.numberFormat ?? "1,234.56"
    }

    /// Calculate total across all accounts
    private var totalAccountBalances: Decimal {
        allAccounts.reduce(0) { $0 + $1.balance }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top banner with total - Refined styling
                VStack(spacing: 8) {
                    Text("TOTAL ACROSS ALL ACCOUNTS")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(colors.textSecondary)
                        .tracking(0.5)

                    Text(CurrencyFormatHelpers.formatCurrency(totalAccountBalances, currencyCode: currencyCode, numberFormat: numberFormat))
                        .font(.system(size: 42, weight: .light, design: .rounded)) // Light weight for elegance
                        .foregroundStyle(colors.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
                .background(colors.background)

                // Accounts list
                if allAccounts.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "banknote")
                            .font(.system(size: 60))
                            .iconNeutral()

                        Text("No Accounts Yet")
                            .font(.title2.bold())
                            .foregroundStyle(colors.textPrimary)

                        Text("Add your first account to start budgeting with the YNAB method.")
                            .font(.body)
                            .foregroundStyle(colors.textSecondary)
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
                    // Accounts list - Refined styling with card layout
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(allAccounts) { account in
                                AccountRow(account: account, currencyCode: currencyCode, numberFormat: numberFormat)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        editingAccount = account
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            if let index = allAccounts.firstIndex(where: { $0.id == account.id }) {
                                                deleteAccounts(at: IndexSet(integer: index))
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .background(colors.background)
                }
            }
			.navigationBarTitleDisplayMode(.inline)
            .background(colors.background)
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text("Accounts")
						.foregroundColor(colors.textPrimary)
				}
			}
            .toolbarBackground(colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .iconAccent()
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
