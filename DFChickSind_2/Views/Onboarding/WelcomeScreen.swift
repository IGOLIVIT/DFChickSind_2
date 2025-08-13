//
//  WelcomeScreen.swift
//  DFChickSind_2
//
//  Created by AI Assistant on 2024
//

import SwiftUI

struct WelcomeScreen: View {
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var animateFeatures = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer(minLength: 40)
                
                // App Logo and Title
                VStack(spacing: 20) {
                    // App Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.primaryYellow, Color.primaryGreen]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Text("🌍")
                            .font(.system(size: 60))
                    }
                    .scaleEffect(animateTitle ? 1.0 : 0.8)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateTitle)
                    
                    // App Name
                    Text("LinguisticBoost")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .opacity(animateTitle ? 1.0 : 0.0)
                        .offset(y: animateTitle ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: animateTitle)
                    
                    // Subtitle
                    Text("Master languages with confidence")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .opacity(animateSubtitle ? 1.0 : 0.0)
                        .offset(y: animateSubtitle ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateSubtitle)
                }
                
                // Features
                VStack(spacing: 24) {
                    WelcomeFeature(
                        icon: "person.3.fill",
                        title: "Learn Together",
                        description: "Connect with native speakers and fellow learners worldwide"
                    )
                    .opacity(animateFeatures ? 1.0 : 0.0)
                    .offset(x: animateFeatures ? 0 : -30)
                    .animation(.easeOut(duration: 0.6).delay(0.9), value: animateFeatures)
                    
                    WelcomeFeature(
                        icon: "brain.head.profile",
                        title: "Smart Learning",
                        description: "Adaptive quizzes and personalized learning paths"
                    )
                    .opacity(animateFeatures ? 1.0 : 0.0)
                    .offset(x: animateFeatures ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(1.1), value: animateFeatures)
                    
                    WelcomeFeature(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Track Progress",
                        description: "Monitor your learning journey with detailed analytics"
                    )
                    .opacity(animateFeatures ? 1.0 : 0.0)
                    .offset(x: animateFeatures ? 0 : -30)
                    .animation(.easeOut(duration: 0.6).delay(1.3), value: animateFeatures)
                }
                .padding(.horizontal, 30)
                
                Spacer(minLength: 80)
            }
        }
        .onAppear {
            animateTitle = true
            animateSubtitle = true
            animateFeatures = true
        }
    }
}

struct WelcomeFeature: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.primaryYellow)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                                            .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

#Preview {
    WelcomeScreen()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#6b7db3"), Color(hex: "#4a5773")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
