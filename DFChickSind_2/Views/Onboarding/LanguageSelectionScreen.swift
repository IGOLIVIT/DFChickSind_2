//
//  LanguageSelectionScreen.swift
//  DFChickSind_2
//
//  Created by AI Assistant on 2024
//

import SwiftUI

struct LanguageSelectionScreen: View {
    @Binding var selectedLanguage: String?
    let availableLanguages: [Language]
    
    @State private var animateContent = false
    @State private var searchText = ""
    
    var filteredLanguages: [Language] {
        if searchText.isEmpty {
            return availableLanguages
        }
        return availableLanguages.filter { language in
            language.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer(minLength: 20)
                
                // Header
                VStack(spacing: 16) {
                    Text("🌍")
                        .font(.system(size: 80))
                        .scaleEffect(animateContent ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateContent)
                    
                    Text("Choose Your Language")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                    
                    Text("Select the language you want to learn. Focus on one language for better results.")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateContent)
                }
                .padding(.horizontal, 30)
                
                // Search Bar
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.6))
                        
                        TextField("Search languages...", text: $searchText)
                            .font(.body)
                            .foregroundColor(.white)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.15))
                    )
                }
                .padding(.horizontal, 30)
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.8).delay(0.6), value: animateContent)
                
                // Selected Language
                if let selectedLanguage = selectedLanguage,
                   let language = availableLanguages.first(where: { $0.code == selectedLanguage }) {
                    HStack {
                        Text("\(language.flag) \(language.name)")
                            .font(.subheadline)
                            .foregroundColor(.primaryYellow)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.primaryYellow.opacity(0.2))
                            )
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Languages Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(filteredLanguages, id: \.id) { language in
                        LanguageSelectionCard(
                            language: language,
                            isSelected: selectedLanguage == language.code,
                            onTap: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    if selectedLanguage == language.code {
                                        selectedLanguage = nil // Deselect if tapping the same language
                                    } else {
                                        selectedLanguage = language.code // Select new language
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 30)
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 30)
                .animation(.easeOut(duration: 0.8).delay(0.8), value: animateContent)
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            animateContent = true
        }
        .animation(.default, value: selectedLanguage)
    }
}

struct LanguageSelectionCard: View {
    let language: Language
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Flag
                Text(language.flag)
                    .font(.system(size: 40))
                
                // Language Name
                Text(language.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Difficulty Badge
                Text(language.difficulty.rawValue)
                    .font(.caption)

                    .foregroundColor(difficultyColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(difficultyColor.opacity(0.2))
                    )
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.primaryYellow.opacity(0.3) : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.primaryYellow : Color.white.opacity(0.3),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(
                color: isSelected ? Color.primaryYellow.opacity(0.3) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isSelected)
    }
    
    private var difficultyColor: Color {
        switch language.difficulty {
        case .beginner: return .primaryGreen
        case .intermediate: return .primaryYellow
        case .advanced: return .orange
        case .expert: return .red
        }
    }
}

#Preview {
    LanguageSelectionScreen(
        selectedLanguage: .constant("es"),
        availableLanguages: [
            Language(name: "Spanish", code: "es", flag: "🇪🇸", difficulty: .beginner, description: "Learn Spanish"),
            Language(name: "French", code: "fr", flag: "🇫🇷", difficulty: .intermediate, description: "Learn French"),
            Language(name: "German", code: "de", flag: "🇩🇪", difficulty: .advanced, description: "Learn German"),
            Language(name: "Japanese", code: "ja", flag: "🇯🇵", difficulty: .expert, description: "Learn Japanese")
        ]
    )
    .background(
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#6b7db3"), Color(hex: "#4a5773")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
