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
                    throw NetworkError.invalidResponse
                }
                
                // Debug: Print raw response
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Raw response data: \(jsonString)")
                }
                
                let decoder = JSONDecoder()
                
                // Custom date decoding strategy
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                decoder.dateDecodingStrategy = .custom { decoder -> Date in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    
                    // Try alternative formats if the first one fails
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    
                    print("❌ Failed to parse date: \(dateString)")
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
                
                let events = try decoder.decode([Event].self, from: data)
                print("✅ Successfully fetched \(events.count) events")
                
                // Log first event as sample
                if let firstEvent = events.first {
                    print("📋 Sample event: \(firstEvent.title)")
                    print("📅 Event date: \(firstEvent.date)")
                    print("🕒 Event times: \(firstEvent.startTime) - \(firstEvent.endTime)")
                }
                
                return events
            } catch {
                print("❌ Error fetching events: \(error)")
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
