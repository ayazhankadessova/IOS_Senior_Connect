import Foundation
import SwiftUI

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
            }
            
            TextField(placeholder, text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .keyboardType(keyboardType)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2))
                )
        }
    }
}

extension MentorshipRequest {
    var formattedDate: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = dateFormatter.date(from: createdAt) else {
            return nil
        }
        
        // Create relative date formatting
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .short
        
        // If date is within last 24 hours, show relative time
        if Date().timeIntervalSince(date) < 86400 {
            return relativeFormatter.localizedString(for: date, relativeTo: Date())
        }
        
        // For older dates, show the date in a more readable format
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

class MentorshipService {
    private let baseURL = "http://localhost:3000/api/mentorship"
    
    func createMentorshipRequest(
            topic: String,
            description: String,
            phoneNumber: String,
            skillLevel: String,
            userId: String,
            completion: @escaping (Result<MentorshipRequest, Error>) -> Void
        ) {
            guard let url = URL(string: "\(baseURL)/requests/\(userId)") else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "topic": topic,
                "description": description,
                "phoneNumber": phoneNumber,
                "skillLevel": skillLevel
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(jsonString)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    
                    // First try to decode as error response
                    if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                        if !errorResponse.success {
                            completion(.failure(NSError(domain: "API Error", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])))
                            return
                        }
                    }
                    
                    // If not an error, decode as success response
                    let response = try decoder.decode(CreateMentorshipResponse.self, from: data)
                    if let mentorshipRequest = response.data {
                        completion(.success(mentorshipRequest))
                    } else {
                        completion(.failure(NSError(domain: "API Error", code: 400, userInfo: [NSLocalizedDescriptionKey: response.message])))
                    }
                } catch {
                    print("createMentorshipRequest error: \(error)")
                    completion(.failure(error))
                }
            }.resume()
        }
    func getUserMentorshipRequests(userId: String, completion: @escaping (Result<[MentorshipRequest], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/requests/\(userId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(GetMentorshipListResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response.data))
                }
            } catch {
                print("getUserMentorshipRequests error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getSingleMentorshipRequest(userId: String, requestId: String, completion: @escaping (Result<MentorshipRequest, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/requests/\(userId)/mentorship/\(requestId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CreateMentorshipResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response.data!))
                }
            } catch {
                print("getSingleMentorshipRequest error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func deleteMentorshipRequest(userId: String, requestId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/requests/\(userId)/mentorship/\(requestId)") else {
            print("❌ Delete Request Error: Invalid URL construction")
            print("BaseURL: \(baseURL)")
            print("UserID: \(userId)")
            print("RequestID: \(requestId)")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        print("🔵 Attempting to delete request")
        print("URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Add logging for request headers if any
        request.allHTTPHeaderFields?.forEach { key, value in
            print("Header - \(key): \(value)")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response Status Code: \(httpResponse.statusCode)")
                
                // Log response headers
                print("📡 Response Headers:")
                httpResponse.allHeaderFields.forEach { key, value in
                    print("\(key): \(value)")
                }
                
                // Log response body if exists
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📡 Response Body: \(responseString)")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Invalid Response Status Code: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.invalidResponse))
                    }
                    return
                }
            }
            
            print("✅ Delete request successful")
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }.resume()
    }
}
