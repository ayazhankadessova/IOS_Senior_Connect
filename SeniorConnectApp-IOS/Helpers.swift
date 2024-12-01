//
//  Helpers.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation
import SwiftUI

struct QuickActionsGrid: View {
    @EnvironmentObject var navigation: NavigationViewModel
    
    let actions = [
        QuickAction(title: "Join Tutorial", icon: "book.fill", color: .blue, tab: .tutorials),
        QuickAction(title: "Find Events", icon: "calendar", color: .green, tab: .events),
        QuickAction(title: "Get Help", icon: "questionmark.circle.fill", color: .purple, tab: .help),
        QuickAction(title: "Settings", icon: "gear", color: .gray, tab: .profile)
    ]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(actions) { action in
                QuickActionButton(action: action)
                    .onTapGesture {
                        navigation.selectedTab = action.tab
                    }
            }
        }
    }
}

struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let tab: Tab
}

enum Tab {
    case tutorials
    case events
    case help
    case profile
    case home
}

class NavigationViewModel: ObservableObject {
    @Published var selectedTab: Tab = .home
}

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
    let totalLessons: Int
    let completedLessons: Int // Added to track completed lessons
    let totalTopics: Int = 10 // Total number of topics
    let completedTopics: Int = 3 // Completed topics
    
    // Calculate progress as a Float between 0 and 1
    private var progress: Float {
        guard totalLessons > 0 else { return 0 }
        return Float(completedLessons) / Float(totalLessons)
    }
    
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
                Text("\(completedTopics)/\(totalTopics) Topics")
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

struct QuickActionButton: View {
    let action: QuickAction
    
