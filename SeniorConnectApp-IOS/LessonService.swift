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
        
//        if category == "Smartphone Basics" -> change to smartphoneBasics 
        
        do {
            
            let apiCategoryName = convertDisplayNameToApiName(category)
            print("Fetching progress for category: \(apiCategoryName)")
            
            let progressResponse = try await fetchUserProgress(userId: userId, category: apiCategoryName)
            let lessons = try await fetchLessonsFromAPI(category: apiCategoryName)
            
            // Update all state together
            self.lessons = lessons
            self.lessonsProgress = Dictionary(
                uniqueKeysWithValues: progressResponse.categoryProgress.map {
                    ($0.lessonId, $0)
                }
            )
            self.overallProgress = progressResponse.overallProgress
            
            print("Updated lessonsProgress: \(self.lessonsProgress)")
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
    
    private func fetchUserProgress(userId: String, category: String) async throws -> CategoryProgressResponse {
            let urlString = "\(baseURL)/api/users/\(userId)/progress/\(category)"
            guard let url = URL(string: urlString) else {
                throw NetworkError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder.authDecoder.decode(CategoryProgressResponse.self, from: data)
        }
}
