//
//  Quiz.swift
//  SeniorConnectApp-IOS
//
//  Created by Аяжан on 20/11/2024.
//

import Foundation
import SwiftUI

// Quiz models (if not already defined)
struct QuizQuestion: Codable, Identifiable {
    let id: String
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case question, options, correctAnswer, explanation
    }
}

struct QuizView: View {
    let questions: [QuizQuestion]
    let onComplete: (Int) -> Void
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int?] = []
    @State private var showExplanation = false
    @State private var score = 0
    @State private var isCompleted = false
    
    var body: some View {
        VStack(spacing: 20) {
            if isCompleted {
                QuizResultView(
                    score: score,
                    totalQuestions: questions.count,
                    onRetake: resetQuiz
                )
            } else {
                if !questions.isEmpty && currentQuestionIndex < questions.count {
                    VStack(alignment: .leading, spacing: 20) {
                        // Progress indicator
                        ProgressView(
                            value: Double(currentQuestionIndex + 1),
                            total: Double(questions.count)
                        )
                        .tint(.blue)
                        
                        Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Question
                        Text(questions[currentQuestionIndex].question)
                            .font(.headline)
                            .padding(.vertical)
                        
                        // Options
                        VStack(spacing: 12) {
                            ForEach(Array(questions[currentQuestionIndex].options.enumerated()), id: \.offset) { index, option in
                                AnswerButton(
                                    text: option,
                                    isSelected: selectedAnswers.indices.contains(currentQuestionIndex) && selectedAnswers[currentQuestionIndex] == index,
                                    isCorrect: showExplanation ? (index == questions[currentQuestionIndex].correctAnswer) : nil,
                                    action: {
                                        if !showExplanation {
                                            ensureArrayCapacity()
                                            selectedAnswers[currentQuestionIndex] = index
                                        }
                                    }
                                )
                            }
                        }
                        
                        // Explanation
                        if showExplanation {
                            ExplanationView(explanation: questions[currentQuestionIndex].explanation)
                        }
                        
                        Spacer()
                        
                        // Navigation buttons
                        HStack {
                            if currentQuestionIndex > 0 {
                                Button(action: previousQuestion) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Previous")
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                            
                            if !showExplanation {
                                Button(action: checkAnswer) {
                                    Text("Check Answer")
                                        .bold()
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedAnswers.indices.contains(currentQuestionIndex) &&
                                            selectedAnswers[currentQuestionIndex] != nil ? Color.blue : Color.gray
                                        )
                                        .cornerRadius(8)
                                }
                                .disabled(!selectedAnswers.indices.contains(currentQuestionIndex) ||
                                         selectedAnswers[currentQuestionIndex] == nil)
                            } else if currentQuestionIndex < questions.count - 1 {
                                Button(action: nextQuestion) {
                                    HStack {
                                        Text("Next")
                                        Image(systemName: "chevron.right")
                                    }
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                }
                            } else {
                                Button(action: completeQuiz) {
                                    Text("Complete Quiz")
                                        .bold()
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.green)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                } else {
                    Text("No questions available")
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            initializeQuiz()
        }
    }
    
    private func initializeQuiz() {
        selectedAnswers = Array(repeating: nil, count: questions.count)
        currentQuestionIndex = 0
        score = 0
        showExplanation = false
        isCompleted = false
    }
    
    private func ensureArrayCapacity() {
        if currentQuestionIndex >= selectedAnswers.count {
            selectedAnswers.append(contentsOf: Array(repeating: nil, count: currentQuestionIndex - selectedAnswers.count + 1))
        }
    }
    
    private func checkAnswer() {
        guard currentQuestionIndex < questions.count,
              let selectedAnswer = selectedAnswers[currentQuestionIndex] else { return }
        
        showExplanation = true
        if selectedAnswer == questions[currentQuestionIndex].correctAnswer {
            score += 1
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            showExplanation = false
        }
    }
    
    private func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            showExplanation = false
        }
    }
    
    private func completeQuiz() {
        isCompleted = true
        onComplete(score)
    }
    
    private func resetQuiz() {
        initializeQuiz()
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void
    
    var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green.opacity(0.2) : .red.opacity(0.2)
        }
        return isSelected ? .blue.opacity(0.2) : Color(.systemGray6)
    }
    
    var borderColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : .red
        }
        return isSelected ? .blue : .clear
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if let isCorrect = isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "x.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExplanationView: View {
    let explanation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Explanation")
                .font(.headline)
            
            Text(explanation)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct QuizResultView: View {
    let score: Int
    let totalQuestions: Int
    let onRetake: () -> Void
    
    var percentage: Double {
        Double(score) / Double(totalQuestions) * 100
    }
    
    var resultColor: Color {
        if percentage >= 80 {
            return .green
        } else if percentage >= 60 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Quiz Complete!")
                .font(.title)
                .bold()
            
            VStack {
                Text("\(score)/\(totalQuestions)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(resultColor)
                
                Text("\(Int(percentage))%")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Text(resultMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: onRetake) {
                Text("Retake Quiz")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var resultMessage: String {
        if percentage >= 80 {
            return "Excellent! You've mastered this lesson!"
        } else if percentage >= 60 {
            return "Good job! Keep practicing to improve!"
        } else {
            return "Keep learning! Try reviewing the lesson again."
        }
    }
}
