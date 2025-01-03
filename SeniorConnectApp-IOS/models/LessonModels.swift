//
//  LessonModels.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation
import SwiftUI

// Models for progress tracking
// Models for server response

struct CategoryLessonProgress: Codable, Identifiable {
    let id: String?  // Make id optional since it's not always returned
    let lessonId: String
    let completed: Bool
    let lastAccessed: Date
    let completedSteps: [String]
    let stepProgress: [StepProgress]
    let quizScores: [QuizScore]
    let savedForLater: Bool
    let needsMentorHelp: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case lessonId
        case completed
        case lastAccessed
        case completedSteps
        case stepProgress
        case quizScores
        case savedForLater
        case needsMentorHelp
    }
    
    // Add init to handle missing id
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode id, but use nil if not present
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        
        // Decode required fields
        self.lessonId = try container.decode(String.self, forKey: .lessonId)
        self.completed = try container.decode(Bool.self, forKey: .completed)
        self.lastAccessed = try container.decode(Date.self, forKey: .lastAccessed)
        self.completedSteps = try container.decode([String].self, forKey: .completedSteps)
        self.stepProgress = try container.decode([StepProgress].self, forKey: .stepProgress)
        self.quizScores = try container.decode([QuizScore].self, forKey: .quizScores)
        self.savedForLater = try container.decode(Bool.self, forKey: .savedForLater)
        self.needsMentorHelp = try container.decode(Bool.self, forKey: .needsMentorHelp)
    }
}

struct SimpleResponse: Codable {
    let success: Bool
}

struct CategoryProgressResponse: Codable {
    let categoryProgress: [CategoryLessonProgress]
    var overallProgress: OverallProgress
}

struct ProgressResponse: Codable {
    let progress: CategoryLessonProgress
    var overallProgress: OverallProgress
}

struct LessonProgress: Codable, Identifiable {
    let id: String
    let lessonId: String
    let completed: Bool
    let lastAccessed: Date
    let completedSteps: [String]
    let stepProgress: [StepProgress]
    let quizScores: [QuizScore]
    let savedForLater: Bool
    let needsMentorHelp: Bool
    let mentorNotes: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case lessonId
        case completed
        case lastAccessed
        case completedSteps
        case stepProgress
        case quizScores
        case savedForLater
        case needsMentorHelp
        case mentorNotes
    }
}

struct OverallProgress: Codable {
    var totalLessonsCompleted: Int
    let averageQuizScore: Double
    let lastActivityDate: Date  // This will now be properly decoded
}

extension Date {
    func formatted() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

struct QuizScore: Codable {
    let score: Int
    let attemptDate: Date
}

struct BatchProgressRequest: Codable {
    let category: String
    let lessonId: String
    let completedSteps: [String]
    let stepActions: [StepAction]
    let savedForLater: Bool?
    let needsMentorHelp: Bool?
    let mentorNotes: String?
    
    struct StepAction: Codable {
        let stepId: String
        let actionItems: [String]
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
}

struct Lesson: Codable, Identifiable {
    let id: String
    let category: String
    let lessonId: String
    let title: String
    let description: String
    let videoUrl: String?
    let order: Int
    let steps: [Step]
    let quiz: [QuizQuestion]
    let v: Int
    
    // UI state properties (not from backend)
    var savedForLater: Bool = false
    var needsMentorHelp: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case category
        case lessonId
        case title
        case description
        case videoUrl
        case order
        case steps
        case quiz
        case v = "__v"
    }
}

struct Step: Codable, Identifiable {
    let id: String
    let stepId: String
    let title: String
    let description: String
    var actionItems: [ActionItem]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case stepId
        case title
        case description
        case actionItems
    }
}

struct ActionItem: Codable, Identifiable {
    let id: String
    let itemId: String
    let task: String
    let isRequired: Bool
    var isCompleted: Bool = false // UI state, not from backend
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case itemId
        case task
        case isRequired
    }
}


// Update TutorialCategory
struct TutorialCategory: Identifiable {
    let id = UUID()
    let name: String
    let apiName: String // Add this
    let description: String
    let icon: String
    let color: Color
    let lessons: [Lesson]?
    
    static let allCategories = [
        TutorialCategory(
            name: "Smartphone Basics",
            apiName: "smartphoneBasics",
            description: "Learn essential smartphone operations",
            icon: "iphone",
            color: .blue,
            lessons: nil
        ),
        TutorialCategory(
            name: "Digital Literacy",
            apiName: "digitalLiteracy",
            description: "Stay safe while browsing online",
            icon: "lock.shield",
            color: .green,
            lessons: nil
        ),
        TutorialCategory(
            name: "Social Media",
            apiName: "socialMedia",
            description: "Connect with friends and family",
            icon: "person.2",
            color: .purple,
            lessons: nil
        ),
        TutorialCategory(
            name: "Smart Home",
            apiName: "iot",
            description: "Control your smart home devices",
            icon: "homekit",
            color: .orange,
            lessons: nil
        )
    ]
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 16, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Structures
struct TutorialStep: Identifiable {
    let id = UUID()
    let order: Int
    let title: String
    let content: String
}

struct StepActionIdentifier: Hashable {
    let stepId: String
    let actionItemId: String
}
//
//struct StepProgress: Codable {
//    let stepId: String
//    let completedActionItems: [String]
//}

