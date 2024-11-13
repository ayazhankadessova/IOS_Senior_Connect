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

struct TutorialDetailView: View {
    let category: TutorialCategory
    @StateObject private var lessonService = LessonService()
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
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
                
                // Lessons
                if lessonService.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !lessonService.lessons.isEmpty {
                    ForEach(lessonService.lessons) { lesson in
                        NavigationLink {
                            LessonDetailView(
                                lesson: .constant(lesson),
                                userId: "" // Pass user ID here
                            )
                        } label: {
                            LessonRowView(lesson: lesson)
                                .padding(.horizontal)
                        }
                    }
                } else {
                    Text("No lessons available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .task {
            do {
                try await lessonService.fetchLessons(category: category.name.replacingOccurrences(of: " ", with: ""))
            } catch {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct LessonRowView: View {
    let lesson: Lesson
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lesson.title)
                .font(.headline)
            
            Text(lesson.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Progress indicator or completion status can be added here
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
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
    let userId: String
    @StateObject private var viewModel: TutorialViewModel
    @State private var showingVideo = false
    @State private var showingMentorRequest = false
    @State private var mentorNotes = ""
    @State private var showingSaveConfirmation = false
    
    init(lesson: Binding<Lesson>, userId: String) {
        self._lesson = lesson
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: TutorialViewModel(userId: userId))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Video Section
                if let videoURL = lesson.videoUrl {
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
                
                // Progress Section
                ProgressView(value: calculateProgress())
                    .tint(.blue)
                    .padding(.horizontal)
                
                // Steps Section
                ForEach(lesson.steps) { step in
                    StepActionItems(step: step) { item in
                        Task {
                            await viewModel.updateLessonProgress(
                                lesson,
                                stepId: step.id,
                                actionItemId: item.id
                            )
                        }
                    }
                }
                
                // Action Buttons
                HStack {
                    Button {
                        Task {
                            await viewModel.saveForLater(lesson)
                            showingSaveConfirmation = true
                        }
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
            VideoPlayerView(videoURL: lesson.videoUrl ?? "")
        }
        .alert("Request Mentor Help", isPresented: $showingMentorRequest) {
            Button("Cancel", role: .cancel) { }
            Button("Request Help") {
                Task {
                    await viewModel.requestMentorHelp(for: lesson)
                }
            }
        }
    }
    
    private func calculateProgress() -> Double {
        let completedItems = lesson.steps.reduce(0) { sum, step in
            sum + step.actionItems.filter { $0.isCompleted }.count
        }
        
        let totalRequiredItems = lesson.steps.reduce(0) { sum, step in
            sum + step.actionItems.filter { $0.isRequired }.count
        }
        
        return totalRequiredItems > 0 ? Double(completedItems) / Double(totalRequiredItems) : 0
    }
}

struct ActionItemRow: View {
    let item: ActionItem
    let onComplete: () -> Void
    @State private var isCompleted = false
    
    var body: some View {
        HStack {
            // Checkbox Button
            Button {
                isCompleted.toggle()
                onComplete()
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .gray)
                    .font(.system(size: 22))
            }
            
            // Task Text
            VStack(alignment: .leading, spacing: 4) {
                Text(item.task)
                    .font(.system(size: 16))
                    .strikethrough(isCompleted)
                
                if item.isRequired {
                    Text("Required")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Makes the whole row tappable
        .onTapGesture {
            isCompleted.toggle()
            onComplete()
        }
    }
}

struct StepActionItems: View {
    let step: Step
    let onItemComplete: (ActionItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(step.title)
                .font(.headline)
            
            Text(step.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(step.actionItems) { item in
                    ActionItemRow(
                        item: item,
                        onComplete: {
                            onItemComplete(item)
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}
