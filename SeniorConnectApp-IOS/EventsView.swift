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
                // Clear cache and fetch fresh data
                await viewModel.refreshEvents()
                print("✅ Refresh completed")
            }
        }
        .onAppear {
            Task { @MainActor in
                viewModel.updateAuthService(authService)
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
        self._viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event, authService: AuthService()))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title and Category
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.system(size: 18, weight: .medium))
                
                // Category Tag
                Text(event.category.rawValue.capitalized)
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(categoryColor(for: event.category).opacity(0.1))
                    .foregroundColor(categoryColor(for: event.category))
                    .cornerRadius(12)
            }
            
            // Date
            HStack {
                Image(systemName: "clock")
                Text(event.date.formatted(date: .abbreviated, time: .shortened))
            }
            .font(.system(size: 16))
            .foregroundColor(.secondary)
            
            // Description
            Text(event.description)
                .font(.system(size: 16))
                .lineLimit(2)
            
            // Tags
            if !event.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(event.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray6))
                                .foregroundColor(.secondary)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            viewModel.updateAuthService(authService)
        }
    }
    
    // Helper function for category colors
    private func categoryColor(for category: EventCategory) -> Color {
        switch category {
        case .technology:
            return .blue
        case .health:
            return .green
        case .social:
            return .orange
        case .entertainment:
            return .purple
        case .educational:
            return .red
        case .other:
            return .gray
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
    @Published private(set) var isLoading = false
    @Published private(set) var hasMoreEvents = false
    @Published var error: Error?
    
    private var currentPage = 1
    private let limit = 10
    private var currentQuery = EventQuery()
    private let eventService = EventService()
    private var authService: AuthService
    
    let categories = ["educational", "social", "health", "technology", "entertainment", "other"]
    var upcomingEvents : [Event]
    
    init(authService: AuthService) {
        self.authService = authService
        upcomingEvents = []
    }
    
    @MainActor
    func updateAuthService(_ newAuthService: AuthService) {
        self.authService = newAuthService
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
        isLoading = true
        currentPage = 1
        
        do {
            // Clear cache before fetching fresh data
            eventService.clearCache()
            
            // Create a new query to ensure fresh data
            let freshQuery = EventQuery(
                page: currentPage,
                limit: limit,
                search: currentQuery.search,
                category: currentQuery.category,
                isOnline: currentQuery.isOnline,
                city: currentQuery.city
            )
            
            let response = try await eventService.fetchEvents(query: freshQuery)
            events = response.events
            hasMoreEvents = response.pagination.hasNextPage
            print("✅ Successfully refreshed events")
        } catch {
            print("❌ Error refreshing events: \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
    }
    
    // Helper method to check if there are any events
    var hasEvents: Bool {
        !events.isEmpty
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
    @State private var hasCheckedStatus = false
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    init(event: Event) {
        self.event = event
        self._viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event, authService: AuthService()))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event Image with Overlay
                AsyncImage(url: URL(string: event.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Text(event.isOnline ? "Online Event" : "In-Person Event")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(20)
                                    Spacer()
                                }
                                .padding()
                            }
                        )
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            ProgressView()
                                .tint(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Category Tag
                    Text(event.category.rawValue.capitalized)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(categoryColor(for: event.category).opacity(0.1))
                        .foregroundColor(categoryColor(for: event.category))
                        .cornerRadius(12)
                    
                    if !event.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(event.tags, id: \.self) { tag in
                                    TagView(tag: tag)
                                }
                            }
                        }
                    }
                    
                    // Title and Date
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Date and Time
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                            Text(event.date.formatted(date: .long, time: .omitted))
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            Text("\(event.startTime) - \(event.endTime)")
                        }
                        
                        // Location
                        if !event.isOnline {
                            HStack(spacing: 12) {
                                Image(systemName: "location")
                                    .foregroundColor(.secondary)
                                VStack(alignment: .leading) {
                                    Text(event.location.address)
                                    if let city = event.location.city {
                                        Text(city)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .font(.system(size: 16))
                    
                    Divider()
                    
                    // Description
                    Text("About this event")
                        .font(.headline)
                    
                    Text(event.description)
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                    
                    Divider()
                    
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
                            Button(action: {
                                // Handle contact action
                                if let email = URL(string: "mailto:\(event.organizer.contact)") {
                                    UIApplication.shared.open(email)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "envelope")
                                    Text("Contact")
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    // Registration Status and Capacity
                    VStack(alignment: .leading, spacing: 8) {
                        if viewModel.isRegistered {
                            Label("You're registered!", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        // Capacity bar
                        VStack(alignment: .leading, spacing: 4) {
                            ProgressView(
                                value: Double(event.currentParticipants),
                                total: Double(event.quota)
                            )
                            .tint(capacityColor(current: event.currentParticipants, total: event.quota))
                            
                            HStack {
                                Text("\(event.currentParticipants)/\(event.quota) spots filled")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                if event.currentParticipants >= event.quota {
                                    Text("Fully Booked")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                } else {
                                    Text("\(event.quota - event.currentParticipants) spots left")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.updateAuthService(authService)
            viewModel.checkRegistrationStatus()
            hasCheckedStatus = true
        }
        .toolbar {
            if hasCheckedStatus {
                if !viewModel.isRegistered {
                    Button(action: {
                        Task {
                            let success = await viewModel.registerForEvent()
                            if success {
                                alertTitle = "Success"
                                alertMessage = "You have been registered for the event!"
                            } else {
                                alertTitle = "Error"
                                alertMessage = "Registration failed. Please try again."
                            }
                            showingAlert = true
                        }
                    }) {
                        Text("Register")
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(event.currentParticipants >= event.quota ? Color.gray : Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(event.currentParticipants >= event.quota)
                } else {
                    Button(action: {
                        Task {
                            let success = await viewModel.unregisterFromEvent()
                            if success {
                                alertTitle = "Success"
                                alertMessage = "You have been unregistered from the event."
                            } else {
                                alertTitle = "Error"
                                alertMessage = "Unregistration failed. Please try again."
                            }
                            showingAlert = true
                        }
                    }) {
                        Text("Unregister")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // Helper function for category colors
    private func categoryColor(for category: EventCategory) -> Color {
        switch category {
        case .technology:
            return .blue
        case .health:
            return .green
        case .social:
            return .orange
        case .entertainment:
            return .purple
        case .educational:
            return .red
        case .other:
            return .gray
        }
    }
    
    // Helper function for capacity color
    private func capacityColor(current: Int, total: Int) -> Color {
        let ratio = Double(current) / Double(total)
        if ratio >= 0.9 {
            return .red
        } else if ratio >= 0.7 {
            return .orange
        } else {
            return .green
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
@MainActor
class EventDetailViewModel: ObservableObject {
    @Published private(set) var isRegistered = false
    @Published private(set) var isLoading = false
    @Published var error: Error?
    @State private var hasCheckedStatus = false
    
    private let event: Event
    private let eventService: EventService
    var authService: AuthService
    
    init(event: Event, authService: AuthService) {
        print("🔄 EventDetailViewModel initialized for event: \(event.id)")
        self.event = event
        self.eventService = EventService()
        self.authService = authService
    }
    
    func updateAuthService(_ newAuthService: AuthService) {
        print("🔄 Updating AuthService in EventDetailViewModel")
        self.authService = newAuthService
//        checkRegistrationStatus()
    }

    
    func checkRegistrationStatus() {
        print("🔍 Checking registration status...")
        if let userId = authService.currentUser?.id {
            print("👤 Found userId from AuthService: \(userId)")
            isRegistered = event.participants.contains(userId)
            print("✅ Registration status check complete. isRegistered: \(isRegistered)")
        } else {
            print("⚠️ No userId available from AuthService")
            isRegistered = false
        }
    }
    
    func registerForEvent() async -> Bool {
        print("📝 Starting event registration process...")
        isLoading = true
        do {
            let userId = authService.currentUser?.id ?? ""
            if !userId.isEmpty {
                print("📍 Registration attempt - Event ID: \(event.id), User ID: \(userId)")
                try await eventService.registerForEvent(event.id, userId: userId)
                isRegistered = true
                print("✅ Registration successful")
                isLoading = false
                return true
            } else {
                print("⚠️ Registration failed - No userId available from AuthService")
                isLoading = false
                return false
            }
        } catch {
            print("❌ Registration error: \(error.localizedDescription)")
            self.error = error
            isRegistered = false
            isLoading = false
            return false
        }
    }
    
    func unregisterFromEvent() async -> Bool {
        print("🗑 Starting event unregistration process...")
        isLoading = true
        do {
            let userId = authService.currentUser?.id ?? ""
            if !userId.isEmpty {
                print("📍 Unregistration attempt - Event ID: \(event.id), User ID: \(userId)")
                try await eventService.unregisterFromEvent(event.id, userId: userId)
                isRegistered = false
                print("✅ Unregistration successful")
                isLoading = false
                return true
            } else {
                print("⚠️ Unregistration failed - No userId available from AuthService")
                isLoading = false
                return false
            }
        } catch {
            print("❌ Unregistration error: \(error.localizedDescription)")
            self.error = error
            isLoading = false
            return false
        }
    }
    
    
}
