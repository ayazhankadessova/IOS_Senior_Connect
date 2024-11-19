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

// MARK: - Home View
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingTutorialPrompt = true
    @EnvironmentObject var authService: AuthService
    
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
        }
        .sheet(isPresented: $showingTutorialPrompt) {
            TutorialPromptView()
        }
    }
}
