//
//  UserProgressModel.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import Foundation

struct UserProgress: Codable {
    var userId: String
    var userName: String // Added user name from onboarding
    var selectedLanguages: [String] // language codes
    var languageSkillLevels: [String: Language.LanguageDifficulty] // Added skill levels
    var completedTopics: [String] // topic IDs
    var bookmarkedPhrases: [String] // phrase IDs
    var quizResults: [QuizResult]
    var streakCount: Int
    var lastActiveDate: Date
    var totalStudyTime: Int // in minutes
    var level: UserLevel
    var achievements: [Achievement]
    var weeklyGoal: Int // minutes per week
    var dailyGoal: Int // minutes per day
    var preferences: UserPreferences
    
    init(userId: String, userName: String, selectedLanguages: [String], languageSkillLevels: [String: Language.LanguageDifficulty] = [:], completedTopics: [String], bookmarkedPhrases: [String], quizResults: [QuizResult], streakCount: Int, lastActiveDate: Date, totalStudyTime: Int, level: UserLevel, achievements: [Achievement], weeklyGoal: Int, dailyGoal: Int, preferences: UserPreferences) {
        self.userId = userId
        self.userName = userName
        self.selectedLanguages = selectedLanguages
        self.languageSkillLevels = languageSkillLevels
        self.completedTopics = completedTopics
        self.bookmarkedPhrases = bookmarkedPhrases
        self.quizResults = quizResults
        self.streakCount = streakCount
        self.lastActiveDate = lastActiveDate
        self.totalStudyTime = totalStudyTime
        self.level = level
        self.achievements = achievements
        self.weeklyGoal = weeklyGoal
        self.dailyGoal = dailyGoal
        self.preferences = preferences
    }
    
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDate(lastActiveDate, inSameDayAs: today) ||
           calendar.isDate(lastActiveDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today) ?? today) {
            return streakCount
        } else {
            return 0
        }
    }
    
    var weeklyProgress: Double {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        let weeklyStudyTime = quizResults
            .filter { $0.completedAt >= startOfWeek }
            .reduce(0) { $0 + $1.timeSpent / 60 }
        
        return min(Double(weeklyStudyTime) / Double(weeklyGoal), 1.0)
    }
    
    func getLanguageProgress(for languageCode: String) -> LanguageProgress {
        let languageTopics = completedTopics.filter { $0.hasPrefix(languageCode) }
        let languageQuizzes = quizResults.filter { quiz in
            Quiz.sampleQuizzes.first { $0.id.uuidString == quiz.quizId.uuidString }?.languageCode == languageCode
        }
        
        let averageScore = languageQuizzes.isEmpty ? 0.0 : 
            languageQuizzes.reduce(0.0) { $0 + $1.score } / Double(languageQuizzes.count)
        
        return LanguageProgress(
            languageCode: languageCode,
            languageName: "Language",
            completedTopics: languageTopics.count,
            totalTopics: 20, // This would come from actual data
            averageQuizScore: averageScore,
            studyTime: languageQuizzes.reduce(0) { $0 + $1.timeSpent / 60 },
            proficiencyLevel: .beginner,
            studyStreakDays: 0,
            lastStudyDate: Date()
        )
    }
}



struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let unlockedDate: Date
    let category: AchievementCategory
    let rarity: AchievementRarity
    
    init(title: String, description: String, icon: String, unlockedDate: Date, category: AchievementCategory, rarity: AchievementRarity) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.icon = icon
        self.unlockedDate = unlockedDate
        self.category = category
        self.rarity = rarity
    }
    
    enum AchievementCategory: String, CaseIterable, Codable {
        case learning = "Learning"
        case consistency = "Consistency"
        case mastery = "Mastery"
        case social = "Social"
        case exploration = "Exploration"
    }
    
    enum AchievementRarity: String, CaseIterable, Codable {
        case common = "Common"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"
        
        var color: String {
            switch self {
            case .common: return "#3cc45b"
            case .rare: return "#007AFF"
            case .epic: return "#5856D6"
            case .legendary: return "#fcc418"
            }
        }
    }
}

