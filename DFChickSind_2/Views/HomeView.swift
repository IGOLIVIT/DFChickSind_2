//
//  HomeView.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var languageDataService = LanguageDataService.shared
    @State private var userProgress: UserProgress = UserProgress.sampleProgress
    @State private var selectedLanguageForSheet: Language? = nil
    @State private var showSuccessAnimation = false
    @State private var showDailyGoalEditor = false
    @State private var tempDailyGoal = 15
    @State private var showCongratulation = false
    @State private var showProfileEditor = false
    
    enum HomeTab: String, CaseIterable {
        case overview = "Overview"
        case progress = "Progress"
        case achievements = "Achievements"
        case bookmarks = "Bookmarks"
        
        var icon: String {
            switch self {
            case .overview: return "house.fill"
            case .progress: return "chart.line.uptrend.xyaxis"
            case .achievements: return "trophy.fill"
            case .bookmarks: return "bookmark.fill"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with Profile Button
                VStack(spacing: 12) {
                    // Profile Edit Button at Top Right
                    HStack {
                        Spacer()
                        Button(action: {
                            showProfileEditor = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.crop.circle.badge.pencil")
                                    .font(.title3)
                                Text("Edit Profile")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    
                    // Welcome Header
                    VStack(spacing: 8) {
                        Text("🏠 Welcome back, \(userProgress.userName)!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Your language learning journey continues")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.top, 20)
                
                // Interactive User Stats Card
                VStack(spacing: 16) {
                    HStack {
                        // Tap to increase streak button
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                userProgress.streakCount += 1
                                showSuccessAnimation = true
                                saveUserProgress()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                showSuccessAnimation = false
                            }
                        }) {
                            VStack(alignment: .leading) {
                                Text("Daily Practice")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                HStack {
                                    Text("\(userProgress.streakCount)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primaryYellow)
                                    if showSuccessAnimation {
                                        Text("🔥")
                                            .font(.title2)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        // Shows actual study time from lessons
                        VStack(alignment: .trailing) {
                            Text("Study Time")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            Text("\(userProgress.totalStudyTime) min")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryGreen)
                        }
                    }
                    
                    // Lesson Study Time Info
                    HStack {
                        Text("Time is tracked from completed lessons")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                        Spacer()
                    }
                    
                    // Interactive Daily Goal Progress
                    VStack(spacing: 8) {
                        HStack {
                            Text("Daily Goal Progress")
                                .font(.subheadline)
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Button(action: {
                                tempDailyGoal = userProgress.dailyGoal
                                showDailyGoalEditor = true
                            }) {
                                HStack(spacing: 4) {
                                    Text("\(userProgress.totalStudyTime)/\(userProgress.dailyGoal) min")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                    Image(systemName: "pencil.circle")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        let progress = Double(userProgress.totalStudyTime) / Double(userProgress.dailyGoal)
                        let isGoalAchieved = userProgress.totalStudyTime >= userProgress.dailyGoal
                        
                        ProgressView(value: min(progress, 1.0))
                            .progressViewStyle(LinearProgressViewStyle(tint: isGoalAchieved ? .green : .blue))
                            .scaleEffect(y: 2)
                        
                        if isGoalAchieved && !showCongratulation {
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    showCongratulation = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showCongratulation = false
                                }
                            }) {
                                HStack {
                                    Text("🎉 Goal Achieved! Tap to celebrate")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        if showCongratulation {
                            VStack(spacing: 4) {
                                Text("🏆 Congratulations! 🏆")
                                    .font(.headline)
                                    .foregroundColor(.primaryYellow)
                                Text("You've reached your daily goal!")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            .padding(8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .padding(20)
                .neumorphic()
                
                // Interactive Available Languages
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Available Languages")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Text("Tap to learn!")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(languageDataService.languages, id: \.id) { language in
                            InteractiveLanguageCard(
                                language: language, 
                                isSelected: userProgress.selectedLanguages.contains(language.code),
                                onTap: {
                                    if language.isAvailable {
                                        handleLanguageTap(language)
                                    } else {
                                        print("🚧 Language not available: \(language.name)")
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
            .padding(.bottom, 20)
        }
        .appBackground()
        .sheet(item: $selectedLanguageForSheet) { language in
            SimpleLanguageDetailSheet(language: language, userProgress: $userProgress, onDismiss: {
                selectedLanguageForSheet = nil
            })
            .onAppear {
                print("🏠 Sheet opened for language: \(language.name)")
            }
        }
        .sheet(isPresented: $showDailyGoalEditor) {
            DailyGoalEditorSheet(dailyGoal: $tempDailyGoal, onSave: {
                userProgress.dailyGoal = tempDailyGoal
                saveUserProgress()
                showDailyGoalEditor = false
            }, onCancel: {
                showDailyGoalEditor = false
            })
        }
        .sheet(isPresented: $showProfileEditor) {
            ProfileEditorSheet(userProgress: $userProgress, onSave: {
                saveUserProgress()
                showProfileEditor = false
            }, onCancel: {
                showProfileEditor = false
            }, onDeleteProfile: {
                deleteUserProfile()
            })
        }
        .onAppear {
            print("🏠 HomeView: Functional version - onAppear called")
            loadUserProgress()
        }
    }
    
    private func loadUserProgress() {
        guard let data = UserDefaults.standard.data(forKey: "user_progress"),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            print("⚠️ HomeView: No saved user progress found, using sample data")
            return
        }
        userProgress = progress
        print("✅ HomeView: Loaded user progress:")
        print("   - User Name: '\(progress.userName)'")
        print("   - Selected Languages: \(progress.selectedLanguages)")
        print("   - Skill Levels: \(progress.languageSkillLevels)")
        print("   - Daily Goal: \(progress.dailyGoal) minutes")
        print("   - Study Time: \(progress.totalStudyTime) minutes")
    }
    
    private func saveUserProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: "user_progress")
        }
    }
    
    private func deleteUserProfile() {
        // Reset onboarding and clear all user data
        UserDefaults.standard.removeObject(forKey: "user_progress")
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "userLanguageSelection")
        UserDefaults.standard.removeObject(forKey: "contacts")
        
        print("🗑️ User profile deleted, all data cleared")
        
        // Reset to sample progress and close the sheet
        userProgress = UserProgress.sampleProgress
        showProfileEditor = false
        
        // Post notification to restart onboarding
        NotificationCenter.default.post(name: NSNotification.Name("ProfileDeleted"), object: nil)
    }
    
    private func handleLanguageTap(_ language: Language) {
        print("🏠 Tapped on language: \(language.name)")
        
        // Add to selected languages if not already added
        if !userProgress.selectedLanguages.contains(language.code) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                userProgress.selectedLanguages.append(language.code)
                saveUserProgress()
            }
        }
        
        // Show language details using item-based sheet
        selectedLanguageForSheet = language
        print("🏠 selectedLanguageForSheet set to: \(selectedLanguageForSheet?.name ?? "nil")")
    }
}

// MARK: - Header View
struct HomeHeaderView: View {
    let userProgress: UserProgress
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Welcome back!")
                        .font(.headline)
                        .foregroundColor(.textSecondary)
                    
                    Text("Ready to learn?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                // Streak display
                StreakDisplayView(streak: userProgress.currentStreak)
            }
            
            // Level progress
            LevelProgressView(level: userProgress.level)
        }
        .padding(Spacing.lg)
        .neumorphic()
    }
}

// MARK: - Tab Selector
struct HomeTabSelector: View {
    @Binding var selectedTab: HomeView.HomeTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeView.HomeTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.smooth) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: tab.icon)
                            .font(.headline)
                        
                        Text(tab.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == tab ? .primaryYellow : .textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xs)
        .neumorphicInset()
    }
}

// MARK: - Overview Tab Content
struct OverviewTabContent: View {
    let userProgress: UserProgress
    @Binding var showQuizSheet: Bool
    @Binding var showTopicSheet: Bool
    @StateObject private var languageDataService = LanguageDataService.shared
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Quick stats
            QuickStatsView(userProgress: userProgress)
            
            // Daily goal progress
            DailyGoalView(userProgress: userProgress)
            
            // Continue learning section
            ContinueLearningSection(
                showQuizSheet: $showQuizSheet,
                showTopicSheet: $showTopicSheet
            )
            
            // Recent activity
            RecentActivityView(userProgress: userProgress)
        }
    }
}

// MARK: - Progress Tab Content
struct ProgressTabContent: View {
    let userProgress: UserProgress
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Weekly progress
            WeeklyProgressView(userProgress: userProgress)
            
            // Language progress
            ForEach(userProgress.selectedLanguages, id: \.self) { languageCode in
                LanguageProgressCard(
                    progress: userProgress.getLanguageProgress(for: languageCode),
                    languageCode: languageCode
                )
            }
            
            // Study time chart
            StudyTimeChartView(userProgress: userProgress)
        }
    }
}

