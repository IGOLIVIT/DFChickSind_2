//
//  LanguageMapView.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import SwiftUI

struct LanguageMapView: View {
    @StateObject private var viewModel = LanguageMapViewModel()
    @State private var selectedNode: MapNode?
    @State private var selectedTopic: LanguageTopic?
    @State private var selectedFactForSheet: LanguageFact?
    @State private var showTopicDetail = false
    @State private var showFilters = false
    @State private var selectedCategory: LanguageTopic.TopicCategory?
    @State private var selectedDifficulty: Language.LanguageDifficulty?
    @State private var searchText = ""
    @State private var mapScale: CGFloat = 1.0
    @State private var mapOffset: CGSize = .zero
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Language History & Facts Header
                VStack(spacing: 12) {
                    Text("🌍 Language World")
                        .font(.largeTitle)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Discover fascinating facts and history about languages")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Search Bar for facts
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textSecondary)
                    TextField("Search language facts...", text: $searchText)
                        .foregroundColor(.textPrimary)
                }
                .padding()
                .neumorphic()
                .padding(.horizontal, 20)
                
                // Language History & Facts Cards
                VStack(spacing: 16) {
                    ForEach(getLanguageFacts(), id: \.id) { fact in
                        LanguageFactCard(fact: fact) {
                            // Напрямую показываем детали факта
                            print("🗺️ Tapped on fact: \(fact.title)")
                            selectedFactForSheet = fact
                            print("🗺️ selectedFactForSheet set to: \(selectedFactForSheet?.title ?? "nil")")
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
            .padding(.bottom, 20)
        }
        .appBackground()
        .sheet(item: $selectedFactForSheet) { fact in
            LanguageFactDetailSheet(
                fact: fact,
                onDismiss: {
                    print("🗺️ Dismissing sheet")
                    selectedFactForSheet = nil
                }
            )
            .onAppear {
                print("🗺️ Sheet opened, showing: \(fact.title)")
            }
        }
        .onAppear {
            print("🌍 LanguageWorldView: onAppear called")
        }
    }
    
    private func getLanguageFacts() -> [LanguageFact] {
        let allFacts = [
            LanguageFact(
                id: "german_history",
                title: "🇩🇪 The Evolution of German",
                preview: "German evolved from Old High German and has influenced many languages...",
                fullContent: "German, or Deutsch, evolved from Old High German around the 6th century. It belongs to the West Germanic branch of the Indo-European language family. German has significantly influenced English, with many loanwords like 'kindergarten', 'wanderlust', and 'schadenfreude'. The language underwent major standardization during the Luther Bible translation in the 16th century. Today, German is spoken by over 100 million people worldwide and is the most widely spoken native language in Europe. The German language has a rich literary tradition, producing famous writers like Goethe, Schiller, and the Brothers Grimm.",
                languageCode: "de",
                category: .history,
                readTime: 3
            ),
            LanguageFact(
                id: "french_culture",
                title: "🇫🇷 French: Language of Diplomacy",
                preview: "French was the international language of diplomacy for centuries...",
                fullContent: "For over 300 years, French was the lingua franca of international diplomacy, science, and culture. The Treaty of Versailles in 1919 was the last major international treaty written exclusively in French. French is derived from Latin and evolved in the northern regions of France. The Académie française, established in 1635, continues to regulate the French language today. French is spoken by 280 million people worldwide and is an official language in 29 countries. The language is known for its precise grammar rules and beautiful literary tradition, producing writers like Victor Hugo, Marcel Proust, and Simone de Beauvoir.",
                languageCode: "fr",
                category: .culture,
                readTime: 4
            ),
            LanguageFact(
                id: "italian_art",
                title: "🇮🇹 Italian: The Language of Art",
                preview: "Italian Renaissance gave birth to countless artistic masterpieces...",
                fullContent: "Italian, descended from Latin, became the language of Renaissance art and culture. During the 14th-16th centuries, Italian artists, writers, and thinkers like Leonardo da Vinci, Michelangelo, and Dante Alighieri created works that still influence the world today. Dante's 'Divine Comedy' helped establish the Tuscan dialect as the basis for modern Italian. Italian has the highest number of UNESCO World Heritage Sites of any country. The language is known for its musicality - most musical terms (forte, allegro, soprano) come from Italian. Today, Italian is spoken by 65 million native speakers and is studied worldwide for its connection to art, music, and cuisine.",
                languageCode: "it",
                category: .culture,
                readTime: 4
            ),
            LanguageFact(
                id: "polish_complexity",
                title: "🇵🇱 Polish: A Complex Beauty",
                preview: "Polish has one of the most complex grammar systems in the world...",
                fullContent: "Polish belongs to the West Slavic language family and is known for its complex grammar system with 7 cases, 3 genders, and intricate consonant clusters. The language has survived despite centuries of foreign occupation and attempts at suppression. Polish literature flourished in the 19th century with writers like Adam Mickiewicz and Henryk Sienkiewicz, who won the Nobel Prize in Literature. The language contains many borrowed words from Latin, German, and French, reflecting Poland's rich cultural history. Modern Polish is spoken by about 45 million people, mostly in Poland. The language uses the Latin alphabet with additional diacritical marks like ą, ć, ę, ł, ń, ó, ś, ź, ż.",
                languageCode: "pl",
                category: .linguistics,
                readTime: 4
            ),
            LanguageFact(
                id: "turkish_bridge",
                title: "🇹🇷 Turkish: Bridge Between Worlds",
                preview: "Turkish connects Europe and Asia, bridging two continents...",
                fullContent: "Turkish is a Turkic language that serves as a bridge between Europe and Asia, reflecting Turkey's unique geographical position. The language underwent a major reform in the 1920s under Mustafa Kemal Atatürk, switching from Arabic script to Latin alphabet. Turkish has a unique grammatical feature called vowel harmony, where vowels in a word must harmonize with each other. The language has influenced many Balkan languages and has borrowed extensively from Arabic, Persian, and French. Turkish is spoken by about 80 million people as a native language and is the official language of Turkey and Northern Cyprus. The language family extends from Turkey to Central Asia and even parts of Siberia.",
                languageCode: "tr",
                category: .history,
                readTime: 4
            ),
            LanguageFact(
                id: "japanese_writing",
                title: "🇯🇵 Japanese: Three Writing Systems",
                preview: "Japanese uses three different writing systems simultaneously...",
                fullContent: "Japanese is unique in using three writing systems: Hiragana (phonetic syllabary), Katakana (for foreign words), and Kanji (Chinese characters). This complex system developed over centuries, with Chinese characters introduced in the 5th century. Japanese has elaborate honorific systems that reflect social hierarchies and relationships. The language has no grammatical gender or plural forms in the traditional sense. Japanese literature has a rich history, from classical works like 'The Tale of Genji' (considered the world's first novel) to modern masters like Haruki Murakami. About 125 million people speak Japanese, primarily in Japan, making it the 9th most spoken language in the world.",
                languageCode: "ja",
                category: .linguistics,
                readTime: 5
            )
        ]
        
        if searchText.isEmpty {
            return allFacts
        } else {
            return allFacts.filter { fact in
                fact.title.localizedCaseInsensitiveContains(searchText) ||
                fact.preview.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func getLanguageFactForTopic(_ topic: LanguageTopic) -> LanguageFact {
        return getLanguageFacts().first { $0.title.contains(topic.title) } ?? getLanguageFacts().first!
    }
    
    private func loadTestTopics() {
        print("🗺️ Loading test topics...")
        
        // Создаем тестовые топики если их нет
        let testTopics = [
            LanguageTopic(
                title: "Basic Vocabulary",
                description: "Learn essential words and phrases",
                languageCode: "en",
                category: .vocabulary,
                estimatedDuration: 15,
                progress: 0.3
            ),
            LanguageTopic(
                title: "Grammar Basics",
                description: "Fundamental grammar rules",
                languageCode: "en", 
                category: .grammar,
                estimatedDuration: 20,
                progress: 0.0
            ),
            LanguageTopic(
                title: "Pronunciation",
                description: "Learn correct pronunciation",
                languageCode: "en",
                category: .pronunciation,
                estimatedDuration: 25,
                isCompleted: true,
                progress: 1.0
            ),
            LanguageTopic(
                title: "Daily Conversations",
                description: "Practice everyday conversations",
                languageCode: "en",
                category: .conversation,
                estimatedDuration: 30,
                progress: 0.6
            ),
            LanguageTopic(
                title: "Business English",
                description: "Professional communication",
                languageCode: "en",
                category: .business,
                estimatedDuration: 40,
                progress: 0.0
            ),
            LanguageTopic(
                title: "Cultural Context",
                description: "Understanding cultural nuances",
                languageCode: "en",
                category: .culture,
                estimatedDuration: 35,
                progress: 0.2
            )
        ]
        
        // Добавляем топики в LanguageDataService
        LanguageDataService.shared.addTestTopics(testTopics)
        
        // Обновляем viewModel
        viewModel.refreshData()
        
        print("🗺️ Added \(testTopics.count) test topics")
    }
    
    private var filteredTopics: [LanguageTopic] {
        var topics = viewModel.topics
        
        // Filter by category
        if let category = selectedCategory {
            topics = topics.filter { $0.category == category }
        }
        
        // Note: Difficulty filtering removed as LanguageTopic doesn't have difficulty property
        
        // Filter by search text
        if !searchText.isEmpty {
            topics = topics.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return topics
    }
    
    private func isTopicUnlocked(_ topic: LanguageTopic) -> Bool {
        // Simple logic: first 3 topics are always unlocked
        // Others are unlocked if previous topics are completed
        guard let index = viewModel.topics.firstIndex(where: { $0.id == topic.id }) else { return false }
        
        if index < 3 { return true }
        
        // Check if previous topics are completed
        let previousTopics = Array(viewModel.topics[0..<index])
        return previousTopics.allSatisfy { $0.isCompleted }
    }
    
    private func resetMapView() {
        withAnimation(.smooth) {
            mapScale = 1.0
            mapOffset = .zero
        }
    }
    
    private func getTopicForNode(_ node: MapNode) -> LanguageTopic? {
        return viewModel.topics.first { $0.id.uuidString == node.id }
    }
}

// MARK: - Map Header
struct MapHeaderView: View {
    let selectedLanguage: Language?
    @Binding var showFilters: Bool
    let onLanguageSelect: (Language?) -> Void
    @StateObject private var languageDataService = LanguageDataService.shared
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            // Language selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    // All languages option
                    LanguageTab(
                        title: "All",
                        flag: "🌍",
                        isSelected: selectedLanguage == nil,
                        onTap: { onLanguageSelect(nil) }
                    )
                    
                    // Individual languages
                    ForEach(languageDataService.languages) { language in
                        LanguageTab(
                            title: language.name,
                            flag: language.flag,
                            isSelected: selectedLanguage?.id == language.id,
                            onTap: { onLanguageSelect(language) }
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
            
            // Progress summary
            if let language = selectedLanguage {
                LanguageProgressSummary(language: language)
            } else {
                OverallProgressSummary()
            }
        }
        .padding(.vertical, Spacing.md)
        .background(Color.appBackground)
    }
}

struct LanguageTab: View {
    let title: String
    let flag: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.xs) {
                Text(flag)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .black : .textPrimary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(isSelected ? Color.primaryYellow : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .stroke(Color.primaryYellow, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LanguageProgressSummary: View {
    let language: Language
    @StateObject private var viewModel = LanguageMapViewModel()
    
    var body: some View {
        if let progress = viewModel.getLanguageProgress(for: language.code) {
            HStack(spacing: Spacing.lg) {
                VStack {
                    Text("\(progress.completedTopics)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                VStack {
                    Text(String(format: "%.0f%%", progress.completionPercentage * 100))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGreen)
                    
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                VStack {
                    Text(progress.proficiencyLevel.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryYellow)
                    
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(Spacing.md)
            .neumorphic()
        }
    }
}

struct OverallProgressSummary: View {
    @StateObject private var viewModel = LanguageMapViewModel()
    
    var body: some View {
        let totalTopics = viewModel.topics.count
        let completedTopics = viewModel.topics.filter { $0.isCompleted }.count
        let progressPercentage = totalTopics > 0 ? Double(completedTopics) / Double(totalTopics) * 100 : 0
        
        HStack(spacing: Spacing.lg) {
            VStack {
                Text("\(completedTopics)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("Completed")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            VStack {
                Text("\(totalTopics)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("Total Topics")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            VStack {
                Text(String(format: "%.0f%%", progressPercentage))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryGreen)
                
                Text("Overall")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.md)
        .neumorphic()
    }
}

// MARK: - Interactive Map
struct InteractiveMapView: View {
    let nodes: [MapNode]
    @Binding var selectedNode: MapNode?
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    let onNodeTap: (MapNode) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Connection lines
                ForEach(nodes, id: \.id) { node in
                    ForEach(node.connections, id: \.self) { connectionId in
                        if let connectedNode = nodes.first(where: { $0.id == connectionId }) {
                            ConnectionLine(
                                from: node.position,
                                to: connectedNode.position,
                                isCompleted: node.isCompleted && connectedNode.isCompleted
                            )
                        }
                    }
                }
                
                // Topic nodes
                ForEach(nodes, id: \.id) { node in
                    TopicNode(
                        node: node,
                        isSelected: selectedNode?.id == node.id,
                        onTap: { onNodeTap(node) }
                    )
                    .position(node.position)
                }
            }
            .frame(width: geometry.size.width * 2, height: geometry.size.height * 2)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = max(0.5, min(3.0, value))
                        },
                    DragGesture()
                        .onChanged { value in
                            offset = value.translation
                        }
                )
            )
        }
        .clipped()
    }
}

struct ConnectionLine: View {
    let from: CGPoint
    let to: CGPoint
    let isCompleted: Bool
    
    var body: some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .stroke(
            isCompleted ? Color.primaryGreen : Color.textSecondary.opacity(0.3),
            lineWidth: isCompleted ? 3 : 2
        )
        .animation(.smooth, value: isCompleted)
    }
}

struct TopicNode: View {
    let node: MapNode
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(nodeBackgroundColor)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(nodeBorderColor, lineWidth: isSelected ? 3 : 2)
                    )
                    .neumorphic()
                
                VStack(spacing: Spacing.xs) {
                    Image(systemName: node.category.icon)
                        .font(.title3)
                        .foregroundColor(nodeIconColor)
                    
                    if node.progress > 0 && node.progress < 1 {
                        ProgressRing(
                            progress: node.progress,
                            lineWidth: 3,
                            backgroundColor: Color.gray.opacity(0.3),
                            foregroundColor: .primaryYellow
                        )
                        .frame(width: 20, height: 20)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.smooth, value: isSelected)
    }
    
    private var nodeBackgroundColor: Color {
        if node.isCompleted {
            return Color.primaryGreen.opacity(0.8)
        } else if node.isAvailable {
            return Color.primaryYellow.opacity(0.8)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var nodeBorderColor: Color {
        if node.isCompleted {
            return Color.primaryGreen
        } else if node.isAvailable {
            return Color.primaryYellow
        } else {
            return Color.gray
        }
    }
    
    private var nodeIconColor: Color {
        if node.isCompleted || node.isAvailable {
            return Color.black
        } else {
            return Color.gray
        }
    }
}

// MARK: - Map Controls
struct MapControlsView: View {
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    let onResetView: () -> Void
    
    var body: some View {
        HStack {
            Button(action: { scale = max(0.5, scale - 0.2) }) {
                Image(systemName: "minus.magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.textPrimary)
                    .padding(Spacing.sm)
                    .neumorphic()
            }
            
            Button(action: onResetView) {
                Image(systemName: "scope")
                    .font(.title2)
                    .foregroundColor(.textPrimary)
                    .padding(Spacing.sm)
                    .neumorphic()
            }
            
            Button(action: { scale = min(3.0, scale + 0.2) }) {
                Image(systemName: "plus.magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.textPrimary)
                    .padding(Spacing.sm)
                    .neumorphic()
            }
            
            Spacer()
            
            // Legend
            MapLegendView()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.appBackground)
    }
}

struct MapLegendView: View {
    @State private var showLegend = false
    
    var body: some View {
        Button(action: { showLegend.toggle() }) {
            Image(systemName: "questionmark.circle")
                .font(.title2)
                .foregroundColor(.textPrimary)
                .padding(Spacing.sm)
                .neumorphic()
        }
        .popover(isPresented: $showLegend) {
            LegendContent()
                .padding(Spacing.lg)
                .background(Color.appBackground)
        }
    }
}

struct LegendContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Map Legend")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            LegendItem(
                color: .primaryGreen,
                description: "Completed Topic"
            )
            
            LegendItem(
                color: .primaryYellow,
                description: "Available Topic"
            )
            
            LegendItem(
                color: .gray,
                description: "Locked Topic"
            )
            
            Text("Tap any available topic to start learning!")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

struct LegendItem: View {
    let color: Color
    let description: String
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Filter Sheet
struct MapFiltersSheet: View {
    @ObservedObject var viewModel: LanguageMapViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: Spacing.lg) {
                // Search
                SearchBar(text: $viewModel.searchText)
                
                // Category filter
                FilterSection(title: "Category") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: Spacing.sm) {
                        ForEach(LanguageTopic.TopicCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                category: category,
                                isSelected: viewModel.selectedCategory == category,
                                onTap: {
                                    viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                                }
                            )
                        }
                    }
                }
                
                // Sort order
                FilterSection(title: "Sort By") {
                    Picker("Sort Order", selection: $viewModel.sortOrder) {
                        ForEach(LanguageMapViewModel.SortOrder.allCases, id: \.self) { order in
                            Label(order.rawValue, systemImage: order.icon)
                                .tag(order)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Show completed toggle
                FilterSection(title: "Display Options") {
                    Toggle("Show Completed Topics", isOn: $viewModel.showCompleted)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                // Clear filters button
                Button("Clear All Filters") {
                    viewModel.clearFilters()
                }
                .secondaryButtonStyle()
            }
            .padding(Spacing.lg)
            .appBackground()
            .navigationTitle("Filter Topics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            
            TextField("Search topics...", text: $text)
                .foregroundColor(.textPrimary)
        }
        .padding(Spacing.md)
        .neumorphicInset()
    }
}

struct FilterSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            content
        }
    }
}

struct CategoryFilterButton: View {
    let category: LanguageTopic.TopicCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .black : .textPrimary)
                
                Text(category.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .black : .textPrimary)
            }
            .padding(Spacing.sm)
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(isSelected ? Color.primaryYellow : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(Color.primaryYellow, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Topic Detail Sheet
struct TopicDetailSheet: View {
    let topic: LanguageTopic
    @ObservedObject var viewModel: LanguageMapViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Topic header
                    TopicDetailHeader(topic: topic)
                    
                    // Progress section
                    if topic.progress > 0 {
                        TopicProgressSection(topic: topic)
                    }
                    
                    // Prerequisites
                    if !topic.prerequisites.isEmpty {
                        PrerequisitesSection(
                            topic: topic,
                            viewModel: viewModel
                        )
                    }
                    
                    // Description
                    TopicDescriptionSection(topic: topic)
                    
                    // Action buttons
                    TopicActionButtons(
                        topic: topic,
                        viewModel: viewModel,
                        onDismiss: {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
                .padding(Spacing.lg)
            }
            .appBackground()
            .navigationTitle(topic.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct TopicDetailHeader: View {
    let topic: LanguageTopic
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: topic.category.icon)
                .font(.system(size: 60))
                .foregroundColor(.primaryYellow)
                .glow(color: .primaryYellow, radius: 10)
            
            VStack(spacing: Spacing.sm) {
                Text(topic.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                Text(topic.title)
                    .font(.title1)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: Spacing.lg) {
                    Label("\(topic.estimatedDuration) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Label(topic.isCompleted ? "Completed" : "Available", systemImage: topic.isCompleted ? "checkmark.circle.fill" : "play.circle")
                        .font(.caption)
                        .foregroundColor(topic.isCompleted ? .primaryGreen : .primaryYellow)
                }
            }
        }
        .padding(Spacing.lg)
        .neumorphic()
    }
}

struct TopicProgressSection: View {
    let topic: LanguageTopic
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Text("Your Progress")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(Int(topic.progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.primaryYellow)
            }
            
            ProgressView(value: topic.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .primaryYellow))
                .scaleEffect(y: 3)
        }
        .padding(Spacing.md)
        .neumorphic()
    }
}

struct PrerequisitesSection: View {
    let topic: LanguageTopic
    @ObservedObject var viewModel: LanguageMapViewModel
    
    var body: some View {
        let prerequisites = viewModel.getPrerequisiteTopics(topic)
        
        if !prerequisites.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Prerequisites")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                ForEach(prerequisites, id: \.id) { prerequisite in
                    PrerequisiteCard(topic: prerequisite)
                }
            }
            .padding(Spacing.md)
            .neumorphic()
        }
    }
}

