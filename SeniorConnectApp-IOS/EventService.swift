//
//  EventService.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 16/11/2024.
//

import Foundation


class EventService {
    private let baseURL = "http://localhost:3000/api"
    
    func fetchEvents() async throws -> [Event] {
        print("📅 Fetching events...")
        
        guard let url = URL(string: "\(baseURL)/events") else {
            print("❌ Invalid URL: \(baseURL)/events")
            throw NetworkError.invalidURL
        }
        
        print("🔍 Making request to: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw NetworkError.invalidResponse
            }
            
            print("📡 Response status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ Error status code: \(httpResponse.statusCode)")
                
                // Try to parse error message if available
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorJson["error"] as? String {
                    print("🚫 Server error: \(errorMessage)")
                }
                
                throw NetworkError.invalidResponse
            }
            
            // Debug: Print raw response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Raw response data: \(jsonString)")
            }
            
            let events = try JSONDecoder.authDecoder.decode([Event].self, from: data)
            print("✅ Successfully fetched \(events.count) events")
            
            // Log first event as sample
            if let firstEvent = events.first {
                print("📋 Sample event: \(firstEvent.title), Date: \(firstEvent.date)")
            }
            
            return events
        } catch let DecodingError.dataCorrupted(context) {
            print("❌ Data corrupted: \(context.debugDescription)")
            print("   - Coding path: \(context.codingPath)")
            throw NetworkError.decodingError
        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ Key '\(key.stringValue)' not found: \(context.debugDescription)")
            print("   - Coding path: \(context.codingPath)")
            throw NetworkError.decodingError
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ Type mismatch for type \(type): \(context.debugDescription)")
            print("   - Coding path: \(context.codingPath)")
            throw NetworkError.decodingError
        } catch let DecodingError.valueNotFound(type, context) {
            print("❌ Value of type \(type) not found: \(context.debugDescription)")
            print("   - Coding path: \(context.codingPath)")
            throw NetworkError.decodingError
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchUpcomingEvents() async throws -> [Event] {
        guard let url = URL(string: "\(baseURL)/events?status=upcoming") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Event].self, from: data)
    }
    
    func registerForEvent(_ eventId: String) async throws {
        guard let url = URL(string: "\(baseURL)/events/\(eventId)/join") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
    }
    
    func unregisterFromEvent(_ eventId: String) async throws {
        guard let url = URL(string: "\(baseURL)/events/\(eventId)/leave") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
    }
}
