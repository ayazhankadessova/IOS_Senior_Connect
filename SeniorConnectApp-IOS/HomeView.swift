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
    @EnvironmentObject var authService: AuthService
    @State private var showError = false
    @State private var errorMessage = ""
    
    private func findLessonProgress(for lessonId: String) -> CategoryLessonProgress? {
        return lessonService.lessonsProgress[lessonId]
    }
    
    func refreshData() async throws {
        do {
            // Fetch latest lessons
            try await lessonService.fetchLessons(
                category: category.name,
                userId: authService.currentUser?.id ?? ""
            )
            print("Updated Lesson Progress:")
            for (lessonId, progress) in lessonService.lessonsProgress {
                print("\(lessonId): completed=\(progress.completed), steps=\(progress.completedSteps.count)")
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section
                CategoryHeaderView(category: category)
                
                // Overall Progress section
                if let overall = lessonService.overallProgress {
                    OverallProgressView(progress: overall)
                }
                
                // Lessons section
                if lessonService.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !lessonService.lessons.isEmpty {
                    ForEach(lessonService.lessons) { lesson in
                        let progress = findLessonProgress(for: lesson.lessonId)
                        NavigationLink {
                            LessonDetailView(
                                lesson: lesson,
                                progress: progress,
                                userId: authService.currentUser?.id ?? "",
                                tutorialDetailView: self
                            )
                        } label: {
                            LessonRowView(
                                lesson: lesson,
                                progress: progress
                            )
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
            try? await refreshData()
        }
        .refreshable {
            try? await refreshData()
        }
    }
}

struct LessonRowView: View {
    let lesson: Lesson
    let progress: CategoryLessonProgress?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lesson.title)
                    .font(.headline)
                
                Spacer()
                
                if progress?.completed == true {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                if progress?.savedForLater == true {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.blue)
                }
            }
            
            Text(lesson.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if progress?.needsMentorHelp == true {
                Label("Help Requested", systemImage: "person.fill.questionmark")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            if let lastAccessed = progress?.lastAccessed {
                Text("Last accessed: \(lastAccessed)")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
    @EnvironmentObject var authService: AuthService
    @State var lesson: Lesson
    @State var progress: CategoryLessonProgress?
    let userId: String
    @StateObject private var viewModel: TutorialViewModel
    @State private var showingVideo = false
    @State private var showingMentorRequest = false
    @State private var mentorNotes = ""
    @State private var showingSaveConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var completedSteps: Set<String> = []
    @State private var completedStepActions: Set<StepActionIdentifier> = []
    @State private var hasUnsavedChanges = false
    let tutorialDetailView: TutorialDetailView
    
    private func findLessonProgress(for lessonId: String) -> CategoryLessonProgress? {
        guard let user = authService.currentUser else { return nil }
        return user.progress.smartphoneBasics.first { $0.lessonId == lessonId }
    }
    
    init(lesson: Lesson, progress: CategoryLessonProgress? = nil, userId: String, tutorialDetailView: TutorialDetailView) {
            self._lesson = State(initialValue: lesson)
            self._progress = State(initialValue: progress)
            self.userId = userId
            self._viewModel = StateObject(wrappedValue: TutorialViewModel(userId: userId))
            self.tutorialDetailView = tutorialDetailView
        }
    
    private func saveProgress() async {
            do {
                viewModel.tutorialDetailView = tutorialDetailView
                try await viewModel.updateBatchProgress(
                    category: "smartphoneBasics",
                    lessonId: lesson.lessonId,
                    completedSteps: Array(completedSteps),
                    completedStepActions: completedStepActions
                )
                
                await MainActor.run {
                    hasUnsavedChanges = false
                    showingSaveConfirmation = true
                    progress = findLessonProgress(for: lesson.lessonId)
                }
            } 
        catch {
                // ... error handling ...
            }
        }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Video Section
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
                
                if let currentProgress = progress {
                                    VStack(alignment: .leading, spacing: 8) {
                                        if currentProgress.completed {
                                            Label("Lesson Completed", systemImage: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                        
                                        Text("Last accessed: \(currentProgress.lastAccessed.formatted())")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        ForEach(currentProgress.stepProgress) { stepProgress in
                                            if let step = lesson.steps.first(where: { $0.stepId == stepProgress.stepId }) {
                                                VStack(alignment: .leading) {
                                                    Text(step.title)
                                                        .font(.headline)
                                                    
                                                    ForEach(step.actionItems.filter { item in
                                                        stepProgress.completedActionItems.contains(item.itemId)
                                                    }) { item in
                                                        Text("✓ \(item.task)")
                                                            .foregroundColor(.green)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                }
                
                // Steps Section
                ForEach(lesson.steps) { step in
                    StepActionItems(
                        step: step,
                        onItemComplete: { item in
                            let identifier = StepActionIdentifier(
                                stepId: step.stepId,
                                actionItemId: item.itemId
                            )
                            
                            if completedStepActions.contains(identifier) {
                                completedStepActions.remove(identifier)
                                print("Removed action: \(identifier)")
                            } else {
                                completedStepActions.insert(identifier)
                                print("Added action: \(identifier)")
                            }
                            
                            let stepCompleted = step.actionItems
                                .filter { $0.isRequired }
                                .allSatisfy { actionItem in
                                    completedStepActions.contains(
                                        StepActionIdentifier(
                                            stepId: step.stepId,
                                            actionItemId: actionItem.itemId
                                        )
                                    )
                                }
                            
                            if stepCompleted {
                                completedSteps.insert(step.stepId)
                                print("Completed step: \(step.stepId)")
                            } else {
                                completedSteps.remove(step.stepId)
                                print("Uncompleted step: \(step.stepId)")
                            }
                            
                            hasUnsavedChanges = true
                        },
                        completedSteps: $completedSteps,
                        completedStepActions: $completedStepActions,
                        currentStepId: step.stepId
                    )
                }
                
                // Save Progress Button
                if hasUnsavedChanges {
                    Button {
                        Task {
                            await saveProgress()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.doc")
                            Text("Save Progress")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
                
                // Action Buttons
                HStack {
                    Button {
                        Task {
                            do {
                                try await viewModel.saveForLater(lesson)
                                showingSaveConfirmation = true
                            } catch {
                                errorMessage = "Failed to save for later: \(error.localizedDescription)"
                                showError = true
                            }
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
                    do {
                        try await viewModel.requestMentorHelp(for: lesson, notes: mentorNotes)
                    } catch {
                        errorMessage = "Failed to request help: \(error.localizedDescription)"
                        showError = true
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Initialize from current progress
            if let currentProgress = progress {
                print("Initializing from current progress: \(currentProgress)")
                completedSteps = Set(currentProgress.completedSteps)
                let stepActions = currentProgress.stepProgress.flatMap { stepProgress in
                    stepProgress.completedActionItems.map { actionId in
                        StepActionIdentifier(
                            stepId: stepProgress.stepId,
                            actionItemId: actionId
                        )
                    }
                }
                completedStepActions = Set(stepActions)
            }
        }
    }
}

struct CategoryHeaderView: View {
    let category: TutorialCategory
    
    var body: some View {
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
    }
}

struct ActionItemRow: View {
    let item: ActionItem
    let isCompleted: Bool
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            Button {
                onComplete()
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .gray)
                    .font(.system(size: 22))
            }
            
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
    }
}

struct StepActionItems: View {
    let step: Step
    let onItemComplete: (ActionItem) -> Void
    @Binding var completedSteps: Set<String>
    @Binding var completedStepActions: Set<StepActionIdentifier>
    let currentStepId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(step.title)
                    .font(.headline)
                
                Spacer()
                
                if completedSteps.contains(step.stepId) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(step.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(step.actionItems) { item in
                ActionItemRow(
                    item: item,
                    isCompleted: completedStepActions.contains(
                        StepActionIdentifier(
                            stepId: currentStepId,
                            actionItemId: item.itemId
                        )
                    )
                ) {
                    onItemComplete(item)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
