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

enum AuthError: Error {
    case invalidCredentials
    case networkError
    case serverError(String)
    case unknown
    case decodingError(String)  // Changed to take a String message instead of Error
}

class AuthService: ObservableObject {
    @Published var currentUser: AuthUser?
    @Published var isAuthenticated = false
    @Published var authError: AuthError?
    
    private let baseURL = "http://localhost:3000"
    private let decoder = JSONDecoder()
    
    func login(email: String, password: String) async throws -> AuthUser {
        guard let url = URL(string: "\(baseURL)/api/users/login") else {
            throw AuthError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let credentials = LoginCredentials(email: email, password: password)
        request.httpBody = try? JSONEncoder().encode(credentials)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debug print
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Login response:", jsonString)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.networkError
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let user = try decoder.decode(AuthUser.self, from: data)
                    await MainActor.run {
                        self.currentUser = user
                        self.isAuthenticated = true
                    }
                    return user
                } catch let DecodingError.dataCorrupted(context) {
                    print("Data corrupted:", context)
                    throw AuthError.decodingError("Data corrupted: \(context.debugDescription)")
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key.stringValue)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    throw AuthError.decodingError("Missing key '\(key.stringValue)'")
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    throw AuthError.decodingError("Type mismatch: expected \(type)")
                } catch let DecodingError.valueNotFound(type, context) {
                    print("Value of type '\(type)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                    throw AuthError.decodingError("Value of type '\(type)' missing")
                } catch {
                    print("Other decoding error:", error)
                    throw AuthError.decodingError(error.localizedDescription)
                }
            case 401:
                throw AuthError.invalidCredentials
            default:
                throw AuthError.serverError("Server returned status code \(httpResponse.statusCode)")
            }
        } catch {
            print("Login error:", error)
            throw error
        }
    }
    
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
            "password": credentials.password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userData) else {
            throw AuthError.unknown
        }
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Debug print
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Signup response:", jsonString)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.networkError
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let user = try decoder.decode(AuthUser.self, from: data)
                    await MainActor.run {
                        self.currentUser = user
                        self.isAuthenticated = true
                    }
                    return user
                } catch let DecodingError.dataCorrupted(context) {
                    throw AuthError.decodingError("Data corrupted: \(context.debugDescription)")
                } catch let DecodingError.keyNotFound(key, context) {
                    throw AuthError.decodingError("Missing key '\(key.stringValue)'")
                } catch let DecodingError.typeMismatch(type, context) {
                    throw AuthError.decodingError("Type mismatch: expected \(type)")
                } catch let DecodingError.valueNotFound(type, context) {
                    throw AuthError.decodingError("Value of type '\(type)' missing")
                } catch {
                    throw AuthError.decodingError(error.localizedDescription)
                }
            case 400:
                throw AuthError.invalidCredentials
            default:
                throw AuthError.serverError("Server returned status code \(httpResponse.statusCode)")
            }
        } catch {
            print("Signup error:", error)
            throw error
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
}

// Helper extension for handling errors in the UI
extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network connection error"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown:
            return "An unknown error occurred"
        case .decodingError(let message):
            return "Data error: \(message)"
        }
    }
}
