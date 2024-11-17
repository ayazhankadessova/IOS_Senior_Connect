//
//  EventsView.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation
import SwiftUI
import SwiftData
// MARK: - Events View
struct EventsView: View {
    @StateObject private var viewModel = EventViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var selectedCity: String?
    @State private var isOnlineOnly = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search and Filters
                SearchBar(text: $searchText, onSubmit: {
                    Task {
                        await viewModel.searchEvents(query: searchText)
                    }
                })
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        FilterChip(
                            title: "Online Only",
                            isSelected: isOnlineOnly,
                            action: { isOnlineOnly.toggle() }
                        )
                        
//                        if let categories = viewModel.categories {
//                            ForEach(categories, id: \.self) { category in
//                                FilterChip(
//                                    title: category,
//                                    isSelected: selectedCategory == category,
//                                    action: { selectedCategory = category }
//                                )
//                            }
//                        }
                    }
                    .padding(.horizontal)
                }
                
                // Events List
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(viewModel.events) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                EventRow(event: event)
                            }
                        }
                        
                        if viewModel.hasMoreEvents {
                            ProgressView()
                                .onAppear {
                                    Task {
                                        await viewModel.loadMoreEvents()
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .onChange(of: isOnlineOnly) { _ in
                Task {
                    await viewModel.applyFilters()
                }
            }
            .onChange(of: selectedCategory) { _ in
                Task {
                    await viewModel.applyFilters()
                }
            }
            .refreshable {
                await viewModel.refreshEvents()
            }
        }
    }
}

struct EventRow: View {
    let event: Event
    @StateObject private var viewModel = EventViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.system(size: 18, weight: .medium))
            
            HStack {
                Image(systemName: "clock")
                Text(event.date.formatted(date: .abbreviated, time: .shortened))
            }
            .font(.system(size: 16))
            .foregroundColor(.secondary)
            
            Text(event.description)
                .font(.system(size: 16))
                .lineLimit(2)
            
            Button("Registered") {
//                Task {
//                    await viewModel.toggleEventRegistration(event)
//                }
            }
            .buttonStyle(.bordered)
            .tint(.green)
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Upcoming Events Preview
struct UpcomingEventsPreview: View {
    @StateObject private var viewModel = EventViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Events")
                .font(.system(size: 20, weight: .bold))
            
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.upcomingEvents.isEmpty {
                Text("No upcoming events")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(viewModel.upcomingEvents.prefix(3)) { event in
                    EventPreviewRow(event: event)
                }
            }
            
            NavigationLink("View All Events") {
                EventsView()
            }
            .font(.system(size: 16, weight: .medium))
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
        .task {
            await viewModel.fetchUpcomingEvents()
        }
    }
}

struct EventPreviewRow: View {
    let event: Event
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 16, weight: .medium))
                
                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

class EventViewModel: ObservableObject {
    @Published private(set) var events: [Event] = []
    @Published private(set) var upcomingEvents: [Event] = []
    @Published private(set) var isLoading = false
    @Published private(set) var hasMoreEvents = false
    @Published var error: Error?
    
    private var currentPage = 1
    private let limit = 10
    private var currentQuery = EventQuery()
    
    let categories = ["educational", "social", "health", "technology", "entertainment", "other"]
    private let eventService = EventService()
    
