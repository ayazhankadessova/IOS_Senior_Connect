import Foundation
import SwiftUI

struct HelpView: View {
    @StateObject private var viewModel = HelpViewModel()
    @EnvironmentObject var authService: AuthService
    @State private var expandedFAQ: String? = nil
    
    let faqs = [
        FAQ(question: "How do I create an account?",
            answer: "To create an account, tap the 'Sign Up' button on the login screen and follow the prompts. You'll need to provide your email, create a password, and fill in some basic profile information."),
        FAQ(question: "How can I find a mentor?",
            answer: "You can request a mentor by tapping the 'Request Mentorship' button below. Fill in your areas of interest and skill level, and we'll match you with an appropriate mentor."),
        FAQ(question: "What should I expect from mentorship?",
            answer: "Mentorship includes regular guidance, feedback, and support from experienced professionals. Sessions can be conducted virtually or in-person, depending on availability and preferences."),
        FAQ(question: "How do I update my profile?",
            answer: "Go to the Profile tab, tap the 'Edit' button, and you can update your personal information, preferences, and profile picture."),
        FAQ(question: "Is the service free?",
            answer: "Basic mentorship services are free. Premium features and extended session times may have associated costs."),
        FAQ(question: "Can I change my mentor?",
            answer: "Yes, you can request a different mentor if you feel the current match isn't suitable. Contact our support team for assistance.")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Welcome Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Welcome to the Help Center!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Find answers to common questions or connect with our mentors for personalized guidance.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom)
                    
                    // Contact Card
                    ContactCard()
                    
                    // FAQ Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Frequently Asked Questions")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 5)
                        
                        ForEach(faqs) { faq in
                            FAQCard(faq: faq, expanded: expandedFAQ == faq.id) {
                                expandedFAQ = expandedFAQ == faq.id ? nil : faq.id
                            }
                        }
                    }
                    
                    // Mentorship Requests Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your Mentorship Requests")
                            .font(.title2)
                            .bold()
                            .padding(.vertical, 5)
                        
                        if viewModel.mentorshipRequests.isEmpty {
                            EmptyRequestsView()
                        } else {
                            ForEach(viewModel.mentorshipRequests, id: \.id) { request in
                                MentorshipRequestCard(request: request, viewModel: viewModel)
                            }
                        }
                    }
                    
                    // Request Mentorship Button
                    NavigationLink(destination: RequestMentorshipView()) {
                        HStack {
                            Image(systemName: "person.fill.badge.plus")
                            Text("Request Mentorship")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Help")
        }
        .onAppear {
            if let userId = authService.currentUser?.id {
                viewModel.fetchMentorshipRequests(userId: userId)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .mentorshipRequestCreated)) { _ in
            if let userId = authService.currentUser?.id {
                viewModel.fetchMentorshipRequests(userId: userId)
            }
        }
    }
}

struct MentorshipRequestDetailView: View {
    let request: MentorshipRequest
    @StateObject private var viewModel: MentorshipRequestDetailViewModel
    @EnvironmentObject var authService: AuthService
    
    init(request: MentorshipRequest) {
        self.request = request
        self._viewModel = StateObject(wrappedValue: MentorshipRequestDetailViewModel(request: request))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(request.topic)
                .font(.title)
            
            Text("Status: \(request.status)")
                .foregroundColor(.secondary)
            
            Text("Description: \(request.description)")
                .foregroundColor(.secondary)

        }
        .padding()
        .navigationTitle("Request Details")
    }
}

class MentorshipRequestDetailViewModel: ObservableObject {
    @Published var newMessage = ""
    private let request: MentorshipRequest
    private let mentorshipService = MentorshipService()
    
    
    init(request: MentorshipRequest) {
        self.request = request
    }

}

