//
//  DesignSystem.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import SwiftUI
import UIKit

// MARK: - Colors
extension Color {
    // Primary color scheme
    static let appBackground = Color(hex: "#3e4464")
    static let primaryYellow = Color(hex: "#fcc418")
    static let primaryGreen = Color(hex: "#3cc45b")
    
    // Neumorphism colors
    static let neuLight = Color.white.opacity(0.1)
    static let neuDark = Color.black.opacity(0.3)
    
    // Gradient colors
    static let gradientStart = Color(hex: "#4c5a7a")
    static let gradientEnd = Color(hex: "#2d3447")
    
    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.8)
    static let textTertiary = Color.white.opacity(0.6)
    
    // System colors adapted for dark theme
    static let systemBlue = Color(hex: "#007AFF")
    static let systemRed = Color(hex: "#FF3B30")
    static let systemOrange = Color(hex: "#FF9500")
    static let systemPurple = Color(hex: "#5856D6")
    static let systemPink = Color(hex: "#FF2D92")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Fonts
extension Font {
    // Custom font sizes following Apple's guidelines
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
}

// MARK: - Spacing
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let button: CGFloat = 12
    static let card: CGFloat = 16
}

// MARK: - Neumorphism View Modifier
struct NeumorphicStyle: ViewModifier {
    var cornerRadius: CGFloat = CornerRadius.md
    var backgroundColor: Color = Color.appBackground
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .shadow(color: Color.neuDark, radius: 8, x: 8, y: 8)
                    .shadow(color: Color.neuLight, radius: 8, x: -8, y: -8)
            )
    }
}

struct NeumorphicInsetStyle: ViewModifier {
    var cornerRadius: CGFloat = CornerRadius.md
    var backgroundColor: Color = Color.appBackground
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.neuDark, Color.neuLight]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .shadow(color: Color.neuLight, radius: 3, x: -3, y: -3)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    )
            )
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = CornerRadius.button
    var backgroundColor: Color = Color.primaryYellow
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .font(.headline)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .shadow(color: Color.neuDark, radius: configuration.isPressed ? 2 : 6, x: configuration.isPressed ? 2 : 6, y: configuration.isPressed ? 2 : 6)
                    .shadow(color: Color.neuLight, radius: configuration.isPressed ? 1 : 3, x: configuration.isPressed ? -1 : -3, y: configuration.isPressed ? -1 : -3)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func neumorphic(cornerRadius: CGFloat = CornerRadius.md, backgroundColor: Color = Color.appBackground) -> some View {
        self.modifier(NeumorphicStyle(cornerRadius: cornerRadius, backgroundColor: backgroundColor))
    }
    
    func neumorphicInset(cornerRadius: CGFloat = CornerRadius.md, backgroundColor: Color = Color.appBackground) -> some View {
        self.modifier(NeumorphicInsetStyle(cornerRadius: cornerRadius, backgroundColor: backgroundColor))
    }
    
    func cardStyle() -> some View {
        self
            .padding(Spacing.md)
            .neumorphic(cornerRadius: CornerRadius.card)
    }
    
    func primaryButtonStyle() -> some View {
        self.buttonStyle(NeumorphicButtonStyle(backgroundColor: Color.primaryYellow))
    }
    
    func secondaryButtonStyle() -> some View {
        self.buttonStyle(NeumorphicButtonStyle(backgroundColor: Color.primaryGreen))
    }
}

// MARK: - Custom Components
struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    
    init(progress: Double, lineWidth: CGFloat = 8, backgroundColor: Color = Color.gray.opacity(0.3), foregroundColor: Color = Color.primaryYellow) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
        }
    }
}

struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius)
            .shadow(color: color, radius: radius * 0.8)
            .shadow(color: color, radius: radius * 0.6)
    }
}

extension View {
    func glow(color: Color = Color.primaryYellow, radius: CGFloat = 10) -> some View {
        self.modifier(GlowEffect(color: color, radius: radius))
    }
    
    func appBackground() -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: [Color.gradientStart, Color.gradientEnd]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Animation Extensions
extension Animation {
    static let smooth = Animation.easeInOut(duration: 0.3)
    static let bounce = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let gentle = Animation.easeInOut(duration: 0.5)
}




