//
//  DeleteAccountView.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct DeleteAccountView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var confirmationText = ""
    @State private var showingFinalConfirmation = false
    
    private let requiredText = "DELETE"
    
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
                
                if viewModel.isDeleting {
                    deletingView
                } else {
                    confirmationView
                }
            }
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                .disabled(viewModel.isDeleting)
            )
        }
        .alert("Final Confirmation", isPresented: $showingFinalConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Forever", role: .destructive) {
                viewModel.resetAllData()
            }
        } message: {
            Text("Are you absolutely sure? This action cannot be undone and all your data will be permanently deleted.")
        }
    }
    
    private var confirmationView: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Warning icon
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.red)
                    }
                    
                    Text("Delete Account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Warning message
                VStack(spacing: 16) {
                    Text("This action is permanent and cannot be undone.")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    
                    Text("Deleting your account will:")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        WarningItem(text: "Permanently delete all your goals and progress")
                        WarningItem(text: "Remove all your reminders and notifications")
                        WarningItem(text: "Clear all your personal data and preferences")
                        WarningItem(text: "Reset the app to its initial state")
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Confirmation input
                VStack(spacing: 16) {
                    Text("To confirm deletion, type \"DELETE\" below:")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Type DELETE to confirm", text: $confirmationText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(confirmationText == requiredText ? Color.red : Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                }
                
                // Delete button
                Button(action: {
                    showingFinalConfirmation = true
                }) {
                    HStack {
                        if confirmationText == requiredText {
                            Image(systemName: "trash.fill")
                        }
                        Text("Delete My Account Forever")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(confirmationText == requiredText ? Color.red : Color.white.opacity(0.1))
                    )
                }
                .disabled(confirmationText != requiredText)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }
    
    private var deletingView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Loading animation
            VStack(spacing: 24) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                    .scaleEffect(1.5)
                
                Text("Deleting Account...")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Please wait while we remove all your data")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct WarningItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.red)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    DeleteAccountView(viewModel: SettingsViewModel())
}
