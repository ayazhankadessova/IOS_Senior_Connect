import Foundation

struct AuthUser: Codable {
    let id: String
    let name: String
    let email: String
    var progress: UserProgress
    var overallProgress: OverallProgress
    let v: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case progress
        case overallProgress
        case v = "__v"
    }
    
    struct UserProgress: Codable {
        var smartphoneBasics: [LessonProgress]
        var digitalLiteracy: [LessonProgress]
        var socialMedia: [LessonProgress]
        var iot: [LessonProgress]
    }
    
    struct LessonProgress: Codable {
        var id: String
        var lessonId: String
        var completed: Bool
        var lastAccessed: String
        var completedSteps: [String]
        var completedActionItems: [String]
        var quizScores: [Int]
        var savedForLater: Bool
        var needsMentorHelp: Bool
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case lessonId
            case completed
            case lastAccessed
            case completedSteps
            case completedActionItems
            case quizScores
            case savedForLater
            case needsMentorHelp
        }
    }
    
    struct OverallProgress: Codable {
        var totalLessonsCompleted: Int
        var averageQuizScore: Double
        var lastActivityDate: String
    }
}

// Extensions for date handling
extension AuthUser.LessonProgress {
    var lastAccessedDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: lastAccessed)
    }
}

extension AuthUser.OverallProgress {
    var activityDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: lastActivityDate)
    }
}

struct LoginResponse: Codable {
    let user: AuthUser
    // Add any other fields that come in the response
}

struct SignupResponse: Codable {
    let user: AuthUser
    // Add any other fields that come in the response
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
