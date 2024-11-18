//
//  HelpView.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 19/11/2024.
//

import Foundation
import SwiftUI

struct HelpView: View {
    @StateObject private var viewModel = HelpViewModel()
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome to the Help Center!")
                    .font(.title)
                
                Text("Here you can find answers to frequently asked questions and request mentorship from our experts.")
                
                Section(header: Text("Frequently Asked Questions")) {
                    // Add your FAQs here
                    Text("Q: How do I create an account?")
                    Text("A: To create an account, tap the 'Sign Up' button on the login screen and follow the prompts.")
                    // Add more Q&A pairs
                }
                
                Section(header: Text("Mentorship Requests")) {
                    if viewModel.mentorshipRequests.isEmpty {
                        Text("You have no mentorship requests.")
                    } else {
                        List(viewModel.mentorshipRequests, id: \.id) { request in
                            NavigationLink(destination: MentorshipRequestDetailView(request: request)) {
                                VStack(alignment: .leading) {
                                    Text(request.topic)
                                        .font(.headline)
                                    Text("Status: \(request.status)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                NavigationLink(destination: RequestMentorshipView()) {
                    Text("Request Mentorship")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Help")
        }
        .onAppear {
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
            
            Section(header: Text("Messages")) {
                if request.messages.isEmpty {
                    Text("No messages yet.")
                } else {
                    ForEach(request.messages, id: \.timestamp) { message in
                        MessageView(message: message)
                    }
                }
            }
            
            Spacer()
            
            HStack {
                TextField("Enter your message", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    
                    if let userId = authService.currentUser?.id {
                        viewModel.sendMessage(userId: userId)
                    }
                }) {
                    Image(systemName: "paperplane")
                }
            }
        }
        .padding()
        .navigationTitle("Request Details")
    }
}

struct MessageView: View {
    let message: MentorshipMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message.content)
                .padding(10)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
            
            Text(message.timestamp)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

class MentorshipRequestDetailViewModel: ObservableObject {
    @Published var newMessage = ""
    private let request: MentorshipRequest
    private let mentorshipService = MentorshipService()
    
    
    init(request: MentorshipRequest) {
        self.request = request
    }
    
    func sendMessage(userId: String) {
        mentorshipService.sendMessage(requestId: request.id!, content: newMessage, userId: userId) { [weak self] result in
            switch result {
            case .success:
                print("Message sent successfully")
                self?.newMessage = ""
            case .failure(let error):
                print("Error sending message: \(error)")
            }
        }
    }
}

struct RequestMentorshipView: View {
    @StateObject private var viewModel = RequestMentorshipViewModel()
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Form {
            Section(header: Text("Request Mentorship")) {
                TextField("Enter your question or topic", text: $viewModel.topic)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    if let userId = authService.currentUser?.id {
                        viewModel.submitMentorshipRequest(userId: userId)
                    }
                }) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .navigationTitle("Request Mentorship")
    }
}

class HelpViewModel: ObservableObject {
    @Published var mentorshipRequests: [MentorshipRequest] = []
    private let mentorshipService = MentorshipService()
    
    func fetchMentorshipRequests(userId: String) {
        mentorshipService.getUserMentorshipRequests(userId: userId) { [weak self] result in
            switch result {
            case .success(let requests):
                self?.mentorshipRequests = requests
            case .failure(let error):
                print("Error fetching mentorship requests: \(error)")
            }
        }
    }
}

class RequestMentorshipViewModel: ObservableObject {
    @Published var topic = ""
    private let mentorshipService = MentorshipService()
    
    func submitMentorshipRequest(userId: String) {
        mentorshipService.createMentorshipRequest(topic: topic, userId: userId) { [weak self] result in
            switch result {
            case .success:
                print("Mentorship request submitted successfully")
                self?.topic = ""
            case .failure(let error):
                print("Error submitting mentorship request: \(error)")
            }
        }
    }
}
