import Foundation

struct MentorshipRequest: Codable {
    let id: String?
    let user: String?
    let topic: String
    let status: String
    let messages: [MentorshipMessage]
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, user, topic, status, messages, createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.user = try container.decodeIfPresent(String.self, forKey: .user)
        self.topic = try container.decode(String.self, forKey: .topic)
        self.status = try container.decode(String.self, forKey: .status)
        self.messages = try container.decode([MentorshipMessage].self, forKey: .messages)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

struct MentorshipMessage: Codable {
    let sender: String
    let content: String
    let timestamp: String
}

class MentorshipService {
    private let baseURL = "http://localhost:3000/api/mentorship"
    
    func createMentorshipRequest(topic: String, userId: String, completion: @escaping (Result<MentorshipRequest, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/requests") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["topic": topic, "userId": userId]
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
                let mentorshipRequest = try decoder.decode(MentorshipRequest.self, from: data)
                print("createMentorshipRequest response: \(mentorshipRequest)")
                completion(.success(mentorshipRequest))
            } catch {
                print("createMentorshipRequest error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getUserMentorshipRequests(userId: String, completion: @escaping (Result<[MentorshipRequest], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/requests") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let queryItems = [URLQueryItem(name: "userId", value: userId)]
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        request.url = components?.url
        
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
                let requests = try decoder.decode([MentorshipRequest].self, from: data)
                completion(.success(requests))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func sendMessage(requestId: String, content: String, userId: String, completion: @escaping (Result<MentorshipRequest, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/requests/\(requestId)/messages") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["content": content, "userId": userId]
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
                let mentorshipRequest = try decoder.decode(MentorshipRequest.self, from: data)
                completion(.success(mentorshipRequest))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
