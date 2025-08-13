//
//  LanguageDataService.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import Foundation
import Combine

class LanguageDataService: ObservableObject {
    static let shared = LanguageDataService()
    
    @Published var languages: [Language] = []
    @Published var topics: [LanguageTopic] = []
    @Published var phrases: [Phrase] = []
    @Published var quizzes: [Quiz] = []
    @Published var isLoading = false
    @Published var error: LanguageDataError?
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    enum LanguageDataError: Error, LocalizedError {
        case dataLoadingFailed
        case networkError
        case dataCorrupted
        case noDataAvailable
        
        var errorDescription: String? {
            switch self {
            case .dataLoadingFailed:
                return "Failed to load language data"
            case .networkError:
                return "Network connection error"
            case .dataCorrupted:
                return "Language data is corrupted"
            case .noDataAvailable:
                return "No language data available"
            }
        }
    }
    
    private init() {
        // Don't auto-load data, let the app control when to load
        print("📱 LanguageDataService: Initialized")
    }
    
    func loadInitialData() {
        print("🔄 LanguageDataService: Starting to load initial data...")
        isLoading = true
        
        // Load data immediately for debugging
        languages = Language.sampleLanguages
        quizzes = Quiz.sampleQuizzes
        loadTopics()
        loadPhrases()
        isLoading = false
        
        print("✅ LanguageDataService: Initial data loaded - Languages: \(languages.count), Quizzes: \(quizzes.count), Topics: \(topics.count)")
    }
    
    private func loadTopics() {
        topics = [
            LanguageTopic(
                title: "Basic Greetings",
                description: "Learn essential greeting phrases",
                languageCode: "es",
                category: .vocabulary,
                estimatedDuration: 15,
                prerequisites: []
            ),
            LanguageTopic(
                title: "Numbers 1-20",
                description: "Master numbers from one to twenty",
                languageCode: "es",
                category: .vocabulary,
                estimatedDuration: 20,
                prerequisites: []
            ),
            LanguageTopic(
                title: "Present Tense Verbs",
                description: "Learn regular verb conjugations",
                languageCode: "es",
                category: .grammar,
                estimatedDuration: 30,
                prerequisites: ["basic_greetings"]
            ),
            LanguageTopic(
                title: "French Pronunciation",
                description: "Master French accent and pronunciation",
                languageCode: "fr",
                category: .pronunciation,
                estimatedDuration: 25,
                prerequisites: []
            ),
            LanguageTopic(
                title: "Business Meeting Vocabulary",
                description: "Essential business terms and phrases",
                languageCode: "en",
                category: .business,
                estimatedDuration: 35,
                prerequisites: []
            ),
            LanguageTopic(
                title: "German Culture Basics",
                description: "Understanding German customs and traditions",
                languageCode: "de",
                category: .culture,
                estimatedDuration: 40,
                prerequisites: []
            )
        ]
    }
    
    private func loadPhrases() {
        phrases = [
            Phrase(
                original: "Hola, ¿cómo estás?",
                translation: "Hello, how are you?",
                languageCode: "es",
                category: "Greetings",
                audioURL: nil,
                difficulty: .beginner,
                usage: "Used as a friendly greeting when meeting someone",
                examples: ["Hola María, ¿cómo estás?", "¡Hola! ¿Cómo estás hoy?"]
            ),
            Phrase(
                original: "Gracias por tu ayuda",
                translation: "Thank you for your help",
                languageCode: "es",
                category: "Gratitude",
                audioURL: nil,
                difficulty: .beginner,
                usage: "Express gratitude for assistance received",
                examples: ["Gracias por tu ayuda con el proyecto", "Gracias por tu ayuda, muy amable"]
            ),
            Phrase(
                original: "Bonjour, comment allez-vous?",
                translation: "Hello, how are you?",
                languageCode: "fr",
                category: "Greetings",
                audioURL: nil,
                difficulty: .intermediate,
                usage: "Formal greeting in French",
                examples: ["Bonjour monsieur, comment allez-vous?", "Bonjour madame, comment allez-vous aujourd'hui?"]
            ),
            Phrase(
                original: "Je voudrais une réservation",
                translation: "I would like a reservation",
                languageCode: "fr",
                category: "Travel",
                audioURL: nil,
                difficulty: .intermediate,
                usage: "Used when making reservations at restaurants or hotels",
                examples: ["Je voudrais une réservation pour deux", "Je voudrais une réservation ce soir"]
            ),
            Phrase(
                original: "Wie geht es Ihnen?",
                translation: "How are you?",
                languageCode: "de",
                category: "Greetings",
                audioURL: nil,
                difficulty: .advanced,
                usage: "Formal way to ask how someone is doing in German",
                examples: ["Guten Tag, wie geht es Ihnen?", "Wie geht es Ihnen heute?"]
            )
        ]
    }
    
