//
//  LifePulseWApp.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

@main
struct LifePulseWApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: .accountDeleted)) { _ in
                    // Сброс состояния онбординга при удалении аккаунта
                    UserDefaults.standard.removeObject(forKey: "LifePulseW_OnboardingCompleted")
                }
        }
    }
}