struct RequestMentorshipView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    @State private var formData = MentorRequestFormData()
    @State private var showForm = true
    
    @StateObject private var viewModel: RequestMentorshipViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: RequestMentorshipViewModel(userId: ""))
    }
    
    var body: some View {
        MentorRequestForm(
            formData: $formData,
            showForm: $showForm,
            delegate: viewModel,
            title: "Request Mentorship",
            subtitle: "Fill in the details below to connect with a mentor who can help guide you on your journey.",
            isStandalone: true
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            if let userId = authService.currentUser?.id {
                viewModel.updateUserId(userId)
            }
        }
        .onDisappear {
            if !showForm {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

class HelpViewModel: ObservableObject {
    @Published var mentorshipRequests: [MentorshipRequest] = []
    @Published var showError = false
    @Published var errorMessage = ""
    private let mentorshipService = MentorshipService()
    
//    func fetchMentorshipRequests(userId: String) {
//        mentorshipService.getUserMentorshipRequests(userId: userId) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let requests):
//                    self?.mentorshipRequests = requests
//                case .failure(let error):
//                    self?.showError = true
//                    self?.errorMessage = error.localizedDescription
//                    print("Error fetching mentorship requests: \(error)")
//                }
//            }
//        }
//    }
    
    func fetchMentorshipRequests(userId: String) {
            mentorshipService.getUserMentorshipRequests(userId: userId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let requests):
                        self?.mentorshipRequests = requests
                    case .failure(let error):
                        print("Error fetching mentorship requests: \(error)")
                    }
                }
            }
        }
    
    func deleteMentorshipRequest(userId: String, requestId: String) {
        print("🚀 Starting delete request")
        print("UserID: \(userId)")
        print("RequestID: \(requestId)")
        
        mentorshipService.deleteMentorshipRequest(userId: userId, requestId: requestId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Successfully deleted request from server")
                    // Log the count before and after removal
                    print("Requests before removal: \(self?.mentorshipRequests.count ?? 0)")
                    self?.mentorshipRequests.removeAll { $0.id == requestId }
                    print("Requests after removal: \(self?.mentorshipRequests.count ?? 0)")
                    
                case .failure(let error):
                    print("❌ Delete request failed")
                    print("Error: \(error.localizedDescription)")
                    if let networkError = error as? NetworkError {
                        print("Network Error Type: \(networkError)")
                    }
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

class RequestMentorshipViewModel: MentorRequestFormDelegate, ObservableObject {
    private var userId: String
    private let mentorshipService: MentorshipService
    
    init(userId: String, mentorshipService: MentorshipService = MentorshipService()) {
        self.userId = userId
        self.mentorshipService = mentorshipService
    }
    
    func updateUserId(_ newId: String) {
        userId = newId
    }
    
    func submitMentorRequest(formData: MentorRequestFormData) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                mentorshipService.createMentorshipRequest(
                    topic: formData.topic,
                    description: formData.description,
                    phoneNumber: formData.phoneNumber,
                    skillLevel: formData.skillLevel,
                    userId: userId
                ) { result in
                    switch result {
                    case .success(let request):
                        print("Successfully created mentorship request: \(request)")
                        // Post notification after successful creation
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .mentorshipRequestCreated, object: nil)
                        }
                        continuation.resume()
                    case .failure(let error):
                        print("Failed to create mentorship request: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    
    func requestMentorHelp(
        for lesson: Lesson,
        notes: String?,
        phoneNumber: String,
        skillLevel: String
    ) async throws {
        print("Creating mentorship request for lesson: \(lesson.title)")
        
        let description = """
        Lesson: \(lesson.title)
        Lesson ID: \(lesson.lessonId)
        
        Additional Notes:
        \(notes ?? "No additional notes provided")
        """
        
        return try await withCheckedThrowingContinuation { continuation in
            mentorshipService.createMentorshipRequest(
                topic: "Help with: \(lesson.title)",
                description: description,
                phoneNumber: phoneNumber,
                skillLevel: skillLevel,
                userId: userId
            ) { result in
                switch result {
                case .success(let request):
                    print("Successfully created mentorship request: \(request)")
                    continuation.resume()
                case .failure(let error):
                    print("Failed to create mentorship request: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

//extension RequestMentorshipViewModel {
//    func updateUserId(_ newUserId: String) {
//        // Only update if the userId is empty (initial state)
//        if userId.isEmpty {
//            userId = newUserId
//        }
//    }
//}

extension Notification.Name {
    static let mentorshipRequestCreated = Notification.Name("mentorshipRequestCreated")
}
