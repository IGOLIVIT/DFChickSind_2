//
//  QuizView.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var languageDataService = LanguageDataService.shared
    @State private var userProgress: UserProgress = UserProgress.sampleProgress
    @State private var showQuiz = false
    @State private var selectedLanguageCode: String?
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [String] = []
    @State private var showResult = false
    @State private var score = 0
    @State private var isQuizActive = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isQuizActive && !showResult {
                    // Active Quiz
                    QuizActiveView(
                        languageCode: selectedLanguageCode ?? "de",
                        currentQuestionIndex: $currentQuestionIndex,
                        selectedAnswers: $selectedAnswers,
                        onQuizComplete: { finalScore in
                            score = finalScore
                            showResult = true
                            isQuizActive = false
                        }
                    )
                } else if showResult {
                    // Quiz Result
                    QuizResultView(
                        score: score,
                        total: 10,
                        onRestart: {
                            restartQuiz()
                        },
                        onBackToMenu: {
                            backToMenu()
                        }
                    )
                } else {
                    // Quiz Menu
                    QuizMenuView(
                        userProgress: userProgress,
                        availableLanguages: languageDataService.languages.filter { $0.isAvailable },
                        onStartQuiz: { languageCode in
                            selectedLanguageCode = languageCode
                            currentQuestionIndex = 0
                            selectedAnswers = Array(repeating: "", count: 10)
                            showQuiz = true
                            isQuizActive = true
                            score = 0
                            showResult = false
                        }
                    )
                }
                
                Spacer(minLength: 100)
            }
            .padding(.bottom, 20)
        }
        .appBackground()
        .onAppear {
            print("❓ QuizView: Translation Quiz - onAppear called")
            loadUserProgress()
        }
    }
    
    private func loadUserProgress() {
        guard let data = UserDefaults.standard.data(forKey: "user_progress"),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return
        }
        userProgress = progress
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        selectedAnswers = Array(repeating: "", count: 10)
        showResult = false
        isQuizActive = true
        score = 0
    }
    
    private func backToMenu() {
        showResult = false
        isQuizActive = false
        selectedLanguageCode = nil
    }
}

