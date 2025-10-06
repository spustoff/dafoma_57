//
//  NotificationService.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
            }
        }
    }
    
    func scheduleReminderNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.description.isEmpty ? "Time for your reminder!" : reminder.description
        content.sound = .default
        content.badge = 1
        
        // Create date components from the scheduled time
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.scheduledTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: reminder.isRecurring && reminder.recurrenceType != .none)
        
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for reminder: \(reminder.title)")
            }
        }
    }
    
    func cancelNotification(for reminderId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderId.uuidString])
    }
    
    func scheduleGoalDeadlineNotification(for goal: Goal) {
        guard !goal.isCompleted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Goal Deadline Approaching"
        content.body = "Your goal '\(goal.title)' is due soon!"
        content.sound = .default
        content.badge = 1
        
        // Schedule notification 1 day before the target date
        let notificationDate = Calendar.current.date(byAdding: .day, value: -1, to: goal.targetDate) ?? goal.targetDate
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "goal_\(goal.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling goal notification: \(error)")
            } else {
                print("Goal deadline notification scheduled for: \(goal.title)")
            }
        }
    }
    
    func cancelGoalNotification(for goalId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["goal_\(goalId.uuidString)"])
    }
    
    func scheduleMotivationalNotification() {
        let motivationalMessages = [
            "Keep pushing towards your goals! 💪",
            "Every small step counts! 🌟",
            "You're making great progress! 🎯",
            "Stay focused on your dreams! ✨",
            "Believe in yourself! 🚀"
        ]
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Motivation"
        content.body = motivationalMessages.randomElement() ?? "Keep going!"
        content.sound = .default
        
        // Schedule for 9 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_motivation",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling motivational notification: \(error)")
            } else {
                print("Daily motivational notification scheduled")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
}
