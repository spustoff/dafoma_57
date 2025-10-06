//
//  SettingsView.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAccountView = false
    
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile section
                        profileSection
                        
                        // Preferences section
                        preferencesSection
                        
                        // Statistics section
                        statisticsSection
                        
                        // About section
                        aboutSection
                        
                        // Danger zone
                        dangerZoneSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(red: 0.004, green: 0.635, blue: 1.0))
            )
        }
        .sheet(isPresented: $showingDeleteAccountView) {
            DeleteAccountView(viewModel: viewModel)
        }
        .alert("Delete Account", isPresented: $viewModel.showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                showingDeleteAccountView = true
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 16) {
            Text("Profile")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                // Profile picture placeholder
                Circle()
                    .fill(Color(red: 0.004, green: 0.635, blue: 1.0))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(viewModel.userPreferences.userName.isEmpty ? "?" : String(viewModel.userPreferences.userName.prefix(1).uppercased()))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                TextField("Your Name", text: $viewModel.userPreferences.userName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
                    .onSubmit {
                        viewModel.savePreferences()
                    }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    private var preferencesSection: some View {
        VStack(spacing: 16) {
            Text("Preferences")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Get reminded about your goals and tasks",
                    iconColor: Color(red: 0.004, green: 0.635, blue: 1.0)
                ) {
                    Toggle("", isOn: $viewModel.userPreferences.notificationsEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.004, green: 0.635, blue: 1.0)))
                        .onChange(of: viewModel.userPreferences.notificationsEnabled) { _ in
                            viewModel.savePreferences()
                        }
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                SettingsRow(
                    icon: "heart.fill",
                    title: "Motivational Notifications",
                    subtitle: "Daily inspiration and encouragement",
                    iconColor: .red
                ) {
                    Toggle("", isOn: $viewModel.userPreferences.motivationalNotificationsEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.004, green: 0.635, blue: 1.0)))
                        .disabled(!viewModel.userPreferences.notificationsEnabled)
                        .onChange(of: viewModel.userPreferences.motivationalNotificationsEnabled) { _ in
                            viewModel.savePreferences()
                        }
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                SettingsRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    subtitle: "Always enabled for better focus",
                    iconColor: .purple
                ) {
                    Toggle("", isOn: $viewModel.userPreferences.darkModeEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.004, green: 0.635, blue: 1.0)))
                        .disabled(true) // Always dark mode
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            Text("Statistics")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let stats = viewModel.statisticsData
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    StatisticCard(
                        title: "Goals Completed",
                        value: "\(stats.goals.completed)",
                        icon: "target",
                        color: Color(red: 0.004, green: 0.635, blue: 1.0)
                    )
                    
                    StatisticCard(
                        title: "Reminders Done",
                        value: "\(stats.reminders.completed)",
                        icon: "checkmark.circle",
                        color: .green
                    )
                }
                
                HStack(spacing: 16) {
                    StatisticCard(
                        title: "Overall Progress",
                        value: "\(Int(stats.completionRate * 100))%",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .orange
                    )
                    
                    StatisticCard(
                        title: "Active Goals",
                        value: "\(stats.goals.inProgress)",
                        icon: "clock",
                        color: .purple
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    private var aboutSection: some View {
        VStack(spacing: 16) {
            Text("About")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Version",
                    subtitle: "App version \(viewModel.appVersion) (\(viewModel.buildNumber))",
                    iconColor: Color(red: 0.004, green: 0.635, blue: 1.0)
                ) {
                    EmptyView()
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    private var dangerZoneSection: some View {
        VStack(spacing: 16) {
            Text("Danger Zone")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                Button(action: {
                    viewModel.showingResetDataAlert = true
                }) {
                    SettingsRow(
                        icon: "arrow.clockwise.circle.fill",
                        title: "Reset All Data",
                        subtitle: "Clear all goals and reminders",
                        iconColor: .orange
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                Button(action: {
                    viewModel.showingDeleteAccountAlert = true
                }) {
                    SettingsRow(
                        icon: "trash.fill",
                        title: "Delete Account",
                        subtitle: "Permanently delete all data",
                        iconColor: .red
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .alert("Reset All Data", isPresented: $viewModel.showingResetDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetAllData()
            }
        } message: {
            Text("This will delete all your goals and reminders. This action cannot be undone.")
        }
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            content
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

#Preview {
    SettingsView()
}