    @MainActor
    func fetchEvents() async {
        isLoading = true
        currentPage = 1
        
        do {
            let response = try await eventService.fetchEvents(query: currentQuery)
            events = response.events
            hasMoreEvents = response.pagination.hasNextPage
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadMoreEvents() async {
        guard hasMoreEvents, !isLoading else { return }
        
        isLoading = true
        currentPage += 1
        currentQuery.page = currentPage
        
        do {
            let response = try await eventService.fetchEvents(query: currentQuery)
            events.append(contentsOf: response.events)
            hasMoreEvents = response.pagination.hasNextPage
        } catch {
            self.error = error
            currentPage -= 1
        }
        
        isLoading = false
    }
    
    @MainActor
    func searchEvents(query: String) async {
        currentQuery.search = query
        await fetchEvents()
    }
    
    @MainActor
    func applyFilters(category: String? = nil, isOnline: Bool? = nil, city: String? = nil) async {
        currentQuery.category = category
        currentQuery.isOnline = isOnline
        currentQuery.city = city
        await fetchEvents()
    }
    
    @MainActor
    func refreshEvents() async {
        currentPage = 1
        await fetchEvents()
    }
    
    @MainActor
    func fetchUpcomingEvents() async {
        isLoading = true
        
        do {
            let query = EventQuery(limit: 3)
            let response = try await eventService.fetchEvents(query: query)
            upcomingEvents = response.events
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

struct EventDetailView: View {
    let event: Event
    @StateObject private var viewModel: EventDetailViewModel
    
    init(event: Event) {
        self.event = event
        self._viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event Image or Banner
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Text(event.isOnline ? "Online Event" : "In-Person Event")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                    )
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Date
                    Text(event.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Date and Time
                    HStack {
                        Image(systemName: "calendar")
                        Text(event.date.formatted(date: .long, time: .omitted))
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                        Text("\(event.startTime) - \(event.endTime)")
                    }
                    
                    // Location
                    if !event.isOnline {
                        HStack {
                            Image(systemName: "location")
                            VStack(alignment: .leading) {
                                Text(event.location.address)
                                if let city = event.location.city {
                                    Text(city)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    // Description
                    Text("About this event")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(event.description)
                        .foregroundColor(.secondary)
                    
                    // Organizer Info
                    GroupBox {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Organized by")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(event.organizer.name)
                                    .font(.headline)
                            }
                            Spacer()
                            Button("Contact") {
                                // Handle contact action
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    // Registration Status
                    if viewModel.isRegistered {
                        Label("You're registered!", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    // Capacity
                    ProgressView(
                        value: Double(event.currentParticipants),
                        total: Double(event.quota)
                    )
                    Text("\(event.currentParticipants)/\(event.quota) spots filled")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !viewModel.isRegistered {
                Button(action: {
                    Task {
                        await viewModel.registerForEvent()
                    }
                }) {
                    Text("Register")
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(event.currentParticipants >= event.quota)
            } else {
                Button("Unregister") {
                    Task {
                        await viewModel.unregisterFromEvent()
                    }
                }
            }
        }
    }
}

// SearchBar.swift
struct SearchBar: View {
    @Binding var text: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search events...", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit(onSubmit)
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        onSubmit()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

// FilterChip.swift
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// EventDetailViewModel.swift
class EventDetailViewModel: ObservableObject {
    @Published private(set) var isRegistered = false
    @Published private(set) var isLoading = false
    @Published var error: Error?
    
    private let event: Event
    private let eventService: EventService
    
    init(event: Event) {
        self.event = event
        self.eventService = EventService()
        
        // Check registration status
        Task {
            await checkRegistrationStatus()
        }
    }
    
    @MainActor
    func checkRegistrationStatus() async {
        isLoading = true
        do {
            if let userId = UserDefaults.standard.string(forKey: "userId") {
                isRegistered = try await eventService.checkRegistrationStatus(
                    eventId: event.id,
                    userId: userId
                )
            }
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    @MainActor
    func registerForEvent() async {
        isLoading = true
        do {
            if let userId = UserDefaults.standard.string(forKey: "userId") {
                try await eventService.registerForEvent(event.id, userId: userId)
                isRegistered = true
            }
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    @MainActor
    func unregisterFromEvent() async {
        isLoading = true
        do {
            if let userId = UserDefaults.standard.string(forKey: "userId") {
                try await eventService.unregisterFromEvent(event.id, userId: userId)
                isRegistered = false
            }
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
