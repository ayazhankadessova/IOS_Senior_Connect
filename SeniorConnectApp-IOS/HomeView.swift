//
//  HomeView.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation

import SwiftUI
import SwiftData
import WebKit

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authService: AuthService
    @AppStorage("hasCompletedInitialTutorial") private var hasCompletedInitialTutorial = false
    @State private var showingTutorialPrompt = false
    
    private var completedLessons: Int {
            // Safely unwrap the optional value with a default of 0
            authService.currentUser?.overallProgress.totalLessonsCompleted ?? 0
        }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Actions
                    QuickActionsGrid()
                    
                    // Upcoming Events Preview
                    UpcomingEventsPreview()
                    
                    // Tutorial Progress
                    TutorialProgressCard(totalLessons: 16,completedLessons: completedLessons)
                }
                .padding()
            }
            .navigationTitle("Welcome")
        }
        .sheet(isPresented: $showingTutorialPrompt) {
            TutorialPromptView()
        }
        .onAppear {
            // Only show tutorial prompt if user hasn't completed it
            if !hasCompletedInitialTutorial {
                showingTutorialPrompt = true
                // Mark as completed once shown
                hasCompletedInitialTutorial = true
            }
        }
    }
}
