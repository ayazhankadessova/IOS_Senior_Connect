//
//  MyProfileView.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 18/11/2024.
//

import Foundation
import SwiftUI

struct MyProfileView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: MyProfileViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: MyProfileViewModel(authService: AuthService()))
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                if let user = authService.currentUser {
                    // User Info
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Name: \(user.name)")
                        Text("Email: \(user.email)")
                    }
                    .padding()
                    
                    // Registered Events
                    if viewModel.registeredEvents.isEmpty {
                        Text("No registered events")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        List(viewModel.registeredEvents, id: \.id) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                EventRow(event: event)
                            }
                        }
                    }
                } else {
                    Text("Please log in to view your profile")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .navigationTitle("My Profile")
        }
        .onAppear {
            viewModel.updateAuthService(authService)
            Task {
                await viewModel.fetchRegisteredEvents()
            }
        }
    }
}

class MyProfileViewModel: ObservableObject {
    @Published var registeredEvents: [Event] = []
    private var authService: AuthService
    private let eventService = EventService()
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func updateAuthService(_ newAuthService: AuthService) {
        self.authService = newAuthService
    }
    
    @MainActor
    func fetchRegisteredEvents() async {
        guard let userId = authService.currentUser?.id else {
            print("⚠️ No user ID available")
            return
        }
        
        do {
            registeredEvents = try await eventService.getRegisteredEvents(userId: userId)
        } catch {
            print("❌ Error fetching registered events: \(error.localizedDescription)")
        }
    }
}
