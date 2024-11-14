import Foundation

class LessonService: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var lessonsProgress: [String: LessonProgress] = [:]
    @Published var overallProgress: OverallProgress?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let baseURL = "http://localhost:3000"
    
    func fetchLessons(category: String, userId: String) async throws {
        isLoading = true
        
        do {
            // Fetch lessons
            let lessons = try await fetchLessonsFromAPI(category: category)
            
            // Fetch progress
            let progressResponse = try await fetchUserProgress(userId: userId, category: category)
            
            await MainActor.run {
                self.lessons = lessons
                
                // Create a dictionary for quick lookup
                self.lessonsProgress = Dictionary(
                    uniqueKeysWithValues: progressResponse.categoryProgress.map {
                        ($0.lessonId, $0)
                    }
                )
                
                self.overallProgress = progressResponse.overallProgress
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            throw error
        }
    }
    
    private func fetchLessonsFromAPI(category: String) async throws -> [Lesson] {
        let urlString = "\(baseURL)/api/lessons?category=\(category)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder.progressDecoder.decode([Lesson].self, from: data)
    }
    
    private func fetchUserProgress(userId: String, category: String) async throws -> CategoryProgressResponse {
        let urlString = "\(baseURL)/api/users/\(userId)/progress/\(category)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        debugPrint("Progress Response: \(userId)", String(data: data, encoding: .utf8) ?? "")
        return try JSONDecoder.progressDecoder.decode(CategoryProgressResponse.self, from: data)
    }
}
