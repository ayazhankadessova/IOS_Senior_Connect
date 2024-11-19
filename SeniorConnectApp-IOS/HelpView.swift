import Foundation
import SwiftUI

struct HelpView: View {
    @StateObject private var viewModel = HelpViewModel()
    @EnvironmentObject var authService: AuthService
    
    // State for expandable FAQs
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
                    .padding(.top)
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
    @StateObject private var viewModel = RequestMentorshipViewModel()
    @EnvironmentObject var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    
    let skillLevels = ["Beginner", "Intermediate", "Advanced"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Request Mentorship")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Fill in the details below to connect with a mentor who can help guide you on your journey.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom)
                
                // Form Fields
                VStack(spacing: 20) {
                    // Topic Field
                    FormField(
                        title: "Topic",
                        placeholder: "What would you like to learn?",
                        text: $viewModel.topic,
                        icon: "book.fill"
                    )
                    
                    // Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(.blue)
                            Text("Description")
                                .font(.headline)
                        }
                        
                        TextEditor(text: $viewModel.description)
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
                        text: $viewModel.phoneNumber,
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
                        
                        Picker("", selection: $viewModel.skillLevel) {
                            ForEach(skillLevels, id: \.self) { level in
                                Text(level).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                // Submit Button
                Button(action: {
                    if let userId = authService.currentUser?.id {
                        viewModel.submitMentorshipRequest(userId: userId)
                    }
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
        // Error Alert
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        // Success Alert
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your mentorship request has been submitted successfully!")
        }
    }
}

class HelpViewModel: ObservableObject {
    @Published var mentorshipRequests: [MentorshipRequest] = []
    @Published var showError = false
    @Published var errorMessage = ""
    private let mentorshipService = MentorshipService()
    
    func fetchMentorshipRequests(userId: String) {
        mentorshipService.getUserMentorshipRequests(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let requests):
                    self?.mentorshipRequests = requests
                case .failure(let error):
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
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

class RequestMentorshipViewModel: ObservableObject {
    @Published var topic = ""
    @Published var description = ""
    @Published var phoneNumber = ""
    @Published var skillLevel = "Beginner"
    @Published var showError = false
    @Published var showSuccess = false
    @Published var errorMessage = ""
    
    private let mentorshipService = MentorshipService()
    
    func submitMentorshipRequest(userId: String) {
        // Basic validation
        guard !topic.isEmpty, !description.isEmpty, !phoneNumber.isEmpty else {
            showError = true
            errorMessage = "Please fill in all fields"
            return
        }
        
        mentorshipService.createMentorshipRequest(
            topic: topic,
            description: description,
            phoneNumber: phoneNumber,
            skillLevel: skillLevel,
            userId: userId
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let request):
                    print("Mentorship request submitted successfully: \(request)")
                    self?.showSuccess = true
                    self?.topic = ""
                    self?.description = ""
                    self?.phoneNumber = ""
                    
                    // Post notification to refresh requests
                    NotificationCenter.default.post(name: .mentorshipRequestCreated, object: nil)
                    
                case .failure(let error):
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                    print("Error submitting mentorship request: \(error)")
                }
            }
        }
    }
}

extension Notification.Name {
    static let mentorshipRequestCreated = Notification.Name("mentorshipRequestCreated")
}
