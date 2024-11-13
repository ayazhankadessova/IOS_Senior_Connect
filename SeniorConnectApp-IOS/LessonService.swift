import Foundation

class LessonService: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let baseURL = "http://localhost:3000"
    
    func fetchLessons(category: String? = nil) async throws {
        let urlString = category != nil ?
            "\(baseURL)/api/lessons?category=\(category!)" :
            "\(baseURL)/api/lessons"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let lessons = try JSONDecoder().decode([Lesson].self, from: data)
        
        await MainActor.run {
            self.lessons = lessons
            self.isLoading = false
        }
    }
    
    func updateLessonProgress(userId: String, progress: LessonProgress) async throws {
        guard let url = URL(string: "\(baseURL)/api/users/\(userId)/progress") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = try JSONEncoder().encode(progress)
        request.httpBody = body
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let updatedProgress = try JSONDecoder().decode(ProgressResponse.self, from: data)
        
        // Update local state if needed
        print("Progress updated: \(updatedProgress)")
    }
    
}
