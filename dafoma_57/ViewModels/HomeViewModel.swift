//
//  HomeViewModel.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var reminders: [Reminder] = []
    @Published var selectedGoal: Goal?
    @Published var selectedReminder: Reminder?
    @Published var showingAddGoal = false
    @Published var showingAddReminder = false
    @Published var showingGoalDetail = false
    @Published var showingReminderDetail = false
    @Published var searchText = ""
    @Published var selectedFilter: FilterType = .all
    
    private let dataService = DataPersistenceService.shared
    private let notificationService = NotificationService.shared
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
        case overdue = "Overdue"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .active: return "clock"
            case .completed: return "checkmark.circle"
            case .overdue: return "exclamationmark.triangle"
            }
        }
    }
    
    init() {
        loadData()
    }
    
    func loadData() {
        goals = dataService.loadGoals()
        reminders = dataService.loadReminders()
    }
    
    // MARK: - Goal Management
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        dataService.saveGoals(goals)
        
        // Schedule deadline notification
        notificationService.scheduleGoalDeadlineNotification(for: goal)
    }
    
    func updateGoal(_ updatedGoal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == updatedGoal.id }) {
            goals[index] = updatedGoal
            dataService.saveGoals(goals)
            
            // Update notifications
            notificationService.cancelGoalNotification(for: updatedGoal.id)
            if !updatedGoal.isCompleted {
                notificationService.scheduleGoalDeadlineNotification(for: updatedGoal)
            }
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        dataService.saveGoals(goals)
        notificationService.cancelGoalNotification(for: goal.id)
    }
    
    func toggleGoalCompletion(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isCompleted.toggle()
            if goals[index].isCompleted {
                goals[index].markCompleted()
            } else {
                goals[index].completedDate = nil
                goals[index].progress = min(goals[index].progress, 0.99)
            }
            dataService.saveGoals(goals)
        }
    }
    
    func updateGoalProgress(_ goal: Goal, progress: Double) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].updateProgress(progress)
            dataService.saveGoals(goals)
        }
    }
    
    // MARK: - Reminder Management
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        dataService.saveReminders(reminders)
        
        // Schedule notification
        if reminder.isEnabled {
            notificationService.scheduleReminderNotification(for: reminder)
        }
    }
    
    func updateReminder(_ updatedReminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == updatedReminder.id }) {
            let oldReminder = reminders[index]
            reminders[index] = updatedReminder
            dataService.saveReminders(reminders)
            
            // Update notifications
            notificationService.cancelNotification(for: oldReminder.id)
            if updatedReminder.isEnabled {
                notificationService.scheduleReminderNotification(for: updatedReminder)
            }
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        dataService.saveReminders(reminders)
        notificationService.cancelNotification(for: reminder.id)
    }
    
    func toggleReminderCompletion(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].toggle()
            dataService.saveReminders(reminders)
        }
    }
    
    func toggleReminderEnabled(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isEnabled.toggle()
            dataService.saveReminders(reminders)
            
            if reminders[index].isEnabled {
                notificationService.scheduleReminderNotification(for: reminders[index])
            } else {
                notificationService.cancelNotification(for: reminder.id)
            }
        }
    }
    
    // MARK: - Filtering and Search
    
    var filteredGoals: [Goal] {
        let filtered = goals.filter { goal in
            let matchesSearch = searchText.isEmpty || 
                               goal.title.localizedCaseInsensitiveContains(searchText) ||
                               goal.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .active:
                matchesFilter = !goal.isCompleted
            case .completed:
                matchesFilter = goal.isCompleted
            case .overdue:
                matchesFilter = goal.isOverdue
            }
            
            return matchesSearch && matchesFilter
        }
        
        return filtered.sorted { goal1, goal2 in
            if goal1.isCompleted != goal2.isCompleted {
                return !goal1.isCompleted
            }
            return goal1.targetDate < goal2.targetDate
        }
    }
    
    var filteredReminders: [Reminder] {
        let filtered = reminders.filter { reminder in
            let matchesSearch = searchText.isEmpty || 
                               reminder.title.localizedCaseInsensitiveContains(searchText) ||
                               reminder.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .active:
                matchesFilter = !reminder.isCompleted && reminder.isEnabled
            case .completed:
                matchesFilter = reminder.isCompleted
            case .overdue:
                matchesFilter = reminder.isOverdue
            }
            
            return matchesSearch && matchesFilter
        }
        
        return filtered.sorted { reminder1, reminder2 in
            if reminder1.isCompleted != reminder2.isCompleted {
                return !reminder1.isCompleted
            }
            return reminder1.scheduledTime < reminder2.scheduledTime
        }
    }
    
    // MARK: - Statistics
    
    var goalStatistics: (completed: Int, inProgress: Int, overdue: Int) {
        return dataService.getGoalStatistics()
    }
    
    var reminderStatistics: (total: Int, completed: Int, pending: Int, overdue: Int) {
        return dataService.getReminderStatistics()
    }
    
    var overallProgress: Double {
        return dataService.getCompletionRate()
    }
    
    var todayReminders: [Reminder] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        return reminders.filter { reminder in
            reminder.scheduledTime >= today && reminder.scheduledTime < tomorrow && !reminder.isCompleted
        }.sorted { $0.scheduledTime < $1.scheduledTime }
    }
    
    var upcomingGoals: [Goal] {
        let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
        
        return goals.filter { goal in
            !goal.isCompleted && goal.targetDate <= nextWeek
        }.sorted { $0.targetDate < $1.targetDate }
    }
    
    // MARK: - Actions
    
    func refreshData() {
        loadData()
    }
    
    func clearSearch() {
        searchText = ""
    }
    
    func resetFilter() {
        selectedFilter = .all
    }
}
