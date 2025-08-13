//
//  QuizModel.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import Foundation

struct Quiz: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let languageCode: String
    let category: QuizCategory
    let difficulty: Language.LanguageDifficulty
    let questions: [QuizQuestion]
    let timeLimit: Int? // in seconds, nil for unlimited
    var isCompleted: Bool = false
    var bestScore: Double = 0.0
    let totalPoints: Int
    
    init(title: String, description: String, languageCode: String, category: QuizCategory, difficulty: Language.LanguageDifficulty, questions: [QuizQuestion], timeLimit: Int? = nil, isCompleted: Bool = false, bestScore: Double = 0.0, totalPoints: Int) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.languageCode = languageCode
        self.category = category
        self.difficulty = difficulty
        self.questions = questions
        self.timeLimit = timeLimit
        self.isCompleted = isCompleted
        self.bestScore = bestScore
        self.totalPoints = totalPoints
    }
    
    enum QuizCategory: String, CaseIterable, Codable {
        case vocabulary = "Vocabulary"
        case grammar = "Grammar"
        case listening = "Listening"
        case reading = "Reading"
        case business = "Business Terms"
        case culture = "Cultural Knowledge"
        
        var icon: String {
            switch self {
            case .vocabulary: return "abc"
            case .grammar: return "textformat.123"
            case .listening: return "ear"
            case .reading: return "book"
            case .business: return "building.2"
            case .culture: return "globe.americas"
            }
        }
        
        var color: String {
            switch self {
            case .vocabulary: return "#3cc45b"
            case .grammar: return "#fcc418"
            case .listening: return "#007AFF"
            case .reading: return "#FF9500"
            case .business: return "#5856D6"
            case .culture: return "#FF2D92"
            }
        }
    }
}

struct QuizQuestion: Identifiable, Codable {
    let id: UUID
    let question: String
    let questionType: QuestionType
    let options: [String]
    let correctAnswer: String
    let explanation: String
    let points: Int
    let audioURL: String?
    let imageURL: String?
    
    init(question: String, questionType: QuestionType, options: [String], correctAnswer: String, explanation: String, points: Int, audioURL: String? = nil, imageURL: String? = nil) {
        self.id = UUID()
        self.question = question
        self.questionType = questionType
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.points = points
        self.audioURL = audioURL
        self.imageURL = imageURL
    }
    
    enum QuestionType: String, CaseIterable, Codable {
        case multipleChoice = "Multiple Choice"
        case trueOrFalse = "True or False"
        case fillInBlank = "Fill in the Blank"
        case matching = "Matching"
        case listening = "Listening"
        case ordering = "Ordering"
    }
}

struct QuizResult: Identifiable, Codable {
    let id: UUID
    let quizId: UUID
    let score: Double
    let totalQuestions: Int
    let correctAnswers: Int
    let timeSpent: Int // in seconds
    let completedAt: Date
    let answers: [QuizAnswer]
    
    init(quizId: UUID, score: Double, totalQuestions: Int, correctAnswers: Int, timeSpent: Int, completedAt: Date, answers: [QuizAnswer]) {
        self.id = UUID()
        self.quizId = quizId
        self.score = score
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.timeSpent = timeSpent
        self.completedAt = completedAt
        self.answers = answers
    }
    
    var percentage: Double {
        return (Double(correctAnswers) / Double(totalQuestions)) * 100
    }
    
    var grade: QuizGrade {
        switch percentage {
        case 90...100: return .excellent
        case 80..<90: return .good
        case 70..<80: return .average
        case 60..<70: return .belowAverage
        default: return .needsImprovement
        }
    }
    
    enum QuizGrade: String, CaseIterable {
        case excellent = "Excellent"
        case good = "Good"
        case average = "Average"
        case belowAverage = "Below Average"
        case needsImprovement = "Needs Improvement"
        
        var color: String {
            switch self {
            case .excellent: return "#3cc45b"
            case .good: return "#fcc418"
            case .average: return "#FF9500"
            case .belowAverage: return "#FF6B35"
            case .needsImprovement: return "#FF3B30"
            }
        }
        
        var emoji: String {
            switch self {
            case .excellent: return "🌟"
            case .good: return "👍"
            case .average: return "👌"
            case .belowAverage: return "📚"
            case .needsImprovement: return "💪"
            }
        }
    }
}

struct QuizAnswer: Identifiable, Codable {
    let id: UUID
    let questionId: UUID
    let userAnswer: String
    let correctAnswer: String
    let isCorrect: Bool
    let timeSpent: Int // in seconds
    
    init(questionId: UUID, userAnswer: String, correctAnswer: String, isCorrect: Bool, timeSpent: Int) {
        self.id = UUID()
        self.questionId = questionId
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
        self.isCorrect = isCorrect
        self.timeSpent = timeSpent
    }
}

// Sample data for development
extension Quiz {
    static let sampleQuizzes: [Quiz] = [
        Quiz(
            title: "Spanish Basics",
            description: "Test your knowledge of basic Spanish vocabulary and phrases",
            languageCode: "es",
            category: .vocabulary,
            difficulty: .beginner,
            questions: [
                QuizQuestion(
                    question: "What does 'Hola' mean in English?",
                    questionType: .multipleChoice,
                    options: ["Hello", "Goodbye", "Thank you", "Please"],
                    correctAnswer: "Hello",
                    explanation: "'Hola' is the most common way to say hello in Spanish.",
                    points: 10,
                    audioURL: nil,
                    imageURL: nil
                ),
                QuizQuestion(
                    question: "How do you say 'Thank you' in Spanish?",
                    questionType: .multipleChoice,
                    options: ["Por favor", "Gracias", "De nada", "Perdón"],
                    correctAnswer: "Gracias",
                    explanation: "'Gracias' means thank you in Spanish.",
                    points: 10,
                    audioURL: nil,
                    imageURL: nil
                )
            ],
            timeLimit: 300,
            totalPoints: 20
        ),
        Quiz(
            title: "French Grammar Challenge",
            description: "Test your understanding of French grammar rules",
            languageCode: "fr",
            category: .grammar,
            difficulty: .intermediate,
            questions: [
                QuizQuestion(
                    question: "Which article goes with 'maison' (house)?",
                    questionType: .multipleChoice,
                    options: ["le", "la", "les", "un"],
                    correctAnswer: "la",
                    explanation: "'Maison' is feminine, so it takes the feminine article 'la'.",
                    points: 15,
                    audioURL: nil,
                    imageURL: nil
                )
            ],
            timeLimit: 600,
            totalPoints: 15
        )
    ]
}