struct PrerequisiteCard: View {
    let topic: LanguageTopic
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: topic.category.icon)
                .font(.title3)
                .foregroundColor(topic.isCompleted ? .primaryGreen : .textSecondary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(topic.title)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                
                Text(topic.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: topic.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(topic.isCompleted ? .primaryGreen : .textSecondary)
        }
        .padding(Spacing.sm)
        .neumorphicInset()
    }
}

// MARK: - Simple Topic Card for Debug
struct SimpleTopicCard: View {
    let topic: LanguageTopic
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Category Icon
                Image(systemName: topic.category.icon)
                    .font(.title)
                    .foregroundColor(.primaryYellow)
                
                // Topic Title
                Text(topic.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Duration
                Text("\(topic.estimatedDuration) min")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Status
                if topic.isCompleted {
                    Text("✅ Done")
                        .font(.caption)
                        .foregroundColor(.primaryGreen)
                } else if topic.progress > 0 {
                    Text("\(Int(topic.progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.primaryYellow)
                } else {
                    Text("🚀 Start")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .neumorphic()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let category: LanguageTopic.TopicCategory?
    let isSelected: Bool
    let onTap: () -> Void
    
    private var title: String {
        category?.rawValue ?? "All"
    }
    
    private var icon: String {
        category?.icon ?? "rectangle.grid.2x2"
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .black : .textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.primaryYellow : Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Interactive Topic Card
struct InteractiveTopicCard: View {
    let topic: LanguageTopic
    let isUnlocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Topic Icon and Status
                ZStack {
                    Circle()
                        .fill(isUnlocked ? topicColor : Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    if isUnlocked {
                        Image(systemName: topic.category.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
                
                // Topic Info
                VStack(spacing: 4) {
                    Text(topic.title)
                        .font(.headline)
                        .foregroundColor(isUnlocked ? .textPrimary : .textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text("\(topic.estimatedDuration) min")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    // Progress Status
                    if isUnlocked {
                        if topic.isCompleted {
                            Text("✅ Completed")
                                .font(.caption)
                                .foregroundColor(.primaryGreen)
                        } else if topic.progress > 0 {
                            Text("\(Int(topic.progress * 100))% Complete")
                                .font(.caption)
                                .foregroundColor(.primaryYellow)
                        } else {
                            Text("🚀 Start Learning")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    } else {
                        Text("🔒 Locked")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(16)
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .neumorphic()
            .scaleEffect(isUnlocked ? 1.0 : 0.95)
            .opacity(isUnlocked ? 1.0 : 0.7)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked)
    }
    
    private var topicColor: Color {
        switch topic.category {
        case .vocabulary: return .primaryYellow
        case .grammar: return .primaryGreen
        case .pronunciation: return .blue
        case .conversation: return .purple
        case .culture: return .orange
        case .business: return .red
        }
    }
}

// MARK: - Enhanced Topic Detail Sheet
struct EnhancedTopicDetailSheet: View {
    let topic: LanguageTopic
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLesson = 0
    
    private let sampleLessons = [
        "Introduction to Topic",
        "Basic Concepts", 
        "Practice Exercises",
        "Advanced Topics",
        "Review & Assessment"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: topic.category.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.primaryYellow)
                            .padding(20)
                            .background(Circle().fill(Color.primaryYellow.opacity(0.2)))
                        
                        Text(topic.title)
                            .font(.largeTitle)
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text(topic.description)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    
                    // Lessons
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Lessons")
                            .font(.title2)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 20)
                        
                        ForEach(0..<sampleLessons.count, id: \.self) { index in
                            LessonRowView(
                                title: sampleLessons[index],
                                number: index + 1,
                                isCompleted: index < Int(topic.progress * Double(sampleLessons.count)),
                                isCurrent: index == selectedLesson
                            ) {
                                selectedLesson = index
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Start Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text(topic.progress > 0 ? "Continue Learning" : "Start Learning")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryYellow)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .appBackground()
            .navigationTitle("Topic Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Lesson Row View
struct LessonRowView: View {
    let title: String
    let number: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Lesson Number/Status
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.primaryGreen : (isCurrent ? Color.primaryYellow : Color.gray.opacity(0.3)))
                        .frame(width: 32, height: 32)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.white)
                    } else {
                        Text("\(number)")
                            .font(.caption)
                            .foregroundColor(isCurrent ? .black : .white)
                    }
                }
                
                // Lesson Title
                Text(title)
                    .font(.body)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                // Play Icon
                Image(systemName: "play.fill")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding()
            .neumorphic()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Enhanced Map Filters Sheet
struct EnhancedMapFiltersSheet: View {
    @Binding var selectedCategory: LanguageTopic.TopicCategory?
    @Binding var selectedDifficulty: Language.LanguageDifficulty?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Category")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(LanguageTopic.TopicCategory.allCases, id: \.self) { category in
                            FilterCategoryButtonView(
                                title: category.rawValue,
                                icon: category.icon,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                    }
                }
                
                // Note: Difficulty filtering temporarily removed
                
                Spacer()
            }
            .padding(20)
            .appBackground()
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct FilterCategoryButtonView: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .black : .textPrimary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .black : .textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.primaryYellow : Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilterDifficultyButtonView: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.body)
                .foregroundColor(isSelected ? .black : .textPrimary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.primaryYellow : Color.gray.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TopicDescriptionSection: View {
    let topic: LanguageTopic
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("About This Topic")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text(topic.description)
                .font(.body)
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
        }
        .padding(Spacing.md)
        .neumorphic()
    }
}

struct TopicActionButtons: View {
    let topic: LanguageTopic
    @ObservedObject var viewModel: LanguageMapViewModel
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            if viewModel.canStartTopic(topic) {
                if topic.isCompleted {
                    Button("Review Topic") {
                        // Navigate to topic content
                        onDismiss()
                    }
                    .primaryButtonStyle()
                } else {
                    Button("Start Learning") {
                        viewModel.startTopic(topic)
                        onDismiss()
                    }
                    .primaryButtonStyle()
                }
            } else {
                VStack(spacing: Spacing.sm) {
                    Text("Complete prerequisites to unlock this topic")
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button("View Prerequisites") {
                        // Scroll to prerequisites section
                    }
                    .secondaryButtonStyle()
                }
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryYellow))
                .scaleEffect(1.5)
            
            Text("Loading Language Map...")
                .font(.headline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

// MARK: - Topic Card View
struct TopicCardView: View {
    let topic: LanguageTopic
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Image(systemName: topic.category.icon)
                        .foregroundColor(.primaryYellow)
                        .font(.title2)
                    
                    Spacer()
                    
                    Text("\(topic.estimatedDuration)min")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Text(topic.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Text(topic.description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                Spacer()
            }
            .padding(Spacing.md)
            .frame(height: 120)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(PlainButtonStyle())
        .neumorphic()
    }
}

// MARK: - Language Facts Data Models
struct LanguageFact: Identifiable {
    let id: String
    let title: String
    let preview: String
    let fullContent: String
    let languageCode: String
    let category: FactCategory
    let readTime: Int
    
    enum FactCategory: String, CaseIterable {
        case history = "History"
        case culture = "Culture"
        case linguistics = "Linguistics"
        case literature = "Literature"
        
        var icon: String {
            switch self {
            case .history: return "clock.fill"
            case .culture: return "globe.europe.africa.fill"
            case .linguistics: return "textformat.abc"
            case .literature: return "book.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .history: return .orange
            case .culture: return .blue
            case .linguistics: return .purple
            case .literature: return .green
            }
        }
    }
}

struct LanguageFactCard: View {
    let fact: LanguageFact
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Category Icon
                VStack {
                    Image(systemName: fact.category.icon)
                        .font(.title2)
                        .foregroundColor(fact.category.color)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(fact.category.color.opacity(0.2))
                        )
                    
                    Text("\(fact.readTime) min")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(fact.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text(fact.preview)
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    
                    HStack {
                        Text(fact.category.rawValue)
                            .font(.caption)
                            .foregroundColor(fact.category.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(fact.category.color.opacity(0.2))
                            )
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .neumorphic()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LanguageFactDetailSheet: View {
    let fact: LanguageFact
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Simple Header
                    VStack(spacing: 12) {
                        Text(fact.category.icon)
                            .font(.system(size: 50))
                        
                        Text(fact.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text(fact.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 20)
                    
                    // Simple Content
                    Text(fact.fullContent)
                        .font(.body)
                        .foregroundColor(.textPrimary)
                        .padding(20)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Language Fact")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                onDismiss()
            })
        }
    }
}

#Preview {
    LanguageMapView()
}
