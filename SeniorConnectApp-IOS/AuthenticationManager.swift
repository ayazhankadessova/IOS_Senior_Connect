//
//  AuthenticationManager.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation
import SwiftUI
import SwiftData
import AuthenticationServices

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    func signInWithSocial(provider: SocialProvider) async throws {
        // Implementation for social login
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
    }
    
    enum SocialProvider {
        case google
        case facebook
        case phone
    }
}


@Model
class User {
    var id: String
    var name: String
    var email: String
    var joinDate: Date
    var mentorshipAreas: [String]
    var eventsAttending: [Event]?
    
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
        self.joinDate = Date()
        self.mentorshipAreas = []
    }
}

@Model
class Event {
    var id: String
    var title: String
    var desc: String
    var date: Date
    var location: String
    var attendees: [User]?
    var type: EventType
    
    enum EventType: String, Codable {
        case workshop
        case socialGathering
        case tutorial
        case mentorship
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         desc: String,
         date: Date,
         location: String,
         type: EventType,
         attendees: [User]? = nil) {
        self.id = id
        self.title = title
        self.desc = desc
        self.date = date
        self.location = location
        self.type = type
        self.attendees = attendees
    }
}

// Example usage:
extension Event {
    static var sampleEvents: [Event] {
        [
            Event(
                title: "Digital Photography Workshop",
                desc: "Learn how to take better photos with your smartphone",
                date: Date().addingTimeInterval(86400), // Tomorrow
                location: "Community Center",
                type: .workshop
            ),
            Event(
                title: "Social Media Safety",
                desc: "Essential tips for staying safe on social media platforms",
                date: Date().addingTimeInterval(172800), // Day after tomorrow
                location: "Online",
                type: .tutorial
            ),
            Event(
                title: "Coffee & Tech Chat",
                desc: "Casual gathering to discuss technology and share tips",
                date: Date().addingTimeInterval(259200), // 3 days from now
                location: "Local Coffee Shop",
                type: .socialGathering
            )
        ]
    }
}

struct AccessibilityConstants {
    static let minimumTapArea: CGFloat = 44
    static let defaultFontSize: CGFloat = 20
    static let headerFontSize: CGFloat = 28
    static let buttonCornerRadius: CGFloat = 12
    static let defaultPadding: CGFloat = 16
}
