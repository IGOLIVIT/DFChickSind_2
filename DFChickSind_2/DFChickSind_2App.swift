//
//  DFChickSind_2App.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import SwiftUI

@main
struct LinguisticBoostApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                        .environmentObject(LanguageDataService.shared)
                        .onReceive(NotificationCenter.default.publisher(for: .profileDeleted)) { _ in
                            hasCompletedOnboarding = false
                        }
                } else {
                    OnboardingView()
                        .environmentObject(LanguageDataService.shared)
                        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                            hasCompletedOnboarding = true
                        }
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                setupApp()
            }
        }
    }
    
    private func setupApp() {
        print("🚀 App: Starting setup...")
        
        // Configure notification service
        NotificationService.shared.requestNotificationPermission()
        
        // DEBUG: Uncomment to reset app state for testing
        // resetAppState() // Отключено для тестирования онбординга
        
        // Load language data - try saved first, then load initial data if none exists
        LanguageDataService.shared.loadSavedData()
        print("📊 App: After loadSavedData - Languages: \(LanguageDataService.shared.languages.count)")
        
        // If no data was loaded from UserDefaults, load initial sample data
        if LanguageDataService.shared.languages.isEmpty {
            print("⚠️ App: No languages found, loading initial data...")
            LanguageDataService.shared.loadInitialData()
        }
        
        print("📊 App: Final - Languages: \(LanguageDataService.shared.languages.count)")
        
        // Check for existing user progress
        if UserDefaults.standard.data(forKey: "user_progress") != nil {
            hasCompletedOnboarding = true
            print("✅ App: Found existing user progress, onboarding completed")
        } else {
            hasCompletedOnboarding = false
            print("🆕 App: No user progress found, onboarding required")
        }
        
        print("🎯 App: Setup completed - hasCompletedOnboarding: \(hasCompletedOnboarding)")
    }
    
    private func resetAppState() {
        UserDefaults.standard.removeObject(forKey: "user_progress")
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "languages")
        UserDefaults.standard.removeObject(forKey: "topics")
        UserDefaults.standard.removeObject(forKey: "phrases")
        UserDefaults.standard.removeObject(forKey: "quizzes")
        print("🔄 App state reset for testing")
    }
    
    private func createSampleUserProgress() {
        let sampleProgress = UserProgress.sampleProgress
        do {
            let data = try JSONEncoder().encode(sampleProgress)
            UserDefaults.standard.set(data, forKey: "user_progress")
        } catch {
            print("Failed to create sample user progress: \(error)")
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
    static let profileDeleted = Notification.Name("ProfileDeleted")
}
