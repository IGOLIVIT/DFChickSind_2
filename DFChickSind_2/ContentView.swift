//
//  ContentView.swift
//  LinguisticBoost
//
//  Created by IGOR on 10/08/2025.
//

import SwiftUI
import UserNotifications
import Combine

enum MainTab: String, CaseIterable {
        case home = "Home"
        case map = "Map"
        case quiz = "Quiz"
        case hub = "Community"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .map: return "map.fill"
            case .quiz: return "questionmark.circle.fill"
            case .hub: return "person.3.fill"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .home: return "house.fill"
            case .map: return "map.fill"
            case .quiz: return "questionmark.circle.fill"
            case .hub: return "person.3.fill"
            }
        }
    }

struct ContentView: View {
    @StateObject private var appState = AppState()
    @StateObject private var appsFlyerService = AppsFlyerService.shared
    @StateObject private var configService = ConfigService.shared
    
    @State private var showNotificationPermission = false
    @State private var isInitializing = true
    @State private var initializationError: String?
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            mainContent
            
            if showNotificationPermission {
                NotificationPermissionView(
                    onPermissionGranted: {
                        handleNotificationPermissionGranted()
                    },
                    onPermissionSkipped: {
                        handleNotificationPermissionSkipped()
                    }
                )
                .environmentObject(appState)
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .environmentObject(appState)
        .onAppear {
            // Устанавливаем ссылку на AppState для PushNotificationService
            PushNotificationService.shared.appState = appState
            initializeApp()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            handleAppDidBecomeActive()
        }
        .alert(isPresented: .constant(initializationError != nil)) {
            Alert(
                title: Text("Initialization Error"),
                message: Text(initializationError ?? ""),
                dismissButton: .default(Text("Retry")) {
                    initializeApp()
                }
            )
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        switch appState.appMode {
        case .undefined:
            if isInitializing {
                LoadingView()
            } else {
                ErrorView(
                    title: "Error",
                    message: "Error while getting app state",
                    buttonTitle: "Retry"
                ) {
                    initializeApp()
                }
            }
            
        case .webView:
            WebViewScreen()
                .environmentObject(appState)
            
        case .game:
            ZaglushkaView()
        }
    }
    
    private func initializeApp() {
        print("🚀 ===== APP INITIALIZATION STARTED =====")
        print("⏰ Init Time: \(Date())")
        print("📱 Current App Mode: \(appState.appMode.rawValue)")
        print("🔄 Is First Launch: \(appState.isFirstLaunch)")
        
        isInitializing = true
        initializationError = nil
        
        // Проверяем конфигурацию проекта и SDK
        DataManager.printFullStatus()
        
        print("🔐 Requesting tracking permission...")
        appsFlyerService.requestTrackingPermission { granted in
            print("🔐 Tracking permission result: \(granted ? "granted" : "denied")")
            print("🚀 Initializing AppsFlyer SDK...")
            appsFlyerService.initializeAppsFlyer()
            
            print("📊 Setting conversion data callback...")
            appsFlyerService.setConversionDataCallback { conversionData in
                print("📊 Conversion data callback triggered!")
                self.handleConversionData(conversionData)
            }
        }
        print("==========================================")
    }
    
    private func handleConversionData(_ conversionData: [String: Any]) {
        appState.saveConversionData(conversionData)
        
        if let appsflyerID = appsFlyerService.getAppsFlyerUID() {
            appState.saveAppsFlyerID(appsflyerID)
        }
        
        if configService.shouldRecheckConversion(conversionData: conversionData) {
            configService.recheckConversionData(appsflyerID: appState.appsflyerID ?? "") { result in
                switch result {
                case .success(let newData):
                    self.processConversionData(newData)
                case .failure:
                    self.processConversionData(conversionData)
                }
            }
        } else {
            processConversionData(conversionData)
        }
    }
    
    private func processConversionData(_ conversionData: [String: Any]) {
        if !appState.isFirstLaunch && appState.appMode != .undefined {
            isInitializing = false
            handleAppModeSet()
            return
        }
        
        guard configService.isConnected else {
            handleNoInternetConnection()
            return
        }
        
        // Начинаем ожидать push токен
        appState.startWaitingForPushToken()
        
        // Ждем готовности push токена
        waitForPushTokenAndFetchConfig(conversionData: conversionData)
    }
    
    private func waitForPushTokenAndFetchConfig(conversionData: [String: Any]) {
        // Если токен уже готов, сразу отправляем запрос
        if appState.isPushTokenReady {
            sendConfigRequest(conversionData: conversionData)
            return
        }
        
        // Иначе ждем изменения состояния
        appState.$isPushTokenReady
            .filter { $0 } // Ждем когда станет true
            .first()
            .sink { _ in
                print("✅ Push token is ready, sending config request...")
                self.sendConfigRequest(conversionData: conversionData)
            }
            .store(in: &cancellables)
    }
    
    private func sendConfigRequest(conversionData: [String: Any]) {
        configService.fetchConfig(
            conversionData: conversionData,
            appsflyerID: appState.appsflyerID,
            pushToken: appState.pushToken
        ) { result in
            DispatchQueue.main.async {
                self.isInitializing = false
                
                switch result {
                case .success(let response):
                    if let url = response.url, let expires = response.expires {
                        self.appState.saveURL(url, expires: expires)
                        self.appState.setAppMode(.webView)
                        self.handleAppModeSet()
                    } else {
                        self.handleConfigError(.invalidResponse)
                    }
                    
                case .failure(let error):
                    self.handleConfigError(error)
                }
            }
        }
    }
    
    private func handleConfigError(_ error: ConfigError) {
        switch error {
        case .serverError(let code, _) where code == 404 || code >= 400:
            appState.setAppMode(.game)
            handleAppModeSet()
            
        case .noInternetConnection:
            handleNoInternetConnection()
            
        default:
            if let savedURL = appState.currentURL, !savedURL.isEmpty {
                appState.setAppMode(.webView)
                handleAppModeSet()
            } else {
                appState.setAppMode(.game)
                handleAppModeSet()
            }
        }
    }
    
    private func handleNoInternetConnection() {
        if let savedURL = appState.currentURL, !savedURL.isEmpty {
            appState.setAppMode(.webView)
            handleAppModeSet()
        } else {
            appState.setAppMode(.game)
            handleAppModeSet()
        }
    }
    
    private func handleAppModeSet() {
        if appState.appMode == .webView && appState.shouldShowNotificationPermission() {
            showNotificationPermission = true
        }
    }
    
    private func handleNotificationPermissionGranted() {
        showNotificationPermission = false
        // При согласии НЕ сохраняем отказ - пользователь может еще отказаться в системном диалоге
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    private func handleNotificationPermissionSkipped() {
        showNotificationPermission = false
        // При отказе на кастомном экране - сохраняем дату для повтора через 3 дня
        appState.saveNotificationPermissionDenied()
    }
    
    private func handleAppDidBecomeActive() {
        if appState.appMode == .webView && appState.isURLExpired() {
            refreshWebViewURL()
        }
    }
    
    private func refreshWebViewURL() {
        guard let conversionData = appState.conversionData else { return }
        
        configService.fetchConfig(
            conversionData: conversionData,
            appsflyerID: appState.appsflyerID,
            pushToken: appState.pushToken
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let url = response.url, let expires = response.expires {
                        self.appState.saveURL(url, expires: expires)
                    }
                case .failure:
                    break
                }
            }
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: MainTab
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(MainTab.home)
                
                LanguageMapView()
                    .tag(MainTab.map)
                
                QuizView()
                    .tag(MainTab.quiz)
                
                CollaborationHubView()
                    .tag(MainTab.hub)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            print("📱 MainTabView: Appeared, selected tab: \(selectedTab)")
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    
    var body: some View {
        HStack {
            ForEach(MainTab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    onTap: {
                        withAnimation(.smooth) {
                            selectedTab = tab
                        }
                    }
                )
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xl)
                .fill(Color.appBackground)
                .shadow(color: Color.neuDark, radius: 8, x: 0, y: -4)
                .shadow(color: Color.neuLight, radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.md)
    }
}

struct TabBarButton: View {
    let tab: MainTab
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .primaryYellow : .textSecondary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(tab.rawValue)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .primaryYellow : .textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(isSelected ? Color.primaryYellow.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .stroke(isSelected ? Color.primaryYellow.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.smooth, value: isSelected)
    }
}

// MARK: - Supporting Views

struct AppLoadingView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // App logo
            Image(systemName: "globe")
                .font(.system(size: 80))
                .foregroundColor(.primaryYellow)
                .glow(color: .primaryYellow, radius: 20)
            
            VStack(spacing: Spacing.sm) {
                Text("LinguisticBoost")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("Loading your language journey...")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryYellow))
                .scaleEffect(1.2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackground()
    }
}

struct ErrorView2: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.systemRed)
            
            VStack(spacing: Spacing.sm) {
                Text("Something went wrong")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
            
            Button("Try Again") {
                onRetry()
            }
            .primaryButtonStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackground()
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
