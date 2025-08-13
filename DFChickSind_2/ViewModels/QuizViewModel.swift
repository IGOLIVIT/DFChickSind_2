//
//  QuizViewModel.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import Foundation
import Combine
import SwiftUI

class QuizViewModel: ObservableObject {
    @Published var availableQuizzes: [Quiz] = []
    @Published var currentQuiz: Quiz?
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswers: [String: String] = [:]
    @Published var isQuizActive: Bool = false
    @Published var quizResult: QuizResult?
    @Published var timeRemaining: Int = 0
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var selectedCategory: Quiz.QuizCategory?
    @Published var selectedDifficulty: Language.LanguageDifficulty?
    @Published var showCompleted: Bool = true
    
    private let languageDataService = LanguageDataService.shared
    private let notificationService = NotificationService.shared
    private var userProgress: UserProgress
    private var quizTimer: Timer?
    private var startTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.userProgress = Self.loadUserProgress()
        setupBindings()
        loadQuizzes()
    }
    
    deinit {
        quizTimer?.invalidate()
    }
    
    private static func loadUserProgress() -> UserProgress {
        guard let data = UserDefaults.standard.data(forKey: "user_progress"),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return UserProgress.sampleProgress
        }
        return progress
    }
    
    private func setupBindings() {
        // Watch for search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterQuizzes()
            }
            .store(in: &cancellables)
        
        // Watch for filter changes
        Publishers.CombineLatest3($selectedCategory, $selectedDifficulty, $showCompleted)
            .sink { [weak self] _, _, _ in
                self?.filterQuizzes()
            }
            .store(in: &cancellables)
        
        // Watch for language data service updates
        languageDataService.$quizzes
            .sink { [weak self] quizzes in
                self?.updateQuizzes(quizzes)
            }
            .store(in: &cancellables)
    }
    
    private func loadUserProgress() -> UserProgress {
        guard let data = UserDefaults.standard.data(forKey: "user_progress"),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return UserProgress.sampleProgress
        }
        return progress
    }
    
    private func loadQuizzes() {
        isLoading = true
        
        // Get recommended quizzes based on user's selected languages
        let allQuizzes = languageDataService.getRecommendedQuizzes(for: userProgress)
        updateQuizzes(allQuizzes)
        
        isLoading = false
    }
    
    private func updateQuizzes(_ quizzes: [Quiz]) {
        availableQuizzes = quizzes
        filterQuizzes()
    }
    
    private func filterQuizzes() {
        var filtered = languageDataService.quizzes.filter { quiz in
            // Filter by user's selected languages
            guard userProgress.selectedLanguages.contains(quiz.languageCode) else { return false }
            
            // Filter by category
            if let category = selectedCategory, quiz.category != category {
                return false
            }
            
            // Filter by difficulty
            if let difficulty = selectedDifficulty, quiz.difficulty != difficulty {
                return false
            }
            
            // Filter by completion status
            if !showCompleted && quiz.isCompleted {
                return false
            }
            
            // Filter by search text
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                return quiz.title.lowercased().contains(searchLower) ||
                       quiz.description.lowercased().contains(searchLower)
            }
            
            return true
        }
        
        // Sort by difficulty and then by title
        filtered.sort { quiz1, quiz2 in
            if quiz1.difficulty != quiz2.difficulty {
                let order: [Language.LanguageDifficulty] = [.beginner, .intermediate, .advanced, .expert]
                let index1 = order.firstIndex(of: quiz1.difficulty) ?? 0
                let index2 = order.firstIndex(of: quiz2.difficulty) ?? 0
                return index1 < index2
            }
            return quiz1.title < quiz2.title
        }
        
        availableQuizzes = filtered
    }
    
    // MARK: - Quiz Management
    
    func startQuiz(_ quiz: Quiz) {
        currentQuiz = quiz
        currentQuestionIndex = 0
        selectedAnswers.removeAll()
        isQuizActive = true
        quizResult = nil
        startTime = Date()
        
        // Set up timer if quiz has time limit
        if let timeLimit = quiz.timeLimit {
            timeRemaining = timeLimit
            startQuizTimer()
        }
    }
    
    func selectAnswer(_ answer: String) {
        guard let quiz = currentQuiz,
              currentQuestionIndex < quiz.questions.count else { return }
        
        let questionId = quiz.questions[currentQuestionIndex].id.uuidString
        selectedAnswers[questionId] = answer
    }
    
    func nextQuestion() {
        guard let quiz = currentQuiz else { return }
        
        if currentQuestionIndex < quiz.questions.count - 1 {
            withAnimation(.smooth) {
                currentQuestionIndex += 1
            }
        } else {
            completeQuiz()
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            withAnimation(.smooth) {
                currentQuestionIndex -= 1
            }
        }
    }
    
    func canProceedToNext() -> Bool {
        guard let quiz = currentQuiz,
              currentQuestionIndex < quiz.questions.count else { return false }
        
        let questionId = quiz.questions[currentQuestionIndex].id.uuidString
        return selectedAnswers[questionId] != nil
    }
    
    func getCurrentQuestion() -> QuizQuestion? {
        guard let quiz = currentQuiz,
              currentQuestionIndex < quiz.questions.count else { return nil }
        
        return quiz.questions[currentQuestionIndex]
    }
    
    func getSelectedAnswer(for questionId: UUID) -> String? {
        return selectedAnswers[questionId.uuidString]
    }
    
    private func completeQuiz() {
        guard let quiz = currentQuiz,
              let startTime = startTime else { return }
        
        quizTimer?.invalidate()
        isQuizActive = false
        
        // Calculate results
        let endTime = Date()
        let timeSpent = Int(endTime.timeIntervalSince(startTime))
        
        var quizAnswers: [QuizAnswer] = []
        var correctCount = 0
        
        for question in quiz.questions {
            let userAnswer = selectedAnswers[question.id.uuidString] ?? ""
            let isCorrect = userAnswer == question.correctAnswer
            if isCorrect { correctCount += 1 }
            
            quizAnswers.append(QuizAnswer(
                questionId: question.id,
                userAnswer: userAnswer,
                correctAnswer: question.correctAnswer,
                isCorrect: isCorrect,
                timeSpent: timeSpent / quiz.questions.count
            ))
        }
        
        let score = Double(correctCount) / Double(quiz.questions.count) * 100
        
        // Create quiz result
        let result = QuizResult(
            quizId: quiz.id,
            score: score,
            totalQuestions: quiz.questions.count,
            correctAnswers: correctCount,
            timeSpent: timeSpent,
            completedAt: Date(),
            answers: quizAnswers
        )
        
        quizResult = result
        
        // Update user progress
        updateUserProgressWithResult(result)
        
        // Update quiz completion status
        if let index = availableQuizzes.firstIndex(where: { $0.id == quiz.id }) {
            availableQuizzes[index].isCompleted = true
            availableQuizzes[index].bestScore = max(availableQuizzes[index].bestScore, score)
        }
        
        // Check for achievements
        checkForAchievements(result: result)
        
        // Schedule next quiz challenge notification
        scheduleNextQuizNotification()
    }
    
    func exitQuiz() {
        quizTimer?.invalidate()
        currentQuiz = nil
        isQuizActive = false
        quizResult = nil
        selectedAnswers.removeAll()
        currentQuestionIndex = 0
    }
    
    // MARK: - Timer Management
    
    private func startQuizTimer() {
        quizTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.completeQuiz() // Auto-complete when time runs out
            }
        }
    }
    
    // MARK: - Statistics and Analysis
    
    func getQuizStatistics() -> QuizStatistics {
        let completedQuizzes = userProgress.quizResults
        let totalQuizzes = completedQuizzes.count
        let averageScore = totalQuizzes > 0 ? completedQuizzes.reduce(0.0) { $0 + $1.score } / Double(totalQuizzes) : 0.0
        let totalTimeSpent = completedQuizzes.reduce(0) { $0 + $1.timeSpent }
        
        let categoryStats = Quiz.QuizCategory.allCases.map { category in
            let categoryQuizzes = completedQuizzes.filter { result in
                availableQuizzes.first { $0.id == result.quizId }?.category == category
            }
            let categoryAverage = categoryQuizzes.isEmpty ? 0.0 : categoryQuizzes.reduce(0.0) { $0 + $1.score } / Double(categoryQuizzes.count)
            
            return CategoryStatistic(category: category, averageScore: categoryAverage, completedCount: categoryQuizzes.count)
        }
        
        return QuizStatistics(
            totalCompleted: totalQuizzes,
            averageScore: averageScore,
            totalTimeSpent: totalTimeSpent,
            categoryStatistics: categoryStats,
            recentResults: Array(completedQuizzes.suffix(5))
        )
    }
    
    func getWeakAreas() -> [Quiz.QuizCategory] {
        let stats = getQuizStatistics()
        return stats.categoryStatistics
            .filter { $0.averageScore < 70 && $0.completedCount > 0 }
            .map { $0.category }
    }
    
    func getRecommendedQuizzes() -> [Quiz] {
        let weakAreas = getWeakAreas()
        let userLanguages = Set(userProgress.selectedLanguages)
        
        return availableQuizzes.filter { quiz in
            userLanguages.contains(quiz.languageCode) &&
            !quiz.isCompleted &&
            (weakAreas.contains(quiz.category) || weakAreas.isEmpty)
        }
        .prefix(5)
        .map { $0 }
    }
    
    // MARK: - Private Methods
    
    private func updateUserProgressWithResult(_ result: QuizResult) {
        userProgress.quizResults.append(result)
        
        // Update streak
        let calendar = Calendar.current
        if calendar.isDate(userProgress.lastActiveDate, inSameDayAs: Date()) {
            // Same day, maintain streak
        } else if calendar.isDate(userProgress.lastActiveDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()) {
            // Previous day, increment streak
            userProgress.streakCount += 1
        } else {
            // Broke streak
            userProgress.streakCount = 1
        }
        
        userProgress.lastActiveDate = Date()
        
        // Award experience points
        let experienceGained = Int(result.score) + (result.correctAnswers * 10)
        let newLevel = UserLevel.calculateLevel(from: userProgress.level.experiencePoints + experienceGained)
        userProgress.level = newLevel
        
        saveUserProgress()
    }
    
    private func checkForAchievements(result: QuizResult) {
        var newAchievements: [Achievement] = []
        
        // Perfect score achievement
        if result.percentage == 100 && !hasAchievement("perfect_score") {
            newAchievements.append(Achievement(
                title: "Perfect Score",
                description: "Get 100% on a quiz",
                icon: "star.circle.fill",
                unlockedDate: Date(),
                category: .mastery,
                rarity: .rare
            ))
        }
        
        // Speed demon achievement (complete quiz in under 30 seconds)
        if result.timeSpent < 30 && result.percentage >= 80 && !hasAchievement("speed_demon") {
            newAchievements.append(Achievement(
                title: "Speed Demon",
                description: "Complete a quiz in under 30 seconds with 80%+ score",
                icon: "bolt.circle.fill",
                unlockedDate: Date(),
                category: .mastery,
                rarity: .epic
            ))
        }
        
        // Quiz marathon achievement (10 quizzes in one day)
        let today = Calendar.current.startOfDay(for: Date())
        let todayQuizzes = userProgress.quizResults.filter { 
            Calendar.current.startOfDay(for: $0.completedAt) == today 
        }
        if todayQuizzes.count >= 10 && !hasAchievement("quiz_marathon") {
            newAchievements.append(Achievement(
                title: "Quiz Marathon",
                description: "Complete 10 quizzes in one day",
                icon: "figure.run.circle.fill",
                unlockedDate: Date(),
                category: .consistency,
                rarity: .epic
            ))
        }
        
        userProgress.achievements.append(contentsOf: newAchievements)
        
        // Send notifications for new achievements
        for achievement in newAchievements {
            notificationService.sendAchievementNotification(achievement: achievement)
        }
    }
    
    private func hasAchievement(_ achievementId: String) -> Bool {
        return userProgress.achievements.contains { 
            $0.title.lowercased().replacingOccurrences(of: " ", with: "_") == achievementId 
        }
    }
    
    private func scheduleNextQuizNotification() {
        // Schedule a quiz challenge notification for tomorrow
        notificationService.scheduleQuizChallengeNotification(
            quizTitle: "Daily Challenge",
            in: 24 * 60 * 60 // 24 hours
        )
    }
    
    private func saveUserProgress() {
        do {
            let data = try JSONEncoder().encode(userProgress)
            UserDefaults.standard.set(data, forKey: "user_progress")
        } catch {
            print("Failed to save user progress: \(error)")
        }
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedDifficulty = nil
        showCompleted = true
    }
    
    func retakeQuiz(_ quiz: Quiz) {
        startQuiz(quiz)
    }
}

// MARK: - Supporting Models
struct QuizStatistics {
    let totalCompleted: Int
    let averageScore: Double
    let totalTimeSpent: Int
    let categoryStatistics: [CategoryStatistic]
    let recentResults: [QuizResult]
    
    var formattedAverageScore: String {
        return String(format: "%.1f%%", averageScore)
    }
    
    var formattedTotalTime: String {
        let hours = totalTimeSpent / 3600
        let minutes = (totalTimeSpent % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct CategoryStatistic: Identifiable {
    let id = UUID()
    let category: Quiz.QuizCategory
    let averageScore: Double
    let completedCount: Int
    
    var formattedScore: String {
        return String(format: "%.1f%%", averageScore)
    }
}
