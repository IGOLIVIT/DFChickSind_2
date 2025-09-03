//
//  UserFeedbackService.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import Foundation
import Combine
import UIKit

enum FeedbackType: String, CaseIterable, Codable {
    case bug = "Bug Report"
    case feature = "Feature Request"
    case improvement = "Improvement Suggestion"
    case content = "Content Feedback"
    case general = "General Feedback"
    case praise = "Praise & Appreciation"
    
    var icon: String {
        switch self {
        case .bug: return "ant.circle"
        case .feature: return "lightbulb"
        case .improvement: return "arrow.up.circle"
        case .content: return "book.circle"
        case .general: return "message.circle"
        case .praise: return "heart.circle"
        }
    }
    
    var color: String {
        switch self {
        case .bug: return "#FF3B30"
        case .feature: return "#007AFF"
        case .improvement: return "#fcc418"
        case .content: return "#3cc45b"
        case .general: return "#8E8E93"
        case .praise: return "#FF2D92"
        }
    }
}

enum FeedbackPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var color: String {
        switch self {
        case .low: return "#3cc45b"
        case .medium: return "#fcc418"
        case .high: return "#FF9500"
        case .critical: return "#FF3B30"
        }
    }
}

enum SubmissionResult {
    case success(String) // success message
    case failure(String) // error message
}

class UserFeedbackService: ObservableObject {
    static let shared = UserFeedbackService()
    
    @Published var feedbackSubmissions: [FeedbackSubmission] = []
    @Published var isSubmitting = false
    @Published var submissionResult: SubmissionResult?
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadSavedFeedback()
    }
    
    func submitFeedback(
        type: FeedbackType,
        title: String,
        description: String,
        priority: FeedbackPriority = .medium,
        userEmail: String? = nil,
        attachments: [FeedbackAttachment] = []
    ) {
        guard !title.isEmpty && !description.isEmpty else {
            submissionResult = .failure("Please provide both title and description")
            return
        }
        
        isSubmitting = true
        
        let feedback = FeedbackSubmission(
            type: type,
            title: title,
            description: description,
            priority: priority,
            userEmail: userEmail,
            attachments: attachments,
            submittedAt: Date(),
            status: .submitted
        )
        
        // Simulate network submission
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.feedbackSubmissions.append(feedback)
            self?.saveFeedback()
            self?.isSubmitting = false
            self?.submissionResult = .success("Thank you for your feedback! We'll review it soon.")
            
            // Auto-clear result after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self?.submissionResult = nil
            }
        }
    }
    
    func submitContentSuggestion(
        languageCode: String,
        contentType: ContentType,
        suggestion: String,
        examples: [String] = []
    ) {
        let title = "Content Suggestion: \(contentType.rawValue) for \(languageCode.uppercased())"
        let description = """
        Content Type: \(contentType.rawValue)
        Language: \(languageCode.uppercased())
        
        Suggestion:
        \(suggestion)
        
        \(examples.isEmpty ? "" : "Examples:\n" + examples.joined(separator: "\n"))
        """
        
        submitFeedback(
            type: .content,
            title: title,
            description: description,
            priority: .medium
        )
    }
    
    func submitBugReport(
        title: String,
        description: String,
        stepsToReproduce: [String],
        expectedBehavior: String,
        actualBehavior: String,
        deviceInfo: DeviceInfo2
    ) {
        let fullDescription = """
        \(description)
        
        Steps to Reproduce:
        \(stepsToReproduce.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        Expected Behavior:
        \(expectedBehavior)
        
        Actual Behavior:
        \(actualBehavior)
        
        Device Information:
        Model: \(deviceInfo.model)
        iOS Version: \(deviceInfo.iOSVersion)
        App Version: \(deviceInfo.appVersion)
        """
        
        submitFeedback(
            type: .bug,
            title: title,
            description: fullDescription,
            priority: .high
        )
    }
    
    func submitFeatureRequest(
        title: String,
        description: String,
        useCase: String,
        priority: FeedbackPriority = .medium
    ) {
        let fullDescription = """
        \(description)
        
        Use Case:
        \(useCase)
        """
        
        submitFeedback(
            type: .feature,
            title: title,
            description: fullDescription,
            priority: priority
        )
    }
    
    func submitQuizFeedback(
        quizId: UUID,
        rating: Int,
        comments: String,
        suggestedImprovements: String? = nil
    ) {
        let title = "Quiz Feedback: \(rating)/5 stars"
        let description = """
        Quiz ID: \(quizId)
        Rating: \(rating)/5
        
        Comments:
        \(comments)
        
        \(suggestedImprovements?.isEmpty == false ? "Suggested Improvements:\n\(suggestedImprovements!)" : "")
        """
        
        submitFeedback(
            type: .content,
            title: title,
            description: description,
            priority: rating <= 2 ? .high : .medium
        )
    }
    
    func getFeedbackHistory() -> [FeedbackSubmission] {
        return feedbackSubmissions.sorted { $0.submittedAt > $1.submittedAt }
    }
    
    func getFeedbackByType(_ type: FeedbackType) -> [FeedbackSubmission] {
        return feedbackSubmissions.filter { $0.type == type }
    }
    
    func deleteFeedback(_ feedbackId: UUID) {
        feedbackSubmissions.removeAll { $0.id == feedbackId }
        saveFeedback()
    }
    
    func clearSubmissionResult() {
        submissionResult = nil
    }
    
    // MARK: - Data Persistence
    
    private func saveFeedback() {
        do {
            let data = try JSONEncoder().encode(feedbackSubmissions)
            userDefaults.set(data, forKey: "feedback_submissions")
        } catch {
            print("Failed to save feedback submissions: \(error)")
        }
    }
    
    private func loadSavedFeedback() {
        guard let data = userDefaults.data(forKey: "feedback_submissions") else { return }
        
        do {
            feedbackSubmissions = try JSONDecoder().decode([FeedbackSubmission].self, from: data)
        } catch {
            print("Failed to load feedback submissions: \(error)")
        }
    }
}