// MARK: - Quiz Menu View
struct QuizMenuView: View {
    let userProgress: UserProgress
    let availableLanguages: [Language]
    let onStartQuiz: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 12) {
                Text("🧠 Translation Quiz")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Test your vocabulary knowledge with translation exercises")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Quiz Info
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Questions")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        Text("10")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryYellow)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Time Limit")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        Text("No limit")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryGreen)
                    }
                }
            }
            .padding(20)
            .neumorphic()
            
            // Language Selection
            VStack(alignment: .leading, spacing: 16) {
                Text("Choose Language to Practice")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 20)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(availableLanguages, id: \.id) { language in
                        QuizLanguageCard(language: language) {
                            onStartQuiz(language.code)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct QuizLanguageCard: View {
    let language: Language
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(language.flag)
                    .font(.largeTitle)
                
                Text(language.name)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text("10 Questions")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(16)
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .neumorphic()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Active Quiz View
struct QuizActiveView: View {
    let languageCode: String
    @Binding var currentQuestionIndex: Int
    @Binding var selectedAnswers: [String]
    let onQuizComplete: (Int) -> Void
    
    var body: some View {
        let questions = QuizQuestionData.getQuestionsForLanguage(languageCode)
        let currentQuestion = questions[currentQuestionIndex]
        
        VStack(spacing: 20) {
            // Progress Header
            VStack(spacing: 12) {
                HStack {
                    Text("Question \(currentQuestionIndex + 1) of 10")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button("Exit") {
                        onQuizComplete(0) // Exit with 0 score
                    }
                    .foregroundColor(.red)
                }
                
                ProgressView(value: Double(currentQuestionIndex + 1), total: 10.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .primaryYellow))
                    .scaleEffect(y: 3)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Question Card
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Text("Translate to English:")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Text(currentQuestion.word)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .neumorphic()
                
                // Answer Options
                VStack(spacing: 12) {
                    ForEach(0..<currentQuestion.options.count, id: \.self) { index in
                        QuizAnswerButton(
                            answer: currentQuestion.options[index],
                            isSelected: selectedAnswers[currentQuestionIndex] == currentQuestion.options[index],
                            onTap: {
                                selectedAnswers[currentQuestionIndex] = currentQuestion.options[index]
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Navigation
                HStack {
                    if currentQuestionIndex > 0 {
                        Button("Previous") {
                            currentQuestionIndex -= 1
                        }
                        .foregroundColor(.blue)
                        .padding()
                    }
                    
                    Spacer()
                    
                    if currentQuestionIndex < 9 {
                        Button("Next") {
                            if selectedAnswers[currentQuestionIndex].isEmpty {
                                return // Can't proceed without answer
                            }
                            currentQuestionIndex += 1
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .disabled(selectedAnswers[currentQuestionIndex].isEmpty)
                    } else {
                        Button("Finish") {
                            let finalScore = calculateScore(questions: questions)
                            onQuizComplete(finalScore)
                        }
                        .foregroundColor(.green)
                        .padding()
                        .disabled(selectedAnswers[currentQuestionIndex].isEmpty)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func calculateScore(questions: [QuizQuestionData]) -> Int {
        var correct = 0
        for (index, question) in questions.enumerated() {
            if selectedAnswers[index] == question.correctAnswer {
                correct += 1
            }
        }
        return correct
    }
}

struct QuizAnswerButton: View {
    let answer: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(answer)
                    .font(.headline)
                    .foregroundColor(isSelected ? .black : .textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.black)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.primaryYellow : Color.clear)
            )
            .neumorphic()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quiz Result View  
struct QuizResultView: View {
    let score: Int
    let total: Int
    let onRestart: () -> Void
    let onBackToMenu: () -> Void
    
    var percentage: Int {
        Int((Double(score) / Double(total)) * 100)
    }
    
    var gradeEmoji: String {
        switch percentage {
        case 90...100: return "🏆"
        case 80...89: return "🥇"
        case 70...79: return "🥈"
        case 60...69: return "🥉"
        default: return "📚"
        }
    }
    
    var gradeMessage: String {
        switch percentage {
        case 90...100: return "Excellent!"
        case 80...89: return "Great job!"
        case 70...79: return "Good work!"
        case 60...69: return "Not bad!"
        default: return "Keep practicing!"
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Result Header
            VStack(spacing: 16) {
                Text(gradeEmoji)
                    .font(.system(size: 80))
                
                Text(gradeMessage)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("\(percentage)%")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryYellow)
            }
            .padding(.top, 20)
            
            // Score Details
            VStack(spacing: 16) {
                HStack {
                    VStack {
                        Text("\(score)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryGreen)
                        Text("Correct")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("\(total - score)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("Wrong")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("\(total)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(20)
            .neumorphic()
            
            // Action Buttons
            VStack(spacing: 16) {
                Button(action: onRestart) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onBackToMenu) {
                    HStack {
                        Image(systemName: "house")
                        Text("Back to Menu")
                    }
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Quiz Question Data
struct QuizQuestionData {
    let word: String
    let options: [String]
    let correctAnswer: String
    
    static func getQuestionsForLanguage(_ code: String) -> [QuizQuestionData] {
        switch code {
        case "de":
            return [
                QuizQuestionData(word: "Hallo", options: ["Hello", "Goodbye", "Please", "Thank you"], correctAnswer: "Hello"),
                QuizQuestionData(word: "Danke", options: ["Please", "Sorry", "Thank you", "Excuse me"], correctAnswer: "Thank you"),
                QuizQuestionData(word: "Wasser", options: ["Fire", "Water", "Earth", "Air"], correctAnswer: "Water"),
                QuizQuestionData(word: "Haus", options: ["Car", "Tree", "House", "Book"], correctAnswer: "House"),
                QuizQuestionData(word: "Katze", options: ["Dog", "Cat", "Bird", "Fish"], correctAnswer: "Cat"),
                QuizQuestionData(word: "Brot", options: ["Bread", "Meat", "Milk", "Cheese"], correctAnswer: "Bread"),
                QuizQuestionData(word: "Schule", options: ["Hospital", "School", "Shop", "Restaurant"], correctAnswer: "School"),
                QuizQuestionData(word: "Auto", options: ["Bicycle", "Train", "Car", "Plane"], correctAnswer: "Car"),
                QuizQuestionData(word: "Buch", options: ["Pen", "Paper", "Book", "Table"], correctAnswer: "Book"),
                QuizQuestionData(word: "Zeit", options: ["Money", "Time", "Love", "Peace"], correctAnswer: "Time")
            ]
        case "fr":
            return [
                QuizQuestionData(word: "Bonjour", options: ["Good morning", "Good night", "Good luck", "Good bye"], correctAnswer: "Good morning"),
                QuizQuestionData(word: "Merci", options: ["Please", "Sorry", "Thank you", "Excuse me"], correctAnswer: "Thank you"),
                QuizQuestionData(word: "Eau", options: ["Fire", "Water", "Earth", "Air"], correctAnswer: "Water"),
                QuizQuestionData(word: "Maison", options: ["Car", "Tree", "House", "Book"], correctAnswer: "House"),
                QuizQuestionData(word: "Chat", options: ["Dog", "Cat", "Bird", "Fish"], correctAnswer: "Cat"),
                QuizQuestionData(word: "Pain", options: ["Bread", "Meat", "Milk", "Cheese"], correctAnswer: "Bread"),
                QuizQuestionData(word: "École", options: ["Hospital", "School", "Shop", "Restaurant"], correctAnswer: "School"),
                QuizQuestionData(word: "Voiture", options: ["Bicycle", "Train", "Car", "Plane"], correctAnswer: "Car"),
                QuizQuestionData(word: "Livre", options: ["Pen", "Paper", "Book", "Table"], correctAnswer: "Book"),
                QuizQuestionData(word: "Temps", options: ["Money", "Time", "Love", "Peace"], correctAnswer: "Time")
            ]
        case "it":
            return [
                QuizQuestionData(word: "Ciao", options: ["Hello", "Goodbye", "Please", "Thank you"], correctAnswer: "Hello"),
                QuizQuestionData(word: "Grazie", options: ["Please", "Sorry", "Thank you", "Excuse me"], correctAnswer: "Thank you"),
                QuizQuestionData(word: "Acqua", options: ["Fire", "Water", "Earth", "Air"], correctAnswer: "Water"),
                QuizQuestionData(word: "Casa", options: ["Car", "Tree", "House", "Book"], correctAnswer: "House"),
                QuizQuestionData(word: "Gatto", options: ["Dog", "Cat", "Bird", "Fish"], correctAnswer: "Cat"),
                QuizQuestionData(word: "Pane", options: ["Bread", "Meat", "Milk", "Cheese"], correctAnswer: "Bread"),
                QuizQuestionData(word: "Scuola", options: ["Hospital", "School", "Shop", "Restaurant"], correctAnswer: "School"),
                QuizQuestionData(word: "Macchina", options: ["Bicycle", "Train", "Car", "Plane"], correctAnswer: "Car"),
                QuizQuestionData(word: "Libro", options: ["Pen", "Paper", "Book", "Table"], correctAnswer: "Book"),
                QuizQuestionData(word: "Tempo", options: ["Money", "Time", "Love", "Peace"], correctAnswer: "Time")
            ]
        case "pl":
            return [
                QuizQuestionData(word: "Cześć", options: ["Hello", "Goodbye", "Please", "Thank you"], correctAnswer: "Hello"),
                QuizQuestionData(word: "Dziękuję", options: ["Please", "Sorry", "Thank you", "Excuse me"], correctAnswer: "Thank you"),
                QuizQuestionData(word: "Woda", options: ["Fire", "Water", "Earth", "Air"], correctAnswer: "Water"),
                QuizQuestionData(word: "Dom", options: ["Car", "Tree", "House", "Book"], correctAnswer: "House"),
                QuizQuestionData(word: "Kot", options: ["Dog", "Cat", "Bird", "Fish"], correctAnswer: "Cat"),
                QuizQuestionData(word: "Chleb", options: ["Bread", "Meat", "Milk", "Cheese"], correctAnswer: "Bread"),
                QuizQuestionData(word: "Szkoła", options: ["Hospital", "School", "Shop", "Restaurant"], correctAnswer: "School"),
                QuizQuestionData(word: "Samochód", options: ["Bicycle", "Train", "Car", "Plane"], correctAnswer: "Car"),
                QuizQuestionData(word: "Książka", options: ["Pen", "Paper", "Book", "Table"], correctAnswer: "Book"),
                QuizQuestionData(word: "Czas", options: ["Money", "Time", "Love", "Peace"], correctAnswer: "Time")
            ]
        case "tr":
            return [
                QuizQuestionData(word: "Merhaba", options: ["Hello", "Goodbye", "Please", "Thank you"], correctAnswer: "Hello"),
                QuizQuestionData(word: "Teşekkürler", options: ["Please", "Sorry", "Thank you", "Excuse me"], correctAnswer: "Thank you"),
                QuizQuestionData(word: "Su", options: ["Fire", "Water", "Earth", "Air"], correctAnswer: "Water"),
                QuizQuestionData(word: "Ev", options: ["Car", "Tree", "House", "Book"], correctAnswer: "House"),
                QuizQuestionData(word: "Kedi", options: ["Dog", "Cat", "Bird", "Fish"], correctAnswer: "Cat"),
                QuizQuestionData(word: "Ekmek", options: ["Bread", "Meat", "Milk", "Cheese"], correctAnswer: "Bread"),
                QuizQuestionData(word: "Okul", options: ["Hospital", "School", "Shop", "Restaurant"], correctAnswer: "School"),
                QuizQuestionData(word: "Araba", options: ["Bicycle", "Train", "Car", "Plane"], correctAnswer: "Car"),
                QuizQuestionData(word: "Kitap", options: ["Pen", "Paper", "Book", "Table"], correctAnswer: "Book"),
                QuizQuestionData(word: "Zaman", options: ["Money", "Time", "Love", "Peace"], correctAnswer: "Time")
            ]
        default:
            return []
        }
    }
}

#Preview {
    QuizView()
}