// MARK: - Achievements Tab Content
struct AchievementsTabContent: View {
    let userProgress: UserProgress
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Achievement summary
            AchievementSummaryView(achievements: userProgress.achievements)
            
            // Recent achievements
            RecentAchievementsView(achievements: userProgress.achievements)
            
            // Achievement categories
            AchievementCategoriesView(achievements: userProgress.achievements)
        }
    }
}

// MARK: - Bookmarks Tab Content
struct BookmarksTabContent: View {
    @StateObject private var languageDataService = LanguageDataService.shared
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            let bookmarkedPhrases = languageDataService.getBookmarkedPhrases()
            
            if bookmarkedPhrases.isEmpty {
                EmptyBookmarksView()
            } else {
                BookmarkedPhrasesView(phrases: bookmarkedPhrases)
            }
        }
    }
}

// MARK: - Supporting Views

struct StreakDisplayView: View {
    let streak: Int
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(streak)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }
            
            Text("day streak")
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
        .padding(Spacing.sm)
        .neumorphic()
    }
}

struct LevelProgressView: View {
    let level: UserLevel
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Text("Level \(level.level)")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text(level.title)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            ProgressView(value: level.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .primaryGreen))
                .scaleEffect(y: 2)
            
            HStack {
                Text("\(level.experiencePoints) XP")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text("\(level.experienceToNextLevel) to next level")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.md)
        .neumorphic()
    }
}

