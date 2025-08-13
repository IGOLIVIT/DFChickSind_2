//
//  NotificationService.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import Foundation
import UserNotifications
import Combine

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var notificationPermissionGranted = false
    private let center = UNUserNotificationCenter.current()
    
    private init() {
        checkNotificationPermission()
    }
    
    func requestNotificationPermission() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.notificationPermissionGranted = granted
            }
            
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkNotificationPermission() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleDailyReminderNotification(at time: Date) {
        guard notificationPermissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Learn!"
        content.body = "Don't forget your daily language practice with LinguisticBoost"
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule daily reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleQuizChallengeNotification(quizTitle: String, in timeInterval: TimeInterval) {
        guard notificationPermissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "New Quiz Challenge!"
        content.body = "A new \(quizTitle) quiz is ready for you to tackle"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "quiz_challenge_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule quiz challenge notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleStreakReminderNotification() {
        guard notificationPermissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Keep Your Streak!"
        content.body = "Don't break your learning streak - practice for just a few minutes today"
        content.sound = .default
        
        // Schedule for 8 PM if user hasn't practiced today
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "streak_reminder",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule streak reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleWeeklyReportNotification() {
        guard notificationPermissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Weekly Progress Report"
        content.body = "Check out your weekly learning progress and achievements!"
        content.sound = .default
        
        // Schedule for Sunday at 6 PM
        var components = DateComponents()
        components.weekday = 1 // Sunday
        components.hour = 18
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weekly_report",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule weekly report: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func sendCommunityHubNotification(message: String, from user: String) {
        guard notificationPermissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Community Hub"
        content.body = "\(user): \(message)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "community_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to send community notification: \(error.localizedDescription)")
            }
        }
    }
    
    func sendAchievementNotification(achievement: Achievement) {
        guard notificationPermissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🏆"
        content.body = "\(achievement.title) - \(achievement.description)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "achievement_\(achievement.id)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to send achievement notification: \(error.localizedDescription)")
            }
        }
    }
}
