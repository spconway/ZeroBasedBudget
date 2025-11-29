//
//  ImportResultsSheet.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/9/25.
//

import SwiftUI

struct ImportResultsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors

    let result: ImportManager.ImportResult
    let account: Account
    let onDismissAll: () -> Void

    @State private var showingErrors = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Success icon
                Image(systemName: result.successCount > 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(result.successCount > 0 ? themeColors.success : themeColors.error)
                    .padding(.top, 40)

                // Results summary
                VStack(spacing: 12) {
                    Text("Import Complete")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(themeColors.textPrimary)

                    VStack(spacing: 4) {
                        Text("\(result.successCount) transactions imported successfully")
                            .font(.body)
                            .foregroundStyle(themeColors.success)
                            .fontWeight(.medium)

                        if result.failureCount > 0 {
                            Text("\(result.failureCount) transactions failed")
                                .font(.body)
                                .foregroundStyle(themeColors.error)
                                .fontWeight(.medium)
                        }
                    }

                    Text("Account: \(account.name)")
                        .font(.subheadline)
                        .foregroundStyle(themeColors.textSecondary)
                        .padding(.top, 4)
                }

                // Error details (if any)
                if result.failureCount > 0 {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .iconWarning()
                            Text("Import Errors")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(themeColors.textPrimary)
                        }

                        DisclosureGroup("View Error Details (\(result.errors.count) errors)", isExpanded: $showingErrors) {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(result.errors, id: \.self) { error in
                                        HStack(alignment: .top, spacing: 8) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                                .foregroundStyle(themeColors.error)
                                            Text(error)
                                                .font(.caption)
                                                .foregroundStyle(themeColors.textSecondary)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding(.top, 8)
                            }
                            .frame(maxHeight: 200)
                        }
                        .tint(themeColors.primary)
                    }
                    .padding()
                    .background(themeColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                // ZeroBudget reminder for category assignment
                if result.successCount > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .iconPrimary()
                            Text("Next Steps")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(themeColors.textPrimary)
                        }

                        Text("All imported transactions need categories assigned. Visit the Budget tab to categorize your transactions and complete your budget.")
                            .font(.caption)
                            .foregroundStyle(themeColors.textSecondary)
                    }
                    .padding()
                    .background(themeColors.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeColors.primary, lineWidth: 1)
                    )
                    .padding(.horizontal)
                }

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    if result.successCount > 0 {
                        // Navigate to transactions tab (dismiss all sheets)
                        Button(action: {
                            dismiss() // Dismiss this sheet first
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onDismissAll() // Then dismiss parent sheets
                            }
                        }) {
                            HStack {
                                Image(systemName: "list.bullet")
                                Text("View Transactions")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeColors.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Done button
                    Button(action: {
                        dismiss() // Dismiss this sheet first
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onDismissAll() // Then dismiss parent sheets
                        }
                    }) {
                        Text(result.successCount > 0 ? "Done" : "Close")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeColors.surface)
                            .foregroundStyle(themeColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeColors.primary, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .background(themeColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled() // Prevent swipe to dismiss - user must tap Done
        }
    }
}

#Preview {
    let successResult = ImportManager.ImportResult(
        successCount: 43,
        failureCount: 2,
        errors: [
            "Row 15: Invalid date '11/32/2025'",
            "Row 28: Duplicate transaction (same date, amount, description)"
        ]
    )

    let account = Account(name: "Checking", balance: 2500.00, accountType: "Checking")

    ImportResultsSheet(result: successResult, account: account, onDismissAll: {})
        .environment(ThemeManager())
}
