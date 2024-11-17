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
    @StateObject private var viewModel: EventViewModel
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var selectedCity: String?
    @State private var isOnlineOnly = false
    @EnvironmentObject var authService: AuthService
    
    private var hasActiveFilters: Bool {
        isOnlineOnly || selectedCategory != nil || selectedCity != nil
    }
    
    init() {
        self._viewModel = StateObject(wrappedValue: EventViewModel(authService: AuthService()))
    }
    
    private func clearAllFilters() {
        isOnlineOnly = false
        selectedCategory = nil
        selectedCity = nil
        Task {
            await viewModel.applyFilters(category: nil, isOnline: false, city: nil)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Search and Clear Filters Row
                HStack {
                    SearchBar(text: $searchText, onSubmit: {
                        Task {
                            await viewModel.searchEvents(query: searchText)
                        }
                    })
                    
                    if hasActiveFilters {
                        Button(action: clearAllFilters) {
                            Text("Clear")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing, 16)
                    }
                }
                
                // Filters Row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "Online Only",
                            isSelected: isOnlineOnly,
                            action: { isOnlineOnly.toggle() }
                        )
                        
                        ForEach(viewModel.categories, id: \.self) { category in
                            FilterChip(
                                title: category,
                                isSelected: selectedCategory == category,
                                action: {
                                    if selectedCategory == category {
                                        selectedCategory = nil
                                    } else {
                                        selectedCategory = category
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Events List
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.events.isEmpty {
                    ContentUnavailableView {
                        Label("No Events", systemImage: "calendar.badge.exclamationmark")
                    } description: {
                        Text("There are no events matching your criteria.")
                    }
                } else {
                    List {
                        ForEach(viewModel.events) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                EventRow(event: event)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        
                        if viewModel.hasMoreEvents {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                                .onAppear {
                                    Task {
                                        await viewModel.loadMoreEvents()
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Events")
            .onChange(of: isOnlineOnly) { oldValue, newValue in
                Task {
                    await viewModel.applyFilters(category: selectedCategory, isOnline: newValue)
                }
            }
            .onChange(of: selectedCategory) { oldValue, newValue in
                Task {
                    await viewModel.applyFilters(category: newValue, isOnline: isOnlineOnly)
                }
            }
            .refreshable {
                await viewModel.refreshEvents()
            }
        }
        .onAppear {
            viewModel.updateAuthService(authService)
            Task {
                await viewModel.fetchEvents()
            }
        }
    }
}

struct EventRow: View {
    let event: Event
    @StateObject private var viewModel: EventDetailViewModel
    @EnvironmentObject var authService: AuthService
    
    init(event: Event) {
            self.event = event
            // Initialize with empty AuthService, will be updated in onAppear
            self._viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event, authService: AuthService()))
        }
    
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
                
                Button(viewModel.isRegistered ? "Registered" : "Register") {
                    Task {
                        if viewModel.isRegistered {
                            await viewModel.unregisterFromEvent()
                        } else {
                            await viewModel.registerForEvent()
                        }
                    }
                }
                .buttonStyle(.bordered)
                .tint(viewModel.isRegistered ? .green : .blue)
                .padding(.top, 4)
            }
            .padding(.vertical, 8)
            .onAppear {
                viewModel.updateAuthService(authService) // Update the AuthService
                Task {
                    await viewModel.checkRegistrationStatus()
                }
            }
        }
}

// MARK: - Upcoming Events Preview
struct UpcomingEventsPreview: View {
    @StateObject private var viewModel: EventViewModel
    @EnvironmentObject var authService: AuthService
    
    // Add initializer
    init() {
        self._viewModel = StateObject(wrappedValue: EventViewModel(authService: AuthService()))
    }
    
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
        .onAppear {
            viewModel.updateAuthService(authService)
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
    private let eventService = EventService()
    private var authService: AuthService
    
    let categories = ["educational", "social", "health", "technology", "entertainment", "other"]
    
    init(authService: AuthService) {
        self.authService = authService
        Task {
            await fetchEvents()
        }
    }
    
    func updateAuthService(_ newAuthService: AuthService) {
        print("🔄 Updating AuthService in EventViewModel")
        self.authService = newAuthService
        Task {
            await fetchEvents()
        }
    }
    
    @MainActor
    func fetchEvents() async {
        print("📥 Fetching events...")
        isLoading = true
        currentPage = 1
        
        do {
            let response = try await eventService.fetchEvents(query: currentQuery)
            events = response.events
            hasMoreEvents = response.pagination.hasNextPage
            print("✅ Successfully fetched \(events.count) events")
        } catch {
            print("❌ Error fetching events: \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadMoreEvents() async {
        guard hasMoreEvents, !isLoading else {
            print("⚠️ Skip loading more: hasMoreEvents=\(hasMoreEvents), isLoading=\(isLoading)")
            return
        }
        
        print("📥 Loading more events...")
        isLoading = true
        currentPage += 1
        currentQuery.page = currentPage
        
        do {
            let response = try await eventService.fetchEvents(query: currentQuery)
            events.append(contentsOf: response.events)
            hasMoreEvents = response.pagination.hasNextPage
            print("✅ Successfully loaded \(response.events.count) more events")
        } catch {
            print("❌ Error loading more events: \(error.localizedDescription)")
            self.error = error
            currentPage -= 1
        }
        
        isLoading = false
    }
    
    @MainActor
    func searchEvents(query: String) async {
        print("🔍 Searching events with query: \(query)")
        currentQuery.search = query
        await fetchEvents()
    }
    
    @MainActor
    func applyFilters(category: String? = nil, isOnline: Bool? = nil, city: String? = nil) async {
        print("🔧 Applying filters - category: \(category ?? "nil"), isOnline: \(String(describing: isOnline)), city: \(city ?? "nil")")
        currentQuery.category = category
        currentQuery.isOnline = isOnline
        currentQuery.city = city
        await fetchEvents()
    }
    
    @MainActor
    func refreshEvents() async {
        print("🔄 Refreshing events...")
        currentPage = 1
        await fetchEvents()
    }
    
    @MainActor
    func fetchUpcomingEvents() async {
        print("📅 Fetching upcoming events...")
        isLoading = true
        
        do {
            let query = EventQuery(limit: 3)
            let response = try await eventService.fetchEvents(query: query)
            upcomingEvents = response.events
            print("✅ Successfully fetched \(upcomingEvents.count) upcoming events")
        } catch {
            print("❌ Error fetching upcoming events: \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
    }
    
    // Helper method to check if there are any events
    var hasEvents: Bool {
        !events.isEmpty
    }
    
    // Helper method to check if there are any upcoming events
    var hasUpcomingEvents: Bool {
        !upcomingEvents.isEmpty
    }
    
    // Helper method to get events count
    var eventsCount: Int {
        events.count
    }
    
    // Helper method to get the current page number
    var currentPageNumber: Int {
        currentPage
    }
    
    // Helper method to check if we're on the first page
    var isFirstPage: Bool {
        currentPage == 1
    }
}

struct EventDetailView: View {
    let event: Event
    @StateObject private var viewModel: EventDetailViewModel
    @EnvironmentObject var authService: AuthService
    
    init(event: Event) {
        self.event = event
        self._viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event, authService: AuthService()))
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
        .onAppear {
                    // Update the viewModel's authService with the environment's authService
                    if let viewModelAuthService = viewModel.authService as? AuthService {
                        viewModelAuthService.currentUser = authService.currentUser
                    }
                }
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
        HStack(spacing: 8) {
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
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}

// FilterChip.swift
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title.capitalized)
                    .font(.system(size: 14, weight: .medium))
                
                if isSelected {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .gray)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
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
    var authService: AuthService
    
    init(event: Event, authService: AuthService) {
        print("🔄 EventDetailViewModel initialized for event: \(event.id)")
        self.event = event
        self.eventService = EventService()
        self.authService = authService
        
        // Check registration status
        Task {
            await checkRegistrationStatus()
        }
    }
    
    // Add method to update AuthService
    func updateAuthService(_ newAuthService: AuthService) {
        print("🔄 Updating AuthService in EventDetailViewModel")
        self.authService = newAuthService
        // Recheck registration status with new auth service
        Task {
            await checkRegistrationStatus()
        }
    }
    
    @MainActor
    func checkRegistrationStatus() async {
        print("🔍 Checking registration status...")
        isLoading = true
        do {
            let userId = authService.currentUser?.id ?? ""
            if !userId.isEmpty {
                print("👤 Found userId from AuthService: \(userId)")
                isRegistered = try await eventService.checkRegistrationStatus(
                    eventId: event.id,
                    userId: userId
                )
                print("✅ Registration status check complete. isRegistered: \(isRegistered)")
            } else {
                print("⚠️ No userId available from AuthService")
                isRegistered = false
            }
        } catch {
            print("❌ Error checking registration status: \(error.localizedDescription)")
            self.error = error
            isRegistered = false
        }
        isLoading = false
    }
    
    @MainActor
    func registerForEvent() async {
        print("📝 Starting event registration process...")
        isLoading = true
        do {
            let userId = authService.currentUser?.id ?? ""
            if !userId.isEmpty {
                print("📍 Registration attempt - Event ID: \(event.id), User ID: \(userId)")
                try await eventService.registerForEvent(event.id, userId: userId)
                isRegistered = true
                print("✅ Registration successful")
            } else {
                print("⚠️ Registration failed - No userId available from AuthService")
//                error = NetworkError.invalidRequest
                return
            }
        } catch {
            print("❌ Registration error: \(error.localizedDescription)")
            self.error = error
            isRegistered = false
        }
        isLoading = false
        print("🔄 Registration process completed. isRegistered: \(isRegistered)")
    }
    
    @MainActor
    func unregisterFromEvent() async {
        print("🗑 Starting event unregistration process...")
        isLoading = true
        do {
            let userId = authService.currentUser?.id ?? ""
            if !userId.isEmpty {
                print("📍 Unregistration attempt - Event ID: \(event.id), User ID: \(userId)")
                try await eventService.unregisterFromEvent(event.id, userId: userId)
                isRegistered = false
                print("✅ Unregistration successful")
            } else {
                print("⚠️ Unregistration failed - No userId available from AuthService")
//                error = NetworkError.invalidRequest
                return
            }
        } catch {
            print("❌ Unregistration error: \(error.localizedDescription)")
            self.error = error
        }
        isLoading = false
        print("🔄 Unregistration process completed. isRegistered: \(isRegistered)")
    }
    
    // Helper method to get current registration status
    var registrationStatus: Bool {
        isRegistered
    }
    
    // Helper method to check if the event is full
    var isEventFull: Bool {
        event.currentParticipants >= event.quota
    }
    
    // Helper method to format remaining spots
    var remainingSpots: String {
        let remaining = event.quota - event.currentParticipants
        return "\(remaining) spot\(remaining == 1 ? "" : "s") remaining"
    }
}
