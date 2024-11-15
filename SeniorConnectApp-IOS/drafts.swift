////
////  drafts.swift
////  SeniorConnectApp-IOS
////
////  Created by Аяжан on 15/11/2024.
////
//
//import Foundation
//
//
//struct LessonDetailView: View {
//    @EnvironmentObject var authService: AuthService
//    @State var lesson: Lesson
//    @State var progress: CategoryLessonProgress?
//    let userId: String
//    @StateObject private var viewModel: TutorialViewModel
//    @State private var showingVideo = false
//    @State private var showingMentorRequest = false
//    @State private var mentorNotes = ""
//    @State private var showingSaveConfirmation = false
//    @State private var showError = false
//    @State private var errorMessage = ""
//    @State private var completedSteps: Set<String> = []
//    @State private var completedStepActions: Set<StepActionIdentifier> = []
//    @State private var hasUnsavedChanges = false
//    let tutorialDetailView: TutorialDetailView
//    
//    private func findLessonProgress(for lessonId: String) -> CategoryLessonProgress? {
//        guard let user = authService.currentUser else { return nil }
//        return user.progress.smartphoneBasics.first { $0.lessonId == lessonId }
//    }
//    
//    init(lesson: Lesson, progress: CategoryLessonProgress? = nil, userId: String, tutorialDetailView: TutorialDetailView) {
//        self._lesson = State(initialValue: lesson)
//        self._progress = State(initialValue: progress)
//        self.userId = userId
//        self._viewModel = StateObject(wrappedValue: TutorialViewModel(userId: userId))
//        self.tutorialDetailView = tutorialDetailView
//        
//        // Initialize completed steps from progress if available
//        if let progress = progress {
//            _completedSteps = State(initialValue: Set(progress.completedSteps))
//            let stepActions = progress.stepProgress.flatMap { stepProgress in
//                stepProgress.completedActionItems.map { actionId in
//                    StepActionIdentifier(
//                        stepId: stepProgress.stepId,
//                        actionItemId: actionId
//                    )
//                }
//            }
//            _completedStepActions = State(initialValue: Set(stepActions))
//        }
//    }
//    
//    private func saveProgress() async {
//        do {
//            print("Starting progress save...")
//            viewModel.tutorialDetailView = tutorialDetailView
//            try await viewModel.updateBatchProgress(
//                category: "smartphoneBasics",
//                lessonId: lesson.lessonId,
//                completedSteps: Array(completedSteps),
//                completedStepActions: completedStepActions
//            )
//            
//            await MainActor.run {
//                hasUnsavedChanges = false
//                showingSaveConfirmation = true
//                progress = findLessonProgress(for: lesson.lessonId)
//            }
//        } catch {
//            print("Error saving progress: \(error)")
//            await MainActor.run {
//                errorMessage = "Failed to save progress: \(error.localizedDescription)"
//                showError = true
//            }
//        }
//    }
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 24) {
//                // Video Section
//                VStack(alignment: .leading, spacing: 8) {
//                    HStack {
//                        Image(systemName: "play.circle")
//                            .foregroundColor(.blue)
//                        Text("Video Tutorial")
//                            .font(.headline)
//                            .foregroundColor(.primary)
//                    }
//                    .padding(.horizontal)
//                    
//                    Button {
//                        showingVideo = true
//                    } label: {
//                        ZStack {
//                            if let _ = lesson.videoUrl {
//                                Rectangle()
//                                    .fill(Color.gray.opacity(0.2))
//                                    .frame(height: 200)
//                                    .overlay(
//                                        VStack(spacing: 8) {
//                                            Image(systemName: "play.circle.fill")
//                                                .font(.system(size: 50))
//                                                .foregroundColor(.blue)
//                                            Text("Tap to play video")
//                                                .font(.subheadline)
//                                                .foregroundColor(.blue)
//                                        }
//                                    )
//                            }
//                        }
//                        .cornerRadius(12)
//                        .shadow(radius: 2)
//                    }
//                    .padding(.horizontal)
//                }
//                
//                Divider()
//                    .padding(.horizontal)
//                
//                // Progress Section
//                if let currentProgress = progress {
//                    VStack(alignment: .leading, spacing: 8) {
//                        HStack {
//                            Image(systemName: "chart.bar.fill")
//                                .foregroundColor(.green)
//                            Text("Your Progress")
//                                .font(.headline)
//                                .foregroundColor(.primary)
//                        }
//                        .padding(.horizontal)
//                        
//                        VStack(alignment: .leading, spacing: 12) {
//                            if currentProgress.completed {
//                                Label("Lesson Completed", systemImage: "checkmark.circle.fill")
//                                    .foregroundColor(.green)
//                                    .font(.headline)
//                            }
//                            
//                            Text("Last accessed: \(currentProgress.lastAccessed.formatted())")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color(.systemBackground))
//                        .cornerRadius(10)
//                        .shadow(radius: 1)
//                        .padding(.horizontal)
//                    }
//                    
//                    Divider()
//                        .padding(.horizontal)
//                }
//                
//                // Steps Section
//                VStack(alignment: .leading, spacing: 16) {
//                    HStack {
//                        Image(systemName: "list.bullet.circle")
//                            .foregroundColor(.blue)
//                        Text("Lesson Steps")
//                            .font(.headline)
//                            .foregroundColor(.primary)
//                    }
//                    .padding(.horizontal)
//                    
//                    ForEach(lesson.steps) { step in
//                        VStack(spacing: 0) {
//                            StepActionItems(
//                                step: step,
//                                onItemComplete: { item in
//                                    handleItemComplete(item: item, step: step)
//                                },
//                                completedSteps: $completedSteps,
//                                completedStepActions: $completedStepActions,
//                                currentStepId: step.stepId
//                            )
//                            .padding(.horizontal)
//                            
//                            if step.id != lesson.steps.last?.id {
//                                Divider()
//                                    .padding(.vertical, 8)
//                                    .padding(.horizontal)
//                            }
//                        }
//                    }
//                }
//                
//                // Save Progress Button
//                if hasUnsavedChanges {
//                    VStack {
//                        Divider()
//                            .padding(.horizontal)
//                        
//                        Button {
//                            Task {
//                                await saveProgress()
//                            }
//                        } label: {
//                            HStack {
//                                Image(systemName: "arrow.up.doc.fill")
//                                Text("Save Progress")
//                                    .fontWeight(.semibold)
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                            .shadow(radius: 2)
//                        }
//                        .padding(.horizontal)
//                    }
//                }
//                
//                // Action Buttons
//                VStack(spacing: 16) {
//                    Divider()
//                        .padding(.horizontal)
//                    
//                    HStack {
//                        Button {
//                            Task {
//                                do {
//                                    try await viewModel.saveForLater(lesson)
//                                    showingSaveConfirmation = true
//                                } catch {
//                                    errorMessage = "Failed to save for later: \(error.localizedDescription)"
//                                    showError = true
//                                }
//                            }
//                        } label: {
//                            Label(
//                                lesson.savedForLater ? "Saved" : "Save for Later",
//                                systemImage: lesson.savedForLater ? "bookmark.fill" : "bookmark"
//                            )
//                            .padding(8)
//                            .background(Color(.systemBackground))
//                            .cornerRadius(8)
//                            .foregroundColor(.blue)
//                        }
//                        
//                        Spacer()
//                        
//                        Button {
//                            showingMentorRequest = true
//                        } label: {
//                            Label("Request Help", systemImage: "person.fill.questionmark")
//                                .padding(8)
//                                .background(Color(.systemBackground))
//                                .cornerRadius(8)
//                                .foregroundColor(.orange)
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//            }
//            .padding(.vertical)
//        }
//        .background(Color(.systemGroupedBackground))
//        .navigationTitle(lesson.title)
//        .sheet(isPresented: $showingVideo) {
//            VideoPlayerView(videoURL: lesson.videoUrl ?? "")
//        }
//        .alert("Request Mentor Help", isPresented: $showingMentorRequest) {
//            Button("Cancel", role: .cancel) { }
//            Button("Request Help") {
//                Task {
//                    do {
//                        try await viewModel.requestMentorHelp(for: lesson, notes: mentorNotes)
//                    } catch {
//                        errorMessage = "Failed to request help: \(error.localizedDescription)"
//                        showError = true
//                    }
//                }
//            }
//        }
//        .alert("Error", isPresented: $showError) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(errorMessage)
//        }
//        .alert("Success", isPresented: $showingSaveConfirmation) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text("Progress saved successfully!")
//        }
//    }
//    
//    private func handleItemComplete(item: ActionItem, step: Step) {
//        let identifier = StepActionIdentifier(
//            stepId: step.stepId,
//            actionItemId: item.itemId
//        )
//        
//        if completedStepActions.contains(identifier) {
//            completedStepActions.remove(identifier)
//            print("Removed action: \(identifier)")
//        } else {
//            completedStepActions.insert(identifier)
//            print("Added action: \(identifier)")
//        }
//        
//        let stepCompleted = step.actionItems
//            .filter { $0.isRequired }
//            .allSatisfy { actionItem in
//                completedStepActions.contains(
//                    StepActionIdentifier(
//                        stepId: step.stepId,
//                        actionItemId: actionItem.itemId
//                    )
//                )
//            }
//        
//        if stepCompleted {
//            completedSteps.insert(step.stepId)
//            print("Completed step: \(step.stepId)")
//        } else {
//            completedSteps.remove(step.stepId)
//            print("Uncompleted step: \(step.stepId)")
//        }
//        
//        hasUnsavedChanges = true
//    }
//}
//
//// Helper Views
//struct SectionHeader: View {
//    let iconName: String
//    let title: String
//    let iconColor: Color
//    
//    var body: some View {
//        HStack {
//            Image(systemName: iconName)
//                .foregroundColor(iconColor)
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.primary)
//        }
//    }
//}