struct UserPreferences: Codable {
    var notificationsEnabled: Bool
    var dailyReminderTime: Date?
    var weeklyReportEnabled: Bool
    var soundEnabled: Bool
    var hapticFeedbackEnabled: Bool
    var preferredStudyTime: StudyTime
    var difficultyPreference: Language.LanguageDifficulty
    var learningStyle: LearningStyle
    
    enum StudyTime: String, CaseIterable, Codable {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
        case flexible = "Flexible"
    }
    
    enum LearningStyle: String, CaseIterable, Codable {
        case visual = "Visual"
        case auditory = "Auditory"
        case kinesthetic = "Kinesthetic"
        case readingWriting = "Reading/Writing"
        case mixed = "Mixed"
    }
}

// MARK: - Language Progress Model
struct LanguageProgress: Identifiable, Codable {
    let id: UUID
    let languageCode: String
    let languageName: String
    var completedTopics: Int
    var totalTopics: Int
    var averageQuizScore: Double
    var studyTime: Int // in minutes
    var completionPercentage: Double {
        guard totalTopics > 0 else { return 0 }
        return Double(completedTopics) / Double(totalTopics)
    }
    var proficiencyLevel: ProficiencyLevel
    var studyStreakDays: Int
    var lastStudyDate: Date?
    
    init(languageCode: String, languageName: String, completedTopics: Int = 0, totalTopics: Int = 0, averageQuizScore: Double = 0.0, studyTime: Int = 0, proficiencyLevel: ProficiencyLevel = .beginner, studyStreakDays: Int = 0, lastStudyDate: Date? = nil) {
        self.id = UUID()
        self.languageCode = languageCode
        self.languageName = languageName
        self.completedTopics = completedTopics
        self.totalTopics = totalTopics
        self.averageQuizScore = averageQuizScore
        self.studyTime = studyTime
        self.proficiencyLevel = proficiencyLevel
        self.studyStreakDays = studyStreakDays
        self.lastStudyDate = lastStudyDate
    }
    
    enum ProficiencyLevel: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case elementary = "Elementary"
        case intermediate = "Intermediate"
        case upperIntermediate = "Upper Intermediate"
        case advanced = "Advanced"
        case proficient = "Proficient"
        
        var color: String {
            switch self {
            case .beginner: return "#FF3B30"
            case .elementary: return "#FF9500"
            case .intermediate: return "#fcc418"
            case .upperIntermediate: return "#30D158"
            case .advanced: return "#3cc45b"
            case .proficient: return "#007AFF"
            }
        }
        
        var icon: String {
            switch self {
            case .beginner: return "leaf"
            case .elementary: return "seedling"
            case .intermediate: return "tree"
            case .upperIntermediate: return "mountain.2"
            case .advanced: return "crown"
            case .proficient: return "star.circle.fill"
            }
        }
    }
}

// MARK: - User Level Model
struct UserLevel: Codable {
    let level: Int
    let experiencePoints: Int
    let experienceToNextLevel: Int
    
    init(level: Int, experiencePoints: Int, experienceToNextLevel: Int) {
        self.level = level
        self.experiencePoints = experiencePoints
        self.experienceToNextLevel = experienceToNextLevel
    }
    
    var title: String {
        switch level {
        case 1...5: return "Novice Linguist"
        case 6...10: return "Language Explorer"
        case 11...20: return "Word Collector"
        case 21...35: return "Grammar Guru"
        case 36...50: return "Polyglot"
        case 51...75: return "Language Master"
        case 76...100: return "Linguistic Scholar"
        default: return "Language Legend"
        }
    }
    
    var progress: Double {
        guard experienceToNextLevel > 0 else { return 1.0 }
        let totalForLevel = experiencePoints + experienceToNextLevel
        return Double(experiencePoints) / Double(totalForLevel)
    }
    