struct QuickStatsView: View {
    let userProgress: UserProgress
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            StatCard(
                title: "Total Study Time",
                value: "\(userProgress.totalStudyTime)m",
                icon: "clock.fill",
                color: .primaryYellow
            )
            
            StatCard(
                title: "Topics Completed",
                value: "\(userProgress.completedTopics.count)",
                icon: "checkmark.circle.fill",
                color: .primaryGreen
            )
            
            StatCard(
                title: "Quiz Results",
                value: "\(userProgress.quizResults.count)",
                icon: "star.fill",
                color: .systemBlue
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .neumorphic()
    }
}

struct DailyGoalView: View {
    let userProgress: UserProgress
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Text("Daily Goal")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(userProgress.totalStudyTime)/\(userProgress.dailyGoal) min")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            let progress = min(Double(userProgress.totalStudyTime) / Double(userProgress.dailyGoal), 1.0)
            
            ProgressRing(progress: progress, lineWidth: 12)
                .frame(width: 80, height: 80)
                .overlay(
                    Text("\(Int(progress * 100))%")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                )
        }
        .padding(Spacing.lg)
        .neumorphic()
    }
}

struct ContinueLearningSection: View {
    @Binding var showQuizSheet: Bool
    @Binding var showTopicSheet: Bool
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Text("Continue Learning")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            HStack(spacing: Spacing.md) {
                Button(action: { showQuizSheet = true }) {
                    ContinueLearningCard(
                        title: "Take Quiz",
                        description: "Test your knowledge",
                        icon: "questionmark.circle.fill",
                        color: .primaryYellow
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { showTopicSheet = true }) {
                    ContinueLearningCard(
                        title: "Study Topic",
                        description: "Learn something new",
                        icon: "book.fill",
                        color: .primaryGreen
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct ContinueLearningCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
        .neumorphic()
    }
}

struct RecentActivityView: View {
    let userProgress: UserProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            if userProgress.quizResults.isEmpty {
                Text("No recent activity")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .padding(Spacing.lg)
                    .frame(maxWidth: .infinity)
                    .neumorphic()
            } else {
                ForEach(userProgress.quizResults.suffix(3).reversed(), id: \.id) { result in
                    RecentActivityCard(result: result)
                }
            }
        }
    }
}

struct RecentActivityCard: View {
    let result: QuizResult
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "star.fill")
                .font(.title2)
                .foregroundColor(.primaryYellow)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Quiz Completed")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text("Score: \(Int(result.score))%")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Text(result.completedAt, style: .relative)
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding(Spacing.md)
        .neumorphic()
    }
}

