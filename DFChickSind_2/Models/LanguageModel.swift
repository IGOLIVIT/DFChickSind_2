//
//  LanguageModel.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import Foundation

struct Language: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let code: String
    let flag: String
    let difficulty: LanguageDifficulty
    let description: String
    var isSelected: Bool = false
    var isAvailable: Bool = true
    var lessons: [LanguageLesson] = []
    
    init(name: String, code: String, flag: String, difficulty: LanguageDifficulty, description: String, isSelected: Bool = false, isAvailable: Bool = true, lessons: [LanguageLesson] = []) {
        self.id = UUID()
        self.name = name
        self.code = code
        self.flag = flag
        self.difficulty = difficulty
        self.description = description
        self.isSelected = isSelected
        self.isAvailable = isAvailable
        self.lessons = lessons.isEmpty ? LanguageLesson.generateLessons(for: code) : lessons
    }
    
    enum LanguageDifficulty: String, CaseIterable, Codable, Comparable {
        case beginner = "Beginner"
        case intermediate = "Intermediate" 
        case advanced = "Advanced"
        case expert = "Expert"
        
        var color: String {
            switch self {
            case .beginner: return "#3cc45b"
            case .intermediate: return "#fcc418"
            case .advanced: return "#ff9500"
            case .expert: return "#ff3b30"
            }
        }
        
        var order: Int {
            switch self {
            case .beginner: return 0
            case .intermediate: return 1
            case .advanced: return 2
            case .expert: return 3
            }
        }
        
        static func < (lhs: LanguageDifficulty, rhs: LanguageDifficulty) -> Bool {
            return lhs.order < rhs.order
        }
    }
}

struct LanguageTopic: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let languageCode: String
    let category: TopicCategory
    let estimatedDuration: Int // in minutes
    var isCompleted: Bool = false
    var progress: Double = 0.0 // 0.0 to 1.0
    let prerequisites: [String] // topic IDs
    
    init(title: String, description: String, languageCode: String, category: TopicCategory, estimatedDuration: Int, isCompleted: Bool = false, progress: Double = 0.0, prerequisites: [String] = []) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.languageCode = languageCode
        self.category = category
        self.estimatedDuration = estimatedDuration
        self.isCompleted = isCompleted
        self.progress = progress
        self.prerequisites = prerequisites
    }
    
    enum TopicCategory: String, CaseIterable, Codable {
        case vocabulary = "Vocabulary"
        case grammar = "Grammar"
        case pronunciation = "Pronunciation"
        case conversation = "Conversation"
        case business = "Business"
        case culture = "Culture"
        
        var icon: String {
            switch self {
            case .vocabulary: return "text.book.closed"
            case .grammar: return "textformat.abc"
            case .pronunciation: return "speaker.wave.3"
            case .conversation: return "bubble.left.and.bubble.right"
            case .business: return "briefcase"
            case .culture: return "globe"
            }
        }
    }
}

