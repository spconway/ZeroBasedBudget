//
//  EditCategoryGroupSheet.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-16.
//

import SwiftUI
import SwiftData

struct EditCategoryGroupSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var colors
    @Query private var existingGroups: [CategoryGroup]

    let group: CategoryGroup
    @State private var groupName: String
    @State private var errorMessage: String?
    @State private var showingDeleteAlert = false
    @State private var deleteErrorMessage: String?

    init(group: CategoryGroup) {
        self.group = group
        _groupName = State(initialValue: group.name)
    }

    private var isValid: Bool {
        let trimmedName = groupName.trimmingCharacters(in: .whitespaces)
        return !trimmedName.isEmpty && !isDuplicate(trimmedName)
    }

    private func isDuplicate(_ name: String) -> Bool {
        existingGroups.contains { $0.name.lowercased() == name.lowercased() && $0.id != group.id }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Group Name", text: $groupName)
                        .autocorrectionDisabled()
                        .onChange(of: groupName) { _, newValue in
                            validateName(newValue)
                        }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(colors.error)
                    }
                } header: {
                    Text("GROUP NAME")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
                }

                Section {
                    Button(role: .destructive, action: { attemptDelete() }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Category Group")
                        }
                    }
                } footer: {
                    Text("Deleting this group will move its categories to 'Variable Expenses'. Groups with transactions cannot be deleted.")
                        .font(.caption)
                        .foregroundStyle(colors.textSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(colors.background)
            .navigationTitle("Edit Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isValid || groupName.trimmingCharacters(in: .whitespaces) == group.name)
                }
            }
            .alert(deleteErrorMessage != nil ? "Cannot Delete" : "Delete Category Group", isPresented: $showingDeleteAlert) {
                if deleteErrorMessage != nil {
                    Button("OK", role: .cancel) {
                        deleteErrorMessage = nil
                    }
                } else {
                    Button("Delete", role: .destructive) {
                        deleteGroup()
                    }
                    Button("Cancel", role: .cancel) { }
                }
            } message: {
                if let errorMsg = deleteErrorMessage {
                    Text(errorMsg)
                } else {
                    Text("Are you sure you want to delete '\(group.name)'? Categories will be moved to 'Variable Expenses'.")
                }
            }
        }
    }

    private func validateName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            errorMessage = nil
            return
        }

        if isDuplicate(trimmed) {
            errorMessage = "A group with this name already exists"
        } else {
            errorMessage = nil
        }
    }

    private func saveChanges() {
        let trimmedName = groupName.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty, !isDuplicate(trimmedName) else {
            return
        }

        group.name = trimmedName

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
        }
    }

    private func attemptDelete() {
        // Check if any categories in this group have transactions
        var hasTransactions = false
        for category in group.categories {
            if !category.transactions.isEmpty {
                hasTransactions = true
                break
            }
        }

        if hasTransactions {
            deleteErrorMessage = "Cannot delete '\(group.name)'. One or more categories have transactions. Delete all transactions first."
            showingDeleteAlert = true
        } else if group.categories.isEmpty {
            // Empty group - just show confirmation
            deleteErrorMessage = nil
            showingDeleteAlert = true
        } else {
            // Has categories but no transactions - show confirmation
            deleteErrorMessage = nil
            showingDeleteAlert = true
        }
    }

    private func deleteGroup() {
        do {
            try CategoryGroupMigration.deleteGroup(group, in: modelContext)
            dismiss()
        } catch {
            deleteErrorMessage = "Failed to delete group: \(error.localizedDescription)"
            showingDeleteAlert = true
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: CategoryGroup.self)
    let group = CategoryGroup(name: "Sample Group", sortOrder: 1)
    container.mainContext.insert(group)

    return EditCategoryGroupSheet(group: group)
        .modelContainer(container)
}