struct WeeklyProgressView: View {
    let userProgress: UserProgress
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Text("This Week")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(Int(userProgress.weeklyProgress * 100))% of goal")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            ProgressView(value: userProgress.weeklyProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .primaryGreen))
                .scaleEffect(y: 3)
        }
        .padding(Spacing.lg)
        .neumorphic()
    }
}

struct LanguageProgressCard: View {
    let progress: LanguageProgress
    let languageCode: String
    @StateObject private var languageDataService = LanguageDataService.shared
    
    var body: some View {
        let language = languageDataService.languages.first { $0.code == languageCode }
        
        VStack(spacing: Spacing.md) {
            HStack {
                Text("\(language?.flag ?? "🌍") \(language?.name ?? languageCode.uppercased())")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text(progress.proficiencyLevel.rawValue)
                    .font(.caption)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.primaryYellow.opacity(0.2))
                    .foregroundColor(.primaryYellow)
                    .cornerRadius(CornerRadius.sm)
            }
            
            HStack(spacing: Spacing.lg) {
                VStack {
                    Text("\(progress.completedTopics)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Topics")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                VStack {
                    Text(String(format: "%.1f%%", progress.averageQuizScore))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Avg Score")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                VStack {
                    Text("\(progress.studyTime)m")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Study Time")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            ProgressView(value: progress.completionPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: .primaryGreen))
                .scaleEffect(y: 2)
        }
        .padding(Spacing.lg)
        .neumorphic()
    }
}

struct StudyTimeChartView: View {
    let userProgress: UserProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Study Time This Week")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            // Simple bar chart representation
            HStack(alignment: .bottom, spacing: Spacing.sm) {
                ForEach(0..<7) { day in
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.primaryYellow)
                            .frame(width: 30, height: CGFloat.random(in: 20...100))
                        
                        Text(dayOfWeek(day))
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .frame(height: 120)
        }
        .padding(Spacing.lg)
        .neumorphic()
    }
    
    private func dayOfWeek(_ index: Int) -> String {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days[index]
    }
}

struct AchievementSummaryView: View {
    let achievements: [Achievement]
    
    var body: some View {
        HStack(spacing: Spacing.lg) {
            VStack {
                Text("\(achievements.count)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryYellow)
                
                Text("Total")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            VStack {
                Text("\(achievements.filter { $0.rarity == .rare }.count)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.systemBlue)
                
                Text("Rare")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            VStack {
                Text("\(achievements.filter { $0.rarity == .epic }.count)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.systemPurple)
                
                Text("Epic")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.lg)
        .neumorphic()
    }
}

struct RecentAchievementsView: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recent Achievements")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            if achievements.isEmpty {
                Text("No achievements yet")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .padding(Spacing.lg)
                    .frame(maxWidth: .infinity)
                    .neumorphic()
            } else {
                ForEach(achievements.suffix(3).reversed(), id: \.id) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(Color(hex: achievement.rarity.color))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Text(achievement.rarity.rawValue)
                .font(.caption)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(Color(hex: achievement.rarity.color).opacity(0.2))
                .foregroundColor(Color(hex: achievement.rarity.color))
                .cornerRadius(CornerRadius.sm)
        }
        .padding(Spacing.md)
        .neumorphic()
    }
}

struct AchievementCategoriesView: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Categories")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Spacing.md) {
                ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                    CategoryCard(
                        category: category,
                        count: achievements.filter { $0.category == category }.count
                    )
                }
            }
        }
    }
}

