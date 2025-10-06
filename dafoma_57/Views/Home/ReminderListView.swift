//
//  ReminderListView.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct ReminderListView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var showingAddReminder = false
    @State private var showingReminderDetail = false
    @State private var selectedReminder: Reminder?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with search and filter
            headerView
            
            // Reminders list
            if viewModel.filteredReminders.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredReminders, id: \.id) { reminder in
                            ReminderRowView(reminder: reminder, viewModel: viewModel)
                                .onTapGesture {
                                    selectedReminder = reminder
                                    showingReminderDetail = true
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(viewModel: viewModel)
        }
        .sheet(item: $selectedReminder) { reminder in
            ReminderDetailView(reminder: reminder, viewModel: viewModel)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("Search reminders...", text: $viewModel.searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
            
            // Filter buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(HomeViewModel.FilterType.allCases, id: \.self) { filter in
                        FilterButton(
                            title: filter.rawValue,
                            icon: filter.icon,
                            isSelected: viewModel.selectedFilter == filter
                        ) {
                            viewModel.selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Add reminder button
            Button(action: {
                showingAddReminder = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add New Reminder")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.004, green: 0.635, blue: 1.0))
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "bell")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.white.opacity(0.4))
            
            VStack(spacing: 8) {
                Text("No Reminders Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Create your first reminder to stay organized")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                showingAddReminder = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Your First Reminder")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(red: 0.004, green: 0.635, blue: 1.0))
                )
            }
            
            Spacer()
        }
    }
}

struct ReminderRowView: View {
    let reminder: Reminder
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Category icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: reminder.category.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(categoryColor)
            }
            
            // Reminder info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(reminder.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if reminder.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                    } else if reminder.isOverdue {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                    } else if !reminder.isEnabled {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                if !reminder.description.isEmpty {
                    Text(reminder.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                // Time and recurrence info
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(categoryColor)
                        
                        Text(reminder.formattedTime)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(categoryColor)
                    }
                    
                    if reminder.isRecurring && reminder.recurrenceType != .none {
                        HStack(spacing: 4) {
                            Image(systemName: "repeat")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(reminder.recurrenceType.rawValue)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    if !Calendar.current.isDateInToday(reminder.scheduledTime) {
                        Text(reminder.formattedDate)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            // Completion toggle
            Button(action: {
                viewModel.toggleReminderCompletion(reminder)
            }) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(reminder.isCompleted ? .green : .white.opacity(0.4))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
        .opacity(reminder.isEnabled ? 1.0 : 0.6)
    }
    
    private var categoryColor: Color {
        switch reminder.category.color {
        case "blue": return Color(red: 0.004, green: 0.635, blue: 1.0)
        case "red": return .red
        case "purple": return .purple
        case "pink": return .pink
        case "green": return .green
        case "orange": return .orange
        case "indigo": return .indigo
        case "teal": return .teal
        default: return Color(red: 0.004, green: 0.635, blue: 1.0)
        }
    }
}

// Placeholder views for sheets
struct AddReminderView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var description = ""
    @State private var scheduledTime = Date()
    @State private var selectedCategory = Reminder.ReminderCategory.personal
    @State private var isRecurring = false
    @State private var recurrenceType = Reminder.RecurrenceType.none
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.035, green: 0.059, blue: 0.118),
                        Color(red: 0.102, green: 0.137, blue: 0.224)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        TextField("Reminder title", text: $title)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        TextField("Description (optional)", text: $description)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        DatePicker("Scheduled Time", selection: $scheduledTime)
                            .foregroundColor(.white)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(Reminder.ReminderCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .foregroundColor(.white)
                        
                        Toggle("Recurring", isOn: $isRecurring)
                            .foregroundColor(.white)
                            .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.004, green: 0.635, blue: 1.0)))
                        
                        if isRecurring {
                            Picker("Recurrence", selection: $recurrenceType) {
                                ForEach(Reminder.RecurrenceType.allCases, id: \.self) { type in
                                    if type != .none {
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        Spacer()
                        
                        Button("Create Reminder") {
                            let newReminder = Reminder(
                                title: title,
                                description: description,
                                scheduledTime: scheduledTime,
                                isRecurring: isRecurring,
                                recurrenceType: isRecurring ? recurrenceType : .none,
                                category: selectedCategory
                            )
                            viewModel.addReminder(newReminder)
                            presentationMode.wrappedValue.dismiss()
                        }
                        .disabled(title.isEmpty)
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(24)
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
        .onChange(of: isRecurring) { newValue in
            if newValue && recurrenceType == .none {
                recurrenceType = .daily
            }
        }
    }
}

struct ReminderDetailView: View {
    let reminder: Reminder
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.035, green: 0.059, blue: 0.118),
                        Color(red: 0.102, green: 0.137, blue: 0.224)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Reminder header
                        VStack(alignment: .leading, spacing: 12) {
                            Text(reminder.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            if !reminder.description.isEmpty {
                                Text(reminder.description)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // Schedule section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Schedule")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color(red: 0.004, green: 0.635, blue: 1.0))
                                    Text(reminder.formattedDate)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(Color(red: 0.004, green: 0.635, blue: 1.0))
                                    Text(reminder.formattedTime)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                if reminder.isRecurring {
                                    HStack {
                                        Image(systemName: "repeat")
                                            .foregroundColor(Color(red: 0.004, green: 0.635, blue: 1.0))
                                        Text("Repeats \(reminder.recurrenceType.rawValue.lowercased())")
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                        
                        // Status section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Status")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : 
                                      reminder.isOverdue ? "exclamationmark.triangle.fill" : "clock")
                                    .foregroundColor(reminder.isCompleted ? .green : 
                                                   reminder.isOverdue ? .red : Color(red: 0.004, green: 0.635, blue: 1.0))
                                
                                Text(reminder.isCompleted ? "Completed" : 
                                     reminder.isOverdue ? "Overdue" : "Pending")
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    viewModel.toggleReminderEnabled(reminder)
                                }) {
                                    Image(systemName: reminder.isEnabled ? "bell.fill" : "bell.slash")
                                        .foregroundColor(reminder.isEnabled ? Color(red: 0.004, green: 0.635, blue: 1.0) : .white.opacity(0.4))
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Reminder Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
    }
}

#Preview {
    ReminderListView(viewModel: HomeViewModel())
}
