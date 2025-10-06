//
//  OnboardingView.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var animateContent = false
    @AppStorage("LifePulseW_OnboardingCompleted") private var isOnboardingCompleted = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.035, green: 0.059, blue: 0.118), // #090F1E
                    Color(red: 0.102, green: 0.137, blue: 0.224)  // #1A2339
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                VStack(spacing: 16) {
                    HStack {
                        ForEach(0..<viewModel.onboardingSteps.count, id: \.self) { index in
                            Rectangle()
                                .fill(index <= viewModel.currentStep ? 
                                     Color(red: 0.004, green: 0.635, blue: 1.0) : 
                                     Color.white.opacity(0.3))
                                .frame(height: 4)
                                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    HStack {
                        Text("Step \(viewModel.currentStep + 1) of \(viewModel.onboardingSteps.count)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        if !viewModel.isLastStep {
                            Button("Skip") {
                                viewModel.skipToEnd()
                            }
                            .font(.caption)
                            .foregroundColor(Color(red: 0.004, green: 0.635, blue: 1.0))
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Content
                TabView(selection: $viewModel.currentStep) {
                    ForEach(0..<viewModel.onboardingSteps.count, id: \.self) { index in
                        OnboardingStepView(
                            step: viewModel.onboardingSteps[index],
                            isActive: index == viewModel.currentStep,
                            viewModel: viewModel
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentStep)
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if !viewModel.isFirstStep {
                        Button(action: {
                            viewModel.previousStep()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    
                    Button(action: {
                        if viewModel.isLastStep {
                            viewModel.completeOnboarding()
                            // @AppStorage автоматически обновится и переключит UI
                        } else {
                            viewModel.nextStep()
                        }
                    }) {
                        HStack {
                            Text(viewModel.isLastStep ? "Get Started" : "Continue")
                            if !viewModel.isLastStep {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(red: 0.004, green: 0.635, blue: 1.0))
                        )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateContent = true
            }
        }
    }
}

#Preview {
    OnboardingView()
}
