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
    @Published var selectedTab: Tab = .tutorials
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
    @State private var progress: Double = 0.3 // Example progress
    
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
                Text("3/10 Topics")
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
        Button {
            // Handle action
        } label: {
            VStack(spacing: 12) {
                Image(systemName: action.icon)
                    .font(.system(size: 30))
                    .foregroundColor(action.color)
                
                Text(action.title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(action.color.opacity(0.1))
            .cornerRadius(12)
        }
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
