//
//  OnboardingComponents.swift
//  DFChickSind_2
//
//  Created by AI Assistant on 2024
//

import SwiftUI

// MARK: - Progress Bar
struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    private var progress: Double {
        return Double(currentStep) / Double(totalSteps - 1)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryYellow)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.primaryYellow, Color.primaryGreen]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Navigation Buttons
struct OnboardingNavigationButtons: View {
    @Binding var currentStep: Int
    let totalSteps: Int
    let canProceed: Bool
    let onComplete: () -> Void
    
    private var isLastStep: Bool {
        currentStep >= totalSteps - 1
    }
    
    private var isFirstStep: Bool {
        currentStep <= 0
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Back Button
            if !isFirstStep {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                        Text("Back")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            } else {
                Spacer()
                    .frame(width: 80)
            }
            
            Spacer()
            
            // Next/Complete Button
            Button(action: {
                if isLastStep {
                    onComplete()
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                }
            }) {
                HStack(spacing: 8) {
                    Text(isLastStep ? "Complete" : "Next")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if !isLastStep {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    } else {
                        Image(systemName: "checkmark")
                            .font(.caption)
                    }
                }
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(canProceed ? Color.primaryYellow : Color.gray.opacity(0.5))
                )
                .scaleEffect(canProceed ? 1.0 : 0.95)
                .animation(.easeInOut(duration: 0.2), value: canProceed)
            }
            .disabled(!canProceed)
        }
    }
}

// MARK: - Skip Button
struct OnboardingSkipButton: View {
    let onSkip: () -> Void
    
    var body: some View {
        Button(action: onSkip) {
            Text("Skip")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Completion Animation
struct OnboardingCompletionView: View {
    @State private var animateCheckmark = false
    @State private var animateText = false
    @State private var animateParticles = false
    
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Success Animation
            ZStack {
                // Particles
                if animateParticles {
                    ForEach(0..<12, id: \.self) { index in
                        Circle()
                            .fill(Color.primaryYellow)
                            .frame(width: 8, height: 8)
                            .offset(
                                x: CGFloat(cos(Double(index) * .pi / 6)) * 60,
                                y: CGFloat(sin(Double(index) * .pi / 6)) * 60
                            )
                            .opacity(animateParticles ? 0.0 : 1.0)
                            .animation(
                                .easeOut(duration: 1.0).delay(Double(index) * 0.1),
                                value: animateParticles
                            )
                    }
                }
                
                // Checkmark Circle
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
                        .scaleEffect(animateCheckmark ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateCheckmark)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)
                        .scaleEffect(animateCheckmark ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateCheckmark)
                }
            }
            
            // Success Text
            VStack(spacing: 16) {
                Text("🎉 Welcome to LinguisticBoost!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.5), value: animateText)
                
                Text("Your language learning journey starts now. Let's make every day count!")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.7), value: animateText)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Continue Button
            Button(action: onContinue) {
                Text("Start Learning")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primaryYellow)
                    )
            }
            .opacity(animateText ? 1.0 : 0.0)
            .offset(y: animateText ? 0 : 20)
            .animation(.easeOut(duration: 0.8).delay(0.9), value: animateText)
            .padding(.bottom, 60)
        }
        .onAppear {
            animateCheckmark = true
            animateText = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animateParticles = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        OnboardingProgressBar(currentStep: 2, totalSteps: 5)
        
        OnboardingNavigationButtons(
            currentStep: .constant(2),
            totalSteps: 5,
            canProceed: true,
            onComplete: {}
        )
        
        OnboardingSkipButton(onSkip: {})
    }
    .padding(20)
    .background(
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#6b7db3"), Color(hex: "#4a5773")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
