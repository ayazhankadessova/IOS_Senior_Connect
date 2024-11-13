//
//  AuthService.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation
//
//  AuthService.swift
//  SeniorConnectApp
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation
import SwiftUI

class AuthService: ObservableObject {
    @Published var currentUser: AuthUser?
    @Published var isAuthenticated = false
    @Published var authError: AuthError?
    
    private let baseURL = "http://localhost:3000" // For local testing
   // Use this when deployed to Vercel:
   // private let baseURL = "https://your-vercel-app.vercel.app"
    
func signup(credentials: SignupCredentials) async throws -> AuthUser {
        guard let url = URL(string: "\(baseURL)/api/users") else {
            throw AuthError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userData: [String: Any] = [
            "name": credentials.name,
            "email": credentials.email,
            "password": credentials.password,
            "progress": [
                "smartphoneBasics": ["completed": [], "currentLesson": 0, "quizScores": []],
                "digitalLiteracy": ["completed": [], "currentLesson": 0, "quizScores": []],
                "socialMedia": ["completed": [], "currentLesson": 0, "quizScores": []],
                "iot": ["completed": [], "currentLesson": 0, "quizScores": []]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userData) else {
            throw AuthError.unknown
        }
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.networkError
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "none")")
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let user = try JSONDecoder().decode(AuthUser.self, from: data)
                    await MainActor.run {
                        self.currentUser = user
                        self.isAuthenticated = true
                    }
                    return user
                } catch {
                    print("Decoding error: \(error)")
                    throw AuthError.unknown
                }
            case 400:
                throw AuthError.invalidCredentials
            default:
                throw AuthError.serverError("Server returned status code \(httpResponse.statusCode)")
            }
        } catch {
            print("Network error: \(error)")
            throw error
        }
    }
    
    func login(email: String, password: String) async throws -> AuthUser {
        guard let url = URL(string: "\(baseURL)/api/users/login") else {
            throw AuthError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let credentials = LoginCredentials(email: email, password: password)
        request.httpBody = try? JSONEncoder().encode(credentials)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let user = try JSONDecoder().decode(AuthUser.self, from: data)
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
            return user
        case 401:
            throw AuthError.invalidCredentials
        default:
            throw AuthError.serverError("Server returned status code \(httpResponse.statusCode)")
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
}
