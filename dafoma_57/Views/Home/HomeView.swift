//
//  HomeView.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab = 0
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
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
                    // Header
                    headerView
                    
                    // Tab selector
                    tabSelectorView
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        dashboardView
                            .tag(0)
                        
                        GoalListView(viewModel: viewModel)
                            .tag(1)
                        
                        ReminderListView(viewModel: viewModel)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.loadData()
        }
        .sheet(isPresented: $showingProfile) {
            SettingsView()
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good \(timeOfDayGreeting)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Ready to achieve your goals?")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(action: {
                showingProfile = true
            }) {
                Circle()
                    .fill(Color(red: 0.004, green: 0.635, blue: 1.0))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
    
    private var tabSelectorView: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: tabIcon(for: index))
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(tabTitle(for: index))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(selectedTab == index ? .white : .white.opacity(0.6))
                        
                        Rectangle()
                            .fill(selectedTab == index ? Color(red: 0.004, green: 0.635, blue: 1.0) : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    private var dashboardView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Statistics cards
                statisticsCardsView
                
                // Today's reminders
                if !viewModel.todayReminders.isEmpty {
                    todayRemindersView
                }
                
                // Upcoming goals
                if !viewModel.upcomingGoals.isEmpty {
                    upcomingGoalsView
                }
                
                // Quick actions
                
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }
    
    private var statisticsCardsView: some View {
        VStack(spacing: 16) {
            Text("Your Progress")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Goals",
                    value: "\(viewModel.goalStatistics.completed)",
                    subtitle: "Completed",
                    icon: "target",
                    color: Color(red: 0.004, green: 0.635, blue: 1.0)
                )
                
                StatCard(
                    title: "Progress",
                    value: "\(Int(viewModel.overallProgress * 100))%",
                    subtitle: "Overall",
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color.green
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Reminders",
                    value: "\(viewModel.reminderStatistics.completed)",
                    subtitle: "Completed",
                    icon: "checkmark.circle",
                    color: Color.orange
                )
                
                StatCard(
                    title: "Streak",
                    value: "7",
                    subtitle: "Days",
                    icon: "flame",
                    color: Color.red
                )
            }
        }
    }
    
    private var todayRemindersView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Reminders")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.todayReminders.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.004, green: 0.635, blue: 1.0))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.004, green: 0.635, blue: 1.0).opacity(0.2))
                    )
            }
            
            ForEach(Array(viewModel.todayReminders.prefix(3)), id: \.id) { reminder in
                ReminderRowView(reminder: reminder, viewModel: viewModel)
            }
            
            if viewModel.todayReminders.count > 3 {
                Button("View All Reminders") {
                    selectedTab = 2
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.004, green: 0.635, blue: 1.0))
            }
        }
    }
    
    private var upcomingGoalsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Upcoming Goals")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.upcomingGoals.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.004, green: 0.635, blue: 1.0))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.004, green: 0.635, blue: 1.0).opacity(0.2))
                    )
            }
            
            ForEach(Array(viewModel.upcomingGoals.prefix(3)), id: \.id) { goal in
                GoalRowView(goal: goal, viewModel: viewModel)
            }
            
            if viewModel.upcomingGoals.count > 3 {
                Button("View All Goals") {
                    selectedTab = 1
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.004, green: 0.635, blue: 1.0))
            }
        }
    }
    
    private var quickActionsView: some View {
        VStack(spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                QuickActionButton(
                    title: "Add Goal",
                    icon: "plus.circle",
                    color: Color(red: 0.004, green: 0.635, blue: 1.0)
                ) {
                    viewModel.showingAddGoal = true
                }
                
                QuickActionButton(
                    title: "Add Reminder",
                    icon: "bell.badge.plus",
                    color: Color.orange
                ) {
                    viewModel.showingAddReminder = true
                }
            }
        }
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "target"
        case 2: return "bell.fill"
        default: return "house.fill"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Dashboard"
        case 1: return "Goals"
        case 2: return "Reminders"
        default: return "Dashboard"
        }
    }
    
    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Morning"
        case 12..<17: return "Afternoon"
        default: return "Evening"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
}

#Preview {
    HomeView()
}
