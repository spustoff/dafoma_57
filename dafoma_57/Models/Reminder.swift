//
//  Reminder.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation

struct Reminder: Identifiable, Codable, Equatable {
    let id = UUID()
    var title: String
    var description: String
    var scheduledTime: Date
    var isRecurring: Bool = false
    var recurrenceType: RecurrenceType = .none
    var isCompleted: Bool = false
    var isEnabled: Bool = true
    var category: ReminderCategory
    var createdDate: Date = Date()
    var completedDate: Date?
    var notificationIdentifier: String?
    
    enum RecurrenceType: String, CaseIterable, Codable {
        case none = "None"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    enum ReminderCategory: String, CaseIterable, Codable {
        case work = "Work"
        case health = "Health"
        case personal = "Personal"
        case hobby = "Hobby"
        case exercise = "Exercise"
        case medication = "Medication"
        case appointment = "Appointment"
        case habit = "Habit"
        
        var icon: String {
            switch self {
            case .work: return "briefcase.fill"
            case .health: return "heart.fill"
            case .personal: return "person.fill"
            case .hobby: return "star.fill"
            case .exercise: return "figure.walk"
            case .medication: return "pills.fill"
            case .appointment: return "calendar"
            case .habit: return "repeat"
            }
        }
        
        var color: String {
            switch self {
            case .work: return "blue"
            case .health: return "red"
            case .personal: return "purple"
            case .hobby: return "pink"
            case .exercise: return "green"
            case .medication: return "orange"
            case .appointment: return "indigo"
            case .habit: return "teal"
            }
        }
    }
    
    var isOverdue: Bool {
        !isCompleted && scheduledTime < Date()
    }
    
    var timeUntilDue: TimeInterval {
        scheduledTime.timeIntervalSinceNow
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: scheduledTime)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: scheduledTime)
    }
    
    mutating func markCompleted() {
        isCompleted = true
        completedDate = Date()
        
        // If recurring, create next occurrence
        if isRecurring && recurrenceType != .none {
            scheduleNextOccurrence()
        }
    }
    
    mutating func scheduleNextOccurrence() {
        guard isRecurring else { return }
        
        let calendar = Calendar.current
        switch recurrenceType {
        case .daily:
            scheduledTime = calendar.date(byAdding: .day, value: 1, to: scheduledTime) ?? scheduledTime
        case .weekly:
            scheduledTime = calendar.date(byAdding: .weekOfYear, value: 1, to: scheduledTime) ?? scheduledTime
        case .monthly:
            scheduledTime = calendar.date(byAdding: .month, value: 1, to: scheduledTime) ?? scheduledTime
        case .none:
            break
        }
        
        isCompleted = false
        completedDate = nil
    }
    
    mutating func toggle() {
        if isCompleted {
            isCompleted = false
            completedDate = nil
        } else {
            markCompleted()
        }
    }
}

extension Reminder {
    static let sampleReminders: [Reminder] = [
        Reminder(
            title: "Morning Workout",
            description: "30 minutes of cardio and strength training",
            scheduledTime: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date(),
            isRecurring: true,
            recurrenceType: .daily,
            category: .exercise
        ),
        Reminder(
            title: "Take Vitamins",
            description: "Daily vitamin D and B12 supplements",
            scheduledTime: Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: Date()) ?? Date(),
            isRecurring: true,
            recurrenceType: .daily,
            category: .medication
        ),
        Reminder(
            title: "Team Meeting",
            description: "Weekly team sync and project updates",
            scheduledTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date(),
            isRecurring: true,
            recurrenceType: .weekly,
            category: .work
        ),
        Reminder(
            title: "Call Mom",
            description: "Weekly check-in call with family",
            scheduledTime: Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date(),
            isRecurring: true,
            recurrenceType: .weekly,
            category: .personal
        )
    ]
}