struct LanguageLesson: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let languageCode: String
    let estimatedMinutes: Int
    var isCompleted: Bool = false
    let lessonNumber: Int
    
    init(title: String, content: String, languageCode: String, estimatedMinutes: Int, lessonNumber: Int, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.languageCode = languageCode
        self.estimatedMinutes = estimatedMinutes
        self.isCompleted = isCompleted
        self.lessonNumber = lessonNumber
    }
    
    static func generateLessons(for languageCode: String) -> [LanguageLesson] {
        switch languageCode {
        case "de":
            return [
                LanguageLesson(title: "Greetings", content: "Guten Tag (Good day), Hallo (Hello), Auf Wiedersehen (Goodbye). Learn basic German greetings used in daily conversations.", languageCode: "de", estimatedMinutes: 5, lessonNumber: 1),
                LanguageLesson(title: "Numbers 1-10", content: "eins, zwei, drei, vier, fünf, sechs, sieben, acht, neun, zehn. Master German numbers from one to ten.", languageCode: "de", estimatedMinutes: 4, lessonNumber: 2),
                LanguageLesson(title: "Family Members", content: "die Familie (family), der Vater (father), die Mutter (mother), der Bruder (brother), die Schwester (sister).", languageCode: "de", estimatedMinutes: 6, lessonNumber: 3),
                LanguageLesson(title: "Colors", content: "rot (red), blau (blue), grün (green), gelb (yellow), schwarz (black), weiß (white).", languageCode: "de", estimatedMinutes: 4, lessonNumber: 4),
                LanguageLesson(title: "Food & Drinks", content: "das Brot (bread), das Wasser (water), der Kaffee (coffee), das Bier (beer), der Apfel (apple).", languageCode: "de", estimatedMinutes: 7, lessonNumber: 5),
                LanguageLesson(title: "Days of Week", content: "Montag, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag, Sonntag. Learn German days of the week.", languageCode: "de", estimatedMinutes: 5, lessonNumber: 6),
                LanguageLesson(title: "Common Verbs", content: "sein (to be), haben (to have), gehen (to go), kommen (to come), sprechen (to speak).", languageCode: "de", estimatedMinutes: 8, lessonNumber: 7),
                LanguageLesson(title: "Weather", content: "das Wetter (weather), die Sonne (sun), der Regen (rain), der Schnee (snow), der Wind (wind).", languageCode: "de", estimatedMinutes: 5, lessonNumber: 8),
                LanguageLesson(title: "Time", content: "die Zeit (time), die Stunde (hour), die Minute (minute), heute (today), morgen (tomorrow).", languageCode: "de", estimatedMinutes: 6, lessonNumber: 9),
                LanguageLesson(title: "Basic Phrases", content: "Wie geht es dir? (How are you?), Danke schön (Thank you), Bitte schön (You're welcome), Entschuldigung (Excuse me).", languageCode: "de", estimatedMinutes: 7, lessonNumber: 10)
            ]
        case "fr":
            return [
                LanguageLesson(title: "Salutations", content: "Bonjour (Hello), Bonsoir (Good evening), Au revoir (Goodbye). Learn essential French greetings.", languageCode: "fr", estimatedMinutes: 5, lessonNumber: 1),
                LanguageLesson(title: "Nombres 1-10", content: "un, deux, trois, quatre, cinq, six, sept, huit, neuf, dix. Master French numbers from one to ten.", languageCode: "fr", estimatedMinutes: 4, lessonNumber: 2),
                LanguageLesson(title: "La Famille", content: "la famille (family), le père (father), la mère (mother), le frère (brother), la sœur (sister).", languageCode: "fr", estimatedMinutes: 6, lessonNumber: 3),
                LanguageLesson(title: "Les Couleurs", content: "rouge (red), bleu (blue), vert (green), jaune (yellow), noir (black), blanc (white).", languageCode: "fr", estimatedMinutes: 4, lessonNumber: 4),
                LanguageLesson(title: "Nourriture", content: "le pain (bread), l'eau (water), le café (coffee), le vin (wine), la pomme (apple).", languageCode: "fr", estimatedMinutes: 7, lessonNumber: 5),
                LanguageLesson(title: "Jours de la Semaine", content: "lundi, mardi, mercredi, jeudi, vendredi, samedi, dimanche. Learn French days of the week.", languageCode: "fr", estimatedMinutes: 5, lessonNumber: 6),
                LanguageLesson(title: "Verbes Communs", content: "être (to be), avoir (to have), aller (to go), venir (to come), parler (to speak).", languageCode: "fr", estimatedMinutes: 8, lessonNumber: 7),
                LanguageLesson(title: "Le Temps", content: "le temps (weather), le soleil (sun), la pluie (rain), la neige (snow), le vent (wind).", languageCode: "fr", estimatedMinutes: 5, lessonNumber: 8),
                LanguageLesson(title: "L'Heure", content: "le temps (time), l'heure (hour), la minute (minute), aujourd'hui (today), demain (tomorrow).", languageCode: "fr", estimatedMinutes: 6, lessonNumber: 9),
                LanguageLesson(title: "Phrases de Base", content: "Comment allez-vous? (How are you?), Merci beaucoup (Thank you), De rien (You're welcome), Excusez-moi (Excuse me).", languageCode: "fr", estimatedMinutes: 7, lessonNumber: 10)
            ]
        case "it":
            return [
                LanguageLesson(title: "Saluti", content: "Ciao (Hello/Bye), Buongiorno (Good morning), Buonasera (Good evening), Arrivederci (Goodbye).", languageCode: "it", estimatedMinutes: 5, lessonNumber: 1),
                LanguageLesson(title: "Numeri 1-10", content: "uno, due, tre, quattro, cinque, sei, sette, otto, nove, dieci. Learn Italian numbers.", languageCode: "it", estimatedMinutes: 4, lessonNumber: 2),
                LanguageLesson(title: "La Famiglia", content: "la famiglia (family), il padre (father), la madre (mother), il fratello (brother), la sorella (sister).", languageCode: "it", estimatedMinutes: 6, lessonNumber: 3),
                LanguageLesson(title: "I Colori", content: "rosso (red), blu (blue), verde (green), giallo (yellow), nero (black), bianco (white).", languageCode: "it", estimatedMinutes: 4, lessonNumber: 4),
                LanguageLesson(title: "Cibo e Bevande", content: "il pane (bread), l'acqua (water), il caffè (coffee), il vino (wine), la mela (apple).", languageCode: "it", estimatedMinutes: 7, lessonNumber: 5),
                LanguageLesson(title: "Giorni della Settimana", content: "lunedì, martedì, mercoledì, giovedì, venerdì, sabato, domenica. Italian days of the week.", languageCode: "it", estimatedMinutes: 5, lessonNumber: 6),
                LanguageLesson(title: "Verbi Comuni", content: "essere (to be), avere (to have), andare (to go), venire (to come), parlare (to speak).", languageCode: "it", estimatedMinutes: 8, lessonNumber: 7),
                LanguageLesson(title: "Il Tempo", content: "il tempo (weather), il sole (sun), la pioggia (rain), la neve (snow), il vento (wind).", languageCode: "it", estimatedMinutes: 5, lessonNumber: 8),
                LanguageLesson(title: "L'Ora", content: "il tempo (time), l'ora (hour), il minuto (minute), oggi (today), domani (tomorrow).", languageCode: "it", estimatedMinutes: 6, lessonNumber: 9),
                LanguageLesson(title: "Frasi di Base", content: "Come stai? (How are you?), Grazie mille (Thank you), Prego (You're welcome), Scusi (Excuse me).", languageCode: "it", estimatedMinutes: 7, lessonNumber: 10)
            ]
        case "pl":
            return [
                LanguageLesson(title: "Powitania", content: "Cześć (Hello), Dzień dobry (Good day), Dobry wieczór (Good evening), Do widzenia (Goodbye).", languageCode: "pl", estimatedMinutes: 5, lessonNumber: 1),
                LanguageLesson(title: "Liczby 1-10", content: "jeden, dwa, trzy, cztery, pięć, sześć, siedem, osiem, dziewięć, dziesięć. Polish numbers.", languageCode: "pl", estimatedMinutes: 4, lessonNumber: 2),
                LanguageLesson(title: "Rodzina", content: "rodzina (family), ojciec (father), matka (mother), brat (brother), siostra (sister).", languageCode: "pl", estimatedMinutes: 6, lessonNumber: 3),
                LanguageLesson(title: "Kolory", content: "czerwony (red), niebieski (blue), zielony (green), żółty (yellow), czarny (black), biały (white).", languageCode: "pl", estimatedMinutes: 4, lessonNumber: 4),
                LanguageLesson(title: "Jedzenie", content: "chleb (bread), woda (water), kawa (coffee), piwo (beer), jabłko (apple).", languageCode: "pl", estimatedMinutes: 7, lessonNumber: 5),
                LanguageLesson(title: "Dni Tygodnia", content: "poniedziałek, wtorek, środa, czwartek, piątek, sobota, niedziela. Polish days of the week.", languageCode: "pl", estimatedMinutes: 5, lessonNumber: 6),
                LanguageLesson(title: "Podstawowe Czasowniki", content: "być (to be), mieć (to have), iść (to go), przyjść (to come), mówić (to speak).", languageCode: "pl", estimatedMinutes: 8, lessonNumber: 7),
                LanguageLesson(title: "Pogoda", content: "pogoda (weather), słońce (sun), deszcz (rain), śnieg (snow), wiatr (wind).", languageCode: "pl", estimatedMinutes: 5, lessonNumber: 8),
                LanguageLesson(title: "Czas", content: "czas (time), godzina (hour), minuta (minute), dziś (today), jutro (tomorrow).", languageCode: "pl", estimatedMinutes: 6, lessonNumber: 9),
                LanguageLesson(title: "Podstawowe Zwroty", content: "Jak się masz? (How are you?), Dziękuję (Thank you), Proszę (Please/You're welcome), Przepraszam (Excuse me).", languageCode: "pl", estimatedMinutes: 7, lessonNumber: 10)
            ]
        case "tr":
            return [
                LanguageLesson(title: "Selamlaşma", content: "Merhaba (Hello), Günaydın (Good morning), İyi akşamlar (Good evening), Hoşça kal (Goodbye).", languageCode: "tr", estimatedMinutes: 5, lessonNumber: 1),
                LanguageLesson(title: "Sayılar 1-10", content: "bir, iki, üç, dört, beş, altı, yedi, sekiz, dokuz, on. Learn Turkish numbers from one to ten.", languageCode: "tr", estimatedMinutes: 4, lessonNumber: 2),
                LanguageLesson(title: "Aile", content: "aile (family), baba (father), anne (mother), erkek kardeş (brother), kız kardeş (sister).", languageCode: "tr", estimatedMinutes: 6, lessonNumber: 3),
                LanguageLesson(title: "Renkler", content: "kırmızı (red), mavi (blue), yeşil (green), sarı (yellow), siyah (black), beyaz (white).", languageCode: "tr", estimatedMinutes: 4, lessonNumber: 4),
                LanguageLesson(title: "Yiyecek ve İçecek", content: "ekmek (bread), su (water), kahve (coffee), çay (tea), elma (apple).", languageCode: "tr", estimatedMinutes: 7, lessonNumber: 5),
                LanguageLesson(title: "Haftanın Günleri", content: "Pazartesi, Salı, Çarşamba, Perşembe, Cuma, Cumartesi, Pazar. Turkish days of the week.", languageCode: "tr", estimatedMinutes: 5, lessonNumber: 6),
                LanguageLesson(title: "Temel Fiiller", content: "olmak (to be), sahip olmak (to have), gitmek (to go), gelmek (to come), konuşmak (to speak).", languageCode: "tr", estimatedMinutes: 8, lessonNumber: 7),
                LanguageLesson(title: "Hava Durumu", content: "hava (weather), güneş (sun), yağmur (rain), kar (snow), rüzgar (wind).", languageCode: "tr", estimatedMinutes: 5, lessonNumber: 8),
                LanguageLesson(title: "Zaman", content: "zaman (time), saat (hour), dakika (minute), bugün (today), yarın (tomorrow).", languageCode: "tr", estimatedMinutes: 6, lessonNumber: 9),
                LanguageLesson(title: "Temel İfadeler", content: "Nasılsın? (How are you?), Teşekkür ederim (Thank you), Rica ederim (You're welcome), Affedersiniz (Excuse me).", languageCode: "tr", estimatedMinutes: 7, lessonNumber: 10)
            ]
        case "ja":
            return [
                LanguageLesson(title: "Coming Soon", content: "Japanese lessons will be available soon. Stay tuned for an amazing journey into Japanese language and culture!", languageCode: "ja", estimatedMinutes: 1, lessonNumber: 1)
            ]
        default:
            return []
        }
    }
}

