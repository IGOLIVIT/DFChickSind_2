//
//  SkillLevelScreen.swift
//  DFChickSind_2
//
//  Created by AI Assistant on 2024
//

import SwiftUI

struct SkillLevelScreen: View {
    let selectedLanguage: String?
    @Binding var skillLevels: [String: Language.LanguageDifficulty]
    
    @EnvironmentObject var languageDataService: LanguageDataService
    @State private var animateContent = false
    @State private var currentLanguageIndex = 0
    
    private var currentLanguage: Language? {
        guard let selectedLanguage = selectedLanguage else { return nil }
        return languageDataService.languages.first { $0.code == selectedLanguage }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer(minLength: 20)
                
                // Header
                VStack(spacing: 16) {
                    Text("📊")
                        .font(.system(size: 80))
                        .scaleEffect(animateContent ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateContent)
                    
                    Text("What's Your Level?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                    
                    Text("Help us personalize your learning experience by selecting your current skill level for each language.")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateContent)
                }
                .padding(.horizontal, 30)
                
                // Single Language - No Progress Indicator Needed
                
                // Current Language Card
                if let language = currentLanguage {
                    VStack(spacing: 24) {
                        // Language Info
                        VStack(spacing: 16) {
                            Text(language.flag)
                                .font(.system(size: 60))
                            
                            Text(language.name)
                                .font(.title)
                                .foregroundColor(.white)
                            
                            Text("Choose your skill level")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                        
                        // Skill Level Options
                        VStack(spacing: 16) {
                            ForEach(Language.LanguageDifficulty.allCases, id: \.self) { level in
                                SkillLevelCard(
                                    level: level,
                                    isSelected: skillLevels[language.code] == level,
                                    onTap: {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            skillLevels[language.code] = level
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .opacity(animateContent ? 1.0 : 0.0)
                    .offset(y: animateContent ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: animateContent)
                }
                
                // Navigation Buttons
                if false { // Disabled for single language
                    HStack(spacing: 16) {
                        if currentLanguageIndex > 0 {
                            Button("Previous") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentLanguageIndex -= 1
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.2))
                            )
                        }
                        
                        Spacer()
                        
                        if false && // Disabled for single language 
                           skillLevels[currentLanguage?.code ?? ""] != nil {
                            Button("Next") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentLanguageIndex += 1
                                }
                            }
                            .font(.headline)
    
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.primaryYellow)
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                }
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            animateContent = true
        }
    }
}

struct SkillLevelCard: View {
    let level: Language.LanguageDifficulty
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Level Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.primaryYellow : Color.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(levelIcon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .black : .white)
                }
                
                // Level Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(levelDescription)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .primaryYellow : .white.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.primaryYellow.opacity(0.2) : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.primaryYellow : Color.white.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isSelected)
    }
    
    private var levelIcon: String {
        switch level {
        case .beginner: return "🌱"
        case .intermediate: return "🌿"
        case .advanced: return "🌳"
        case .expert: return "🎯"
        }
    }
    
    private var levelDescription: String {
        switch level {
        case .beginner: return "Just starting out, know very basic words"
        case .intermediate: return "Can have simple conversations"
        case .advanced: return "Comfortable with complex topics"
        case .expert: return "Near-native or native level"
        }
    }
}

#Preview {
    SkillLevelScreen(
        selectedLanguage: "es",
        skillLevels: .constant(["es": Language.LanguageDifficulty.beginner])
    )
    .environmentObject(LanguageDataService.shared)
    .background(
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#6b7db3"), Color(hex: "#4a5773")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
