//
//  TutorialViewModel.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 13/11/2024.
//

import Foundation
import SwiftUI

class TutorialViewModel: ObservableObject {
    
    @Published var selectedLesson: Lesson?
    @Published var currentStep: Int = 0
    @Published var lessons: [Lesson] = []
    @Published var isLoading = false
    private let lessonService = LessonService()
    
    private var userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func updateUserId(_ newId: String) {
        userId = newId
    }

    func fetchLessons(category: String? = nil) async {
        isLoading = true
        do {
            try await lessonService.fetchLessons(category: category)
            isLoading = false
        } catch {
            print("Error fetching lessons: \(error)")
            isLoading = false
        }
    }
    
    func updateLessonProgress(_ lesson: Lesson, stepId: String? = nil, actionItemId: String? = nil) async {
        let progress = LessonProgress(
            category: "smartphoneBasics",  // Or pass this as parameter
            lessonId: lesson.id,
            stepId: stepId,
            actionItemId: actionItemId,
            savedForLater: nil,
            needsMentorHelp: nil,
            mentorNotes: nil
        )
        
        do {
            try await lessonService.updateLessonProgress(userId: userId, progress: progress)
        } catch {
            print("Error updating progress: \(error)")
        }
    }
    
    func saveForLater(_ lesson: Lesson) async {
        let progress = LessonProgress(
            category: "smartphoneBasics",
            lessonId: lesson.id,
            stepId: nil,
            actionItemId: nil,
            savedForLater: true,
            needsMentorHelp: false,
            mentorNotes: nil
        )
        
        do {
            try await lessonService.updateLessonProgress(userId: userId, progress: progress)
        } catch {
            print("Error saving for later: \(error)")
        }
    }
    
    func requestMentorHelp(for lesson: Lesson, notes: String? = nil) async {
        let progress = LessonProgress(
            category: "smartphoneBasics",
            lessonId: lesson.id,
            stepId: nil,
            actionItemId: nil,
            savedForLater: false,
            needsMentorHelp: true,
            mentorNotes: notes
        )
        
        do {
            try await lessonService.updateLessonProgress(userId: userId, progress: progress)
        } catch {
            print("Error requesting mentor help: \(error)")
        }
    }
}
