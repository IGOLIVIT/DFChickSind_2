//
//  CollaborationHubViewModel.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import Foundation
import Combine
import SwiftUI

class CollaborationHubViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var activeUsers: [CommunityUser] = []
    @Published var languagePartners: [LanguagePartner] = []
    @Published var currentConversation: Conversation?
    @Published var isVoiceChatActive: Bool = false
    @Published var selectedLanguage: String = ""
    @Published var searchText: String = ""
    @Published var selectedSkillLevel: Language.LanguageDifficulty?
    @Published var isConnecting: Bool = false
    @Published var connectionError: String?
    
    private let notificationService = NotificationService.shared
    private var userProgress: UserProgress
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.userProgress = Self.loadUserProgress()
        setupBindings()
        loadInitialData()
    }
    
    private func setupBindings() {
        // Watch for search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterUsers()
            }
            .store(in: &cancellables)
        
        // Watch for filter changes
        Publishers.CombineLatest($selectedLanguage, $selectedSkillLevel)
            .sink { [weak self] _, _ in
                self?.filterUsers()
            }
            .store(in: &cancellables)
    }
    
    private static func loadUserProgress() -> UserProgress {
        guard let data = UserDefaults.standard.data(forKey: "user_progress"),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return UserProgress.sampleProgress
        }
        return progress
    }
    
    private func loadInitialData() {
        // Load sample conversations and users for demonstration
        loadSampleConversations()
        loadSampleUsers()
        loadLanguagePartners()
    }
    
    private func loadSampleConversations() {
        conversations = [
            Conversation(
                participants: ["user1", "user2", "user3"],
                participantNames: ["Maria", "Carlos", "Ana"],
                language: "es",
                topic: "Spanish Practice Group",
                messages: [
                    ConversationMessage(
                        senderId: "user1",
                        senderName: "Maria",
                        content: "¡Hola! ¿Cómo están todos hoy?",
                        timestamp: Date().addingTimeInterval(-3600),
                        messageType: .text
                    ),
                    ConversationMessage(
                        senderId: "user2",
                        senderName: "Carlos",
                        content: "¡Muy bien! Practicando mi pronunciación.",
                        timestamp: Date().addingTimeInterval(-1800),
                        messageType: .text
                    )
                ],
                createdAt: Date().addingTimeInterval(-86400),
                lastMessageAt: Date().addingTimeInterval(-1800),
                isVoiceChat: false,
                isActive: true
            ),
            Conversation(
                participants: ["user1", "user4"],
                participantNames: ["You", "Pierre"],
                language: "fr",
                topic: "French Business Terms",
                messages: [
                    ConversationMessage(
                        senderId: "user4",
                        senderName: "Pierre",
                        content: "Discutons les termes commerciaux essentiels",
                        timestamp: Date().addingTimeInterval(-7200),
                        messageType: .text
                    )
                ],
                createdAt: Date().addingTimeInterval(-172800),
                lastMessageAt: Date().addingTimeInterval(-7200),
                isVoiceChat: false,
                isActive: true
            )
        ]
    }
    
    private func loadSampleUsers() {
        activeUsers = [
            CommunityUser(
                userId: "user1",
                username: "maria_es",
                displayName: "Maria",
                nativeLanguages: ["es"],
                learningLanguages: ["en", "fr"],
                skillLevels: ["es": .expert, "en": .intermediate, "fr": .beginner],
                bio: "Native Spanish speaker who loves helping others learn!",
                location: "Madrid, Spain",
                isOnline: true,
                lastSeen: Date(),
                responseRate: 0.95,
                rating: 4.8,
                totalConversations: 150,
                totalSessions: 200,
                preferredTopics: [.culture, .travel, .dailyLife],
                isVerified: true
            ),
            CommunityUser(
                userId: "user2",
                username: "carlos_business",
                displayName: "Carlos",
                nativeLanguages: ["es"],
                learningLanguages: ["en"],
                skillLevels: ["es": .expert, "en": .beginner],
                bio: "Learning English for business opportunities",
                location: "Barcelona, Spain",
                isOnline: true,
                lastSeen: Date(),
                responseRate: 0.88,
                rating: 4.5,
                totalConversations: 45,
                totalSessions: 60,
                preferredTopics: [.business, .work],
                isVerified: false
            ),
            CommunityUser(
                userId: "user3",
                displayName: "Sophie",
                nativeLanguages: ["fr"],
                learningLanguages: ["en", "es"],
                skillLevels: ["fr": .expert, "en": .advanced, "es": .intermediate],
                bio: "French teacher available for conversation practice",
                isOnline: false,
                lastSeen: Date().addingTimeInterval(-3600),
                responseRate: 0.98,
                rating: 4.9,
                totalConversations: 300,
                preferredTopics: [.education, .culture, .books],
                isVerified: true
            ),
            CommunityUser(
                userId: "user4",
                displayName: "Pierre",
                nativeLanguages: ["fr"],
                learningLanguages: ["en"],
                skillLevels: ["fr": .expert, "en": .advanced],
                bio: "Business professional, happy to help with French business terms",
                isOnline: true,
                lastSeen: Date(),
                responseRate: 0.92,
                rating: 4.7,
                totalConversations: 200,
                preferredTopics: [.business, .technology],
                isVerified: true
            )
        ]
    }
    
    private func loadLanguagePartners() {
        languagePartners = [
            LanguagePartner(
                user: activeUsers[0],
                commonLanguages: ["es", "en"],
                matchScore: 0.92,
                relationship: .active,
                conversationHistory: [],
                lastInteraction: Date().addingTimeInterval(-86400),
                isFavorite: true,
                notes: "Great conversation partner, very patient!"
            ),
            LanguagePartner(
                user: activeUsers[2],
                commonLanguages: ["fr", "en"],
                matchScore: 0.88,
                relationship: .potential,
                conversationHistory: [],
                lastInteraction: Date().addingTimeInterval(-172800),
                isFavorite: false,
                notes: ""
            )
        ]
    }
    
    // MARK: - User Interaction
    
    func startConversationWith(_ user: CommunityUser, language: String) {
        isConnecting = true
        connectionError = nil
        
        // Simulate connection delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            let conversation = Conversation(
                participants: [self.userProgress.userId, user.userId],
                participantNames: ["You", user.displayName],
                language: language,
                topic: "Practice with \(user.displayName)",
                messages: [],
                createdAt: Date(),
                lastMessageAt: Date(),
                isVoiceChat: false,
                isActive: true
            )
            
            self.conversations.insert(conversation, at: 0)
            self.currentConversation = conversation
            self.isConnecting = false
            
            // Send notification to other user
            self.notificationService.scheduleQuizChallengeNotification(quizTitle: "New Conversation", in: 1.0)
        }
    }
    
    func joinVoiceChat(for conversation: Conversation) {
        isVoiceChatActive = true
        currentConversation = conversation
        
        // In a real app, this would initialize voice chat functionality
        // For now, we'll simulate the voice chat interface
    }
    
    func endVoiceChat() {
        isVoiceChatActive = false
        
        // Update interaction if applicable
        if let conversation = currentConversation,
           let partnerUserId = conversation.participants.first(where: { $0 != userProgress.userId }),
           let partnerIndex = languagePartners.firstIndex(where: { $0.user.userId == partnerUserId }) {
            
            languagePartners[partnerIndex].lastInteraction = Date()
        }
    }
    
    func sendMessage(_ content: String, to conversation: Conversation) {
        let message = ConversationMessage(
            senderId: userProgress.userId,
            senderName: "You",
            content: content,
            timestamp: Date(),
            messageType: .text
        )
        
        // Add message to conversation
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].messages.append(message)
            conversations[index].lastMessageAt = Date()
            
            // Move conversation to top
            let updatedConversation = conversations[index]
            conversations.remove(at: index)
            conversations.insert(updatedConversation, at: 0)
        }
        
        // Send notification to other participants
        notificationService.scheduleQuizChallengeNotification(quizTitle: "New Message", in: 1.0)
    }
    
    func sendVoiceMessage(_ audioData: Data, to conversation: Conversation) {
        let message = ConversationMessage(
            senderId: userProgress.userId,
            senderName: "You",
            content: "[Voice Message]",
            timestamp: Date(),
            messageType: .voice
        )
        
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].messages.append(message)
            conversations[index].lastMessageAt = Date()
        }
    }
    
    func rateUser(_ user: CommunityUser, rating: Int, feedback: String) {
        // In a real app, this would send the rating to the server
        // For now, we'll update the local user rating
        if let index = activeUsers.firstIndex(where: { $0.userId == user.userId }) {
            let currentRating = activeUsers[index].rating
            let totalConversations = activeUsers[index].totalConversations
            let newRating = ((currentRating * Double(totalConversations)) + Double(rating)) / Double(totalConversations + 1)
            
            activeUsers[index].rating = newRating
            activeUsers[index].totalConversations += 1
        }
    }
    
    func reportUser(_ user: CommunityUser, reason: String) {
        // In a real app, this would send a report to the moderation team
        print("User \(user.displayName) reported for: \(reason)")
    }
    
    func blockUser(_ user: CommunityUser) {
        // Remove user from active users and language partners
        activeUsers.removeAll { $0.userId == user.userId }
        languagePartners.removeAll { $0.user.userId == user.userId }
        
        // Remove conversations with this user
        conversations.removeAll { conversation in
            conversation.participants.contains(user.userId)
        }
    }
    
    // MARK: - Language Partner Management
    
    func findLanguagePartners() {
        isConnecting = true
        
        // Simulate finding compatible partners
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.isConnecting = false
            // In a real app, this would use a matching algorithm
            // based on languages, skill levels, interests, etc.
        }
    }
    
    func acceptPartnerRequest(_ partner: LanguagePartner) {
        if let index = languagePartners.firstIndex(where: { $0.user.userId == partner.user.userId }) {
            languagePartners[index].relationship = .active
        }
    }
    
    func declinePartnerRequest(_ partner: LanguagePartner) {
        languagePartners.removeAll { $0.user.userId == partner.user.userId }
    }
    
    // MARK: - Filtering and Search
    
    private func filterUsers() {
        // This would filter the activeUsers array based on current filters
        // For now, we'll keep all users visible
    }
    
    func getOnlineUsers() -> [CommunityUser] {
        return activeUsers.filter { $0.isOnline }
    }
    
    func getUsersForLanguage(_ languageCode: String) -> [CommunityUser] {
        return activeUsers.filter { user in
            user.nativeLanguages.contains(languageCode) || user.learningLanguages.contains(languageCode)
        }
    }
    
    func getConversationsForLanguage(_ languageCode: String) -> [Conversation] {
        return conversations.filter { $0.language == languageCode }
    }
    
    // MARK: - Statistics
    
    func getCommunityStats() -> CommunityStats {
        let totalConversations = conversations.count
        let totalMessages = conversations.reduce(0) { $0 + $1.messages.count }
        let averageRating = activeUsers.isEmpty ? 0.0 : activeUsers.reduce(0.0) { $0 + $1.rating } / Double(activeUsers.count)
        let languageDistribution = Dictionary(grouping: activeUsers.flatMap { $0.nativeLanguages }, by: { $0 })
            .mapValues { $0.count }
        
        return CommunityStats(
            totalUsers: activeUsers.count,
            onlineUsers: getOnlineUsers().count,
            totalConversations: totalConversations,
            totalMessages: totalMessages,
            averageRating: averageRating,
            languageDistribution: languageDistribution
        )
    }
    
    func clearFilters() {
        searchText = ""
        selectedLanguage = ""
        selectedSkillLevel = nil
    }
}

// MARK: - Supporting Types

struct CommunityStats {
    let totalUsers: Int
    let onlineUsers: Int
    let totalConversations: Int
    let totalMessages: Int
    let averageRating: Double
    let languageDistribution: [String: Int]
    
    var formattedAverageRating: String {
        return String(format: "%.1f", averageRating)
    }
}