struct CategoryCard: View {
    let category: Achievement.AchievementCategory
    let count: Int
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text("\(count)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primaryYellow)
            
            Text(category.rawValue)
                .font(.headline)
                .foregroundColor(.textPrimary)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .neumorphic()
    }
}

struct EmptyBookmarksView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "bookmark")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("No Bookmarks Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text("Start bookmarking phrases and words as you learn to create your personal study guide.")
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
        }
        .padding(Spacing.xl)
        .neumorphic()
    }
}

struct BookmarkedPhrasesView: View {
    let phrases: [Phrase]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Bookmarked Phrases")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            ForEach(phrases.prefix(5), id: \.id) { phrase in
                BookmarkedPhraseCard(phrase: phrase)
            }
            
            if phrases.count > 5 {
                Button("View All Bookmarks") {
                    // Navigate to full bookmarks view
                }
                .primaryButtonStyle()
            }
        }
    }
}

struct BookmarkedPhraseCard: View {
    let phrase: Phrase
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(phrase.original)
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text(phrase.translation)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            HStack {
                Text(phrase.category)
                    .font(.caption)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.primaryYellow.opacity(0.2))
                    .foregroundColor(.primaryYellow)
                    .cornerRadius(CornerRadius.sm)
                
                Spacer()
                
                Button(action: {
                    // Toggle bookmark
                    LanguageDataService.shared.bookmarkPhrase(phrase.id.uuidString)
                }) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.primaryYellow)
                }
            }
        }
        .padding(Spacing.md)
        .neumorphic()
    }
}

// MARK: - Language Card
struct LanguageCard: View {
    let language: Language
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(language.flag)
                .font(.largeTitle)
            
            Text(language.name)
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text(language.difficulty.rawValue)
                .font(.caption)
                .foregroundColor(isSelected ? .primaryGreen : .textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.primaryGreen.opacity(0.2) : Color.clear)
                )
        }
        .padding(16)
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .neumorphic()
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(isSelected ? Color.primaryGreen : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Sheet Views
struct QuizSelectionSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Text("Quiz Selection")
                .font(.title)
                .navigationTitle("Select Quiz")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
        .appBackground()
    }
}

struct TopicSelectionSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Text("Topic Selection")
                .font(.title)
                .navigationTitle("Select Topic")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
        .appBackground()
    }
}

// MARK: - Simple Interactive Components
struct InteractiveLanguageCard: View {
    let language: Language
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Text(language.flag)
                        .font(.largeTitle)
                        .opacity(language.isAvailable ? 1.0 : 0.5)
                    
                    if !language.isAvailable {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                
                Text(language.name)
                    .font(.headline)
                    .foregroundColor(language.isAvailable ? .textPrimary : .textSecondary)
                
                HStack {
                    Text(language.isAvailable ? language.difficulty.rawValue : "Coming Soon")
                        .font(.caption)
                        .foregroundColor(isSelected ? .primaryGreen : .textSecondary)
                    
                    if isSelected && language.isAvailable {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.primaryGreen)
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.primaryGreen.opacity(0.2) : Color.clear)
                )
            }
            .padding(16)
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .neumorphic()
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(isSelected ? Color.primaryGreen : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .opacity(language.isAvailable ? 1.0 : 0.7)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!language.isAvailable)
    }
}

struct SimpleLanguageDetailSheet: View {
    let language: Language
    @Binding var userProgress: UserProgress
    let onDismiss: () -> Void
    
