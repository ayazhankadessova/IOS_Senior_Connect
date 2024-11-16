//
//  TutorialViewModel.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation
import SwiftUI

class TutorialViewModel: ObservableObject {
    private let baseURL = "http://localhost:3000"
    
    @Published var selectedLesson: Lesson?
    @Published var currentStep: Int = 0
    @Published var lessons: [Lesson] = []
    @Published var isLoading = false
    @Published var lessonProgress: CategoryLessonProgress?
    var tutorialDetailView: TutorialDetailView?
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func updateBatchProgress(
            category: String,
            lessonId: String,
            completedSteps: [String],
            completedStepActions: Set<StepActionIdentifier>
        ) async throws {
            let progress = BatchProgressRequest(
                category: category,
                lessonId: lessonId,
                completedSteps: completedSteps,
                stepActions: makeStepActions(from: completedStepActions),
                savedForLater: nil,
                needsMentorHelp: nil,
                mentorNotes: nil
            )
            
            let url = URL(string: "\(baseURL)/api/users/\(userId)/progress/batch")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(progress)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder.authDecoder.decode(ProgressResponse.self, from: data)
            
            // Update local progress state first
            await MainActor.run {
                self.lessonProgress = response.progress
            }
            
            // Refresh parent view data
            guard let parentView = tutorialDetailView else {
                print("Parent view reference is missing")
                return
            }
            try await parentView.refreshData()
            
            // After parent refresh, update our local progress again
            try await fetchLessonProgress(lessonId: lessonId)
        }
    
    private func makeStepActions(from actions: Set<StepActionIdentifier>) -> [BatchProgressRequest.StepAction] {
            return Dictionary(grouping: actions) { $0.stepId }
                .map { stepId, identifiers in
                    BatchProgressRequest.StepAction(
                        stepId: stepId,
                        actionItems: identifiers.map { $0.actionItemId }
                    )
                }
        }
        
    
    func saveForLater(_ lesson: Lesson) async throws {
        print("Saving lesson for later: \(lesson.lessonId)")
        let requestData = [
            "category": "smartphoneBasics",
            "lessonId": lesson.lessonId
        ]
        
        let url = URL(string: "\(baseURL)/api/users/\(userId)/progress/save-for-later")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(requestData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug response
        if let responseString = String(data: data, encoding: .utf8) {
            print("Save for later response:", responseString)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
        }
        
        let progressResponse = try JSONDecoder.authDecoder.decode(SaveForLaterResponse.self, from: data)
        
        // Update local progress if needed
        await MainActor.run {
            self.lessonProgress = progressResponse.progress
        }
        
    }
        
    func requestMentorHelp(for lesson: Lesson, notes: String? = nil) async throws {
            print("Requesting mentor help for lesson: \(lesson.lessonId)")
            let requestData = [
                "category": "smartphoneBasics",
                "lessonId": lesson.lessonId,
                "notes": notes
            ] as [String : Any?]
            
            let url = URL(string: "\(baseURL)/api/users/\(userId)/progress/request-mentor")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try JSONSerialization.data(withJSONObject: requestData.compactMapValues { $0 })
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debug response
            if let responseString = String(data: data, encoding: .utf8) {
                print("Request mentor help response:", responseString)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
            }
            
            let progressResponse = try JSONDecoder.authDecoder.decode(MentorHelpResponse.self, from: data)
            
            // Update local progress if needed
            await MainActor.run {
                self.lessonProgress = progressResponse.progress
            }
            
        }
    
    func fetchLessonProgress(lessonId: String) async throws {
            let url = URL(string: "\(baseURL)/api/users/\(userId)/lessons/\(lessonId)/progress")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let progress = try JSONDecoder.authDecoder.decode(CategoryLessonProgress.self, from: data)
            
            await MainActor.run {
                self.lessonProgress = progress
            }
        }
}

extension JSONDecoder {
    static var authDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid date format: \(dateString)"
                )
            )
        }
        return decoder
    }
}

// Add these response types
struct SaveForLaterResponse: Codable {
    let progress: CategoryLessonProgress
}

struct MentorHelpResponse: Codable {
    let progress: CategoryLessonProgress
}

//struct ProgressResponse: Codable {
//    let progress: Progress
//    let overallProgress: OverallProgress
//    
//    struct Progress: Codable {
//        let lessonId: String
//        let completed: Bool
//        let lastAccessed: Date
//        let completedSteps: [String]
//        let completedActionItems: [String]
//        let quizScores: [QuizScore]
//        let savedForLater: Bool
//        let needsMentorHelp: Bool
//        let mentorNotes: String?
//    }
//    
//    struct QuizScore: Codable {
//        let score: Int
//        let attemptDate: Date
//    }
//}

//struct OverallProgress: Codable {
//    let totalLessonsCompleted: Int
//    let averageQuizScore: Double
//    let lastActivityDate: Date
//}
//
//struct BatchProgress: Codable {
//    let category: String
//    let lessonId: String
//    let completedSteps: [String]
//    let completedItems: [String]
//}