    var body: some View {
        VStack {
            Image(systemName: action.icon)
                .font(.largeTitle)
                .foregroundColor(action.color)
            Text(action.title)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

struct OverallProgressView: View {
    let progress: OverallProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overall Progress")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Completed Lessons")
                    Text("\(progress.totalLessonsCompleted)")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                if progress.averageQuizScore > 0 {
                    VStack(alignment: .leading) {
                        Text("Quiz Average")
                        Text("\(Int(progress.averageQuizScore))%")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Text("Last Activity: \(progress.lastActivityDate)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct TagView: View {
    let tag: String
    
    var body: some View {
        Text("#\(tag)")
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(.systemGray6))
            .foregroundColor(.secondary)
            .cornerRadius(8)
    }
}


// MARK: - Upcoming Events Preview
struct UpcomingEventsPreview: View {
    @StateObject private var viewModel: EventViewModel
    @EnvironmentObject var authService: AuthService
    
    // Add initializer
    init() {
        self._viewModel = StateObject(wrappedValue: EventViewModel(authService: AuthService()))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Events")
                .font(.system(size: 20, weight: .bold))
            
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.upcomingEvents.isEmpty {
                Text("No upcoming events")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(viewModel.upcomingEvents.prefix(3)) { event in
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
        .task {
            await viewModel.fetchUpcomingEvents()
        }
        .onAppear {
            viewModel.updateAuthService(authService)
        }
    }
}

struct ContactCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "phone.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Need immediate assistance?")
                    .font(.headline)
            }
            
            Text("Call our support team:")
                .foregroundColor(.secondary)
            
            Button(action: {
                guard let url = URL(string: "tel://+85292888547") else { return }
                UIApplication.shared.open(url)
            }) {
                Text("+852 9288 8547")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct FAQCard: View {
    let faq: FAQ
    let expanded: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: action) {
                HStack {
                    Text(faq.question)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        .animation(.easeInOut, value: expanded)
                }
            }
            
            if expanded {
                Text(faq.answer)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                    .transition(.opacity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MentorshipRequestCard: View {
    let request: MentorshipRequest
    @EnvironmentObject var authService: AuthService
    @ObservedObject var viewModel: HelpViewModel
    @State private var showDeleteAlert = false
    @State private var navigateToDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(request.topic)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                StatusBadge(status: request.status)
                Spacer()
                Text(request.formattedDate ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .contextMenu {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete Request", systemImage: "trash")
            }
        }
        .onTapGesture {
            navigateToDetail = true
        }
        .background(
            NavigationLink(isActive: $navigateToDetail,
                         destination: { MentorshipRequestDetailView(request: request) },
                         label: { EmptyView() })
        )
        .alert("Delete Request", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let userId = authService.currentUser?.id,
                   let requestId = request.id {
                    print("🗑️ Delete button tapped")
                    print("UserID: \(userId)")
                    print("RequestID: \(requestId)")
                    viewModel.deleteMentorshipRequest(userId: userId, requestId: requestId)
                } else {
                    print("❌ Missing userId or requestId")
                    print("UserID: \(authService.currentUser?.id ?? "nil")")
                    print("RequestID: \(request.id ?? "nil")")
                }
            }
        } message: {
            Text("Are you sure you want to delete this mentorship request? This action cannot be undone.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct StatusBadge: View {
    let status: String
    
    var statusColor: Color {
        switch status.lowercased() {
        case "pending": return .orange
        case "accepted": return .green
        case "completed": return .blue
        default: return .gray
        }
    }
    
    var body: some View {
        Text(status)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
}

struct EmptyRequestsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.square.dashed")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No mentorship requests yet")
                .font(.headline)
            
            Text("Start your learning journey by requesting mentorship below")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MentorRequestForm: View {
    @Binding var formData: MentorRequestFormData
    @Binding var showForm: Bool
    let delegate: MentorRequestFormDelegate
    let title: String
    let subtitle: String?
    let isStandalone: Bool
    
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    private let skillLevels = ["Beginner", "Intermediate", "Advanced"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if isStandalone {
                        FormField(
                            title: "Topic",
                            placeholder: "What would you like to learn?",
                            text: $formData.topic,
                            icon: "book.fill"
                        )
                    }
                    
                    // Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(.blue)
                            Text("Description")
                                .font(.headline)
                        }
                        
                        TextEditor(text: $formData.description)
                            .frame(height: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.2))
                            )
                    }
                    
                    // Phone Number Field
                    FormField(
                        title: "Phone Number",
                        placeholder: "Enter your phone number",
                        text: $formData.phoneNumber,
                        icon: "phone.fill",
                        keyboardType: .phonePad
                    )
                    
                    // Skill Level Picker
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "stairs")
                                .foregroundColor(.blue)
                            Text("Skill Level")
                                .font(.headline)
                        }
                        
                        Picker("", selection: $formData.skillLevel) {
                            ForEach(skillLevels, id: \.self) { level in
                                Text(level).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Submit Button
                    Button(action: {
                        validateAndSubmit()
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Submit Request")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    showForm = false
                }
            )
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") {
                showForm = false
            }
        } message: {
            Text("Your mentor request has been submitted successfully!")
        }
    }
    
    private func validateAndSubmit() {
            // Validate all required fields
            if formData.phoneNumber.isEmpty {
                errorMessage = "Please enter your phone number"
                showError = true
                return
            }
            
            if isStandalone && formData.topic.isEmpty {
                errorMessage = "Please enter a topic"
                showError = true
                return
            }
            
            if formData.description.isEmpty {
                errorMessage = "Please provide a description"
                showError = true
                return
            }
            
            // Submit if validation passes
            Task {
                do {
                    try await delegate.submitMentorRequest(formData: formData)
                    await MainActor.run {
                        showSuccess = true
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        }
}

struct VideoThumbnailView: View {
    let videoUrl: String?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background Image/Placeholder
                Image(systemName: "video.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                
                // Overlay with play button and gradient
                ZStack {
                    // Semi-transparent gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.1)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    
                    // Play Button
                    Circle()
                        .fill(Color.white)
                        .opacity(0.9)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: "play.fill")
                                .foregroundColor(.blue)
                                .font(.title)
                                .offset(x: 2) // Small offset to visually center the play icon
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
}

struct LoadingIndicator: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
        .padding()
    }
}

// Supporting Views
struct ProgressCard: View {
    let progress: CategoryLessonProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if progress.completed {
                Label("Lesson Completed", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Last accessed:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(progress.lastAccessed.formatted())
                    .font(.subheadline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct SaveProgressButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "arrow.up.doc.fill")
                Text("Save Progress")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct SaveForLaterButton: View {
    let isSaved: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                Text(isSaved ? "Saved" : "Save for Later")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .foregroundColor(.primary)
            .cornerRadius(12)
        }
    }
}

struct RequestHelpButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "person.fill.questionmark")
                Text("Request Help")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .foregroundColor(.primary)
            .cornerRadius(12)
        }
    }
}

struct QuizScoreCard: View {
    let score: Int
    let totalQuestions: Int
    
    var percentage: Double {
        Double(score) / Double(totalQuestions) * 100
    }
    
    var scoreColor: Color {
        if percentage >= 80 {
            return .green
        } else if percentage >= 60 {
            return .orange
        } else {
            return .red
        }
    }
    
    var scoreMessage: String {
        if percentage >= 80 {
            return "Great job! You've mastered this lesson!"
        } else if percentage >= 60 {
            return "Good progress! Keep practicing to improve."
        } else {
            return "Review the lesson material and try again."
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(scoreColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text("\(Int(percentage))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(scoreColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Score: \(score)/\(totalQuestions)")
                    .font(.headline)
                    .foregroundColor(scoreColor)
                
                Text(scoreMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
