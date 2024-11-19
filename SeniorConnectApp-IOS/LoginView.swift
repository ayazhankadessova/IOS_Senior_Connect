//
//  LoginView.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation
//
//  LoginView.swift
//  SeniorConnectApp
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showingSignup = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Logo or App Title
                Text("Senior Connect")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 50)
                
                Text("Welcome Back!")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
//                        .autocapitalization(.none)
//                        .font(.system(size: 20))
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.password)
                        .font(.system(size: 20))
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                
                Button {
                    Task {
                        await login()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Login")
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal, 32)
                .disabled(isLoading)
                
                Button {
                    showingSignup = true
                } label: {
                    Text("Don't have an account? Sign Up")
                        .font(.system(size: 18))
                }
                .padding(.top)
                
                Spacer()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingSignup) {
                SignupView().environmentObject(authService)
            }
        }
    }
    
    private func login() async {
        isLoading = true
        do {
            let _ = try await authService.login(email: email, password: password)
            // Login was successful, authentication state will update automatically
        } catch AuthError.invalidCredentials {
            errorMessage = "Invalid email or password"
            showError = true
        } catch {
            errorMessage = "An error occurred. Please try again."
            showError = true
            print("Login error: \(error)")  // Add error logging
        }
        isLoading = false
    }
}

struct SignupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    @AppStorage("hasCompletedInitialTutorial") private var hasCompletedInitialTutorial = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.title)
                    .padding(.top, 50)
                
                VStack(spacing: 15) {
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.name)
                        .font(.system(size: 20))
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
//                        .autocapitalization(.none)
//                        .font(.system(size: 20))
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.newPassword)
                        .font(.system(size: 20))
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                
                Button {
                    Task {
                        await signup()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign Up")
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal, 32)
                .disabled(isLoading)
                
                Spacer()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem() {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func signup() async {
        isLoading = true
        do {
            let credentials = SignupCredentials(name: name, email: email, password: password)
            let _ = try await authService.signup(credentials: credentials)
            // Reset the tutorial flag for new users
            hasCompletedInitialTutorial = false
            dismiss()
        } catch AuthError.invalidCredentials {
            errorMessage = "Invalid information provided"
            showError = true
        } catch {
            errorMessage = "An error occurred. Please try again."
            showError = true
            print("Signup error: \(error)")
        }
        isLoading = false
    }
}

//// Add this to your main app file
//@main
//struct SeniorConnectApp: App {
//    @StateObject private var authService = AuthService()
//    
//    var body: some Scene {
//        WindowGroup {
//            if authService.isAuthenticated {
//                MainTabView()
//                    .environmentObject(authService)
//            } else {
//                LoginView()
//                    .environmentObject(authService)
//            }
//        }
//    }
//}
