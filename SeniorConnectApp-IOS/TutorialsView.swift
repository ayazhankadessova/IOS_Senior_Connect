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
    
    private func findLessonProgress(lessonId: String, category: String) -> CategoryLessonProgress? {
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
//                if let overall = lessonService.overallProgress {
//                    OverallProgressView(progress: overall)
//                }
                
                // Lessons section
                if lessonService.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !lessonService.lessons.isEmpty {
                    ForEach(lessonService.lessons) { lesson in
                        let progress = findLessonProgress(lessonId: lesson.lessonId, category: lesson.category)
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

enum LearningCategory: String {
    case smartphoneBasics = "smartphoneBasics"
    case digitalLiteracy = "digitalLiteracy"
    case socialMedia = "socialMedia"
    case iot = "iot"
    
    var displayName: String {
        switch self {
        case .smartphoneBasics: return "Smartphone Basics"
        case .digitalLiteracy: return "Digital Literacy"
        case .socialMedia: return "Social Media"
        case .iot: return "Internet of Things"
        }
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
    
    @State private var showingQuiz = false
    @State private var quizScore: Int?
    
    private func findLessonProgress(lessonId: String, category: String) -> CategoryLessonProgress? {
        guard let user = authService.currentUser else { return nil }
        
        switch category {
        case "smartphoneBasics":
            return user.progress.smartphoneBasics.first { $0.lessonId == lessonId }
        case "digitalLiteracy":
            return user.progress.digitalLiteracy.first { $0.lessonId == lessonId }
        case "socialMedia":
            return user.progress.socialMedia.first { $0.lessonId == lessonId }
        case "iot":
            return user.progress.iot.first { $0.lessonId == lessonId }
        default:
            return nil
        }
    }
    
    init(lesson: Lesson, progress: CategoryLessonProgress? = nil, userId: String, tutorialDetailView: TutorialDetailView) {
            self._lesson = State(initialValue: lesson)
            self._progress = State(initialValue: progress)
            self.userId = userId
            self._viewModel = StateObject(wrappedValue: TutorialViewModel(userId: userId))
            self.tutorialDetailView = tutorialDetailView
        }
    
    private func saveProgress() async {
        print("💾 Starting progress save")
        print("📋 Completed steps: \(completedSteps)")
        print("📋 Completed actions: \(completedStepActions)")
        
        do {
            viewModel.tutorialDetailView = tutorialDetailView
            try await viewModel.updateBatchProgress(
                category: lesson.category,
                lessonId: lesson.lessonId,
                completedSteps: Array(completedSteps),
                completedStepActions: completedStepActions
            )
            
            await MainActor.run {
                hasUnsavedChanges = false
                showingSaveConfirmation = true
                progress = findLessonProgress(lessonId: lesson.lessonId, category: lesson.category)
                print("✅ Progress updated: \(String(describing: progress))")
            }
        } catch {
            print("❌ Save failed: \(error)")
            errorMessage = "Failed to save progress: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private var lastQuizScore: Int? {
            if let progress = progress, !progress.quizScores.isEmpty {
                return progress.quizScores[0].score
            }
            return nil
        }
    
    @ViewBuilder
   private var quizScoreSection: some View {
       // First check current quiz score
       if let currentScore = quizScore {
           QuizScoreCard(
               score: currentScore,
               totalQuestions: lesson.quiz.count
           )
           .padding(.horizontal)
       }
       // If no current score, check last saved score
       else if let lastScore = lastQuizScore {
           QuizScoreCard(
               score: lastScore,
               totalQuestions: lesson.quiz.count
           )
           .padding(.horizontal)
       }
   }
    
    private func saveQuizScore(_ score: Int) async {
            do {
                try await viewModel.updateQuizScore(lessonId: lesson.lessonId, score: score, category: lesson.category)
                await MainActor.run {
                    quizScore = score
//                    lastQuizScore = score
                    // Refresh progress to get updated quiz scores
                    progress = findLessonProgress(lessonId: lesson.lessonId, category: lesson.category)
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save quiz score: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section with Video
                Group {
                    if let videoUrl = lesson.videoUrl {
                        VideoThumbnailView(videoUrl: videoUrl) {
                            showingVideo = true
                        }
                    }
                }
                .padding(.horizontal)
                
                // Progress Card
                if let currentProgress = progress {
                    ProgressCard(progress: currentProgress)
                }
                
                // Description Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("About this lesson")
                        .font(.headline)
                    
                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Steps Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Lesson Steps")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(lesson.steps) { step in
                        StepActionItems(
                            step: step,
                            onItemComplete: { item in
                                handleStepCompletion(step: step, item: item)
                            },
                            completedSteps: $completedSteps,
                            completedStepActions: $completedStepActions,
                            currentStepId: step.stepId
                        )
                    }
                }
                
                // Action Buttons Section
                VStack(spacing: 16) {
                    if hasUnsavedChanges {
                        SaveProgressButton {
                            Task {
                                await saveProgress()
                            }
                        }
                    }
                    
                    HStack(spacing: 20) {
                        SaveForLaterButton(
                            isSaved: lesson.savedForLater,
                            action: {
                                Task {
                                    do {
                                        try await viewModel.saveForLater(lesson)
                                        showingSaveConfirmation = true
                                    } catch {
                                        errorMessage = "Failed to save for later: \(error.localizedDescription)"
                                        showError = true
                                    }
                                }
                            }
                        )
                        
                        RequestHelpButton {
                            viewModel.setCurrentLesson(lesson)
                            formData = MentorRequestFormData()
                            showingMentorRequestSheet = true
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                
                // Quiz Section
               VStack(alignment: .leading, spacing: 16) {
                   
                   Text("Lesson Quiz")
                       .font(.headline)
                       .padding(.horizontal)
                   
                   quizScoreSection
                   
                   Button {
                       showingQuiz = true
                   } label: {
                       HStack {
                           Image(systemName: "doc.text.fill")
                           Text(quizScore == nil ? "Take Quiz" : "Retake Quiz")
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
            .padding(.vertical)
        }
        .navigationTitle(lesson.title)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingVideo) {
            VideoPlayerView(videoURL: lesson.videoUrl ?? "")
        }
        .sheet(isPresented: $showingMentorRequestSheet) {
            MentorRequestForm(
                formData: $formData,
                showForm: $showingMentorRequestSheet,
                delegate: viewModel,
                title: "Request Help",
                subtitle: "Request help with: \(lesson.title)",
                isStandalone: false
            )
        }
        .sheet(isPresented: $showingQuiz) {
                    NavigationView {
                        QuizView(questions: lesson.quiz) { score in
                            Task {
                                await saveQuizScore(score)
                            }
                            showingQuiz = false
                        }
                        .navigationTitle("Lesson Quiz")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") {
                                    showingQuiz = false
                                }
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
            initializeProgress()
        }
    }
    
    private func handleStepCompletion(step: Step, item: ActionItem) {
        print("🔄 Processing step completion:")
        print("  Step ID: \(step.stepId)")
        print("  Item ID: \(item.itemId)")
        print("  Required: \(item.isRequired)")
        
        let identifier = StepActionIdentifier(
            stepId: step.stepId,
            actionItemId: item.itemId
        )
        
        if completedStepActions.contains(identifier) {
            completedStepActions.remove(identifier)
            print("❌ Removed action: \(identifier)")
        } else {
            completedStepActions.insert(identifier)
            print("✅ Added action: \(identifier)")
        }
        
        // Check step completion
        let allRequiredStepItems = step.actionItems.filter { $0.isRequired }
        print("📋 Required items for step \(step.stepId): \(allRequiredStepItems.count)")
        
        let completedRequiredItems = allRequiredStepItems.filter { actionItem in
            completedStepActions.contains(
                StepActionIdentifier(
                    stepId: step.stepId,
                    actionItemId: actionItem.itemId
                )
            )
        }
        print("✓ Completed required items: \(completedRequiredItems.count)")
        
        let stepCompleted = completedRequiredItems.count == allRequiredStepItems.count
        
        if stepCompleted {
            completedSteps.insert(step.stepId)
            print("🎉 Completed step: \(step.stepId)")
        } else {
            completedSteps.remove(step.stepId)
            print("📝 Uncompleted step: \(step.stepId)")
        }
        
        print("📊 Current completed steps: \(completedSteps)")
        
        hasUnsavedChanges = true
    }
    
    private func initializeProgress() {
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

