//
//  HomeView.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation

import SwiftUI
import SwiftData

// MARK: - Home View
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingTutorialPrompt = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
//                    WelcomeCard()
                    
                    // Quick Actions
                    QuickActionsGrid()
                    
                    // Upcoming Events Preview
                    UpcomingEventsPreview()
                    
                    // Tutorial Progress
                    TutorialProgressCard()
                }
                .padding()
            }
            .navigationTitle("Welcome")
//            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingTutorialPrompt) {
            TutorialPromptView()
        }
    }
}

// MARK: - Tutorials View
struct TutorialsView: View {
    let tutorials = TutorialCategory.allCategories
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tutorials) { category in
                    NavigationLink(destination: TutorialDetailView(category: category)) {
                        TutorialCategoryRow(category: category)
                    }
                }
            }
            .navigationTitle("Learn Digital Skills")
            .listStyle(.insetGrouped)
        }
    }
}

// MARK: - Events View
struct EventsView: View {
    @Query private var events: [Event]
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Custom Calendar View
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                List {
                    ForEach(filterEvents(for: selectedDate)) { event in
                        EventRow(event: event)
                    }
                }
            }
            .navigationTitle("Events")
            .toolbar {
                Button("Add Event") {
                    // Show add event sheet
                }
                .font(.system(size: 18))
            }
        }
    }
    
    private func filterEvents(for date: Date) -> [Event] {
        // Filter events for selected date
        return events
    }
}

// MARK: - Supporting Views
//struct WelcomeCard: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Hello!")
//                .font(.system(size: 28, weight: .bold))
//
//            Text("What would you like to learn today?")
//                .font(.system(size: 20))
//
//            HStack(spacing: 16) {
//                NavigationLink(destination: TutorialsView()) {
//                    ActionButton(
//                        title: "Start Learning",
//                        icon: "book.fill",
//                        color: .blue
//                    )
//                }
//
//                NavigationLink(destination: EventsView()) {
//                    ActionButton(
//                        title: "Join Events",
//                        icon: "calendar",
//                        color: .green
//                    )
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(15)
//        .shadow(radius: 2)
//    }
//}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 16, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TutorialCategoryRow: View {
    let category: TutorialCategory
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: category.icon)
                .font(.system(size: 24))
                .foregroundColor(category.color)
                .frame(width: 44, height: 44)
                .background(category.color.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 18, weight: .medium))
                Text(category.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct EventRow: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.system(size: 18, weight: .medium))
            
            HStack {
                Image(systemName: "clock")
                Text(event.date.formatted(date: .abbreviated, time: .shortened))
            }
            .font(.system(size: 16))
            .foregroundColor(.secondary)
            
            Text(event.desc)
                .font(.system(size: 16))
                .lineLimit(2)
            
            Button("RSVP") {
                // Handle RSVP
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Tutorial Models
struct TutorialCategory: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: Color
    
    static let allCategories = [
        TutorialCategory(
            name: "Smartphone Basics",
            description: "Learn essential smartphone operations",
            icon: "iphone",
            color: .blue
        ),
        TutorialCategory(
            name: "Internet Safety",
            description: "Stay safe while browsing online",
            icon: "lock.shield",
            color: .green
        ),
        TutorialCategory(
            name: "Social Media",
            description: "Connect with friends and family",
            icon: "person.2",
            color: .purple
        ),
        TutorialCategory(
            name: "Smart Home",
            description: "Control your smart home devices",
            icon: "homekit",
            color: .orange
        )
    ]
}

// MARK: - Tutorial Detail View
struct TutorialDetailView: View {
    let category: TutorialCategory
    @State private var currentStep = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Tutorial Header
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 40))
                        .foregroundColor(category.color)
                    
                    VStack(alignment: .leading) {
                        Text(category.name)
                            .font(.system(size: 24, weight: .bold))
                        Text(category.description)
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // Tutorial Steps
                ForEach(getTutorialSteps(), id: \.title) { step in
                    TutorialStepCard(
                        step: step,
                        isActive: currentStep == step.order,
                        isCompleted: currentStep > step.order
                    )
                    .onTapGesture {
                        withAnimation {
                            currentStep = step.order
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getTutorialSteps() -> [TutorialStep] {
        // Return appropriate steps based on category
        switch category.name {
        case "Smartphone Basics":
            return [
                TutorialStep(order: 0, title: "Turning On Your Device", content: "Learn how to power on and unlock your device safely."),
                TutorialStep(order: 1, title: "Understanding the Home Screen", content: "Navigate your home screen and understand app icons."),
                TutorialStep(order: 2, title: "Basic Gestures", content: "Master essential touch gestures like tap, swipe, and pinch.")
            ]
        default:
            return []
        }
    }
}

// MARK: - Tutorial Prompt View
struct TutorialPromptView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Welcome to Senior Connect!")
                .font(.system(size: 24, weight: .bold))
            
            Text("Would you like to start with our beginner-friendly tutorial?")
                .font(.system(size: 18))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button("Maybe Later") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Start Tutorial") {
                    // Navigate to first tutorial
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
        .padding()
    }
}

// MARK: - Tutorial Progress Card
struct TutorialProgressCard: View {
    @State private var progress: Double = 0.3 // Example progress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Learning Progress")
                .font(.system(size: 20, weight: .bold))
            
            ProgressView(value: progress)
                .tint(.blue)
                .scaleEffect(y: 2)
            
            HStack {
                Text("\(Int(progress * 100))% Complete")
                    .foregroundColor(.secondary)
                Spacer()
                Text("3/10 Topics")
                    .foregroundColor(.secondary)
            }
            .font(.system(size: 16))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

// MARK: - Upcoming Events Preview
struct UpcomingEventsPreview: View {
    @Query private var events: [Event]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Events")
                .font(.system(size: 20, weight: .bold))
            
            if events.isEmpty {
                Text("No upcoming events")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(Array(events.prefix(3))) { event in
                    EventPreviewRow(event: event)
                }
            }
            
            NavigationLink("View All Events") {
                EventsView()
            }
            .font(.system(size: 16, weight: .medium))
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

// MARK: - Quick Actions Grid
struct QuickActionsGrid: View {
    let actions = [
        QuickAction(title: "Join Tutorial", icon: "book.fill", color: .blue),
        QuickAction(title: "Find Events", icon: "calendar", color: .green),
        QuickAction(title: "Get Help", icon: "questionmark.circle.fill", color: .purple),
        QuickAction(title: "Settings", icon: "gear", color: .gray)
    ]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(actions) { action in
                QuickActionButton(action: action)
            }
        }
    }
}

// MARK: - Supporting Structures
struct TutorialStep: Identifiable {
    let id = UUID()
    let order: Int
    let title: String
    let content: String
}

struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

// MARK: - Supporting Views
struct TutorialStepCard: View {
    let step: TutorialStep
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(isCompleted ? .green : (isActive ? .blue : .gray))
                .frame(width: 30, height: 30)
                .overlay {
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                    } else {
                        Text("\(step.order + 1)")
                            .foregroundColor(.white)
                    }
                }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(step.title)
                    .font(.system(size: 18, weight: .medium))
                
                if isActive {
                    Text(step.content)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading, 8)
            
            Spacer()
        }
        .padding()
        .background(isActive ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let action: QuickAction
    
    var body: some View {
        Button {
            // Handle action
        } label: {
            VStack(spacing: 12) {
                Image(systemName: action.icon)
                    .font(.system(size: 30))
                    .foregroundColor(action.color)
                
                Text(action.title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(action.color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct EventPreviewRow: View {
    let event: Event
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 16, weight: .medium))
                
                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
