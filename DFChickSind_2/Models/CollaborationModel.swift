//
//  CollaborationModel.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import Foundation

// MARK: - Conversation Model
struct Conversation: Identifiable, Codable {
    let id: UUID
    let participants: [String] // User IDs
    let participantNames: [String]
    let language: String // Language code
    let topic: String
    let title: String // Added missing property
    let category: ConversationCategory? // Added missing property
    var messages: [ConversationMessage]
    let createdAt: Date
    var lastMessageAt: Date
    var isVoiceChat: Bool
    var isActive: Bool
    
    init(participants: [String], participantNames: [String], language: String, topic: String, title: String? = nil, category: ConversationCategory? = nil, messages: [ConversationMessage] = [], createdAt: Date = Date(), lastMessageAt: Date = Date(), isVoiceChat: Bool = false, isActive: Bool = true) {
        self.id = UUID()
        self.participants = participants
        self.participantNames = participantNames
        self.language = language
        self.topic = topic
        self.title = title ?? topic
        self.category = category
        self.messages = messages
        self.createdAt = createdAt
        self.lastMessageAt = lastMessageAt
        self.isVoiceChat = isVoiceChat
        self.isActive = isActive
    }
    
    var lastMessage: ConversationMessage? {
        return messages.last
    }
    
    var participantCount: Int {
        return participants.count
    }
}

// MARK: - Conversation Message Model
struct ConversationMessage: Identifiable, Codable {
    let id: UUID
    let senderId: String
    let senderName: String
    let content: String
    let timestamp: Date
    let messageType: MessageType
    let isRead: Bool
    
    init(senderId: String, senderName: String, content: String, timestamp: Date = Date(), messageType: MessageType = .text, isRead: Bool = false) {
        self.id = UUID()
        self.senderId = senderId
        self.senderName = senderName
        self.content = content
        self.timestamp = timestamp
        self.messageType = messageType
        self.isRead = isRead
    }
    
    enum MessageType: String, Codable {
        case text = "text"
        case voice = "voice"
        case image = "image"
        case systemMessage = "system"
    }
}

// MARK: - Community User Model
struct CommunityUser: Identifiable, Codable {
    let id: UUID
    let userId: String
    let username: String // Added missing property
    let displayName: String
    let nativeLanguages: [String] // Language codes
    let nativeLanguage: String // Primary native language
    let learningLanguages: [String] // Language codes
    let skillLevels: [String: Language.LanguageDifficulty] // Language code to skill level
    let bio: String
    let avatarURL: String?
    let location: String? // Added missing property
    let isOnline: Bool
    let lastSeen: Date
    let responseRate: Double // 0.0 to 1.0
    var rating: Double // 1.0 to 5.0
    var totalConversations: Int
    var totalSessions: Int // Added missing property
    let timeZone: String
    let preferredTopics: [ConversationTopic]
    let isVerified: Bool
    
    init(userId: String, username: String? = nil, displayName: String, nativeLanguages: [String], learningLanguages: [String], skillLevels: [String: Language.LanguageDifficulty] = [:], bio: String = "", avatarURL: String? = nil, location: String? = nil, isOnline: Bool = false, lastSeen: Date = Date(), responseRate: Double = 1.0, rating: Double = 5.0, totalConversations: Int = 0, totalSessions: Int = 0, timeZone: String = "UTC", preferredTopics: [ConversationTopic] = [], isVerified: Bool = false) {
        self.id = UUID()
        self.userId = userId
        self.username = username ?? userId
        self.displayName = displayName
        self.nativeLanguages = nativeLanguages
        self.nativeLanguage = nativeLanguages.first ?? "en"
        self.learningLanguages = learningLanguages
        self.skillLevels = skillLevels
        self.bio = bio
        self.avatarURL = avatarURL
        self.location = location
        self.isOnline = isOnline
        self.lastSeen = lastSeen
        self.responseRate = responseRate
        self.rating = rating
        self.totalConversations = totalConversations
        self.totalSessions = totalSessions
        self.timeZone = timeZone
        self.preferredTopics = preferredTopics
        self.isVerified = isVerified
    }
    
    var skillLevel: Language.LanguageDifficulty {
        return skillLevels.values.max() ?? .beginner
    }
    
