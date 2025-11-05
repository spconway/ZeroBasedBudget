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
                Account.self
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
            ContentView()
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
