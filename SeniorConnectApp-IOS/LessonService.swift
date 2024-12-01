import Foundation

class LessonService: ObservableObject {
    @Published private(set) var lessons: [Lesson] = []
    @Published private(set) var lessonsProgress: [String: CategoryLessonProgress] = [:]
    @Published private(set) var overallProgress: OverallProgress?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let baseURL = "http://localhost:3000"
    
    private func convertDisplayNameToApiName(_ displayName: String) -> String {
        switch displayName {
        case "Smartphone Basics":
            return "smartphoneBasics"
        case "Digital Literacy":
            return "digitalLiteracy"
        case "Social Media":
            return "socialMedia"
        case "Smart Home":
            return "iot"
        default:
            return displayName.replacingOccurrences(of: " ", with: "")
        }
    }
    
    @MainActor
    func fetchLessons(category: String, userId: String) async throws {
        isLoading = true
        error = nil
                
        do {
            let apiCategoryName = convertDisplayNameToApiName(category)
            print("Fetching progress for category: \(apiCategoryName)")
            
            async let progressResponseFuture = fetchUserProgress(userId: userId, category: apiCategoryName)
            async let lessonsFuture = fetchLessonsFromAPI(category: apiCategoryName)
            
            let (progressResponse, lessons) = try await (progressResponseFuture, lessonsFuture)
            
            // Update all state together
            let newProgress = Dictionary(
                uniqueKeysWithValues: progressResponse.categoryProgress.map {
                    ($0.lessonId, $0)
                }
            )
            
            // Print debug info
            print("Current lessonsProgress count: \(self.lessonsProgress.count)")
            print("New progress count: \(newProgress.count)")
            
            // Update state
            self.lessons = lessons
            self.lessonsProgress = newProgress
            self.overallProgress = progressResponse.overallProgress
            
            // Print updated progress for each lesson
            print("Updated Lesson Progress:")
            for (lessonId, progress) in self.lessonsProgress {
                print("\(lessonId): completed=\(progress.completed), steps=\(progress.completedSteps.count)")
            }
            
        } catch {
            self.error = error
            throw error
        }
        
        self.isLoading = false
    }
        
    private func fetchLessonsFromAPI(category: String) async throws -> [Lesson] {
        let urlString = "\(baseURL)/api/lessons?category=\(category)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder.authDecoder.decode([Lesson].self, from: data)
    }
    
    func fetchTotalLessonsCompleted(userId: String) async throws -> Int {
            let urlString = "\(baseURL)/api/users/\(userId)/progress/total-completed"
            guard let url = URL(string: urlString) else {
                throw NetworkError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
            
            struct TotalProgressResponse: Codable {
                var totalLessonsCompleted: Int
            }
            
            let result = try JSONDecoder().decode(TotalProgressResponse.self, from: data)
            return result.totalLessonsCompleted
        }
    
    private func fetchUserProgress(userId: String, category: String) async throws -> CategoryProgressResponse {
            let urlString = "\(baseURL)/api/users/\(userId)/progress/\(category)"
            guard let url = URL(string: urlString) else {
                throw NetworkError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder.authDecoder.decode(CategoryProgressResponse.self, from: data)
        }
}
