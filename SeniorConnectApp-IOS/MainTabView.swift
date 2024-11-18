import Foundation
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var navigation: NavigationViewModel
    
    var body: some View {
        TabView(selection: $navigation.selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }.tag(Tab.home)
                TutorialsView()
                    .tabItem {
                        Label("Learn", systemImage: "book.fill")
                    }
                    .tag(Tab.tutorials)
                
                EventsView()
                    .tabItem {
                        Label("Events", systemImage: "calendar")
                    }
                    .tag(Tab.events)
                
                HelpView()
                    .tabItem {
                        Label("Help", systemImage: "questionmark.circle.fill")
                    }
                    .tag(Tab.help)
                
                MyProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(Tab.profile)
            }
        .font(.system(size: 20)) // Larger text for better readability
        .tint(.blue) // Consistent accent color
    }
}
