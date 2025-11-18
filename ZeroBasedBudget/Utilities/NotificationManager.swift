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

    /// Schedule notifications for a budget category based on frequency settings
    /// - Parameters:
    ///   - categoryID: The category's UUID
    ///   - categoryName: The category name
    ///   - budgetedAmount: The budgeted amount
    ///   - dueDate: The due date
    ///   - notify7DaysBefore: Schedule notification 7 days before
    ///   - notify2DaysBefore: Schedule notification 2 days before
    ///   - notifyOnDueDate: Schedule notification on due date
    ///   - notifyCustomDays: Schedule notification custom days before
    ///   - customDaysCount: Number of days before for custom notification
    ///   - currencyCode: Currency code for formatting amount (e.g., "USD", "EUR")
    ///   - notificationTimeHour: Hour for notification delivery (0-23), defaults to 9 AM
    ///   - notificationTimeMinute: Minute for notification delivery (0-59), defaults to 0
    func scheduleNotifications(
        for categoryID: UUID,
        categoryName: String,
        budgetedAmount: Decimal,
        dueDate: Date,
        notify7DaysBefore: Bool,
        notify2DaysBefore: Bool,
        notifyOnDueDate: Bool,
        notifyCustomDays: Bool,
        customDaysCount: Int,
        currencyCode: String = "USD",
        notificationTimeHour: Int = 9,
        notificationTimeMinute: Int = 0
    ) async {
        // Cancel any existing notifications for this category
        await cancelNotification(for: categoryID)

        let calendar = Calendar.current
        var notificationCount = 0

        // Schedule 7 days before notification
        if notify7DaysBefore, let notificationDate = calendar.date(byAdding: .day, value: -7, to: dueDate) {
            await scheduleNotification(
                categoryID: categoryID,
                categoryName: categoryName,
                budgetedAmount: budgetedAmount,
                notificationDate: notificationDate,
                dueDate: dueDate,
                type: .sevenDaysBefore,
                currencyCode: currencyCode,
                notificationTimeHour: notificationTimeHour,
                notificationTimeMinute: notificationTimeMinute
            )
            notificationCount += 1
        }

        // Schedule 2 days before notification
        if notify2DaysBefore, let notificationDate = calendar.date(byAdding: .day, value: -2, to: dueDate) {
            await scheduleNotification(
                categoryID: categoryID,
                categoryName: categoryName,
                budgetedAmount: budgetedAmount,
                notificationDate: notificationDate,
                dueDate: dueDate,
                type: .twoDaysBefore,
                currencyCode: currencyCode,
                notificationTimeHour: notificationTimeHour,
                notificationTimeMinute: notificationTimeMinute
            )
            notificationCount += 1
        }

        // Schedule on due date notification
        if notifyOnDueDate {
            await scheduleNotification(
                categoryID: categoryID,
                categoryName: categoryName,
                budgetedAmount: budgetedAmount,
                notificationDate: dueDate,
                dueDate: dueDate,
                type: .onDueDate,
                currencyCode: currencyCode,
                notificationTimeHour: notificationTimeHour,
                notificationTimeMinute: notificationTimeMinute
            )
            notificationCount += 1
        }

        // Schedule custom days before notification
        if notifyCustomDays, customDaysCount > 0, let notificationDate = calendar.date(byAdding: .day, value: -customDaysCount, to: dueDate) {
            await scheduleNotification(
                categoryID: categoryID,
                categoryName: categoryName,
                budgetedAmount: budgetedAmount,
                notificationDate: notificationDate,
                dueDate: dueDate,
                type: .customDays(customDaysCount),
                currencyCode: currencyCode,
                notificationTimeHour: notificationTimeHour,
                notificationTimeMinute: notificationTimeMinute
            )
            notificationCount += 1
        }

        print("✅ Scheduled \(notificationCount) notification(s) for \(categoryName)")
    }

    /// Schedule a single notification with specific timing
    private func scheduleNotification(
        categoryID: UUID,
        categoryName: String,
        budgetedAmount: Decimal,
        notificationDate: Date,
        dueDate: Date,
        type: NotificationType,
        currencyCode: String,
        notificationTimeHour: Int,
        notificationTimeMinute: Int
    ) async {
        // Create notification identifier
        let identifier = notificationIdentifier(for: categoryID, type: type)

        // Create notification content
        let content = UNMutableNotificationContent()
        let formattedAmount = budgetedAmount.formatted(.currency(code: currencyCode))

        switch type {
        case .sevenDaysBefore:
            content.title = "Budget Reminder: \(categoryName)"
            content.body = "Your \(categoryName) budget of \(formattedAmount) is due in 7 days."
        case .twoDaysBefore:
            content.title = "Budget Reminder: \(categoryName)"
            content.body = "Your \(categoryName) budget of \(formattedAmount) is due in 2 days."
        case .onDueDate:
            content.title = "Budget Due: \(categoryName)"
            content.body = "Your \(categoryName) budget of \(formattedAmount) is due today."
        case .customDays(let days):
            content.title = "Budget Reminder: \(categoryName)"
            content.body = "Your \(categoryName) budget of \(formattedAmount) is due in \(days) day\(days == 1 ? "" : "s")."
        }

        content.sound = .default
        content.badge = 1

        // Add category ID to userInfo for deep linking
        content.userInfo = ["categoryID": categoryID.uuidString]

        // Create trigger - Set notification for user-configured time
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: notificationDate)
        dateComponents.hour = notificationTimeHour
        dateComponents.minute = notificationTimeMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // Create request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Schedule notification
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("❌ Error scheduling \(type) notification: \(error)")
        }
    }

    /// Cancel all notifications for a specific category
    /// - Parameter categoryID: The category's UUID
    func cancelNotification(for categoryID: UUID) async {
        // Get all pending notifications and filter by category ID prefix
        // This catches all notification types including custom day variations
        let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let categoryPrefix = "category-\(categoryID.uuidString)"
        let categoryIdentifiers = pendingRequests
            .map { $0.identifier }
            .filter { $0.hasPrefix(categoryPrefix) }

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: categoryIdentifiers)
        print("🗑️ Cancelled \(categoryIdentifiers.count) notification(s) for category: \(categoryID)")
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Cancelled all pending notifications")
    }

    /// Clear app icon badge count
    /// Call this when user opens the app or views notifications to remove the badge indicator
    func clearBadge() async {
        do {
            try await UNUserNotificationCenter.current().setBadgeCount(0)
            print("✨ Badge cleared")
        } catch {
            print("❌ Error clearing badge: \(error)")
        }
    }

    /// Remove all delivered notifications from notification center
    /// This clears notifications from the notification list without affecting pending scheduled notifications
    func clearDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("🗑️ Cleared all delivered notifications")
    }

    // MARK: - Notification Identifiers

    /// Notification type for different timing options
    private enum NotificationType {
        case sevenDaysBefore
        case twoDaysBefore
        case onDueDate
        case customDays(Int)
    }

    /// Generate notification identifier for a category and type
    /// - Parameters:
    ///   - categoryID: The category's UUID
    ///   - type: The notification type
    /// - Returns: Notification identifier string
    private func notificationIdentifier(for categoryID: UUID, type: NotificationType) -> String {
        let baseIdentifier = "category-\(categoryID.uuidString)"
        switch type {
        case .sevenDaysBefore:
            return "\(baseIdentifier)-7days"
        case .twoDaysBefore:
            return "\(baseIdentifier)-2days"
        case .onDueDate:
            return "\(baseIdentifier)-duedate"
        case .customDays(let days):
            return "\(baseIdentifier)-custom\(days)days"
        }
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