struct Phrase: Identifiable, Codable {
    let id: UUID
    let original: String
    let translation: String
    let languageCode: String
    let category: String
    let audioURL: String?
    var isBookmarked: Bool = false
    let difficulty: Language.LanguageDifficulty
    let usage: String
    let examples: [String]
    
    init(original: String, translation: String, languageCode: String, category: String, audioURL: String? = nil, isBookmarked: Bool = false, difficulty: Language.LanguageDifficulty, usage: String, examples: [String]) {
        self.id = UUID()
        self.original = original
        self.translation = translation
        self.languageCode = languageCode
        self.category = category
        self.audioURL = audioURL
        self.isBookmarked = isBookmarked
        self.difficulty = difficulty
        self.usage = usage
        self.examples = examples
    }
}

// Sample data for development
extension Language {
    static let sampleLanguages: [Language] = [
        Language(name: "German", code: "de", flag: "🇩🇪", difficulty: .intermediate, description: "Master the precise and logical German language", isAvailable: true),
        Language(name: "French", code: "fr", flag: "🇫🇷", difficulty: .beginner, description: "Learn the elegant language of love and culture", isAvailable: true),
        Language(name: "Italian", code: "it", flag: "🇮🇹", difficulty: .beginner, description: "Discover the melodic and expressive Italian language", isAvailable: true),
        Language(name: "Polish", code: "pl", flag: "🇵🇱", difficulty: .advanced, description: "Explore the rich and complex Polish language", isAvailable: true),
        Language(name: "Turkish", code: "tr", flag: "🇹🇷", difficulty: .intermediate, description: "Learn Turkish, the bridge between Europe and Asia", isAvailable: true),
        Language(name: "Japanese", code: "ja", flag: "🇯🇵", difficulty: .expert, description: "Coming soon - The fascinating Japanese language", isAvailable: false)
    ]
}

// MARK: - Extensions
extension Language.LanguageDifficulty {
    var iconColor: String {
        return self.color
    }
}
