//
//  TutorialsView.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 19/11/2024.
//

import Foundation
import SwiftUI
import SwiftData
import WebKit


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
            // Header with title and icons
            HStack {
                Text(lesson.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 4) {
                    if progress?.needsMentorHelp == true {
                        Image(systemName: "person.fill.questionmark")
                            .foregroundColor(.orange)
                    }
                    
                    if progress?.completed == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    if progress?.savedForLater == true {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Description
            Text(lesson.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Status indicators
            VStack(alignment: .leading, spacing: 4) {
                if progress?.needsMentorHelp == true {
                    Label("Help Requested", systemImage: "person.fill.questionmark")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                if let lastAccessed = progress?.lastAccessed {
                    Text("Last accessed: \(lastAccessed)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct YouTubePlayerView: UIViewRepresentable {
    let videoId: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.allowsBackForwardNavigationGestures = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Create YouTube embed HTML with custom parameters
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                body { margin: 0; }
                .video-container {
                    position: relative;
                    padding-bottom: 56.25%;
                    height: 0;
                    overflow: hidden;
                }
                .video-container iframe {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe src="https://www.youtube.com/embed/\(videoId)?playsinline=1&rel=0"
                    frameborder="0"
                    allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                    allowfullscreen>
                </iframe>
            </div>
        </body>
        </html>
        """
        
        uiView.loadHTMLString(embedHTML, baseURL: nil)
    }
}

struct VideoPlayerView: View {
    let videoURL: String
    
    private var videoId: String? {
            guard let url = URL(string: videoURL) else { return nil }
            
            // Handle different YouTube URL formats
            if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                return queryItems.first(where: { $0.name == "v" })?.value
            }
            
            // Handle youtu.be format
            if url.host == "youtu.be" {
                return url.lastPathComponent
            }
            
            return nil
        }
    
    var body: some View {
        VStack {
            if let videoId = videoId {
                YouTubePlayerView(videoId: videoId)
                    .frame(height: 220)
            } else {
                Text("Invalid YouTube URL")
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
            }
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
    @State private var showingMentorRequestSheet = false
    @State private var phoneNumber = ""
    @State private var skillLevel = "Beginner"
    @State private var mentorRequestSuccessful = false
    let tutorialDetailView: TutorialDetailView
    @State private var formData = MentorRequestFormData()
    
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
                        if let _ = lesson.videoUrl {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .overlay(
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.blue)
                                )
                        }
                    }
                    .cornerRadius(12)
                }
                
                Divider().padding(.horizontal)
                
                // Curr progress Section
                if let currentProgress = progress {
                    VStack(alignment: .leading, spacing: 8) {
                        if currentProgress.completed {
                            Label("Lesson Completed", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        
                        Text("Last accessed: \(currentProgress.lastAccessed.formatted())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                }
                
                Divider().padding(.horizontal)
                
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
                                print(lesson)
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
                        viewModel.setCurrentLesson(lesson)
                        formData = MentorRequestFormData() // Reset form data
                        showingMentorRequestSheet = true
                    } label: {
                        Label("Request Help", systemImage: "person.fill.questionmark")
                    }
                    .sheet(isPresented: $showingMentorRequestSheet) {
                        MentorRequestForm(
                            formData: $formData,
                            showForm: $showingMentorRequestSheet,
                            delegate: viewModel,
                            title: "Request Help",
                            subtitle: "Request help with: \(lesson.title)",
                            isStandalone: false // This is not a standalone form
                        )
                    }
                }
                .sheet(isPresented: $showingMentorRequestSheet) {
                    NavigationView {
                        Form {
                            Section(header: Text("Contact Information")) {
                                TextField("Phone Number", text: $phoneNumber)
                                    .keyboardType(.phonePad)
                                    .textContentType(.telephoneNumber)
                            }
                            
                            Section(header: Text("Skill Level")) {
                                Picker("Your current skill level", selection: $skillLevel) {
                                    Text("Beginner").tag("Beginner")
                                    Text("Intermediate").tag("Intermediate")
                                    Text("Advanced").tag("Advanced")
                                }
                            }
                            
                            Section(header: Text("Additional Notes")) {
                                TextEditor(text: $mentorNotes)
                                    .frame(height: 100)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2))
                                    )
                            }
                            
                            Section {
                                Button(action: {
                                    if !phoneNumber.isEmpty {
                                        Task {
                                            do {
                                                try await viewModel.requestMentorHelp(
                                                    for: lesson,
                                                    notes: mentorNotes,
                                                    phoneNumber: phoneNumber,
                                                    skillLevel: skillLevel
                                                )
                                                mentorRequestSuccessful = true
                                                showingMentorRequestSheet = false
                                            } catch {
                                                errorMessage = "Failed to request help: \(error.localizedDescription)"
                                                showError = true
                                            }
                                        }
                                    } else {
                                        errorMessage = "Please enter your phone number"
                                        showError = true
                                    }
                                }) {
                                    Text("Submit Request")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .navigationTitle("Request Mentor Help")
                        .navigationBarItems(
                            trailing: Button("Cancel") {
                                showingMentorRequestSheet = false
                            }
                        )
                    }
                }
                .alert("Success", isPresented: $mentorRequestSuccessful) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Your mentor request has been submitted successfully!")
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
            }
            .padding()
        }
        .navigationTitle(lesson.title)
        .sheet(isPresented: $showingVideo) {
            VideoPlayerView(videoURL: lesson.videoUrl ?? "")
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