// MARK: - Supporting Models

struct FeedbackSubmission: Identifiable, Codable {
    let id: UUID
    let type: FeedbackType
    let title: String
    let description: String
    let priority: FeedbackPriority
    let userEmail: String?
    let attachments: [FeedbackAttachment]
    let submittedAt: Date
    var status: FeedbackStatus
    
    init(type: FeedbackType, title: String, description: String, priority: FeedbackPriority, userEmail: String? = nil, attachments: [FeedbackAttachment] = [], submittedAt: Date = Date(), status: FeedbackStatus = .submitted) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.description = description
        self.priority = priority
        self.userEmail = userEmail
        self.attachments = attachments
        self.submittedAt = submittedAt
        self.status = status
    }
}

enum FeedbackStatus: String, Codable {
    case submitted = "Submitted"
    case inReview = "In Review"
    case inProgress = "In Progress"
    case resolved = "Resolved"
    case closed = "Closed"
    
    var color: String {
        switch self {
        case .submitted: return "#007AFF"
        case .inReview: return "#fcc418"
        case .inProgress: return "#FF9500"
        case .resolved: return "#3cc45b"
        case .closed: return "#8E8E93"
        }
    }
}

struct FeedbackAttachment: Identifiable, Codable {
    let id: UUID
    let filename: String
    let data: Data
    let mimeType: String
    
    init(filename: String, data: Data, mimeType: String) {
        self.id = UUID()
        self.filename = filename
        self.data = data
        self.mimeType = mimeType
    }
    
    var fileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(data.count))
    }
}

struct DeviceInfo2: Codable {
    let model: String
    let iOSVersion: String
    let appVersion: String
    
    static var current: DeviceInfo2 {
        return DeviceInfo2(
            model: UIDevice.current.model,
            iOSVersion: UIDevice.current.systemVersion,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        )
    }
}

enum ContentType: String, CaseIterable {
    case vocabulary = "Vocabulary"
    case phrases = "Phrases"
    case grammar = "Grammar Rules"
    case pronunciation = "Pronunciation Guide"
    case quiz = "Quiz Questions"
    case topics = "Learning Topics"
    case culturalNotes = "Cultural Notes"
    case businessTerms = "Business Terms"
}
