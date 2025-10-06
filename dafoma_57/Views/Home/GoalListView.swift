//
//  GoalListView.swift
//  LifePulseW
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct GoalListView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var showingAddGoal = false
    @State private var showingGoalDetail = false
    @State private var selectedGoal: Goal?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with search and filter
            headerView
            
            // Goals list
            if viewModel.filteredGoals.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredGoals, id: \.id) { goal in
                            GoalRowView(goal: goal, viewModel: viewModel)
                                .onTapGesture {
                                    selectedGoal = goal
                                    showingGoalDetail = true
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView(viewModel: viewModel)
        }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailView(goal: goal, viewModel: viewModel)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("Search goals...", text: $viewModel.searchText)
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
            
            // Add goal button
            Button(action: {
                showingAddGoal = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add New Goal")
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
            
            Image(systemName: "target")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.white.opacity(0.4))
            
            VStack(spacing: 8) {
                Text("No Goals Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Create your first goal to start tracking your progress")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                showingAddGoal = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Your First Goal")
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

struct GoalRowView: View {
    let goal: Goal
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Category icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: goal.category.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(categoryColor)
            }
            
            // Goal info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(goal.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if goal.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                    } else if goal.isOverdue {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                    }
                }
                
                Text(goal.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                
                // Progress bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(Int(goal.progress * 100))%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(categoryColor)
                        
                        Spacer()
                        
                        Text(goal.daysRemaining >= 0 ? "\(goal.daysRemaining) days left" : "Overdue")
                            .font(.system(size: 12))
                            .foregroundColor(goal.isOverdue ? .red : .white.opacity(0.6))
                    }
                    
                    ProgressView(value: goal.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: categoryColor))
                        .scaleEffect(x: 1, y: 0.8, anchor: .center)
                }
            }
            
            // Completion toggle
            Button(action: {
                viewModel.toggleGoalCompletion(goal)
            }) {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(goal.isCompleted ? .green : .white.opacity(0.4))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var categoryColor: Color {
        switch goal.category.color {
        case "red": return .red
        case "blue": return Color(red: 0.004, green: 0.635, blue: 1.0)
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        default: return Color(red: 0.004, green: 0.635, blue: 1.0)
        }
    }
}

struct FilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color(red: 0.004, green: 0.635, blue: 1.0) : Color.white.opacity(0.1))
            )
        }
    }
}

// Placeholder views for sheets
struct AddGoalView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var description = ""
    @State private var targetDate = Date()
    @State private var selectedCategory = Goal.GoalCategory.personal
    
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
                
                VStack(spacing: 24) {
                    TextField("Goal title", text: $title)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    TextField("Description (optional)", text: $description)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                        .foregroundColor(.white)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Goal.GoalCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Create Goal") {
                        let newGoal = Goal(
                            title: title,
                            description: description,
                            targetDate: targetDate,
                            category: selectedCategory
                        )
                        viewModel.addGoal(newGoal)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty)
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(24)
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
    }
}

struct GoalDetailView: View {
    let goal: Goal
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
                        // Goal header
                        VStack(alignment: .leading, spacing: 12) {
                            Text(goal.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(goal.description)
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Progress section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Progress")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("\(Int(goal.progress * 100))%")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color(red: 0.004, green: 0.635, blue: 1.0))
                                    
                                    Spacer()
                                    
                                    Text(goal.isCompleted ? "Completed" : "In Progress")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(goal.isCompleted ? .green : .white.opacity(0.7))
                                }
                                
                                ProgressView(value: goal.progress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.004, green: 0.635, blue: 1.0)))
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
            .navigationTitle("Goal Details")
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

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.004, green: 0.635, blue: 1.0))
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
    }
}

#Preview {
    GoalListView(viewModel: HomeViewModel())
}
