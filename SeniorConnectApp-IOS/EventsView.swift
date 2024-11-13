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
    @Query private var events: [Event]
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
                
                List {
                    ForEach(filterEvents(for: selectedDate)) { event in
                        EventRow(event: event)
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
        }
    }
    
    private func filterEvents(for date: Date) -> [Event] {
        // Filter events for selected date
        return events
    }
}

struct EventRow: View {
    let event: Event
    
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
            
            Text(event.desc)
                .font(.system(size: 16))
                .lineLimit(2)
            
            Button("RSVP") {
                // Handle RSVP
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Upcoming Events Preview
struct UpcomingEventsPreview: View {
    @Query private var events: [Event]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Events")
                .font(.system(size: 20, weight: .bold))
            
            if events.isEmpty {
                Text("No upcoming events")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(Array(events.prefix(3))) { event in
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
