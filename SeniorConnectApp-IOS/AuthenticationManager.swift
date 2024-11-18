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


struct AccessibilityConstants {
    static let minimumTapArea: CGFloat = 44
    static let defaultFontSize: CGFloat = 20
    static let headerFontSize: CGFloat = 28
    static let buttonCornerRadius: CGFloat = 12
    static let defaultPadding: CGFloat = 16
}
