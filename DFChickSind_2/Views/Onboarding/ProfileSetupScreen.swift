//
//  ProfileSetupScreen.swift
//  DFChickSind_2
//
//  Created by AI Assistant on 2024
//

import SwiftUI

struct ProfileSetupScreen: View {
    @Binding var userName: String
    @State private var animateContent = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer(minLength: 40)
                
                // Header
                VStack(spacing: 16) {
                    Text("👋")
                        .font(.system(size: 80))
                        .scaleEffect(animateContent ? 1.0 : 0.8)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateContent)
                    
                    Text("Let's get to know you!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                    
                    Text("Tell us your name so we can personalize your learning experience")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateContent)
                }
                .padding(.horizontal, 30)
                
                // Profile Avatar
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.primaryYellow, Color.primaryGreen]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        if userName.isEmpty {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        } else {
                            Text(String(userName.prefix(1)).uppercased())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .scaleEffect(animateContent ? 1.0 : 0.8)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.6), value: animateContent)
                }
                
                // Name Input
                VStack(spacing: 16) {
                    HStack {
                        Text("Your Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    TextField("Enter your name", text: $userName)
                        .font(.title2)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.15))
                        )
                        .foregroundColor(.white)
                        .focused($isTextFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            isTextFieldFocused = false
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primaryYellow.opacity(isTextFieldFocused ? 0.8 : 0.3), lineWidth: 2)
                        )
                        .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                }
                .padding(.horizontal, 30)
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 30)
                .animation(.easeOut(duration: 0.8).delay(0.8), value: animateContent)
                
                // Tips
                VStack(spacing: 12) {
                    ProfileTip(
                        icon: "sparkles",
                        text: "Your name will be visible to other learners in the community"
                    )
                    
                    ProfileTip(
                        icon: "shield.fill",
                        text: "You can change your name anytime in settings"
                    )
                }
                .padding(.horizontal, 30)
                .opacity(animateContent ? 1.0 : 0.0)
                .offset(y: animateContent ? 0 : 30)
                .animation(.easeOut(duration: 0.8).delay(1.0), value: animateContent)
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            animateContent = true
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}

struct ProfileTip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.primaryYellow)
                .frame(width: 20)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
        )
    }
}

#Preview {
    ProfileSetupScreen(userName: .constant(""))
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#6b7db3"), Color(hex: "#4a5773")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
