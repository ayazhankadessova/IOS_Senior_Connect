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
        // Group completed actions by step
        let stepActionsDict = Dictionary(grouping: completedStepActions) { $0.stepId }
        let stepActions = stepActionsDict.map { stepId, identifiers in
            BatchProgressRequest.StepAction(
                stepId: stepId,
                actionItems: identifiers.map { $0.actionItemId }
            )
        }
        
        let progress = BatchProgressRequest(
            category: category,
            lessonId: lessonId,
            completedSteps: completedSteps,
            stepActions: stepActions,
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
        debugPrint("Progress updated:", response)
    }
    
    func saveForLater(_ lesson: Lesson) async throws {
        let progress = BatchProgressRequest(
            category: "smartphoneBasics",
            lessonId: lesson.lessonId,
            completedSteps: [],
            stepActions: [],
            savedForLater: true,
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
        debugPrint("Saved for later:", response)
    }
    
    func requestMentorHelp(for lesson: Lesson, notes: String? = nil) async throws {
        let progress = BatchProgressRequest(
            category: "smartphoneBasics",
            lessonId: lesson.lessonId,
            completedSteps: [],
            stepActions: [],
            savedForLater: nil,
            needsMentorHelp: true,
            mentorNotes: notes
        )
        
        let url = URL(string: "\(baseURL)/api/users/\(userId)/progress/batch")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(progress)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder.authDecoder.decode(ProgressResponse.self, from: data)
        debugPrint("Mentor help requested:", response)
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