    var onlineStatus: OnlineStatus {
        if isOnline {
            return .online
        } else {
            let timeSinceLastSeen = Date().timeIntervalSince(lastSeen)
            if timeSinceLastSeen < 300 { // 5 minutes
                return .away
            } else {
                return .offline
            }
        }
    }
    
    enum OnlineStatus: String, CaseIterable {
        case online = "Online"
        case away = "Away"
        case offline = "Offline"
        
        var color: String {
            switch self {
            case .online: return "#3cc45b"
            case .away: return "#fcc418"
            case .offline: return "#8E8E93"
            }
        }
    }
}

// MARK: - Language Partner Model
struct LanguagePartner: Identifiable, Codable {
    let id: UUID
    let user: CommunityUser
    let commonLanguages: [String] // Languages both users are interested in
    let matchScore: Double // 0.0 to 1.0
    var relationship: PartnershipType
    let conversationHistory: [Conversation]
    var lastInteraction: Date?
    let isFavorite: Bool
    let notes: String
    
    init(user: CommunityUser, commonLanguages: [String], matchScore: Double = 0.0, relationship: PartnershipType = .potential, conversationHistory: [Conversation] = [], lastInteraction: Date? = nil, isFavorite: Bool = false, notes: String = "") {
        self.id = UUID()
        self.user = user
        self.commonLanguages = commonLanguages
        self.matchScore = matchScore
        self.relationship = relationship
        self.conversationHistory = conversationHistory
        self.lastInteraction = lastInteraction
        self.isFavorite = isFavorite
        self.notes = notes
    }
    
    enum PartnershipType: String, CaseIterable, Codable {
        case potential = "Potential Partner"
        case active = "Active Partner"
        case close = "Close Partner"
        case mentor = "Mentor"
        case mentee = "Mentee"
        
        var icon: String {
            switch self {
            case .potential: return "person.badge.plus"
            case .active: return "person.2"
            case .close: return "heart"
            case .mentor: return "graduationcap"
            case .mentee: return "person.badge.key"
            }
        }
        
        var color: String {
            switch self {
            case .potential: return "#007AFF"
            case .active: return "#3cc45b"
            case .close: return "#FF2D92"
            case .mentor: return "#5856D6"
            case .mentee: return "#fcc418"
            }
        }
    }
}

// MARK: - Conversation Topic Model
enum ConversationTopic: String, CaseIterable, Codable {
    case dailyLife = "Daily Life"
    case culture = "Culture"
    case travel = "Travel"
    case food = "Food"
    case hobbies = "Hobbies"
    case work = "Work & Career"
    case education = "Education"
    case technology = "Technology"
    case sports = "Sports"
    case movies = "Movies & TV"
    case music = "Music"
    case books = "Books"
    case news = "Current Events"
    case family = "Family"
    case relationships = "Relationships"
    case health = "Health & Fitness"
    case environment = "Environment"
    case politics = "Politics"
    case business = "Business"
    case science = "Science"
    
    var icon: String {
        switch self {
        case .dailyLife: return "house"
        case .culture: return "globe"
        case .travel: return "airplane"
        case .food: return "fork.knife"
        case .hobbies: return "gamecontroller"
        case .work: return "briefcase"
        case .education: return "book"
        case .technology: return "desktopcomputer"
        case .sports: return "sportscourt"
        case .movies: return "tv"
        case .music: return "music.note"
        case .books: return "book.closed"
        case .news: return "newspaper"
        case .family: return "figure.2.and.child.holdinghands"
        case .relationships: return "heart.text.square"
        case .health: return "heart.text.square"
        case .environment: return "leaf"
        case .politics: return "building.columns"
        case .business: return "chart.line.uptrend.xyaxis"
        case .science: return "atom"
        }
    }
    
    var color: String {
        switch self {
        case .dailyLife: return "#3cc45b"
        case .culture: return "#5856D6"
        case .travel: return "#007AFF"
        case .food: return "#FF9500"
        case .hobbies: return "#FF2D92"
        case .work: return "#8E8E93"
        case .education: return "#fcc418"
        case .technology: return "#00D4AA"
        case .sports: return "#FF3B30"
        case .movies: return "#AF52DE"
        case .music: return "#FF2D92"
        case .books: return "#5856D6"
        case .news: return "#007AFF"
        case .family: return "#FF9500"
        case .relationships: return "#FF2D92"
        case .health: return "#3cc45b"
        case .environment: return "#30D158"
        case .politics: return "#8E8E93"
        case .business: return "#007AFF"
        case .science: return "#5856D6"
        }
    }
}

