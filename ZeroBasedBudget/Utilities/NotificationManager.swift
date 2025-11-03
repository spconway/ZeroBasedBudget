//
//  NotificationManager.swift
//  ZeroBasedBudget
//
//  Created by Claude Code on 2025-11-02.
//

import Foundation
import UserNotifications

/// Manages local push notifications for budget category due dates
@MainActor
class NotificationManager {

    static let shared = NotificationManager()

    private init() {}

    // MARK: - Permission Management

    /// Request notification permissions from the user
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }

    /// Check current notification authorization status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Notification Scheduling

    /// Schedule a notification for a budget category's due date
    /// - Parameters:
    ///   - category: The budget category
    ///   - dueDate: The due date for the notification
    func scheduleNotification(for categoryID: UUID, categoryName: String, budgetedAmount: Decimal, dueDate: Date) async {
        // Cancel any existing notification for this category
        await cancelNotification(for: categoryID)

        // Create notification identifier
        let identifier = notificationIdentifier(for: categoryID)

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Budget Due: \(categoryName)"
        content.body = "Your \(categoryName) budget of \(budgetedAmount.formatted(.currency(code: "USD"))) is due today."
        content.sound = .default
        content.badge = 1

        // Add category ID to userInfo for deep linking
        content.userInfo = ["categoryID": categoryID.uuidString]

        // Create trigger based on due date
        // Set notification for 9:00 AM on the due date
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: dueDate)
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // Create request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Schedule notification
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Scheduled notification for \(categoryName) on \(dueDate)")
        } catch {
            print("❌ Error scheduling notification: \(error)")
        }
    }

    /// Cancel notification for a specific category
    /// - Parameter categoryID: The category's UUID
    func cancelNotification(for categoryID: UUID) async {
        let identifier = notificationIdentifier(for: categoryID)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ Cancelled notification for category: \(categoryID)")
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Cancelled all pending notifications")
    }

    // MARK: - Notification Identifiers

    /// Generate notification identifier for a category
    /// - Parameter categoryID: The category's UUID
    /// - Returns: Notification identifier string
    private func notificationIdentifier(for categoryID: UUID) -> String {
        return "category-due-date-\(categoryID.uuidString)"
    }

    // MARK: - Debugging Helpers

    /// Get all pending notification requests (for debugging)
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }

    /// Print all pending notifications (for debugging)
    func printPendingNotifications() async {
        let requests = await getPendingNotifications()
        print("📋 Pending Notifications: \(requests.count)")
        for request in requests {
            print("  - \(request.identifier): \(request.content.title)")
        }
    }
}
