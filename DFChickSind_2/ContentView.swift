//
//  ContentView.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import SwiftUI

enum MainTab: String, CaseIterable {
        case home = "Home"
        case map = "Map"
        case quiz = "Quiz"
        case hub = "Community"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .map: return "map.fill"
            case .quiz: return "questionmark.circle.fill"
            case .hub: return "person.3.fill"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .home: return "house.fill"
            case .map: return "map.fill"
            case .quiz: return "questionmark.circle.fill"
            case .hub: return "person.3.fill"
            }
        }
    }

struct ContentView: View {
    @State private var selectedTab: MainTab = .home
    
    var body: some View {
        MainTabView(selectedTab: $selectedTab)
            .onAppear {
                print("📱 ContentView: MainTabView loaded")
            }
        .appBackground()

    }
}

struct MainTabView: View {
    @Binding var selectedTab: MainTab
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(MainTab.home)
                
                LanguageMapView()
                    .tag(MainTab.map)
                
                QuizView()
                    .tag(MainTab.quiz)
                
                CollaborationHubView()
                    .tag(MainTab.hub)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            print("📱 MainTabView: Appeared, selected tab: \(selectedTab)")
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    
    var body: some View {
        HStack {
            ForEach(MainTab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    onTap: {
                        withAnimation(.smooth) {
                            selectedTab = tab
                        }
                    }
                )
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xl)
                .fill(Color.appBackground)
                .shadow(color: Color.neuDark, radius: 8, x: 0, y: -4)
                .shadow(color: Color.neuLight, radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.md)
    }
}

struct TabBarButton: View {
    let tab: MainTab
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .primaryYellow : .textSecondary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(tab.rawValue)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .primaryYellow : .textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(isSelected ? Color.primaryYellow.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .stroke(isSelected ? Color.primaryYellow.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.smooth, value: isSelected)
    }
}

// MARK: - Supporting Views

struct AppLoadingView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // App logo
            Image(systemName: "globe")
                .font(.system(size: 80))
                .foregroundColor(.primaryYellow)
                .glow(color: .primaryYellow, radius: 20)
            
            VStack(spacing: Spacing.sm) {
                Text("LinguisticBoost")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("Loading your language journey...")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryYellow))
                .scaleEffect(1.2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackground()
    }
}

struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.systemRed)
            
            VStack(spacing: Spacing.sm) {
                Text("Something went wrong")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
            
            Button("Try Again") {
                onRetry()
            }
            .primaryButtonStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackground()
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
