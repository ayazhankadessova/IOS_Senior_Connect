import Foundation

struct AuthUser: Codable {
    let id: String
    let name: String
    let email: String
    let progress: UserProgress
    var overallProgress: OverallProgress
    let registeredEvents: [String]  // Add registeredEvents array
    let v: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case progress
        case overallProgress
        case registeredEvents
        case v = "__v"
    }
}

extension AuthUser {
    func getProgress(for category: LearningCategory) -> [CategoryLessonProgress] {
        switch category {
        case .smartphoneBasics:
            return progress.smartphoneBasics
        case .digitalLiteracy:
            return progress.digitalLiteracy
        case .socialMedia:
            return progress.socialMedia
        case .iot:
            return progress.iot
        }
    }
}

// Extensions for date handling
//extension AuthUser.LessonProgress {
//    var lastAccessedDate: Date? {
//        let formatter = ISO8601DateFormatter()
//        return formatter.date(from: lastAccessed)
//    }
//}
//
//extension AuthUser.OverallProgress {
//    var activityDate: Date? {
//        let formatter = ISO8601DateFormatter()
//        return formatter.date(from: lastActivityDate)
//    }
//}

struct LoginResponse: Codable {
    let user: AuthUser
    // Add any other fields that come in the response
}

struct SignupResponse: Codable {
    let name: String
    let email: String
    let progress: UserProgress
    var overallProgress: OverallProgress
    let registeredEvents: [String]  // Add registeredEvents array
    let id: String
    let v: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case progress
        case overallProgress
        case registeredEvents
        case id = "_id"
        case v = "__v"
    }
}

struct LoginCredentials: Codable {
    let email: String
    let password: String
}

struct SignupCredentials: Codable {
    let name: String
    let email: String
    let password: String
}

//enum AuthError: Error {
//    case invalidCredentials
//    case networkError
//    case serverError(String)
//    case unknown
//    case decodingError(Error)
//}

struct AuthResponse: Codable {
    let progress: UserProgress
    var overallProgress: OverallProgress
    let id: String
    let name: String
    let email: String
    let v: Int
    
    enum CodingKeys: String, CodingKey {
        case progress
        case overallProgress
        case id = "_id"
        case name
        case email
        case v = "__v"
    }
}

struct UserProgress: Codable {
    let smartphoneBasics: [CategoryLessonProgress]
    let digitalLiteracy: [CategoryLessonProgress]
    let socialMedia: [CategoryLessonProgress]
    let iot: [CategoryLessonProgress]
}

struct StepProgress: Codable {
    let id: String?  // Make id optional since it's not always returned
    let stepId: String
    let completedActionItems: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case stepId
        case completedActionItems
    }
    
    // Add init to handle missing id
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode id, but use nil if not present
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        
        // Decode required fields
        self.stepId = try container.decode(String.self, forKey: .stepId)
        self.completedActionItems = try container.decode([String].self, forKey: .completedActionItems)
    }
}
