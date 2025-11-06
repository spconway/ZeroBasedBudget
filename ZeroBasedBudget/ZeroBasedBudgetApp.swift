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
    let container: ModelContainer

    init() {
        do {
            // Configure schema with all models
            let schema = Schema([
                Transaction.self,
                BudgetCategory.self,
                MonthlyBudget.self,
                Account.self,
                AppSettings.self
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
                    // Request notification permissions on app launch
                    await requestNotificationPermissions()
                }
        }
        .modelContainer(container)
    }

    // MARK: - Notification Permissions

    /// Request notification permissions on app launch
    private func requestNotificationPermissions() async {
        let granted = await NotificationManager.shared.requestAuthorization()
        if granted {
            print("✅ Notification permissions granted")
        } else {
            print("⚠️ Notification permissions denied")
        }
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
            } else {
                // Loading state (brief flash while theme initializes)
                Color.clear
                    .onAppear {
                        initializeTheme()
                    }
            }
        }
    }

    /// Initialize theme manager from AppSettings
    private func initializeTheme() {
        themeManager = ThemeManager(appSettings: appSettings, modelContext: modelContext)
    }
}
