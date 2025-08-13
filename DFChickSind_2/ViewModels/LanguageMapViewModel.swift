//
//  LanguageMapViewModel.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import Foundation
import Combine
import SwiftUI

class LanguageMapViewModel: ObservableObject {
    @Published var selectedLanguage: Language?
    @Published var languageProgresses: [LanguageProgress] = []
    @Published var topics: [LanguageTopic] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedCategory: LanguageTopic.TopicCategory?
    @Published var showCompleted = true
    @Published var sortOrder: SortOrder = .progress
    
    private let languageDataService = LanguageDataService.shared
    private var userProgress: UserProgress
    private var cancellables = Set<AnyCancellable>()
    
    enum SortOrder: String, CaseIterable {
        case progress = "Progress"
        case difficulty = "Difficulty"
        case duration = "Duration"
        case alphabetical = "A-Z"
        
        var icon: String {
            switch self {
            case .progress: return "chart.bar"
            case .difficulty: return "star"
            case .duration: return "clock"
            case .alphabetical: return "textformat"
            }
        }
    }
    
    init() {
        self.userProgress = Self.loadUserProgress()
        setupBindings()
        loadData()
    }
    
    private func setupBindings() {
        // Watch for search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterTopics()
            }
            .store(in: &cancellables)
        
        // Watch for category changes
        $selectedCategory
            .sink { [weak self] _ in
                self?.filterTopics()
            }
            .store(in: &cancellables)
        
        // Watch for sort order changes
        $sortOrder
            .sink { [weak self] _ in
                self?.sortTopics()
            }
            .store(in: &cancellables)
        
