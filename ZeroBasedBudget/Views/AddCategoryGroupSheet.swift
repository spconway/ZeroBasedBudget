//
//  AddCategoryGroupSheet.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-16.
//

import SwiftUI
import SwiftData

struct AddCategoryGroupSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var colors
    @Query private var existingGroups: [CategoryGroup]

    @State private var groupName: String = ""
    @State private var errorMessage: String?

    private var isValid: Bool {
        let trimmedName = groupName.trimmingCharacters(in: .whitespaces)
        return !trimmedName.isEmpty && !isDuplicate(trimmedName)
    }

    private func isDuplicate(_ name: String) -> Bool {
        existingGroups.contains { $0.name.lowercased() == name.lowercased() }
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
                    Text("GROUP DETAILS")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(colors.textSecondary)
                } footer: {
                    Text("Create a custom category group to organize your budget categories. Examples: \"Savings\", \"Debt Payments\", \"Fun Money\"")
                        .font(.caption)
                        .foregroundStyle(colors.textSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(colors.background)
            .navigationTitle("New Category Group")
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
                        saveGroup()
                    }
                    .disabled(!isValid)
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

    private func saveGroup() {
        let trimmedName = groupName.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty, !isDuplicate(trimmedName) else {
            return
        }

        do {
            _ = try CategoryGroupMigration.createGroup(name: trimmedName, in: modelContext)
            dismiss()
        } catch {
            errorMessage = "Failed to create group: \(error.localizedDescription)"
        }
    }
}

#Preview {
    AddCategoryGroupSheet()
        .modelContainer(for: [CategoryGroup.self])
}
