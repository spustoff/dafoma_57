//
//  OnboardingStepView.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct OnboardingStepView: View {
    let step: OnboardingStep
    let isActive: Bool
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var animateIcon = false
    @State private var animateText = false
    
    var body: some View {
        VStack(spacing: 40) {
            // Icon with animation
            ZStack {
                Circle()
                    .fill(step.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateIcon ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 0.6).delay(0.2), value: animateIcon)
                
                Image(systemName: step.imageName)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(step.color)
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateIcon)
            }
            
            // Text content
            VStack(spacing: 16) {
                Text(step.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeInOut(duration: 0.6).delay(0.6), value: animateText)
                
                Text(step.subtitle)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(step.color)
                    .multilineTextAlignment(.center)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeInOut(duration: 0.6).delay(0.8), value: animateText)
                
                Text(step.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeInOut(duration: 0.6).delay(1.0), value: animateText)
            }
            
            // Special content for specific steps
            if viewModel.currentStep == 1 {
                goalCategoriesView
            } else if viewModel.currentStep == 2 {
                notificationPermissionView
            } else if viewModel.currentStep == 3 {
                userNameInputView
            }
        }
        .padding(.horizontal, 32)
        .onChange(of: isActive) { newValue in
            if newValue {
                withAnimation {
                    animateIcon = true
                    animateText = true
                }
            } else {
                animateIcon = false
                animateText = false
            }
        }
        .onAppear {
            if isActive {
                withAnimation {
                    animateIcon = true
                    animateText = true
                }
            }
        }
    }
    
    private var goalCategoriesView: some View {
        VStack(spacing: 16) {
            Text("Choose your interests")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .opacity(animateText ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6).delay(1.2), value: animateText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(Goal.GoalCategory.allCases, id: \.self) { category in
                    Button(action: {
                        if viewModel.selectedCategories.contains(category) {
                            viewModel.selectedCategories.remove(category)
                        } else {
                            viewModel.selectedCategories.insert(category)
                        }
                    }) {
                        HStack {
                            Image(systemName: category.icon)
                                .font(.system(size: 16, weight: .medium))
                            Text(category.rawValue)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(viewModel.selectedCategories.contains(category) ? .white : .white.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(viewModel.selectedCategories.contains(category) ? 
                                     Color(red: 0.004, green: 0.635, blue: 1.0) : 
                                     Color.white.opacity(0.1))
                        )
                    }
                }
            }
            .opacity(animateText ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.6).delay(1.4), value: animateText)
        }
    }
    
    private var notificationPermissionView: some View {
        VStack(spacing: 16) {
            Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.004, green: 0.635, blue: 1.0)))
                .opacity(animateText ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6).delay(1.2), value: animateText)
            
            Text("Get reminded about your goals and daily activities")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .opacity(animateText ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6).delay(1.4), value: animateText)
        }
        .padding(.horizontal, 20)
    }
    
    private var userNameInputView: some View {
        VStack(spacing: 16) {
            TextField("Enter your name (optional)", text: $viewModel.userName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
                .opacity(animateText ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6).delay(1.2), value: animateText)
            
            Text("We'll use this to personalize your experience")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .opacity(animateText ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6).delay(1.4), value: animateText)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    OnboardingStepView(
        step: OnboardingStep(
            title: "Welcome to LifePulseW",
            subtitle: "Your personal lifestyle companion",
            description: "Transform your daily routine with smart goal tracking, intelligent reminders, and personalized insights.",
            imageName: "heart.fill",
            color: Color(red: 0.004, green: 0.635, blue: 1.0)
        ),
        isActive: true,
        viewModel: OnboardingViewModel()
    )
    .background(
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.035, green: 0.059, blue: 0.118),
                Color(red: 0.102, green: 0.137, blue: 0.224)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
