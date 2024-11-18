//
//  EventService.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 16/11/2024.
//

import Foundation


class EventService {
    private let baseURL = "http://localhost:3000/api"
    
    private var cache: [String: Any] = [:] // Simple cache
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    // Add cache structure
    private struct CacheEntry {
        let data: Any
        let timestamp: Date
        
        var isValid: Bool {
            Date().timeIntervalSince(timestamp) < 300 // 5 minutes
        }
    }
    
    private var eventCache: [String: CacheEntry] = [:]
    
    func clearCache() {
        eventCache.removeAll()
        print("🧹 Cache cleared")
    }
    
                
    func fetchEvents(query: EventQuery) async throws -> PaginatedResponse<Event> {
        // When refreshing, skip cache and fetch from network
        if query.page == 1 {
            print("📥 Fetching fresh data from network")
            return try await fetchEventsFromNetwork(query: query)
        }
        
        let cacheKey = query.cacheKey
        
        // Check cache for subsequent pages
        if let cached = eventCache[cacheKey],
           cached.isValid,
           let response = cached.data as? PaginatedResponse<Event> {
            print("📦 Using cached events data")
            return response
        }
        
        // If not in cache, fetch from network
        let response = try await fetchEventsFromNetwork(query: query)
        
        // Store in cache
        eventCache[cacheKey] = CacheEntry(data: response, timestamp: Date())
        return response
    }
    
    // Renamed to fetchEventsFromNetwork
    private func fetchEventsFromNetwork(query: EventQuery) async throws -> PaginatedResponse<Event> {
        print("📅 Fetching events with query parameters...")
        
        var components = URLComponents(string: "\(baseURL)/events")!
        var queryItems = [
            URLQueryItem(name: "page", value: String(query.page)),
            URLQueryItem(name: "limit", value: String(query.limit))
        ]
        
        if let search = query.search, !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        
        if let category = query.category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        if let isOnline = query.isOnline {
            queryItems.append(URLQueryItem(name: "isOnline", value: String(isOnline)))
        }
        
        if let city = query.city {
            queryItems.append(URLQueryItem(name: "city", value: city))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("❌ Invalid URL")
            throw NetworkError.invalidURL
        }
        
        print("🔍 Making request to: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorJson["error"] as? String {
                print("🚫 Server error: \(errorMessage)")
            }
            throw NetworkError.invalidResponse
        }
        
        let responseDec = try JSONDecoder.authDecoder.decode(PaginatedResponse<Event>.self, from: data)
        print("✅ Successfully fetched \(responseDec.events.count) events")
        
        return responseDec
    }
    
    // Add method to clear specific cache entry
    func clearCache(for query: EventQuery) {
        eventCache.removeValue(forKey: query.cacheKey)
        print("🧹 Cache cleared for query: \(query.cacheKey)")
    }
    
    // Add method to check if data is cached
    func isCached(for query: EventQuery) -> Bool {
        if let cached = eventCache[query.cacheKey] {
            return cached.isValid
        }
        return false
    }
    
    func registerForEvent(_ eventId: String, userId: String) async throws {
            print("\n=== EVENT REGISTRATION START ===")
            print("📝 Registering for event: \(eventId)")
            print("👤 User ID: \(userId)")
            
            guard let url = URL(string: "\(baseURL)/events/\(eventId)/join") else {
                print("❌ Invalid URL construction")
                throw NetworkError.invalidURL
            }
            print("🌐 Registration URL: \(url.absoluteString)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = ["userId": userId]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            print("📤 Request body: \(body)")
            print("📤 Request headers: \(request.allHTTPHeaderFields ?? [:])")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response type received")
                    throw NetworkError.invalidResponse
                }
                
                print("📡 Response status code: \(httpResponse.statusCode)")
                print("📡 Response headers: \(httpResponse.allHeaderFields)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Response data: \(responseString)")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessage = errorJson["error"] as? String {
                        print("🚫 Server error: \(errorMessage)")
                    }
                    throw NetworkError.invalidResponse
                }
                
                print("✅ Registration successful")
            } catch {
                print("❌ Registration failed with error: \(error.localizedDescription)")
                throw error
            }
            
            print("=== EVENT REGISTRATION END ===\n")
        }
    
    func unregisterFromEvent(_ eventId: String, userId: String) async throws {
        print("🗑 Unregistering from event: \(eventId)")
        
        guard let url = URL(string: "\(baseURL)/events/\(eventId)/leave") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["userId": userId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorJson["error"] as? String {
                print("🚫 Unregistration error: \(errorMessage)")
            }
            throw NetworkError.invalidResponse
        }
        
        print("✅ Successfully unregistered from event")
    }
    
    func checkRegistrationStatus(eventId: String, userId: String) async throws -> Bool {
        let url = URL(string: "\(baseURL)/events/\(eventId)/registration-status?userId=\(userId)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        let registrationResponse = try JSONDecoder.authDecoder.decode(RegistrationResponse.self, from: data)
        return registrationResponse.isRegistered
    }
    
    func getEventDetails(eventId: String, userId: String?) async throws -> Event {
        var components = URLComponents(string: "\(baseURL)/events/\(eventId)")!
        
        if let userId = userId {
            components.queryItems = [URLQueryItem(name: "userId", value: userId)]
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder.authDecoder.decode(Event.self, from: data)
    }
    
    func getRegisteredEvents(userId: String) async throws -> [Event] {
            let url = URL(string: "\(baseURL)/events/registered?userId=\(userId)")!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
            
            let events = try JSONDecoder.authDecoder.decode([Event].self, from: data)
            return events
        }
}
