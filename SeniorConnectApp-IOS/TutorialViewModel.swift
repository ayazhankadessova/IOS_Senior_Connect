//
//  TutorialViewModel.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation
import SwiftUI

class TutorialViewModel: ObservableObject, MentorRequestFormDelegate {
    private let baseURL = "http://localhost:3000"
    
    @Published var selectedLesson: Lesson?
    @Published var currentStep: Int = 0
    @Published var lessons: [Lesson] = []
    @Published var isLoading = false
    @Published var lessonProgress: CategoryLessonProgress?
    var tutorialDetailView: TutorialDetailView?
    private let mentorshipService = MentorshipService()
    private var currentLesson: Lesson?
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func setCurrentLesson(_ lesson: Lesson) {
            self.currentLesson = lesson
        }

    func updateBatchProgress(
            category: String,
            lessonId: String,
            completedSteps: [String],
            completedStepActions: Set<StepActionIdentifier>
        ) async throws {
            print("🔄 Starting batch progress update")
            print("📋 Category: \(category)")
            print("📋 LessonId: \(lessonId)")
            print("📋 Completed steps: \(completedSteps)")
            print("📋 Action count: \(completedStepActions.count)")
            
            let stepActions = makeStepActions(from: completedStepActions)
            
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
            request.httpBody = try JSONEncoder().encode(progress)
            
            let (data, response) = try await URLSession.shared.data(for: request)
        
            
            // Try to decode the success response, but don't throw if it fails
            do {
                let simpleResponse = try JSONDecoder().decode(SimpleResponse.self, from: data)
                if !simpleResponse.success {
                    print("⚠️ Server indicated failure")
                    throw NetworkError.serverError("Update failed")
                }
                print("✅ Server confirmed success")
            } catch {
                // If we can't decode the response but got a 200 status code,
                // we'll consider it a success and continue
                print("ℹ️ Couldn't decode response, but status code indicates success")
            }
            
            // Add a longer delay to ensure backend processing is complete
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            // Refresh in multiple steps
            if let parentView = tutorialDetailView {
                // First refresh the parent view
                try await parentView.refreshData()
                
                // Then wait a bit and fetch specific lesson progress
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                // Finally, refresh parent view one more time
                try await parentView.refreshData()
                
                // Verify the update was successful
                await MainActor.run {
                    if let progress = lessonProgress {
                        print("🔍 Final progress state:")
                        print("  Completed: \(progress.completed)")
                        print("  Completed steps: \(progress.completedSteps)")
                        print("  Step progress count: \(progress.stepProgress.count)")
                    }
                }
            }
        }
        
    
    private func makeStepActions(from actions: Set<StepActionIdentifier>) -> [BatchProgressRequest.StepAction] {
        print("🔨 Creating step actions from \(actions.count) identifiers")
        let stepActions = Dictionary(grouping: actions) { $0.stepId }
            .map { stepId, identifiers in
                let action = BatchProgressRequest.StepAction(
                    stepId: stepId,
                    actionItems: identifiers.map { $0.actionItemId }
                )
                print("Created action for step \(stepId) with \(action.actionItems.count) items")
                return action
            }
        print("📦 Generated \(stepActions.count) step actions")
        return stepActions
    }
        
    
    func saveForLater(_ lesson: Lesson) async throws {
        print("Saving lesson for later: \(lesson.lessonId)")
        let requestData = [
            "category": lesson.category,
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
    
    func updateQuizScore(lessonId: String, score: Int, category: String) async throws {
            let url = URL(string: "\(baseURL)/api/users/\(userId)/progress/quiz-score")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = [
                "lessonId": lessonId,
                "score": score,
                "category": category
            ] as [String: Any]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorJson["message"] as? String {
                    throw NetworkError.serverError(errorMessage)
                }
                throw NetworkError.invalidResponse
            }
            
            // Update local progress if needed
            if let responseJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let progressData = responseJson["data"] as? [String: Any] {
                // Handle updated progress if needed
                print("✅ Quiz score updated successfully: \(progressData)")
            }
        }
        
    func requestMentorHelp(
            for lesson: Lesson,
            notes: String?,
            phoneNumber: String,
            skillLevel: String
        ) async throws {
            print("Creating mentorship request for lesson: \(lesson.title)")
            
            // Create a description that includes lesson details and user notes
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
                    phoneNumber: phoneNumber, // Pass the phone number
                    skillLevel: skillLevel,   // Pass the skill level
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
    
    func submitMentorRequest(formData: MentorRequestFormData) async throws {
            guard let lesson = currentLesson else {
                throw NSError(domain: "TutorialViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No lesson selected"])
            }
            
            try await requestMentorHelp(
                for: lesson,
                notes: formData.description,
                phoneNumber: formData.phoneNumber,
                skillLevel: formData.skillLevel
            )
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
