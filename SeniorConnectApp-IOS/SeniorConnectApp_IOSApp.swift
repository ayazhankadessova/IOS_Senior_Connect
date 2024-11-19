//
//  SeniorConnectApp_IOSApp.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import SwiftUI

@main
struct SeniorConnectApp_IOSApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var navigation = NavigationViewModel()

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService).environmentObject(navigation)
            } else {
                LoginView()
                    .environmentObject(authService).environmentObject(navigation)
            }
        }
    }
}
