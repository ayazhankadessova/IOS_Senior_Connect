import Foundation

struct MentorshipResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
    let message: String?
}

struct CreateMentorshipResponse: Codable {
    let success: Bool
    let data: MentorshipRequest?
    let message: String
}

struct ErrorResponse: Codable {
    let success: Bool
    let message: String
}

struct FAQ: Identifiable {
    let id = UUID().uuidString
    let question: String
    let answer: String
}

struct MentorshipRequest: Codable, Identifiable {
    let id: String?
    let user: String?
    let mentor: String?
    let topic: String
    let description: String
    let phoneNumber: String
    let status: String
    let skillLevel: String
    let tags: [String]
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, mentor, topic, description, phoneNumber
        case status, skillLevel, tags, isActive, createdAt, updatedAt
    }
}

struct GetMentorshipListResponse: Codable {
    let success: Bool
    let data: [MentorshipRequest]
}

struct MentorRequestFormData {
    var topic: String = ""
    var description: String = ""
    var phoneNumber: String = ""
    var skillLevel: String = "Beginner"
}

// Create a protocol for form submission handling
protocol MentorRequestFormDelegate {
    func submitMentorRequest(formData: MentorRequestFormData) async throws
}