// MARK: - Sample Data
extension Conversation {
    static let sampleConversations: [Conversation] = [
        Conversation(
            participants: ["user1", "user2"],
            participantNames: ["Anna", "Miguel"],
            language: "es",
            topic: "Travel in Spain",
            messages: [
                ConversationMessage(
                    senderId: "user1",
                    senderName: "Anna",
                    content: "¡Hola! I'm planning a trip to Barcelona next month."
                ),
                ConversationMessage(
                    senderId: "user2",
                    senderName: "Miguel",
                    content: "¡Qué genial! Barcelona is amazing. Have you been to Sagrada Familia?"
                )
            ]
        ),
        Conversation(
            participants: ["user1", "user3"],
            participantNames: ["Anna", "Yuki"],
            language: "ja",
            topic: "Japanese Cuisine",
            messages: [
                ConversationMessage(
                    senderId: "user3",
                    senderName: "Yuki",
                    content: "こんにちは！ Do you like sushi?"
                )
            ]
        )
    ]
}

extension CommunityUser {
    static let sampleUsers: [CommunityUser] = [
        CommunityUser(
            userId: "user1",
            displayName: "Anna Chen",
            nativeLanguages: ["en"],
            learningLanguages: ["es", "ja"],
            skillLevels: ["es": .intermediate, "ja": .beginner],
            bio: "Love learning languages and cultures! Always happy to help with English.",
            isOnline: true,
            responseRate: 0.95,
            rating: 4.8,
            totalConversations: 23,
            preferredTopics: [.travel, .culture, .food],
            isVerified: true
        ),
        CommunityUser(
            userId: "user2",
            displayName: "Miguel Rodriguez",
            nativeLanguages: ["es"],
            learningLanguages: ["en", "fr"],
            skillLevels: ["en": .advanced, "fr": .intermediate],
            bio: "Spanish teacher from Madrid. Love helping others with Spanish!",
            isOnline: false,
            lastSeen: Date().addingTimeInterval(-3600), // 1 hour ago
            responseRate: 0.92,
            rating: 4.9,
            totalConversations: 156,
            preferredTopics: [.education, .culture, .travel],
            isVerified: true
        ),
        CommunityUser(
            userId: "user3",
            displayName: "Yuki Tanaka",
            nativeLanguages: ["ja"],
            learningLanguages: ["en", "ko"],
            skillLevels: ["en": .intermediate, "ko": .beginner],
            bio: "From Tokyo! Interested in K-pop and Korean culture.",
            isOnline: true,
            responseRate: 0.88,
            rating: 4.7,
            totalConversations: 45,
            preferredTopics: [.music, .culture, .food, .movies],
            isVerified: false
        )
    ]
}

extension LanguagePartner {
    static let samplePartners: [LanguagePartner] = [
        LanguagePartner(
            user: CommunityUser.sampleUsers[1],
            commonLanguages: ["es", "en"],
            matchScore: 0.92,
            relationship: .active,
            lastInteraction: Date().addingTimeInterval(-86400), // 1 day ago
            isFavorite: true,
            notes: "Great conversation partner, very patient!"
        ),
        LanguagePartner(
            user: CommunityUser.sampleUsers[2],
            commonLanguages: ["ja", "en"],
            matchScore: 0.78,
            relationship: .potential,
            lastInteraction: nil,
            isFavorite: false,
            notes: ""
        )
    ]
}

// MARK: - Supporting Enums
enum ConversationCategory: String, CaseIterable, Codable {
    case practice = "Practice"
    case lesson = "Lesson"
    case casual = "Casual"
    case business = "Business"
    case cultural = "Cultural Exchange"
    case study = "Study Group"
    
    var icon: String {
        switch self {
        case .practice: return "book"
        case .lesson: return "graduationcap"
        case .casual: return "message"
        case .business: return "briefcase"
        case .cultural: return "globe"
        case .study: return "person.3"
        }
    }
}
