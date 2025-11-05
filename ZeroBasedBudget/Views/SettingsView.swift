//
//  SettingsView.swift
//  ZeroBasedBudget
//
//  Created by Claude on 11/5/25.
//  Enhanced in Enhancement 3.2 with comprehensive settings
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// Comprehensive settings view for app configuration and preferences
///
/// Sections:
/// - Appearance (dark mode toggle)
/// - Currency & Formatting
/// - Budget Behavior
/// - Notifications
/// - Data Management
/// - About
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Query private var accounts: [Account]
    @Query private var categories: [BudgetCategory]
    @Query private var transactions: [Transaction]
    @Query private var monthlyBudgets: [MonthlyBudget]

    @State private var showingClearDataAlert = false
    @State private var showingYNABMethodology = false
    @State private var showingExportCSV = false
    @State private var showingExportJSON = false
    @State private var showingImportPicker = false
    @State private var showingImportAlert = false
    @State private var importAlertMessage = ""
    @State private var csvExportData: Data?
    @State private var jsonExportData: Data?

    /// Get or create singleton settings
    private var appSettings: AppSettings {
        if let existing = settings.first {
            return existing
        } else {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            return newSettings
        }
    }

    /// Available currency codes
    private let currencies = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY", "CHF", "CNY", "INR", "MXN"]

    /// Available date formats
    private let dateFormats = ["MM/DD/YYYY", "DD/MM/YYYY", "YYYY-MM-DD"]

    /// Available number formats
    private let numberFormats = ["1,234.56", "1.234,56", "1 234,56"]

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Appearance Section
                appearanceSection

                // MARK: - Currency & Formatting Section
                currencyFormattingSection

                // MARK: - Budget Behavior Section
                budgetBehaviorSection

                // MARK: - Notifications Section
                notificationsSection

                // MARK: - Data Management Section
                dataManagementSection

                // MARK: - About Section
                aboutSection
            }
            .navigationTitle("Settings")
            .alert("Clear All Data", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All Data", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all accounts, categories, transactions, and budgets. This action cannot be undone.")
            }
            .sheet(isPresented: $showingYNABMethodology) {
                ynabMethodologySheet
            }
            .sheet(isPresented: $showingExportCSV) {
                if let data = csvExportData {
                    ShareSheet(items: [data])
                }
            }
            .sheet(isPresented: $showingExportJSON) {
                if let data = jsonExportData {
                    ShareSheet(items: [data])
                }
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
            .alert("Import Result", isPresented: $showingImportAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importAlertMessage)
            }
        }
    }

    // MARK: - Section Views

    private var appearanceSection: some View {
        Section {
            Picker("Appearance", selection: Binding(
                get: { appSettings.colorSchemePreference },
                set: { newValue in
                    appSettings.colorSchemePreference = newValue
                    appSettings.lastModifiedDate = Date()
                }
            )) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Appearance")
        } footer: {
            Text("Choose your preferred color scheme. System will match your device settings.")
        }
    }

    private var currencyFormattingSection: some View {
        Section {
            // Currency Selection
            Picker("Currency", selection: Binding(
                get: { appSettings.currencyCode },
                set: { newValue in
                    appSettings.currencyCode = newValue
                    appSettings.lastModifiedDate = Date()
                }
            )) {
                ForEach(currencies, id: \.self) { currency in
                    Text(currencySymbol(for: currency) + " \(currency)").tag(currency)
                }
            }

            // Date Format
            Picker("Date Format", selection: Binding(
                get: { appSettings.dateFormat },
                set: { newValue in
                    appSettings.dateFormat = newValue
                    appSettings.lastModifiedDate = Date()
                }
            )) {
                ForEach(dateFormats, id: \.self) { format in
                    Text(format).tag(format)
                }
            }

            // Number Format
            Picker("Number Format", selection: Binding(
                get: { appSettings.numberFormat },
                set: { newValue in
                    appSettings.numberFormat = newValue
                    appSettings.lastModifiedDate = Date()
                }
            )) {
                ForEach(numberFormats, id: \.self) { format in
                    Text(format).tag(format)
                }
            }
        } header: {
            Text("Currency & Formatting")
        } footer: {
            Text("Changes apply immediately to all monetary values and dates in the app.")
        }
    }

    private var budgetBehaviorSection: some View {
        Section {
            // Month Start Date
            Stepper("Month Starts on Day \(appSettings.monthStartDate)", value: Binding(
                get: { appSettings.monthStartDate },
                set: { newValue in
                    appSettings.monthStartDate = max(1, min(31, newValue))
                    appSettings.lastModifiedDate = Date()
                }
            ), in: 1...31)

            // Default Notification Schedule
            Picker("Default Notifications", selection: Binding(
                get: { appSettings.defaultNotificationSchedule },
                set: { newValue in
                    appSettings.defaultNotificationSchedule = newValue
                    appSettings.lastModifiedDate = Date()
                }
            )) {
                Text("7 Days Before").tag("7-day")
                Text("2 Days Before").tag("2-day")
                Text("On Due Date").tag("on-date")
                Text("Custom").tag("custom")
            }

            // Allow Negative Amounts
            Toggle("Allow Over-Budget", isOn: Binding(
                get: { appSettings.allowNegativeCategoryAmounts },
                set: { newValue in
                    appSettings.allowNegativeCategoryAmounts = newValue
                    appSettings.lastModifiedDate = Date()
                }
            ))
        } header: {
            Text("Budget Behavior")
        } footer: {
            Text("Month start date is useful if you get paid mid-month. Default notifications apply to new categories.")
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle("Enable Notifications", isOn: Binding(
                get: { appSettings.notificationsEnabled },
                set: { newValue in
                    appSettings.notificationsEnabled = newValue
                    appSettings.lastModifiedDate = Date()
                }
            ))

            if !appSettings.notificationsEnabled {
                Text("Notifications are disabled. Category due date reminders will not appear.")
                    .font(.caption)
                    .foregroundStyle(Color.appWarning)
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Master switch for all budget notifications. Individual categories can still have their own notification settings.")
        }
    }

    private var dataManagementSection: some View {
        Section {
            // Export CSV
            Button {
                exportCSV()
            } label: {
                Label("Export Budget (CSV)", systemImage: "square.and.arrow.up")
            }

            // Export JSON
            Button {
                exportJSON()
            } label: {
                Label("Export All Data (JSON)", systemImage: "doc.on.doc")
            }

            // Import JSON
            Button {
                showingImportPicker = true
            } label: {
                Label("Import Data (JSON)", systemImage: "square.and.arrow.down")
            }

            // Clear All Data
            Button(role: .destructive) {
                showingClearDataAlert = true
            } label: {
                Label("Clear All Data", systemImage: "trash")
                    .foregroundStyle(Color.appError)
            }

            // Storage Info
            HStack {
                Text("Storage")
                Spacer()
                Text("Local Only")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Data Management")
        } footer: {
            Text("All data is stored locally on your device. No cloud sync. Export for backup.")
        }
    }

    private var aboutSection: some View {
        Section {
            // Version
            HStack {
                Text("Version")
                Spacer()
                Text("1.4.0")
                    .foregroundStyle(.secondary)
            }

            // Build
            HStack {
                Text("Build")
                Spacer()
                Text("Enhancement 3.2")
                    .foregroundStyle(.secondary)
            }

            // YNAB Methodology
            Button {
                showingYNABMethodology = true
            } label: {
                Label("YNAB Methodology", systemImage: "book")
            }

            // Privacy
            HStack {
                Text("Privacy")
                Spacer()
                Text("Local Only")
                    .foregroundStyle(.secondary)
            }

            // GitHub Link (placeholder)
            Button {
                // TODO: Open GitHub link
            } label: {
                Label("Feedback & Source Code", systemImage: "link")
            }
        } header: {
            Text("About")
        } footer: {
            Text("Zero-Based Budget v1.4.0 • Built with SwiftUI & SwiftData • No cloud sync, complete privacy")
        }
    }

    private var ynabMethodologySheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("YNAB Methodology")
                        .font(.title.bold())

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rule 1: Give Every Dollar a Job")
                            .font(.headline)
                        Text("Budget only money you have RIGHT NOW, not money you expect to receive. Assign ALL of that money to categories until Ready to Assign = $0.")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rule 2: Embrace Your True Expenses")
                            .font(.headline)
                        Text("Break up larger, less-frequent expenses into manageable monthly amounts. Save for annual insurance, quarterly taxes, or any irregular expense.")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rule 3: Roll With the Punches")
                            .font(.headline)
                        Text("When life happens and you overspend, move money from another category. Your budget is flexible—adjust it as needed.")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rule 4: Age Your Money")
                            .font(.headline)
                        Text("As you get ahead, you'll spend money you earned weeks or even months ago. This creates a buffer and reduces financial stress.")
                    }

                    Text("This app follows YNAB principles by tracking real account balances and helping you assign every dollar a specific job.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            .navigationTitle("YNAB Methodology")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingYNABMethodology = false
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func currencySymbol(for code: String) -> String {
        let locale = Locale(identifier: code == "USD" ? "en_US" : code == "EUR" ? "en_EU" : "en_\(code)")
        return locale.currencySymbol ?? "$"
    }

    // MARK: - Data Management Methods

    private func exportCSV() {
        // Export all budget categories
        if let data = DataExporter.exportCategoriesCSV(categories: categories) {
            csvExportData = data
            showingExportCSV = true
        }
    }

    private func exportJSON() {
        if let data = DataExporter.exportFullDataJSON(
            accounts: accounts,
            categories: categories,
            transactions: transactions,
            monthlyBudgets: monthlyBudgets
        ) {
            jsonExportData = data
            showingExportJSON = true
        }
    }

    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            do {
                // Read file data
                let data = try Data(contentsOf: url)

                // Import data
                let summary = try DataImporter.importFullDataJSON(data: data, into: modelContext)

                // Show success message
                importAlertMessage = summary.description
                showingImportAlert = true
            } catch let error as DataImporter.ImportError {
                importAlertMessage = "Import failed: \(error.localizedDescription)"
                showingImportAlert = true
            } catch {
                importAlertMessage = "Import failed: \(error.localizedDescription)"
                showingImportAlert = true
            }

        case .failure(let error):
            importAlertMessage = "Failed to read file: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }

    private func clearAllData() {
        // Delete all accounts
        for account in accounts {
            modelContext.delete(account)
        }

        // Delete all categories
        for category in categories {
            modelContext.delete(category)
        }

        // Delete all transactions
        for transaction in transactions {
            modelContext.delete(transaction)
        }

        // Delete all monthly budgets
        for budget in monthlyBudgets {
            modelContext.delete(budget)
        }

        // Save context (AppSettings is preserved)
        do {
            try modelContext.save()
        } catch {
            print("❌ Failed to clear data: \(error)")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: AppSettings.self, inMemory: true)
}

// MARK: - ShareSheet Helper

/// UIKit wrapper for UIActivityViewController (share sheet)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}
