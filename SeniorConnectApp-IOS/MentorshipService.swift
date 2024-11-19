import Foundation

// First, let's define the MentorshipResponse wrapper
struct MentorshipResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
    let message: String?
}

// Then update the MentorshipRequest model
struct MentorshipRequest: Codable, Identifiable {
    let id: String?
    let user: String?
    let mentor: String?
    let topic: String
    let description: String
    let status: String
    let skillLevel: String
    let tags: [String]
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    let completedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, mentor, topic, description, status, skillLevel
        case tags, isActive, createdAt, updatedAt, completedAt
    }
}

// To handle both array and single object responses
//enum MentorshipDataType: Codable {
//    case single(MentorshipRequest)
//    case array([MentorshipRequest])
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if let array = try? container.decode([MentorshipRequest].self) {
//            self = .array(array)
//        } else if let object = try? container.decode(MentorshipRequest].self) {
//            self = .single(object)
//        } else {
//            throw DecodingError.typeMismatch(MentorshipDataType.self, DecodingError.Context(
//                codingPath: decoder.codingPath,
//                debugDescription: "Expected [MentorshipRequest] or MentorshipRequest"
//            ))
//        }
//    }
//}

class MentorshipService {
    private let baseURL = "http://localhost:3000/api/mentorship"
    
    func createMentorshipRequest(
        topic: String,
        description: String,
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
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(MentorshipResponse<MentorshipRequest>.self, from: data)
                completion(.success(response.data))
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
                let response = try decoder.decode(MentorshipResponse<[MentorshipRequest]>.self, from: data)
                completion(.success(response.data))
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
                let response = try decoder.decode(MentorshipResponse<MentorshipRequest>.self, from: data)
                completion(.success(response.data))
            } catch {
                print("getSingleMentorshipRequest error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