    static func calculateLevel(from experiencePoints: Int) -> UserLevel {
        let level = Int(sqrt(Double(experiencePoints) / 100)) + 1
        let experienceForCurrentLevel = (level - 1) * (level - 1) * 100
        let experienceForNextLevel = level * level * 100
        let experienceToNextLevel = experienceForNextLevel - experiencePoints
        
        return UserLevel(
            level: level,
            experiencePoints: experiencePoints,
            experienceToNextLevel: experienceToNextLevel
        )
    }
}

// MARK: - Learning Goal Model
struct LearningGoal: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: GoalCategory
    let targetValue: Int
    var currentValue: Int
    let unit: String
    let deadline: Date?
    let isCompleted: Bool
    
    init(title: String, description: String, category: GoalCategory, targetValue: Int, currentValue: Int = 0, unit: String, deadline: Date? = nil, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.category = category
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.unit = unit
        self.deadline = deadline
        self.isCompleted = isCompleted
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }
    
    enum GoalCategory: String, CaseIterable, Codable {
        case vocabulary = "Vocabulary"
        case grammar = "Grammar"
        case conversation = "Conversation"
        case listening = "Listening"
        case reading = "Reading"
        case writing = "Writing"
        case pronunciation = "Pronunciation"
        case culture = "Culture"
        
        var icon: String {
            switch self {
            case .vocabulary: return "text.book.closed"
            case .grammar: return "textformat.abc"
            case .conversation: return "bubble.left.and.bubble.right"
            case .listening: return "ear"
            case .reading: return "book"
            case .writing: return "pencil"
            case .pronunciation: return "waveform"
            case .culture: return "globe"
            }
        }
        
        var color: String {
            switch self {
            case .vocabulary: return "#007AFF"
            case .grammar: return "#5856D6"
            case .conversation: return "#FF2D92"
            case .listening: return "#30D158"
            case .reading: return "#fcc418"
            case .writing: return "#FF9500"
            case .pronunciation: return "#00D4AA"
            case .culture: return "#AF52DE"
            }
        }
    }
}

extension LearningGoal {
    static let sampleGoals: [LearningGoal] = [
        LearningGoal(
            title: "Learn 500 Spanish Words",
            description: "Build a strong vocabulary foundation",
            category: .vocabulary,
            targetValue: 500,
            currentValue: 127,
            unit: "words",
            deadline: Calendar.current.date(byAdding: .month, value: 3, to: Date())
        ),
        LearningGoal(
            title: "Complete 20 Conversations",
            description: "Practice speaking with native speakers",
            category: .conversation,
            targetValue: 20,
            currentValue: 5,
            unit: "conversations",
            deadline: Calendar.current.date(byAdding: .month, value: 2, to: Date())
        ),
        LearningGoal(
            title: "Master Present Tense",
            description: "Understand and use present tense correctly",
            category: .grammar,
            targetValue: 10,
            currentValue: 7,
            unit: "exercises",
            deadline: Calendar.current.date(byAdding: .weekOfYear, value: 2, to: Date())
        )
    ]
}

// Sample data for development
extension UserProgress {
    static let sampleProgress = UserProgress(
        userId: "user123",
        userName: "Sample User",
        selectedLanguages: ["es", "fr"],
        languageSkillLevels: ["es": .beginner, "fr": .intermediate],
        completedTopics: ["es_basics_1", "es_basics_2", "fr_intro_1"],
        bookmarkedPhrases: [],
        quizResults: [],
        streakCount: 5,
        lastActiveDate: Date(),
        totalStudyTime: 120,
        level: UserLevel.calculateLevel(from: 2500),
        achievements: [
            Achievement(
                title: "First Steps",
                description: "Complete your first quiz",
                icon: "star.fill",
                unlockedDate: Date(),
                category: .learning,
                rarity: .common
            )
        ],
        weeklyGoal: 180,
        dailyGoal: 30,
        preferences: UserPreferences(
            notificationsEnabled: true,
            dailyReminderTime: nil,
            weeklyReportEnabled: true,
            soundEnabled: true,
            hapticFeedbackEnabled: true,
            preferredStudyTime: .evening,
            difficultyPreference: .intermediate,
            learningStyle: .mixed
        )
    )
}
