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
    
    func login(email: String, password: String) async throws {
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
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.networkError
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                // Use custom decoder for date handling
                let user = try JSONDecoder.authDecoder.decode(AuthUser.self, from: data)
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
//                return user
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
            guard let url = URL(string: "\(baseURL)/api/users/signup") else {
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
                        // Use the custom decoder instead of the default one
                        let user = try JSONDecoder.authDecoder.decode(AuthUser.self, from: data)
                        await MainActor.run {
                            self.currentUser = user
                            self.isAuthenticated = true
                        }
                        return user
                    } catch let error as DecodingError {
                        print("Detailed decoding error:", error)
                        switch error {
                        case .dataCorrupted(let context):
                            throw AuthError.decodingError("Data corrupted: \(context.debugDescription)")
                        case .keyNotFound(let key, _):
                            throw AuthError.decodingError("Missing key '\(key.stringValue)'")
                        case .typeMismatch(let type, let context):
                            throw AuthError.decodingError("Type mismatch at path: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")), expected \(type)")
                        case .valueNotFound(let type, let context):
                            throw AuthError.decodingError("Value of type '\(type)' missing at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                        @unknown default:
                            throw AuthError.decodingError(error.localizedDescription)
                        }
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
