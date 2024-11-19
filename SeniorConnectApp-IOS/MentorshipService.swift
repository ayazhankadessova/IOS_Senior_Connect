import Foundation

// First, let's define the MentorshipResponse wrapper
struct MentorshipResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
    let message: String?
}

// Then update the MentorshipRequest model
// Success response with data
struct CreateMentorshipResponse: Codable {
    let success: Bool
    let data: MentorshipRequest?
    let message: String
}

// Error response without data
struct ErrorResponse: Codable {
    let success: Bool
    let message: String
}

struct MentorshipRequest: Codable, Identifiable {
    let id: String?
    let user: String?
    let mentor: String?
    let topic: String
    let description: String
    let phoneNumber: String
    let status: String
    let skillLevel: String
    let tags: [String]
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, mentor, topic, description, phoneNumber
        case status, skillLevel, tags, isActive, createdAt, updatedAt
    }
}

struct GetMentorshipListResponse: Codable {
    let success: Bool
    let data: [MentorshipRequest]
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
}
