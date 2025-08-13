//
//  LearningGoalsScreen.swift
//  DFChickSind_2
//
//  Created by AI Assistant on 2024
//

import SwiftUI

struct LearningGoalsScreen: View {
    @Binding var learningGoals: Set<OnboardingGoal>
    @Binding var dailyGoalMinutes: Int
    
    @State private var animateContent = false
    
    private let dailyGoalOptions = [5, 10, 15, 30, 45, 60]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer(minLength: 20)
                
                // Header
                VStack(spacing: 16) {
                    Text("🎯")
                        .font(.system(size: 80))
                        .scaleEffect(animateContent ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateContent)
                    
                    Text("Set Your Goals")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                    
                    Text("Tell us why you want to learn languages and how much time you can dedicate daily.")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateContent)
                }
                .padding(.horizontal, 30)
                
                // Learning Goals Section
                VStack(spacing: 20) {
                    HStack {
                        Text("Why do you want to learn?")
                            .font(.headline)

                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(OnboardingGoal.allCases, id: \.self) { goal in
                            LearningGoalCard(
                                goal: goal,
                                isSelected: learningGoals.contains(goal),
                                onTap: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        if learningGoals.contains(goal) {
                                            learningGoals.remove(goal)
                                        } else {
                                            learningGoals.insert(goal)
                                        }
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
                
                // Daily Goal Section
                VStack(spacing: 20) {
                    HStack {
                        Text("Daily Study Goal")
                            .font(.headline)

                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    Text("How many minutes per day can you commit to learning?")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(dailyGoalOptions, id: \.self) { minutes in
                            DailyGoalCard(
                                minutes: minutes,
                                isSelected: dailyGoalMinutes == minutes,
                                onTap: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        dailyGoalMinutes = minutes
                                    }
                                }
                            )
                        }
                    }
                    
                    // Encouragement Message
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.primaryYellow)
                            Text("Pro Tip")
                                .font(.subheadline)
    
                                .foregroundColor(.primaryYellow)
                            Spacer()
                        }
                        
                        Text("Consistency is more important than duration. Even 5 minutes daily can lead to amazing progress!")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primaryYellow.opacity(0.1))
                    )
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
        .animation(.default, value: learningGoals)
        .animation(.default, value: dailyGoalMinutes)
    }
}

struct LearningGoalCard: View {
    let goal: OnboardingGoal
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: goal.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .black : .primaryYellow)
                
                // Title
                Text(goal.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(goal.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.primaryYellow.opacity(0.3) : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.primaryYellow : Color.white.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(
                color: isSelected ? Color.primaryYellow.opacity(0.3) : Color.clear,
                radius: isSelected ? 6 : 0,
                x: 0,
                y: isSelected ? 3 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isSelected)
    }
}

struct DailyGoalCard: View {
    let minutes: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text("\(minutes)")
                    .font(.title)

                    .foregroundColor(isSelected ? .black : .white)
                
                Text("min")
                    .font(.caption)
                    .foregroundColor(isSelected ? .black : .white.opacity(0.8))
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.primaryYellow : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.primaryYellow : Color.white.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.1 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isSelected)
    }
}

#Preview {
    LearningGoalsScreen(
        learningGoals: .constant(Set([OnboardingGoal.travel, OnboardingGoal.culture])),
        dailyGoalMinutes: .constant(15)
    )
    .background(
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#6b7db3"), Color(hex: "#4a5773")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
