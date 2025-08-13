//
//  OnboardingView.swift
//  DFChickSind_2
//
//  Created by AI Assistant on 2024
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var languageDataService: LanguageDataService
    @State private var currentStep = 0
    @State private var userName = ""
    @State private var selectedLanguage: String? = nil
    @State private var languageSkillLevels: [String: Language.LanguageDifficulty] = [:]
    @State private var learningGoals: Set<OnboardingGoal> = []
    @State private var dailyGoalMinutes = 15
    @State private var onboardingCompleted = false
    
    let totalSteps = 5
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#6b7db3"),
                    Color(hex: "#4a5773")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                OnboardingProgressBar(currentStep: currentStep, totalSteps: totalSteps)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                
                // Content
                TabView(selection: $currentStep) {
                    WelcomeScreen()
                        .tag(0)
                    
                    ProfileSetupScreen(userName: $userName)
                        .tag(1)
                    
                    LanguageSelectionScreen(
                        selectedLanguage: $selectedLanguage,
                        availableLanguages: languageDataService.languages
                    )
                    .tag(2)
                    
                    SkillLevelScreen(
                        selectedLanguage: selectedLanguage,
                        skillLevels: $languageSkillLevels
                    )
                    .tag(3)
                    
                    LearningGoalsScreen(
                        learningGoals: $learningGoals,
                        dailyGoalMinutes: $dailyGoalMinutes
                    )
                    .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation Buttons
                OnboardingNavigationButtons(
                    currentStep: $currentStep,
                    totalSteps: totalSteps,
                    canProceed: canProceedToNextStep(),
                    onComplete: completeOnboarding
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            print("🎯 Onboarding: Started")
        }
    }
    
    private func canProceedToNextStep() -> Bool {
        switch currentStep {
        case 0: return true // Welcome screen
        case 1: return !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 2: return selectedLanguage != nil
        case 3: return selectedLanguage != nil && languageSkillLevels[selectedLanguage!] != nil
        case 4: return !learningGoals.isEmpty
        default: return false
        }
    }
    
    private func completeOnboarding() {
        print("🎯 Completing onboarding...")
        
        // Create user progress with onboarding data
        let userPreferences = UserPreferences(
            notificationsEnabled: true,
            dailyReminderTime: Date(),
            weeklyReportEnabled: true,
            soundEnabled: true,
            hapticFeedbackEnabled: true,
            preferredStudyTime: .flexible,
            difficultyPreference: .beginner,
            learningStyle: .mixed
        )
        
        let userProgress = UserProgress(
            userId: UUID().uuidString,
            userName: userName.trimmingCharacters(in: .whitespacesAndNewlines),
            selectedLanguages: selectedLanguage != nil ? [selectedLanguage!] : [],
            languageSkillLevels: languageSkillLevels,
            completedTopics: [],
            bookmarkedPhrases: [],
            quizResults: [],
            streakCount: 0,
            lastActiveDate: Date(),
            totalStudyTime: 0,
            level: UserLevel(level: 1, experiencePoints: 0, experienceToNextLevel: 1000),
            achievements: [],
            weeklyGoal: dailyGoalMinutes * 7,
            dailyGoal: dailyGoalMinutes,
            preferences: userPreferences
        )
        
        // Save to UserDefaults
        saveUserProgress(userProgress)
        
        // Save learning goals and preferences
        saveLearningPreferences()
        
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onboardingCompleted = true
        
        // Notify the app that onboarding is completed
        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
        
        print("✅ Onboarding completed successfully!")
        
        // Debug: Print what was saved
        print("📝 Onboarding Debug:")
        print("   - User Name: '\(userName)'")
        print("   - Selected Language: '\(selectedLanguage ?? "none")'")
        print("   - Skill Levels: \(languageSkillLevels)")
        print("   - Learning Goals: \(learningGoals.map { $0.rawValue })")
        print("   - Daily Goal: \(dailyGoalMinutes) minutes")
        print("   - Weekly Goal: \(dailyGoalMinutes * 7) minutes")
    }
    
    private func saveUserProgress(_ userProgress: UserProgress) {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: "user_progress")
        }
    }
    
    private func saveLearningPreferences() {
        let preferences = LearningPreferences(
            goals: Array(learningGoals),
            dailyGoalMinutes: dailyGoalMinutes,
            preferredStudyTime: .evening, // Default
            notificationsEnabled: true
        )
        
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: "learning_preferences")
        }
    }
}

// MARK: - Supporting Models

enum OnboardingGoal: String, CaseIterable, Codable {
    case travel = "Travel"
    case business = "Business"
    case education = "Education"
    case culture = "Culture"
    case family = "Family"
    case career = "Career"
    case hobby = "Hobby"
    case immigration = "Immigration"
    
    var icon: String {
        switch self {
        case .travel: return "airplane"
        case .business: return "briefcase.fill"
        case .education: return "graduationcap.fill"
        case .culture: return "globe"
        case .family: return "house.fill"
        case .career: return "chart.line.uptrend.xyaxis"
        case .hobby: return "heart.fill"
        case .immigration: return "location.fill"
        }
    }
    
    var description: String {
        switch self {
        case .travel: return "Communicate while traveling"
        case .business: return "Professional communication"
        case .education: return "Academic purposes"
        case .culture: return "Cultural understanding"
        case .family: return "Family connections"
        case .career: return "Career advancement"
        case .hobby: return "Personal interest"
        case .immigration: return "Living in new country"
        }
    }
}

enum StudyTime: String, CaseIterable, Codable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case night = "Night"
}

struct LearningPreferences: Codable {
    let goals: [OnboardingGoal]
    let dailyGoalMinutes: Int
    let preferredStudyTime: StudyTime
    let notificationsEnabled: Bool
}

#Preview {
    OnboardingView()
        .environmentObject(LanguageDataService.shared)
}
