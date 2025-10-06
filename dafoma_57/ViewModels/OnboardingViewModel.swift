//
//  OnboardingViewModel.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var userName = ""
    @Published var selectedCategories: Set<Goal.GoalCategory> = []
    @Published var notificationsEnabled = true
    
    private let dataService = DataPersistenceService.shared
    private let notificationService = NotificationService.shared
    
    let onboardingSteps = [
        OnboardingStep(
            title: "Welcome to LifePulseW",
            subtitle: "Your personal lifestyle companion",
            description: "Transform your daily routine with smart goal tracking, intelligent reminders, and personalized insights.",
            imageName: "heart.fill",
            color: Color(red: 0.004, green: 0.635, blue: 1.0) // #01A2FF
        ),
        OnboardingStep(
            title: "Set & Achieve Goals",
            subtitle: "Turn dreams into reality",
            description: "Create meaningful goals, track your progress with beautiful visualizations, and celebrate every milestone.",
            imageName: "target",
            color: Color(red: 0.004, green: 0.635, blue: 1.0)
        ),
        OnboardingStep(
            title: "Smart Reminders",
            subtitle: "Never miss what matters",
            description: "Set intelligent reminders for your daily activities, habits, and important tasks. Stay organized effortlessly.",
            imageName: "bell.fill",
            color: Color(red: 0.004, green: 0.635, blue: 1.0)
        ),
        OnboardingStep(
            title: "Daily Insights",
            subtitle: "Understand your progress",
            description: "Get personalized insights into your habits and achievements. See your growth over time with detailed analytics.",
            imageName: "chart.line.uptrend.xyaxis",
            color: Color(red: 0.004, green: 0.635, blue: 1.0)
        )
    ]
    
    init() {
        // Инициализация без проверки состояния онбординга
        // Состояние теперь управляется через @AppStorage в ContentView
    }
    
    func nextStep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentStep < onboardingSteps.count - 1 {
                currentStep += 1
            } else {
                completeOnboarding()
            }
        }
    }
    
    func previousStep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentStep > 0 {
                currentStep -= 1
            }
        }
    }
    
    func skipToEnd() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = onboardingSteps.count - 1
        }
    }
    
    func completeOnboarding() {
        // Save user preferences
        var preferences = dataService.loadUserPreferences()
        preferences.userName = userName
        preferences.notificationsEnabled = notificationsEnabled
        preferences.preferredCategories = selectedCategories.map { $0.rawValue }
        dataService.saveUserPreferences(preferences)
        
        // Request notification permissions if enabled
        if notificationsEnabled {
            notificationService.requestPermission()
            notificationService.scheduleMotivationalNotification()
        }
        
        // Mark onboarding as completed через @AppStorage
        UserDefaults.standard.set(true, forKey: "LifePulseW_OnboardingCompleted")
    }
    
    func resetOnboarding() {
        currentStep = 0
        userName = ""
        selectedCategories.removeAll()
        notificationsEnabled = true
        // Сброс состояния онбординга через @AppStorage
        UserDefaults.standard.removeObject(forKey: "LifePulseW_OnboardingCompleted")
    }
    
    var progress: Double {
        return Double(currentStep + 1) / Double(onboardingSteps.count)
    }
    
    var isFirstStep: Bool {
        return currentStep == 0
    }
    
    var isLastStep: Bool {
        return currentStep == onboardingSteps.count - 1
    }
    
    var currentOnboardingStep: OnboardingStep {
        return onboardingSteps[currentStep]
    }
}

struct OnboardingStep {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let color: Color
}
