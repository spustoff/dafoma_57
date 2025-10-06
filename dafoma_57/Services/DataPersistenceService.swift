//
//  DataPersistenceService.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation

class DataPersistenceService: ObservableObject {
    static let shared = DataPersistenceService()
    
    private let goalsKey = "LifePulseW_Goals"
    private let remindersKey = "LifePulseW_Reminders"
    private let onboardingCompletedKey = "LifePulseW_OnboardingCompleted"
    private let userPreferencesKey = "LifePulseW_UserPreferences"
    
    private init() {}
    
    // MARK: - Goals Management
    
    func saveGoals(_ goals: [Goal]) {
        do {
            let data = try JSONEncoder().encode(goals)
            UserDefaults.standard.set(data, forKey: goalsKey)
            print("Goals saved successfully")
        } catch {
            print("Error saving goals: \(error)")
        }
    }
    
    func loadGoals() -> [Goal] {
        guard let data = UserDefaults.standard.data(forKey: goalsKey) else {
            print("No saved goals found, returning sample data")
            return Goal.sampleGoals
        }
        
        do {
            let goals = try JSONDecoder().decode([Goal].self, from: data)
            print("Goals loaded successfully: \(goals.count) goals")
            return goals
        } catch {
            print("Error loading goals: \(error)")
            return Goal.sampleGoals
        }
    }
    
    func addGoal(_ goal: Goal) {
        var goals = loadGoals()
        goals.append(goal)
        saveGoals(goals)
    }
    
    func updateGoal(_ updatedGoal: Goal) {
        var goals = loadGoals()
        if let index = goals.firstIndex(where: { $0.id == updatedGoal.id }) {
            goals[index] = updatedGoal
            saveGoals(goals)
        }
    }
    
    func deleteGoal(withId id: UUID) {
        var goals = loadGoals()
        goals.removeAll { $0.id == id }
        saveGoals(goals)
        
        // Cancel associated notifications
        NotificationService.shared.cancelGoalNotification(for: id)
    }
    
    // MARK: - Reminders Management
    
    func saveReminders(_ reminders: [Reminder]) {
        do {
            let data = try JSONEncoder().encode(reminders)
            UserDefaults.standard.set(data, forKey: remindersKey)
            print("Reminders saved successfully")
        } catch {
            print("Error saving reminders: \(error)")
        }
    }
    
    func loadReminders() -> [Reminder] {
        guard let data = UserDefaults.standard.data(forKey: remindersKey) else {
            print("No saved reminders found, returning sample data")
            return Reminder.sampleReminders
        }
        
        do {
            let reminders = try JSONDecoder().decode([Reminder].self, from: data)
            print("Reminders loaded successfully: \(reminders.count) reminders")
            return reminders
        } catch {
            print("Error loading reminders: \(error)")
            return Reminder.sampleReminders
        }
    }
    
    func addReminder(_ reminder: Reminder) {
        var reminders = loadReminders()
        reminders.append(reminder)
        saveReminders(reminders)
        
        // Schedule notification if enabled
        if reminder.isEnabled {
            NotificationService.shared.scheduleReminderNotification(for: reminder)
        }
    }
    
    func updateReminder(_ updatedReminder: Reminder) {
        var reminders = loadReminders()
        if let index = reminders.firstIndex(where: { $0.id == updatedReminder.id }) {
            let oldReminder = reminders[index]
            reminders[index] = updatedReminder
            saveReminders(reminders)
            
            // Update notifications
            NotificationService.shared.cancelNotification(for: oldReminder.id)
            if updatedReminder.isEnabled {
                NotificationService.shared.scheduleReminderNotification(for: updatedReminder)
            }
        }
    }
    
    func deleteReminder(withId id: UUID) {
        var reminders = loadReminders()
        reminders.removeAll { $0.id == id }
        saveReminders(reminders)
        
        // Cancel associated notifications
        NotificationService.shared.cancelNotification(for: id)
    }
    
    // MARK: - Onboarding Management
    // Онбординг теперь управляется через @AppStorage в ContentView
    // Ключ: "LifePulseW_OnboardingCompleted"
    
    // MARK: - User Preferences
    
    struct UserPreferences: Codable {
        var notificationsEnabled: Bool = true
        var motivationalNotificationsEnabled: Bool = true
        var darkModeEnabled: Bool = false
        var userName: String = ""
        var preferredCategories: [String] = []
    }
    
    func saveUserPreferences(_ preferences: UserPreferences) {
        do {
            let data = try JSONEncoder().encode(preferences)
            UserDefaults.standard.set(data, forKey: userPreferencesKey)
            print("User preferences saved successfully")
        } catch {
            print("Error saving user preferences: \(error)")
        }
    }
    
    func loadUserPreferences() -> UserPreferences {
        guard let data = UserDefaults.standard.data(forKey: userPreferencesKey) else {
            print("No saved preferences found, returning defaults")
            return UserPreferences()
        }
        
        do {
            let preferences = try JSONDecoder().decode(UserPreferences.self, from: data)
            print("User preferences loaded successfully")
            return preferences
        } catch {
            print("Error loading user preferences: \(error)")
            return UserPreferences()
        }
    }
    
    // MARK: - Data Reset (for account deletion)
    
    func resetAllData() {
        // Cancel all notifications
        NotificationService.shared.cancelAllNotifications()
        
        // Clear all stored data
        UserDefaults.standard.removeObject(forKey: goalsKey)
        UserDefaults.standard.removeObject(forKey: remindersKey)
        UserDefaults.standard.removeObject(forKey: "LifePulseW_OnboardingCompleted") // @AppStorage ключ
        UserDefaults.standard.removeObject(forKey: userPreferencesKey)
        
        print("All user data has been reset")
    }
    
    // MARK: - Statistics and Insights
    
    func getGoalStatistics() -> (completed: Int, inProgress: Int, overdue: Int) {
        let goals = loadGoals()
        let completed = goals.filter { $0.isCompleted }.count
        let overdue = goals.filter { $0.isOverdue }.count
        let inProgress = goals.count - completed
        
        return (completed: completed, inProgress: inProgress, overdue: overdue)
    }
    
    func getReminderStatistics() -> (total: Int, completed: Int, pending: Int, overdue: Int) {
        let reminders = loadReminders()
        let total = reminders.count
        let completed = reminders.filter { $0.isCompleted }.count
        let overdue = reminders.filter { $0.isOverdue }.count
        let pending = total - completed
        
        return (total: total, completed: completed, pending: pending, overdue: overdue)
    }
    
    func getCompletionRate() -> Double {
        let goals = loadGoals()
        guard !goals.isEmpty else { return 0.0 }
        
        let totalProgress = goals.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(goals.count)
    }
}
