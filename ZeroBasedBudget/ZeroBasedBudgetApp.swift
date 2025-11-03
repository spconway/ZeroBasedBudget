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
                MonthlyBudget.self
            ])

            // Configure ModelContainer with local-only storage (NO cloud sync)
            let configuration = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .none  // Explicitly disables cloud sync
            )

            // Initialize ModelContainer
            container = try ModelContainer(
                for: schema,
                configurations: configuration
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
