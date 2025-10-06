//
//  Goal.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation

struct Goal: Identifiable, Codable, Equatable {
    let id = UUID()
    var title: String
    var description: String
    var targetDate: Date
    var isCompleted: Bool = false
    var progress: Double = 0.0 // 0.0 to 1.0
    var category: GoalCategory
    var createdDate: Date = Date()
    var completedDate: Date?
    
    enum GoalCategory: String, CaseIterable, Codable {
        case health = "Health"
        case career = "Career"
        case personal = "Personal"
        case fitness = "Fitness"
        case learning = "Learning"
        case hobby = "Hobby"
        
        var icon: String {
            switch self {
            case .health: return "heart.fill"
            case .career: return "briefcase.fill"
            case .personal: return "person.fill"
            case .fitness: return "figure.walk"
            case .learning: return "book.fill"
            case .hobby: return "star.fill"
            }
        }
        
        var color: String {
            switch self {
            case .health: return "red"
            case .career: return "blue"
            case .personal: return "purple"
            case .fitness: return "green"
            case .learning: return "orange"
            case .hobby: return "pink"
            }
        }
    }
    
    var isOverdue: Bool {
        !isCompleted && targetDate < Date()
    }
    
    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
    }
    
    mutating func markCompleted() {
        isCompleted = true
        progress = 1.0
        completedDate = Date()
    }
    
    mutating func updateProgress(_ newProgress: Double) {
        progress = min(max(newProgress, 0.0), 1.0)
        if progress >= 1.0 && !isCompleted {
            markCompleted()
        }
    }
}

extension Goal {
    static let sampleGoals: [Goal] = [
        Goal(
            title: "Learn SwiftUI",
            description: "Master SwiftUI development by building 5 apps",
            targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date(),
            progress: 0.6,
            category: .learning
        ),
        Goal(
            title: "Run 5K Daily",
            description: "Build a habit of running 5K every morning",
            targetDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date(),
            progress: 0.3,
            category: .fitness
        ),
        Goal(
            title: "Read 12 Books",
            description: "Read one book per month this year",
            targetDate: Calendar.current.date(byAdding: .month, value: 12, to: Date()) ?? Date(),
            progress: 0.4,
            category: .personal
        )
    ]
}
