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
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Custom Calendar View
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(viewModel.filterEvents(for: selectedDate)) { event in
                            EventRow(event: event)
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .toolbar {
                Button("Add Event") {
                    // Show add event sheet
                }
                .font(.system(size: 18))
            }
            .task {
                await viewModel.fetchEvents()
            }
            .refreshable {
                await viewModel.fetchEvents()
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
                Task {
                    await viewModel.toggleEventRegistration(event)
                }
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
    @Published var error: Error?
    
    private let eventService = EventService()
    
    @MainActor
    func fetchEvents() async {
        isLoading = true
        
        do {
            events = try await eventService.fetchEvents()
            print(events)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    @MainActor
    func fetchUpcomingEvents() async {
        isLoading = true
        
        do {
            upcomingEvents = try await eventService.fetchUpcomingEvents()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func filterEvents(for date: Date) -> [Event] {
        // Implement date filtering logic
        print(events)
        return events
//        return events.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func toggleEventRegistration(_ event: Event) async {
        do {
            if true {
                try await eventService.unregisterFromEvent(event.id)
            } else {
                try await eventService.registerForEvent(event.id)
            }
            await fetchEvents() // Refresh events list
        } catch {
            self.error = error
        }
    }
}
