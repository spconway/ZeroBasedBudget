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
import UserNotifications

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
    @Environment(\.theme) private var theme
    @Environment(\.themeColors) private var colors
    @Environment(\.themeManager) private var themeManager
    @Environment(\.scenePhase) private var scenePhase
    @Query private var settings: [AppSettings]
    @Query private var accounts: [Account]
    @Query private var categories: [BudgetCategory]
    @Query private var transactions: [Transaction]
    @Query private var monthlyBudgets: [MonthlyBudget]

    @State private var showingClearDataAlert = false
    @State private var showingZeroBudgetMethodology = false
    @State private var showingExportCSV = false
    @State private var showingExportJSON = false
    @State private var showingImportPicker = false
    @State private var showingImportAlert = false
    @State private var importAlertMessage = ""
    @State private var csvExportData: Data?
    @State private var jsonExportData: Data?

    // Notification permission state
    @State private var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingPermissionDeniedAlert = false
    @State private var isCheckingPermissions = false

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

                // MARK: - Theme Section
                themeSection

                // MARK: - Currency & Formatting Section
                currencyFormattingSection

                // MARK: - Budget Behavior Section
                budgetBehaviorSection

                // MARK: - Notifications Section
                notificationsSection

                // MARK: - Transaction Filters Section
                transactionFiltersSection

                // MARK: - Category Sorting Section
                categorySortingSection

                // MARK: - Data Management Section
                dataManagementSection

                // MARK: - About Section
                aboutSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(colors.background)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text("Settings")
						.foregroundColor(colors.textPrimary)
				}
			}
            .toolbarBackground(colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Clear All Data", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All Data", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all accounts, categories, transactions, and budgets. This action cannot be undone.")
            }
            .sheet(isPresented: $showingZeroBudgetMethodology) {
                ZeroBudgetMethodologySheet
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
            Text("APPEARANCE")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(colors.textSecondary)
        } footer: {
            Text("Choose your preferred color scheme. System will match your device settings.")
        }
    }

    private var themeSection: some View {
        Section {
            if let themeManager = themeManager {
                ThemePicker(themeManager: themeManager)
            } else {
                Text("Theme selection unavailable")
                    .foregroundStyle(colors.textSecondary)
            }
        } header: {
            Text("VISUAL THEME")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(colors.textSecondary)
        } footer: {
            Text("Choose your preferred visual theme. Theme changes apply instantly throughout the app.")
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
            Text("CURRENCY & FORMATTING")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(colors.textSecondary)
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
            Text("BUDGET BEHAVIOR")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(colors.textSecondary)
        } footer: {
            Text("Month start date is useful if you get paid mid-month. Default notifications apply to new categories.")
        }
    }

    private var notificationsSection: some View {
        Section {
            // Main enable/disable toggle
            Toggle("Enable Notifications", isOn: Binding(
                get: { appSettings.notificationsEnabled },
                set: { newValue in
                    if newValue {
                        // User wants to enable - request permissions
                        Task {
                            isCheckingPermissions = true
                            let result = await NotificationManager.shared.requestPermissions()
                            isCheckingPermissions = false

                            switch result {
                            case .granted, .alreadyGranted:
                                appSettings.notificationsEnabled = true
                                appSettings.lastModifiedDate = Date()
                                await scheduleAllCategoryNotifications()
                            case .denied, .previouslyDenied:
                                appSettings.notificationsEnabled = false
                                showingPermissionDeniedAlert = true
                            }

                            await updatePermissionStatus()
                        }
                    } else {
                        // User wants to disable - cancel all notifications
                        appSettings.notificationsEnabled = false
                        appSettings.lastModifiedDate = Date()
                        Task {
                            await NotificationManager.shared.cancelAllNotifications()
                        }
                    }
                }
            ))
            .disabled(isCheckingPermissions)

            // Permission status indicator
            Button(action: {
                if notificationPermissionStatus == .denied || notificationPermissionStatus == .notDetermined {
                    NotificationManager.shared.openNotificationSettings()
                }
            }) {
                HStack {
                    Text("System Permissions")
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(permissionStatusColor)
                            .frame(width: 8, height: 8)
                        Text(permissionStatusText)
                            .foregroundStyle(colors.textSecondary)
                    }
                }
            }
            .disabled(notificationPermissionStatus == .authorized)

            // Notification time picker (only if enabled)
            if appSettings.notificationsEnabled {
                DatePicker(
                    "Notification Time",
                    selection: Binding(
                        get: {
                            Calendar.current.date(from: DateComponents(
                                hour: appSettings.notificationTimeHour,
                                minute: appSettings.notificationTimeMinute
                            )) ?? Date()
                        },
                        set: { newDate in
                            let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                            appSettings.notificationTimeHour = components.hour ?? 9
                            appSettings.notificationTimeMinute = components.minute ?? 0
                            appSettings.lastModifiedDate = Date()
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )

                Text("All budget notifications will be delivered at this time")
                    .font(.caption)
                    .foregroundStyle(colors.textSecondary)
            } else {
                Text("Notifications are disabled. Category due date reminders will not appear.")
                    .font(.caption)
                    .foregroundStyle(colors.warning)
            }
        } header: {
            Text("NOTIFICATIONS")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(colors.textSecondary)
        } footer: {
            Text("Master switch for all budget notifications. Individual categories can still have their own notification settings.")
        }
        .onAppear {
            Task {
                await updatePermissionStatus()
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                Task {
                    await updatePermissionStatus()
                }
            }
        }
        .alert("Notification Permissions Required", isPresented: $showingPermissionDeniedAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") {
                NotificationManager.shared.openNotificationSettings()
            }
        } message: {
            Text("This app needs notification permissions to send budget reminders. Please enable notifications in Settings > ZeroBasedBudget > Notifications.")
        }
    }

    private var transactionFiltersSection: some View {
        Section {
            Toggle("Remember Transaction Filters", isOn: Binding(
                get: { appSettings.rememberTransactionFilters },
                set: { newValue in
                    appSettings.rememberTransactionFilters = newValue
                    appSettings.lastModifiedDate = Date()
                }
            ))
        } header: {
            Text("TRANSACTION FILTERS")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(colors.textSecondary)
        } footer: {
            Text("When enabled, your filter selections will be remembered between app sessions.")
        }
    }

    private var categorySortingSection: some View {
        Section {
            Toggle("Remember Category Sort Preferences", isOn: Binding(
                get: { appSettings.rememberCategorySortPreferences ?? false },
                set: { newValue in
                    appSettings.rememberCategorySortPreferences = newValue
                    appSettings.lastModifiedDate = Date()
                }
            ))
        } header: {
            Text("CATEGORY SORTING")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(colors.textSecondary)
        } footer: {
            Text("When enabled, your category sort preferences for each group will be remembered between app sessions.")
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
                    .foregroundStyle(colors.error)
            }

            // Storage Info
            HStack {
                Text("Storage")
                Spacer()
                Text("Local Only")
                    .foregroundStyle(colors.textSecondary)
            }
        } header: {
            Text("DATA MANAGEMENT")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(colors.textSecondary)
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
                Text("1.12.0")
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(colors.textSecondary)
            }

            // Build
            HStack {
                Text("Build")
                Spacer()
                Text("Notification Badge Clearing")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(colors.textSecondary)
            }

            // ZeroBudget Methodology
            Button {
                showingZeroBudgetMethodology = true
            } label: {
                Label("ZeroBudget Methodology", systemImage: "book")
            }

            // Privacy
            HStack {
                Text("Privacy")
                Spacer()
                Text("Local Only")
                    .foregroundStyle(colors.textSecondary)
            }

            // GitHub Link (placeholder)
            Button {
                // TODO: Open GitHub link
            } label: {
                Label("Feedback & Source Code", systemImage: "link")
            }
        } header: {
            Text("ABOUT")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(colors.textSecondary)
        } footer: {
            Text("Zero-Based Budget v1.12.0 • Built with SwiftUI & SwiftData • No cloud sync, complete privacy")
        }
    }

    private var ZeroBudgetMethodologySheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("ZeroBudget METHODOLOGY")
                        .font(.system(size: 24, weight: .semibold))
                        .tracking(1.0)
                        .foregroundStyle(colors.textPrimary)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("RULE 1: GIVE EVERY DOLLAR A JOB")
                            .font(.system(size: 13, weight: .semibold))
                            .tracking(0.6)
                            .foregroundStyle(colors.textSecondary)
                        Text("Budget only money you have RIGHT NOW, not money you expect to receive. Assign ALL of that money to categories until Ready to Assign = $0.")
                            .font(.system(size: 15, weight: .regular))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("RULE 2: EMBRACE YOUR TRUE EXPENSES")
                            .font(.system(size: 13, weight: .semibold))
                            .tracking(0.6)
                            .foregroundStyle(colors.textSecondary)
                        Text("Break up larger, less-frequent expenses into manageable monthly amounts. Save for annual insurance, quarterly taxes, or any irregular expense.")
                            .font(.system(size: 15, weight: .regular))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("RULE 3: ROLL WITH THE PUNCHES")
                            .font(.system(size: 13, weight: .semibold))
                            .tracking(0.6)
                            .foregroundStyle(colors.textSecondary)
                        Text("When life happens and you overspend, move money from another category. Your budget is flexible—adjust it as needed.")
                            .font(.system(size: 15, weight: .regular))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("RULE 4: AGE YOUR MONEY")
                            .font(.system(size: 13, weight: .semibold))
                            .tracking(0.6)
                            .foregroundStyle(colors.textSecondary)
                        Text("As you get ahead, you'll spend money you earned weeks or even months ago. This creates a buffer and reduces financial stress.")
                            .font(.system(size: 15, weight: .regular))
                    }

                    Text("This app follows ZeroBudget principles by tracking real account balances and helping you assign every dollar a specific job.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(colors.textSecondary)
                        .padding(.top, 8)
                }
                .padding()
            }
            .background(colors.background)
            .navigationTitle("ZeroBudget Methodology")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(colors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingZeroBudgetMethodology = false
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

    // MARK: - Notification Permission Helpers

    private var permissionStatusColor: Color {
        switch notificationPermissionStatus {
        case .authorized: return colors.success
        case .denied, .notDetermined: return colors.error
        default: return colors.warning
        }
    }

    private var permissionStatusText: String {
        switch notificationPermissionStatus {
        case .authorized: return "Granted"
        case .denied: return "Denied (Tap to Open Settings)"
        case .notDetermined: return "Not Requested"
        default: return "Unknown"
        }
    }

    private func updatePermissionStatus() async {
        notificationPermissionStatus = await NotificationManager.shared.checkAuthorizationStatus()
    }

    private func scheduleAllCategoryNotifications() async {
        let allCategories = categories
        let currencyCode = appSettings.currencyCode

        for category in allCategories {
            guard let dueDate = category.effectiveDueDate else { continue }

            await NotificationManager.shared.scheduleNotifications(
                for: category.notificationID,
                categoryName: category.name,
                budgetedAmount: category.budgetedAmount,
                dueDate: dueDate,
                notify7DaysBefore: category.notify7DaysBefore,
                notify2DaysBefore: category.notify2DaysBefore,
                notifyOnDueDate: category.notifyOnDueDate,
                notifyCustomDays: category.notifyCustomDays,
                customDaysCount: category.customDaysCount,
                currencyCode: currencyCode,
                notificationTimeHour: category.notificationTimeHour ?? appSettings.notificationTimeHour,
                notificationTimeMinute: category.notificationTimeMinute ?? appSettings.notificationTimeMinute
            )
        }
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
