//
//  TutorialViewModel.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation
import SwiftUI

class TutorialViewModel: ObservableObject {
    
    let baseUrl = "http://localhost:3000"
    
    @Published var selectedLesson: Lesson?
    @Published var currentStep: Int = 0
    @Published var lessons: [Lesson] = []
    @Published var isLoading = false
    private let lessonService = LessonService()
    
    private var userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func updateUserId(_ newId: String) {
        userId = newId
    }

    func fetchLessons(category: String? = nil) async {
        isLoading = true
        do {
            try await lessonService.fetchLessons(category: category)
            isLoading = false
        } catch {
            print("Error fetching lessons: \(error)")
            isLoading = false
        }
    }
    
    func updateLessonProgress(_ lesson: Lesson, stepId: String? = nil, actionItemId: String? = nil) async {
        let progress = LessonProgress(
            category: "smartphoneBasics",  // Or pass this as parameter
            lessonId: lesson.id,
            stepId: stepId,
            actionItemId: actionItemId,
            savedForLater: nil,
            needsMentorHelp: nil,
            mentorNotes: nil
        )
        
        do {
            try await lessonService.updateLessonProgress(userId: userId, progress: progress)
        } catch {
            print("Error updating progress: \(error)")
        }
    }
    
    func saveForLater(_ lesson: Lesson) async {
        let progress = LessonProgress(
            category: "smartphoneBasics",
            lessonId: lesson.id,
            stepId: nil,
            actionItemId: nil,
            savedForLater: true,
            needsMentorHelp: false,
            mentorNotes: nil
        )
        
        do {
            try await lessonService.updateLessonProgress(userId: userId, progress: progress)
        } catch {
            print("Error saving for later: \(error)")
        }
    }
    
    func requestMentorHelp(for lesson: Lesson, notes: String? = nil) async {
        let progress = LessonProgress(
            category: "smartphoneBasics",
            lessonId: lesson.id,
            stepId: nil,
            actionItemId: nil,
            savedForLater: false,
            needsMentorHelp: true,
            mentorNotes: notes
        )
        
        do {
            try await lessonService.updateLessonProgress(userId: userId, progress: progress)
        } catch {
            print("Error requesting mentor help: \(error)")
        }
    }
}

extension TutorialViewModel {
    func updateBatchProgress(
        category: String,
        lessonId: String,
        completedSteps: [String],
        completedItems: [String]
    ) async throws {
        print("\n--- Starting Batch Progress Update ---")
        print("Category:", category)
        print("Lesson ID:", lessonId)
        print("User ID:", userId)
        print("Completed Steps:", completedSteps)
        print("Completed Items:", completedItems)
        
        let progress = BatchProgress(
            category: category,
            lessonId: lessonId,
            completedSteps: completedSteps,
            completedItems: completedItems
        )
        
        // Log request details
        print("\n--- Request Details ---")
        let url = URL(string: "http://localhost:3000/api/users/\(userId)/progress/batch")!
        print("URL:", url.absoluteString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let requestData = try encoder.encode(progress)
        request.httpBody = requestData
        
        // Log request body
        print("\nRequest Body:")
        if let requestJson = String(data: requestData, encoding: .utf8) {
            print(requestJson)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Log response details
            print("\n--- Response Details ---")
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code:", httpResponse.statusCode)
            }
            
            print("\nResponse Body:")
            if let responseString = String(data: data, encoding: .utf8) {
                print(responseString)
            }
            
            // Try to decode the response
            print("\n--- Decoded Response ---")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                let response = try decoder.decode(ProgressResponse.self, from: data)
                print("Progress Response:")
                print("- Completed:", response.progress.completed)
                print("- Last Accessed:", response.progress.lastAccessed)
                print("- Completed Steps:", response.progress.completedSteps)
                print("- Completed Items:", response.progress.completedActionItems)
                print("\nOverall Progress:")
                print("- Total Lessons Completed:", response.overallProgress.totalLessonsCompleted)
                print("- Average Quiz Score:", response.overallProgress.averageQuizScore)
                print("- Last Activity Date:", response.overallProgress.lastActivityDate)
            } catch {
                print("\nDecoding Error:", error)
                print("Failed to decode response. Raw response body:")
                print(String(data: data, encoding: .utf8) ?? "Unable to read response data")
                throw error
            }
            
        } catch {
            print("\n--- Error ---")
            print("Error making request:", error)
            throw error
        }
        
        print("\n--- End of Batch Progress Update ---")
    }
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
