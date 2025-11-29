//
//  ZeroBasedBudgetApp.swift
//  ZeroBasedBudget
//
//  Created by Stephen Conway on 11/1/25.
//

import SwiftUI
import SwiftData

@main
struct ZeroBasedBudgetApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let container: ModelContainer

    init() {
        do {
            // Configure schema with all models
            let schema = Schema([
                Transaction.self,
                BudgetCategory.self,
                MonthlyBudget.self,
                Account.self,
                AppSettings.self,
                CategoryMonthlyBudget.self,
                CategoryGroup.self
            ])

            // Get application support directory
            let appSupportURL = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first!

            // Create app-specific directory
            let storeURL = appSupportURL.appendingPathComponent("ZeroBasedBudget")

            // Ensure directory exists BEFORE SwiftData tries to create store
            // This prevents "Failed to create file; code = 2" CoreData errors
            try FileManager.default.createDirectory(
                at: storeURL,
                withIntermediateDirectories: true,
                attributes: nil
            )

            // Configure ModelContainer with explicit URL and local-only storage (NO cloud sync)
            let configuration = ModelConfiguration(
                schema: schema,
                url: storeURL.appendingPathComponent("ZeroBasedBudget.store"),
                cloudKitDatabase: .none  // Explicitly disables cloud sync
            )

            // Initialize ModelContainer
            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to configure SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    // Check if notifications are enabled and schedule if permissions granted
                    await checkAndScheduleNotifications()
                    // Clear badge on app launch
                    await clearBadgeOnLaunch()
                }
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Clear badge when app becomes active (returns from background)
            if newPhase == .active {
                Task {
                    await clearBadgeOnLaunch()
                }
            }
        }
    }

    // MARK: - Notification Permissions

    /// Check if notifications are enabled in Settings AND permissions granted
    /// If both true, schedule notifications for all categories with due dates
    /// This handles the case where user denied initially, then manually granted in iOS Settings
    private func checkAndScheduleNotifications() async {
        // Get app settings
        guard let settings = try? container.mainContext.fetch(FetchDescriptor<AppSettings>()).first,
              settings.notificationsEnabled else {
            return
        }

        // Check if notification permissions are granted
        let status = await NotificationManager.shared.checkAuthorizationStatus()
        guard status == .authorized else {
            return
        }

        // Schedule notifications for all categories with due dates
        let categories = try? container.mainContext.fetch(FetchDescriptor<BudgetCategory>())
        for category in categories ?? [] {
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
                currencyCode: settings.currencyCode,
                notificationTimeHour: category.notificationTimeHour ?? settings.notificationTimeHour,
                notificationTimeMinute: category.notificationTimeMinute ?? settings.notificationTimeMinute
            )
        }
        print("✅ Scheduled notifications for all categories on app launch")
    }

    /// Clear badge when app becomes active
    /// This removes the notification badge from the app icon
    private func clearBadgeOnLaunch() async {
        await NotificationManager.shared.clearBadge()
    }
}

// MARK: - Root View (Theme Injection)

/// Root view that handles theme initialization and injection
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]

    @State private var themeManager: ThemeManager?

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

    var body: some View {
        Group {
            if let themeManager = themeManager {
                // Access currentTheme to create dependency for observation
                let currentTheme = themeManager.currentTheme

                ContentView()
                    .environment(\.theme, currentTheme)
                    .environment(\.themeManager, themeManager)
                    .id(currentTheme.identifier) // Force re-render when theme changes
            } else {
                // Loading state (brief flash while theme initializes)
                Color.clear
                    .onAppear {
                        initializeTheme()
                        migrateCategoriesToGroups()
                    }
            }
        }
    }

    /// Initialize theme manager from AppSettings
    private func initializeTheme() {
        themeManager = ThemeManager(appSettings: appSettings, modelContext: modelContext)
    }

    /// Migrate existing categories to category groups (one-time migration)
    private func migrateCategoriesToGroups() {
        CategoryGroupMigration.ensureDefaultGroupsExist(in: modelContext)
    }
}