        // Watch for language data service updates
        languageDataService.$topics
            .sink { [weak self] topics in
                self?.updateTopics(topics)
            }
            .store(in: &cancellables)
    }
    
    private static func loadUserProgress() -> UserProgress {
        guard let data = UserDefaults.standard.data(forKey: "user_progress"),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return UserProgress.sampleProgress
        }
        return progress
    }
    
    private func loadData() {
        isLoading = true
        
        // Load language progresses
        languageProgresses = userProgress.selectedLanguages.map { languageCode in
            userProgress.getLanguageProgress(for: languageCode)
        }
        
        // Load topics for selected languages
        updateTopics(languageDataService.topics)
        
        isLoading = false
    }
    
    private func updateTopics(_ allTopics: [LanguageTopic]) {
        let userLanguages = Set(userProgress.selectedLanguages)
        topics = allTopics.filter { userLanguages.contains($0.languageCode) }
        filterTopics()
    }
    
    private func filterTopics() {
        var filtered = languageDataService.topics.filter { topic in
            let userLanguages = Set(userProgress.selectedLanguages)
            
            // Filter by selected languages
            guard userLanguages.contains(topic.languageCode) else { return false }
            
            // Filter by selected language if any
            if let selectedLang = selectedLanguage {
                guard topic.languageCode == selectedLang.code else { return false }
            }
            
            // Filter by category if selected
            if let category = selectedCategory {
                guard topic.category == category else { return false }
            }
            
            // Filter by completion status
            if !showCompleted && topic.isCompleted {
                return false
            }
            
            // Filter by search text
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                return topic.title.lowercased().contains(searchLower) ||
                       topic.description.lowercased().contains(searchLower)
            }
            
            return true
        }
        
        // Apply sorting
        switch sortOrder {
        case .progress:
            filtered.sort { $0.progress > $1.progress }
        case .difficulty:
            let difficultyOrder: [Language.LanguageDifficulty] = [.beginner, .intermediate, .advanced, .expert]
            filtered.sort { topic1, topic2 in
                let lang1 = getLanguage(for: topic1.languageCode)?.difficulty ?? .beginner
                let lang2 = getLanguage(for: topic2.languageCode)?.difficulty ?? .beginner
                return (difficultyOrder.firstIndex(of: lang1) ?? 0) < (difficultyOrder.firstIndex(of: lang2) ?? 0)
            }
        case .duration:
            filtered.sort { $0.estimatedDuration < $1.estimatedDuration }
        case .alphabetical:
            filtered.sort { $0.title < $1.title }
        }
        
        topics = filtered
    }
    
    private func sortTopics() {
        filterTopics() // This will apply the new sort order
    }
    
    func selectLanguage(_ language: Language?) {
        selectedLanguage = language
        filterTopics()
    }
    
    func startTopic(_ topic: LanguageTopic) {
        // Check prerequisites
        let completedTopics = Set(userProgress.completedTopics)
        let unmetPrerequisites = topic.prerequisites.filter { !completedTopics.contains($0) }
        
        guard unmetPrerequisites.isEmpty else {
            // Handle prerequisites not met
            return
        }
        
        // Update topic progress
        languageDataService.updateTopicProgress(topic.id.uuidString, progress: 0.1)
        updateUserProgress()
    }
    
    func completeTopic(_ topic: LanguageTopic) {
        // Mark topic as completed
        languageDataService.updateTopicProgress(topic.id.uuidString, progress: 1.0)
        
        // Update user progress
        userProgress.completedTopics.append(topic.id.uuidString)
        userProgress.totalStudyTime += topic.estimatedDuration
        
        // Award experience points
        let experienceGained = topic.estimatedDuration * 10
        let newLevel = UserLevel.calculateLevel(from: userProgress.level.experiencePoints + experienceGained)
        userProgress.level = newLevel
        
        // Check for achievements
        checkForAchievements()
        
        saveUserProgress()
        updateUserProgress()
    }
    
    func getTopicProgress(_ topic: LanguageTopic) -> Double {
        return topic.progress
    }
    
    func canStartTopic(_ topic: LanguageTopic) -> Bool {
        let completedTopics = Set(userProgress.completedTopics)
        return topic.prerequisites.allSatisfy { completedTopics.contains($0) }
    }
    
    func getPrerequisiteTopics(_ topic: LanguageTopic) -> [LanguageTopic] {
        return languageDataService.topics.filter { candidateTopic in
            topic.prerequisites.contains(candidateTopic.id.uuidString)
        }
    }
    
    func getLanguageProgress(for languageCode: String) -> LanguageProgress? {
        return languageProgresses.first { $0.languageCode == languageCode }
    }
    
    func getLanguage(for languageCode: String) -> Language? {
        return languageDataService.languages.first { $0.code == languageCode }
    }
    
    func refreshData() {
        loadData()
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedLanguage = nil
        showCompleted = true
        sortOrder = .progress
    }
    
    // MARK: - Private Methods
    
    private func updateUserProgress() {
        // Reload language progresses
        languageProgresses = userProgress.selectedLanguages.map { languageCode in
            userProgress.getLanguageProgress(for: languageCode)
        }
    }
    
    private func checkForAchievements() {
        let completedCount = userProgress.completedTopics.count
        var newAchievements: [Achievement] = []
        
        // First topic completed
        if completedCount == 1 && !hasAchievement("first_topic") {
            newAchievements.append(Achievement(
                title: "First Steps",
                description: "Complete your first topic",
                icon: "star.fill",
                unlockedDate: Date(),
                category: .learning,
                rarity: .common
            ))
        }
        
        // 10 topics completed
        if completedCount >= 10 && !hasAchievement("dedicated_learner") {
            newAchievements.append(Achievement(
                title: "Dedicated Learner",
                description: "Complete 10 topics",
                icon: "book.fill",
                unlockedDate: Date(),
                category: .learning,
                rarity: .rare
            ))
        }
        
        // 50 topics completed
        if completedCount >= 50 && !hasAchievement("topic_master") {
            newAchievements.append(Achievement(
                title: "Topic Master",
                description: "Complete 50 topics",
                icon: "crown.fill",
                unlockedDate: Date(),
                category: .mastery,
                rarity: .epic
            ))
        }
        
        userProgress.achievements.append(contentsOf: newAchievements)
        
        // Send notifications for new achievements
        for achievement in newAchievements {
            NotificationService.shared.sendAchievementNotification(achievement: achievement)
        }
    }
    
    private func hasAchievement(_ achievementId: String) -> Bool {
        return userProgress.achievements.contains { $0.title.lowercased().replacingOccurrences(of: " ", with: "_") == achievementId }
    }
    
    private func saveUserProgress() {
        do {
            let data = try JSONEncoder().encode(userProgress)
            UserDefaults.standard.set(data, forKey: "user_progress")
        } catch {
            print("Failed to save user progress: \(error)")
        }
    }
}

// MARK: - Map Visualization Data
extension LanguageMapViewModel {
    
    func getMapNodes() -> [MapNode] {
        return topics.map { topic in
            MapNode(
                id: topic.id.uuidString,
                title: topic.title,
                category: topic.category,
                position: getNodePosition(for: topic),
                isCompleted: topic.isCompleted,
                isAvailable: canStartTopic(topic),
                progress: topic.progress,
                connections: topic.prerequisites
            )
        }
    }
    
    private func getNodePosition(for topic: LanguageTopic) -> CGPoint {
        // Generate positions based on topic dependencies and categories
        let baseX: CGFloat = 100
        let baseY: CGFloat = 100
        let spacing: CGFloat = 120
        
        let categoryIndex = LanguageTopic.TopicCategory.allCases.firstIndex(of: topic.category) ?? 0
        let topicsInCategory = topics.filter { $0.category == topic.category }
        let indexInCategory = topicsInCategory.firstIndex(where: { $0.id == topic.id }) ?? 0
        
        let x = baseX + CGFloat(categoryIndex) * spacing * 2
        let y = baseY + CGFloat(indexInCategory) * spacing
        
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Supporting Models
struct MapNode: Identifiable {
    let id: String
    let title: String
    let category: LanguageTopic.TopicCategory
    let position: CGPoint
    let isCompleted: Bool
    let isAvailable: Bool
    let progress: Double
    let connections: [String] // IDs of prerequisite topics
}
