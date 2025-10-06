//
//  SettingsViewModel.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var userPreferences: DataPersistenceService.UserPreferences
    @Published var showingDeleteAccountAlert = false
    @Published var showingResetDataAlert = false
    @Published var showingAboutSheet = false
    @Published var showingPrivacySheet = false
    @Published var isDeleting = false
    
    private let dataService = DataPersistenceService.shared
    private let notificationService = NotificationService.shared
    
    init() {
        self.userPreferences = dataService.loadUserPreferences()
    }
    
    func savePreferences() {
        dataService.saveUserPreferences(userPreferences)
        
        // Update notification settings
        if userPreferences.notificationsEnabled {
            notificationService.requestPermission()
            if userPreferences.motivationalNotificationsEnabled {
                notificationService.scheduleMotivationalNotification()
            }
        } else {
            notificationService.cancelAllNotifications()
        }
    }
    
    func updateUserName(_ name: String) {
        userPreferences.userName = name
        savePreferences()
    }
    
    func toggleNotifications() {
        userPreferences.notificationsEnabled.toggle()
        savePreferences()
    }
    
    func toggleMotivationalNotifications() {
        userPreferences.motivationalNotificationsEnabled.toggle()
        savePreferences()
    }
    
    func toggleDarkMode() {
        userPreferences.darkModeEnabled.toggle()
        savePreferences()
    }
    
    func addPreferredCategory(_ category: Goal.GoalCategory) {
        if !userPreferences.preferredCategories.contains(category.rawValue) {
            userPreferences.preferredCategories.append(category.rawValue)
            savePreferences()
        }
    }
    
    func removePreferredCategory(_ category: Goal.GoalCategory) {
        userPreferences.preferredCategories.removeAll { $0 == category.rawValue }
        savePreferences()
    }
    
    func resetAllData() {
        isDeleting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dataService.resetAllData()
            self.userPreferences = DataPersistenceService.UserPreferences()
            self.isDeleting = false
            
            // This will trigger the app to return to onboarding
            NotificationCenter.default.post(name: .accountDeleted, object: nil)
        }
    }
    
    func exportData() -> String {
        let goals = dataService.loadGoals()
        let reminders = dataService.loadReminders()
        
        var exportString = "LifePulseW Data Export\n"
        exportString += "Generated on: \(Date())\n\n"
        
        exportString += "GOALS (\(goals.count)):\n"
        exportString += "==================\n"
        for goal in goals {
            exportString += "• \(goal.title)\n"
            exportString += "  Description: \(goal.description)\n"
            exportString += "  Category: \(goal.category.rawValue)\n"
            exportString += "  Progress: \(Int(goal.progress * 100))%\n"
            exportString += "  Target Date: \(DateFormatter.mediumDate.string(from: goal.targetDate))\n"
            exportString += "  Status: \(goal.isCompleted ? "Completed" : "In Progress")\n\n"
        }
        
        exportString += "REMINDERS (\(reminders.count)):\n"
        exportString += "=====================\n"
        for reminder in reminders {
            exportString += "• \(reminder.title)\n"
            exportString += "  Description: \(reminder.description)\n"
            exportString += "  Category: \(reminder.category.rawValue)\n"
            exportString += "  Scheduled: \(DateFormatter.mediumDateTime.string(from: reminder.scheduledTime))\n"
            exportString += "  Recurring: \(reminder.isRecurring ? reminder.recurrenceType.rawValue : "No")\n"
            exportString += "  Status: \(reminder.isCompleted ? "Completed" : "Pending")\n\n"
        }
        
        return exportString
    }
    
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var statisticsData: (goals: (completed: Int, inProgress: Int, overdue: Int), 
                        reminders: (total: Int, completed: Int, pending: Int, overdue: Int),
                        completionRate: Double) {
        let goalStats = dataService.getGoalStatistics()
        let reminderStats = dataService.getReminderStatistics()
        let completionRate = dataService.getCompletionRate()
        
        return (goals: goalStats, reminders: reminderStats, completionRate: completionRate)
    }
}

extension Notification.Name {
    static let accountDeleted = Notification.Name("accountDeleted")
}

extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    static let mediumDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
