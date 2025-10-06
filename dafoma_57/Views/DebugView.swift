//
//  DebugView.swift
//  LifePulseW
//
//  Демонстрационный файл для тестирования @AppStorage онбординга
//

import SwiftUI

struct DebugView: View {
    @AppStorage("LifePulseW_OnboardingCompleted") private var isOnboardingCompleted = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Debug: Onboarding Status")
                .font(.title)
                .foregroundColor(.white)
            
            Text("Onboarding Completed: \(isOnboardingCompleted ? "Yes" : "No")")
                .font(.headline)
                .foregroundColor(isOnboardingCompleted ? .green : .red)
            
            Button("Toggle Onboarding Status") {
                isOnboardingCompleted.toggle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Reset Onboarding") {
                isOnboardingCompleted = false
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Text("Этот экран показывает, как @AppStorage автоматически синхронизирует состояние онбординга")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
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
}

#Preview {
    DebugView()
}
