//
//  AuthModels.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation

struct AuthUser: Codable {
    let id: String
    let name: String
    let email: String
    var progress: UserProgress
    
    // Add CodingKeys to map _id to id
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case progress
    }
    
    struct UserProgress: Codable {
        var smartphoneBasics: CategoryProgress
        var digitalLiteracy: CategoryProgress
        var socialMedia: CategoryProgress
        var iot: CategoryProgress
        
        struct CategoryProgress: Codable {
            var completed: [String]
            var currentLesson: Int
            var quizScores: [Int]
        }
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

enum AuthError: Error {
    case invalidCredentials
    case networkError
    case serverError(String)
    case unknown
}
