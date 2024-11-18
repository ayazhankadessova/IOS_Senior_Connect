//
//  EventModels.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 16/11/2024.
//

import Foundation

struct Event: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let category: EventCategory
    let date: Date
    let startTime: String
    let endTime: String
    let location: EventLocation
    let organizer: EventOrganizer
    let quota: Int
    let currentParticipants: Int
    let participants: [String]
    let status: EventStatus
    let imageUrl: String
    let isOnline: Bool
    let meetingLink: String?
    let tags: [String]
    let createdAt: Date
    let updatedAt: Date
    
    var isFullyBooked: Bool {
        currentParticipants >= quota
    }
    
    var isPast: Bool {
        Date() > date
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, category, date, startTime, endTime
        case location, organizer, quota, currentParticipants, participants
        case status, imageUrl, isOnline, meetingLink, tags, createdAt, updatedAt
    }
}

enum EventCategory: String, Codable {
    case educational
    case social
    case health
    case technology
    case entertainment
    case other
}

enum EventStatus: String, Codable {
    case upcoming
    case ongoing
    case completed
    case cancelled
}

struct EventLocation: Codable {
    let address: String
    let city: String?
    let zipCode: String?
}

struct EventOrganizer: Codable {
    let name: String
    let contact: String
    let type: OrganizerType
    
    enum OrganizerType: String, Codable {
        case staff
        case partner
        case volunteer
    }
}

struct EventQuery {
    var page: Int = 1
    var limit: Int = 10
    var search: String?
    var category: String?
    var isOnline: Bool?
    var city: String?
    
    // Add description property
    var cacheKey: String {
        let components = [
            "page_\(page)",
            "limit_\(limit)",
            search.map { "search_\($0)" },
            category.map { "category_\($0)" },
            isOnline.map { "online_\($0)" },
            city.map { "city_\($0)" }
        ].compactMap { $0 }
        
        return components.joined(separator: "_")
    }
}

struct PaginatedResponse<T: Codable>: Codable {
    let events: [T]
    let pagination: Pagination
}

struct Pagination: Codable {
    let currentPage: Int
    let totalPages: Int
    let totalEvents: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
}


struct RegistrationResponse: Codable {
    let isRegistered: Bool
}
