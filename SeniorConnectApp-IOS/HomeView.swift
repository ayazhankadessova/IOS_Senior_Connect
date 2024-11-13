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
// MARK: - Models for Lessons and Tutorials
struct Lesson: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let videoURL: String?
    let steps: [LessonStep]
    var isCompleted: Bool
    var savedForLater: Bool
    var needsMentorHelp: Bool
}

struct LessonStep: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let actionItems: [ActionItem]
    var isCompleted: Bool
}

struct ActionItem: Identifiable, Codable {
    let id: String
    let task: String
    var isCompleted: Bool
    var needsHelp: Bool
}

// Update TutorialCategory
struct TutorialCategory: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: Color
    let lessons: [Lesson]?
    
    static let allCategories = [
        TutorialCategory(
            name: "Smartphone Basics",
            description: "Learn essential smartphone operations",
            icon: "iphone",
            color: .blue,
            lessons: [
                Lesson(
                    id: "intro",
                    title: "Introduction to Android",
                    description: "Learn how to navigate through Android basics",
                    videoURL: "video_url_1",
                    steps: [
                        LessonStep(
                            id: "step1",
                            title: "Getting Started",
                            description: "Basic navigation and controls",
                            actionItems: [
                                ActionItem(id: "1", task: "Locate and test the power button", isCompleted: false, needsHelp: false),
                                ActionItem(id: "2", task: "Practice volume controls", isCompleted: false, needsHelp: false),
                                ActionItem(id: "3", task: "Try different sound modes", isCompleted: false, needsHelp: false)
                            ],
                            isCompleted: false
                        )
                    ],
                    isCompleted: false,
                    savedForLater: false,
                    needsMentorHelp: false
                ),
                Lesson(
                    id: "setup",
                    title: "Phone Setup & Controls",
                    description: "Master phone settings and basic controls",
                    videoURL: "video_url_2",
                    steps: [
                        LessonStep(
                            id: "step1",
                            title: "Basic Controls",
                            description: "Learn about essential phone controls",
                            actionItems: [
                                ActionItem(id: "1", task: "Practice using power button", isCompleted: false, needsHelp: false),
                                ActionItem(id: "2", task: "Adjust volume settings", isCompleted: false, needsHelp: false),
                                ActionItem(id: "3", task: "Use notification panel", isCompleted: false, needsHelp: false)
                            ],
                            isCompleted: false
                        ),
                        LessonStep(
                            id: "step2",
                            title: "Phone Settings",
                            description: "Configure basic phone settings",
                            actionItems: [
                                ActionItem(id: "1", task: "Adjust display brightness", isCompleted: false, needsHelp: false),
                                ActionItem(id: "2", task: "Set up sound profiles", isCompleted: false, needsHelp: false)
                            ],
                            isCompleted: false
                        )
                    ],
                    isCompleted: false,
                    savedForLater: false,
                    needsMentorHelp: false
                ),
                Lesson(
                    id: "homescreen",
                    title: "Home Screen Customization",
                    description: "Learn to personalize your home screen",
                    videoURL: "video_url_3",
                    steps: [
                        LessonStep(
                            id: "step1",
                            title: "App Management",
                            description: "Learn to organize your apps",
                            actionItems: [
                                ActionItem(id: "1", task: "Add apps to home screen", isCompleted: false, needsHelp: false),
                                ActionItem(id: "2", task: "Create app folders", isCompleted: false, needsHelp: false),
                                ActionItem(id: "3", task: "Arrange apps and folders", isCompleted: false, needsHelp: false)
                            ],
                            isCompleted: false
                        ),
                        LessonStep(
                            id: "step2",
                            title: "Widgets",
                            description: "Add and customize widgets",
                            actionItems: [
                                ActionItem(id: "1", task: "Add a calendar widget", isCompleted: false, needsHelp: false),
                                ActionItem(id: "2", task: "Add weather widget", isCompleted: false, needsHelp: false),
                                ActionItem(id: "3", task: "Resize widgets", isCompleted: false, needsHelp: false)
                            ],
                            isCompleted: false
                        )
                    ],
                    isCompleted: false,
                    savedForLater: false,
                    needsMentorHelp: false
                ),
                Lesson(
                            id: "sharing",
                            title: "Sharing Content",
                            description: "Learn how to share content with others through various apps",
                            videoURL: "video_url_4",
                            steps: [
                                LessonStep(
                                    id: "share1",
                                    title: "Share Pictures",
                                    description: "Learn how to share photos from your gallery",
                                    actionItems: [
                                        ActionItem(id: "s1", task: "Open Gallery and select a photo", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "s2", task: "Tap the share button (arrow icon)", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "s3", task: "Practice sending a photo via message", isCompleted: false, needsHelp: false)
                                    ],
                                    isCompleted: false
                                ),
                                LessonStep(
                                    id: "share2",
                                    title: "Share from Apps",
                                    description: "Share content from different applications",
                                    actionItems: [
                                        ActionItem(id: "s4", task: "Share a YouTube video link", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "s5", task: "Use the paperclip in messages to share content", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "s6", task: "Pin frequently used sharing options", isCompleted: false, needsHelp: false)
                                    ],
                                    isCompleted: false
                                ),
                                LessonStep(
                                    id: "share3",
                                    title: "Advanced Sharing",
                                    description: "Learn additional sharing features",
                                    actionItems: [
                                        ActionItem(id: "s7", task: "Share to multiple apps at once", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "s8", task: "Copy links for sharing later", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "s9", task: "Customize your quick share options", isCompleted: false, needsHelp: false)
                                    ],
                                    isCompleted: false
                                )
                            ],
                            isCompleted: false,
                            savedForLater: false,
                            needsMentorHelp: false
                        ),
                        
                        Lesson(
                            id: "keyboard",
                            title: "Keyboard Mastery",
                            description: "Master the Android keyboard features and settings",
                            videoURL: "video_url_5",
                            steps: [
                                LessonStep(
                                    id: "key1",
                                    title: "Basic Keyboard Controls",
                                    description: "Learn fundamental keyboard operations",
                                    actionItems: [
                                        ActionItem(id: "k1", task: "Practice showing/hiding keyboard", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "k2", task: "Switch between letter and number modes", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "k3", task: "Use shift key for capitalization", isCompleted: false, needsHelp: false)
                                    ],
                                    isCompleted: false
                                ),
                                LessonStep(
                                    id: "key2",
                                    title: "Special Features",
                                    description: "Explore advanced keyboard features",
                                    actionItems: [
                                        ActionItem(id: "k4", task: "Try voice-to-text input", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "k5", task: "Use emoji keyboard", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "k6", task: "Practice one-handed keyboard mode", isCompleted: false, needsHelp: false)
                                    ],
                                    isCompleted: false
                                ),
                                LessonStep(
                                    id: "key3",
                                    title: "Keyboard Settings",
                                    description: "Customize your keyboard experience",
                                    actionItems: [
                                        ActionItem(id: "k7", task: "Adjust keyboard size", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "k8", task: "Configure autocorrect settings", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "k9", task: "Set up keyboard shortcuts", isCompleted: false, needsHelp: false)
                                    ],
                                    isCompleted: false
                                ),
                                LessonStep(
                                    id: "key4",
                                    title: "Text Editing",
                                    description: "Master text editing features",
                                    actionItems: [
                                        ActionItem(id: "k10", task: "Practice copy and paste", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "k11", task: "Use text selection tools", isCompleted: false, needsHelp: false),
                                        ActionItem(id: "k12", task: "Try clipboard features", isCompleted: false, needsHelp: false)
                                    ],
                                    isCompleted: false
                                )
                            ],
                            isCompleted: false,
                            savedForLater: false,
                            needsMentorHelp: false
                        )
            ]
        ),
        TutorialCategory(
            name: "Internet Safety",
            description: "Stay safe while browsing online",
            icon: "lock.shield",
            color: .green,
            lessons: nil
        ),
        TutorialCategory(
            name: "Social Media",
            description: "Connect with friends and family",
            icon: "person.2",
            color: .purple,
            lessons: nil
        ),
        TutorialCategory(
            name: "Smart Home",
            description: "Control your smart home devices",
            icon: "homekit",
            color: .orange,
            lessons: nil
        )
    ]
}