    private func completeLesson(_ lesson: LanguageLesson) {
        // Add study time from completed lesson
        userProgress.totalStudyTime += lesson.estimatedMinutes
        print("📖 Completed lesson: \(lesson.title) (+\(lesson.estimatedMinutes) minutes)")
        
        // Save progress
        if let encoded = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(encoded, forKey: "user_progress")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Language Header
                    VStack(spacing: 16) {
                        Text(language.flag)
                            .font(.system(size: 80))
                        
                        Text(language.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        
                        Text(language.description)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    // Language Lessons
                    VStack(alignment: .leading, spacing: 16) {
                        Text("📚 Reading Lessons")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 20)
                        
                        if language.isAvailable {
                            VStack(spacing: 8) {
                                ForEach(language.lessons, id: \.id) { lesson in
                                    SimpleLessonRow(
                                        lesson: lesson,
                                        onComplete: completeLesson
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 12) {
                                Text("🚧")
                                    .font(.system(size: 40))
                                Text("Coming Soon")
                                    .font(.headline)
                                    .foregroundColor(.textSecondary)
                                Text("This language will be available in a future update.")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .neumorphic()
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle(language.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                onDismiss()
            })
        }
    }
}

struct SimpleActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(16)
            .neumorphic()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SimpleLessonRow: View {
    let lesson: LanguageLesson
    let onComplete: (LanguageLesson) -> Void
    @State private var isCompleted = false
    @State private var isExpanded = false
    @State private var studyCount = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack(spacing: 12) {
                Text("📖")
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    Text("\(lesson.estimatedMinutes) min")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                // Expand/Collapse indicator
                if !isCompleted {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .padding(.trailing, 8)
                }
                
                if !isCompleted {
                    Button(action: {
                        if !isExpanded {
                            // First tap - show content
                            isExpanded = true
                            print("📖 Opened lesson: \(lesson.title)")
                        } else {
                            // Second tap - complete lesson
                            isCompleted = true
                            studyCount += 1
                            onComplete(lesson)
                            print("✅ Completed lesson: \(lesson.title) (Study #\(studyCount))")
                        }
                    }) {
                        Text(isExpanded ? "Complete" : "Start")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isExpanded ? Color.green : Color.blue)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        Button(action: {
                            // Reset lesson for studying again
                            isCompleted = false
                            isExpanded = false
                            print("🔄 Reset lesson for study again: \(lesson.title) (Total studies: \(studyCount))")
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.caption2)
                                Text(studyCount > 1 ? "Study Again (\(studyCount)x)" : "Study Again")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange)
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // Lesson Content - shown when expanded
            if isExpanded && !isCompleted {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                    
                    Text("📚 Lesson Content")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Text(lesson.content)
                        .font(.body)
                        .foregroundColor(.textPrimary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color.gray.opacity(isExpanded ? 0.15 : 0.1))
        .cornerRadius(12)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

struct DailyGoalEditorSheet: View {
    @Binding var dailyGoal: Int
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Text("🎯")
                        .font(.system(size: 60))
                    
                    Text("Set Your Daily Goal")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("How many minutes would you like to study each day?")
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                VStack(spacing: 20) {
                    Text("\(dailyGoal) minutes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryYellow)
                    
                    Slider(value: Binding(
                        get: { Double(dailyGoal) },
                        set: { dailyGoal = Int($0) }
                    ), in: 5...120, step: 5)
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Text("5 min")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        Spacer()
                        Text("120 min")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(20)
                .neumorphic()
                
                Spacer()
            }
            .padding(20)
            .appBackground()
            .navigationTitle("Daily Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ProfileEditorSheet: View {
    @Binding var userProgress: UserProgress
    let onSave: () -> Void
    let onCancel: () -> Void
    let onDeleteProfile: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var editedUserName: String = ""
    @State private var editedDailyGoal: Int = 15
    @State private var editedWeeklyGoal: Int = 105
    @State private var selectedLanguages: [String] = []
    @State private var languageSkillLevels: [String: Language.LanguageDifficulty] = [:]
    @State private var showDeleteAlert = false
    
    @StateObject private var languageDataService = LanguageDataService.shared
    
    var body: some View {
        NavigationView {
            profileEditorContent
                .appBackground()
                .navigationTitle("Edit Profile")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        onCancel()
                    },
                    trailing: Button("Save") {
                        saveChanges()
                    }
                    .disabled(editedUserName.isEmpty || selectedLanguages.isEmpty)
                )
                .alert("Delete Profile", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete Everything", role: .destructive) {
                        onDeleteProfile()
                    }
                } message: {
                    Text("This will permanently delete your profile, progress, and all data. This action cannot be undone.")
                }
        }
        .onAppear {
            loadCurrentData()
        }
    }
    
    private var profileEditorContent: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 20) {
                profileInfoSection
                goalsSection
                languagesSection
                dangerZoneSection
                Spacer(minLength: 100)
            }
            .padding(20)
        }
    }
    
    private var profileInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profile Information")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            TextField("Your name", text: $editedUserName)
                .padding()
                .neumorphic()
        }
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Study Goals")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Daily Goal")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    Stepper("\(editedDailyGoal) minutes", value: $editedDailyGoal, in: 5...180, step: 5)
                        .padding()
                        .neumorphic()
                }
                
                VStack(alignment: .leading) {
                    Text("Weekly Goal")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    Stepper("\(editedWeeklyGoal) minutes", value: $editedWeeklyGoal, in: 35...1260, step: 35)
                        .padding()
                        .neumorphic()
                }
            }
        }
    }
    
    private var languagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Languages & Skills")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ForEach(languageDataService.languages.filter { $0.isAvailable }, id: \.id) { language in
                languageRow(for: language)
            }
        }
    }
    
    private func languageRow(for language: Language) -> some View {
        HStack {
            HStack {
                Text(language.flag)
                    .font(.title2)
                Text(language.name)
                    .font(.body)
                    .foregroundColor(.textPrimary)
                Spacer()
            }
            
            Button(action: {
                toggleLanguageSelection(language)
            }) {
                Image(systemName: selectedLanguages.contains(language.code) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selectedLanguages.contains(language.code) ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
            
            if selectedLanguages.contains(language.code) {
                Picker("Level", selection: Binding(
                    get: { languageSkillLevels[language.code] ?? .beginner },
                    set: { languageSkillLevels[language.code] = $0 }
                )) {
                    Text("Beginner").tag(Language.LanguageDifficulty.beginner)
                    Text("Intermediate").tag(Language.LanguageDifficulty.intermediate)
                    Text("Advanced").tag(Language.LanguageDifficulty.advanced)
                    Text("Expert").tag(Language.LanguageDifficulty.expert)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 120)
            }
        }
        .padding()
        .neumorphic()
    }
    
    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Danger Zone")
                .font(.headline)
                .foregroundColor(.red)
            
            Button(action: {
                showDeleteAlert = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete Profile & All Data")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func loadCurrentData() {
        editedUserName = userProgress.userName
        editedDailyGoal = userProgress.dailyGoal
        editedWeeklyGoal = userProgress.weeklyGoal
        selectedLanguages = userProgress.selectedLanguages
        languageSkillLevels = userProgress.languageSkillLevels
    }
    
    private func saveChanges() {
        userProgress.userName = editedUserName
        userProgress.dailyGoal = editedDailyGoal
        userProgress.weeklyGoal = editedWeeklyGoal
        userProgress.selectedLanguages = selectedLanguages
        userProgress.languageSkillLevels = languageSkillLevels
        
        onSave()
    }
    
    private func toggleLanguageSelection(_ language: Language) {
        if selectedLanguages.contains(language.code) {
            selectedLanguages.removeAll { $0 == language.code }
            languageSkillLevels.removeValue(forKey: language.code)
        } else {
            selectedLanguages.append(language.code)
            languageSkillLevels[language.code] = .beginner
        }
    }
}

#Preview {
    HomeView()
}