    func getLanguageTopics(for languageCode: String) -> [LanguageTopic] {
        return topics.filter { $0.languageCode == languageCode }
    }
    
    func getLanguagePhrases(for languageCode: String) -> [Phrase] {
        return phrases.filter { $0.languageCode == languageCode }
    }
    
    func getLanguageQuizzes(for languageCode: String) -> [Quiz] {
        return quizzes.filter { $0.languageCode == languageCode }
    }
    
    func searchPhrases(query: String) -> [Phrase] {
        guard !query.isEmpty else { return phrases }
        
        return phrases.filter { phrase in
            phrase.original.localizedCaseInsensitiveContains(query) ||
            phrase.translation.localizedCaseInsensitiveContains(query) ||
            phrase.category.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getPhrasesByCategory(_ category: String) -> [Phrase] {
        return phrases.filter { $0.category.localizedCaseInsensitiveCompare(category) == .orderedSame }
    }
    
    func getPhrasesByDifficulty(_ difficulty: Language.LanguageDifficulty) -> [Phrase] {
        return phrases.filter { $0.difficulty == difficulty }
    }
    
    func getRecommendedQuizzes(for userProgress: UserProgress) -> [Quiz] {
        let userLanguages = userProgress.selectedLanguages
        let completedQuizzes = Set(userProgress.quizResults.map { $0.quizId })
        
        return quizzes.filter { quiz in
            userLanguages.contains(quiz.languageCode) &&
            !completedQuizzes.contains(quiz.id)
        }
    }
    
    func getTopicRecommendations(for userProgress: UserProgress) -> [LanguageTopic] {
        let userLanguages = userProgress.selectedLanguages
        let completedTopics = Set(userProgress.completedTopics)
        
        return topics.filter { topic in
            userLanguages.contains(topic.languageCode) &&
            !completedTopics.contains(topic.id.uuidString) &&
            topic.prerequisites.allSatisfy { completedTopics.contains($0) }
        }
    }
    
    func updateTopicProgress(_ topicId: String, progress: Double) {
        if let index = topics.firstIndex(where: { $0.id.uuidString == topicId }) {
            topics[index].progress = progress
            if progress >= 1.0 {
                topics[index].isCompleted = true
            }
        }
    }
    
    func bookmarkPhrase(_ phraseId: String) {
        if let index = phrases.firstIndex(where: { $0.id.uuidString == phraseId }) {
            phrases[index].isBookmarked.toggle()
        }
    }
    
    func getBookmarkedPhrases() -> [Phrase] {
        return phrases.filter { $0.isBookmarked }
    }
    
    func refreshData() {
        loadInitialData()
    }
    
    // MARK: - Data Persistence
    
    func saveData() {
        do {
            let languagesData = try JSONEncoder().encode(languages)
            let topicsData = try JSONEncoder().encode(topics)
            let phrasesData = try JSONEncoder().encode(phrases)
            let quizzesData = try JSONEncoder().encode(quizzes)
            
            userDefaults.set(languagesData, forKey: "languages")
            userDefaults.set(topicsData, forKey: "topics")
            userDefaults.set(phrasesData, forKey: "phrases")
            userDefaults.set(quizzesData, forKey: "quizzes")
        } catch {
            print("Failed to save language data: \(error)")
            self.error = .dataCorrupted
        }
    }
    
    func loadSavedData() {
        do {
            if let languagesData = userDefaults.data(forKey: "languages") {
                languages = try JSONDecoder().decode([Language].self, from: languagesData)
            }
            
            if let topicsData = userDefaults.data(forKey: "topics") {
                topics = try JSONDecoder().decode([LanguageTopic].self, from: topicsData)
            }
            
            if let phrasesData = userDefaults.data(forKey: "phrases") {
                phrases = try JSONDecoder().decode([Phrase].self, from: phrasesData)
            }
            
            if let quizzesData = userDefaults.data(forKey: "quizzes") {
                quizzes = try JSONDecoder().decode([Quiz].self, from: quizzesData)
            }
        } catch {
            print("Failed to load saved language data: \(error)")
            self.error = .dataCorrupted
            loadInitialData() // Fallback to initial data
        }
    }
    
    // MARK: - Debug Methods
    func addTestTopics(_ testTopics: [LanguageTopic]) {
        print("📊 LanguageDataService: Adding \(testTopics.count) test topics")
        topics.append(contentsOf: testTopics)
        
        // Сохраняем топики в UserDefaults
        if let encoded = try? JSONEncoder().encode(topics) {
            userDefaults.set(encoded, forKey: "topics")
        }
        
        print("📊 LanguageDataService: Total topics now: \(topics.count)")
    }
}
