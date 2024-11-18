import Foundation
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: AuthService
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            TutorialsView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
            
            EventsView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
            
            MyProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
//            MentorshipView()
//                .tabItem {
//                    Label("Mentors", systemImage: "person.2.fill")
//                }
//
//            IoTControlView()
//                .tabItem {
//                    Label("Smart Home", systemImage: "homekit")
//                }
        }
        .font(.system(size: 20)) // Larger text for better readability
        .tint(.blue) // Consistent accent color
    }
}