// MARK: - ViewModel for managing tutorial state
class TutorialViewModel: ObservableObject {
    @Published var selectedLesson: Lesson?
    @Published var currentStep: Int = 0
    
    func updateLessonProgress(_ lesson: Lesson) {
        // Update lesson progress in your data store
    }
    
    func requestMentorHelp(for lesson: Lesson) {
        // Handle mentor help request
    }
    
    func saveForLater(_ lesson: Lesson) {
        // Save lesson for later
    }
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
                
                if let lessons = category.lessons {
                    // Show lessons
                    ForEach(lessons, id: \.id) { lesson in
                        NavigationLink(destination: LessonDetailView(lesson: .constant(lesson))) {
                            LessonRowView(lesson: lesson)
                        }
                    }
                } else {
                    // Show default tutorial steps
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
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getTutorialSteps() -> [TutorialStep] {
        // Your existing getTutorialSteps implementation
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

struct LessonRowView: View {
    let lesson: Lesson
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(lesson.title)
                        .font(.headline)
                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if lesson.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            if lesson.needsMentorHelp {
                Label("Help Requested", systemImage: "person.fill.questionmark")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct VideoPlayerView: View {
    let videoURL: String
    
    var body: some View {
        VStack {
            // Placeholder for video player
            Text("Video Player")
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
            
            Text("Video URL: \(videoURL)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct LessonDetailView: View {
    @Binding var lesson: Lesson
    @StateObject private var viewModel = TutorialViewModel()
    @State private var showingVideo = false
    @State private var showingMentorRequest = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Video Section
                if let videoURL = lesson.videoURL {
                    Button {
                        showingVideo = true
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                            
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }
                        .cornerRadius(12)
                    }
                }
                
                // Lesson Content
                ForEach(lesson.steps.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(lesson.steps[index].title)
                            .font(.headline)
                        
                        Text(lesson.steps[index].description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Action Items
                        ForEach(lesson.steps[index].actionItems) { item in
                            HStack {
                                Button {
                                    // Toggle completion
                                } label: {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isCompleted ? .green : .gray)
                                }
                                
                                Text(item.task)
                                    .strikethrough(item.isCompleted)
                                
                                Spacer()
                                
                                if !item.isCompleted {
                                    Button {
                                        showingMentorRequest = true
                                    } label: {
                                        Image(systemName: "questionmark.circle")
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                
                // Action Buttons
                HStack {
                    Button {
                        lesson.savedForLater.toggle()
                    } label: {
                        Label(
                            lesson.savedForLater ? "Saved" : "Save for Later",
                            systemImage: lesson.savedForLater ? "bookmark.fill" : "bookmark"
                        )
                    }
                    
                    Spacer()
                    
                    Button {
                        showingMentorRequest = true
                    } label: {
                        Label("Request Help", systemImage: "person.fill.questionmark")
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle(lesson.title)
        .sheet(isPresented: $showingVideo) {
            VideoPlayerView(videoURL: lesson.videoURL ?? "")
        }
        .alert("Request Mentor Help", isPresented: $showingMentorRequest) {
            Button("Cancel", role: .cancel) { }
            Button("Request Help") {
                lesson.needsMentorHelp = true
            }
        } message: {
            Text("Would you like to request help from a mentor for this lesson?")
        }
    }
}
