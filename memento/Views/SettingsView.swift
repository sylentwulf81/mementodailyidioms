//
//  SettingsView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("useSystemVoice") private var useSystemVoice = true
    @AppStorage("useJapaneseInterface") private var useJapaneseInterface = true
    @AppStorage("isPro") private var isPro = false
    @EnvironmentObject private var paywallManager: PaywallManager
    @State private var showingAbout = false
    @State private var showingAITranslation = false
    @EnvironmentObject private var languageService: LanguageService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // PRO Upgrade Card (if not premium)
                    if !isPro {
                        ProUpgradeCard {
                            paywallManager.showPaywall()
                        }
                    }
                    
                    // Subscription Section
                    SettingsSection(title: languageService.subscriptionLabel) {
                        SettingsCard {
                            SettingsRow(
                                icon: "crown.fill",
                                iconColor: .orange,
                                title: isPro ? languageService.proMemberLabel : languageService.freePlanLabel,
                                subtitle: isPro ? languageService.allFeaturesAvailable : languageService.basicFeaturesOnly,
                                action: isPro ? nil : {
                                    paywallManager.showPaywall()
                                }
                            )
                            
                            if isPro {
                                SettingsRow(
                                    icon: "arrow.clockwise",
                                    iconColor: .blue,
                                    title: languageService.restorePurchasesLabel,
                                    action: {
                                        // TODO: Implement StoreKit2 restore
                                    }
                                )
                            }
                        }
                    }
                    
                    // Interface Section
                    SettingsSection(title: languageService.interfaceLabel) {
                        SettingsCard {
                            // Language Interface Picker
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(languageService.languageInterfaceLabel)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                Picker("Language Interface", selection: $useJapaneseInterface) {
                                    Text("English").tag(false)
                                    Text("日本語").tag(true)
                                }
                                .pickerStyle(.menu)
                                .onChange(of: useJapaneseInterface) { oldValue, newValue in
                                    languageService.objectWillChange.send()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            // Audio Settings Toggle
                            HStack(spacing: 12) {
                                Image(systemName: "speaker.wave.2")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(languageService.audioSettingsLabel)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(useSystemVoice ? (languageService.isJapanese ? "システム音声" : "System Voice") : (languageService.isJapanese ? "カスタム音声" : "Custom Voice"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle(languageService.isJapanese ? "カスタム音声" : "Custom Voice", isOn: Binding(
                                    get: { !useSystemVoice },
                                    set: { newValue in
                                        if newValue && !isPro {
                                            // User tried to enable Custom Voice but isn't Pro
                                            paywallManager.showPaywall()
                                            // Don't change the value - keep it as System Voice
                                        } else {
                                            useSystemVoice = !newValue
                                        }
                                    }
                                ))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            // Audio Settings Explainer
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .frame(width: 24, height: 24)
                                
                                Text(languageService.isJapanese ? "カスタム音声は、ネイティブスピーカーがイディオムをどのように言うかを表現する自然な音声です。" : "Custom Voices are natural-sounding voices that express how the idioms would be said by a native speaker.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        }
                    }
                    
                    // Feedback & Support Section
                    SettingsSection(title: languageService.feedbackSupportLabel) {
                        SettingsCard {
                            SettingsRow(
                                icon: "envelope",
                                iconColor: .blue,
                                title: languageService.sendFeedbackLabel,
                                subtitle: languageService.weLoveToHearFromYou,
                                action: {
                                    if let url = URL(string: "mailto:support@infinitytrigger.com") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                            
                            SettingsRow(
                                icon: "star",
                                iconColor: .blue,
                                title: languageService.rateAppLabel,
                                subtitle: languageService.thankYouForSupport,
                                action: {
                                    // TODO: Implement App Store review
                                }
                            )
                            
                            SettingsRow(
                                icon: "info.circle",
                                iconColor: .blue,
                                title: languageService.aboutMementoLabel,
                                action: {
                                    showingAbout = true
                                }
                            )
                        }
                    }
                    
                    // App Info Section
                    SettingsSection(title: languageService.appInfoLabel) {
                        SettingsCard {
                            SettingsRow(
                                icon: "info.circle",
                                iconColor: .gray,
                                title: languageService.versionLabel,
                                subtitle: "1.1.0",
                                action: nil
                            )
                            
                            SettingsRow(
                                icon: "hand.raised",
                                iconColor: .blue,
                                title: languageService.privacyPolicyLabel,
                                action: {
                                    // TODO: Navigate to Privacy Policy
                                }
                            )
                            
                            SettingsRow(
                                icon: "doc.text",
                                iconColor: .blue,
                                title: languageService.termsOfServiceLabel,
                                action: {
                                    // TODO: Navigate to Terms of Service
                                }
                            )
                        }
                    }
                    
                            // Developer Tools (Debug only)
        #if DEBUG
        SettingsSection(title: "DEVELOPER TOOLS") {
            SettingsCard {
                DeveloperToolsSection()
            }
        }
        
        // AI Translation Feature (Debug only)
        #if DEBUG
        SettingsSection(title: "AI FEATURES") {
            SettingsCard {
                SettingsRow(
                    icon: "brain.head.profile",
                    iconColor: .purple,
                    title: "AI Translation",
                    subtitle: "Translate Japanese to English with matching idioms",
                    action: {
                        showingAITranslation = true
                    }
                )
            }
        }
        #endif
        #endif
                }
                .padding()
            }
            .navigationTitle(languageService.settingsTitle)
		.sheet(isPresented: paywallManager.isShowingBinding) {
                PaywallView()
                    .environmentObject(paywallManager)
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingAITranslation) {
                AITranslationView()
            }
        }
    }
}

// MARK: - Supporting Views

struct ProUpgradeCard: View {
    let onUpgrade: () -> Void
    
    var body: some View {
        Button(action: onUpgrade) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Memento PRO")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("PRO")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    
                    Text("Unlock all levels & features")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Text("Try for free >")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.blue, .blue.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            content
        }
    }
}

struct SettingsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    
    init(icon: String, iconColor: Color, title: String, subtitle: String? = nil, action: (() -> Void)? = nil) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .disabled(action == nil)
    }
}

struct DeveloperToolsSection: View {
    @EnvironmentObject private var userProgressService: UserProgressService
    @StateObject private var dailyIdiomService = DailyIdiomService()
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    @AppStorage("isPro") private var isPro = false
    
    var body: some View {
        // Date advancement
        VStack(alignment: .leading, spacing: 12) {
            Text("Test Date Advancement")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Current: \(Date().formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                Button("Advance Date") {
                    showingDatePicker = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .controlSize(.small)
                
                if UserDefaults.standard.object(forKey: "testDate") != nil {
                    HStack {
                        Text("Test date active")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Button("Clear Test Date") {
                            clearTestDate()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .controlSize(.small)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        
        // Premium toggle
        VStack(alignment: .leading, spacing: 12) {
            Text("Premium Status")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Current: \(isPro ? "Premium" : "Free")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                Button(isPro ? "Switch to Free" : "Switch to Premium") {
                    isPro.toggle()
                }
                .buttonStyle(.borderedProminent)
                .tint(isPro ? .red : .green)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 8)
        
        // Progress reset
        VStack(alignment: .leading, spacing: 12) {
            Text("Reset Progress")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(spacing: 8) {
                Text("Clear all learning data")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Reset All Progress") {
                    resetAllProgress()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 8)
        
        // Simulate actions
        VStack(alignment: .leading, spacing: 12) {
            Text("Simulate Actions")
                .font(.subheadline)
                .fontWeight(.medium)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                Button("View Idiom") {
                    userProgressService.recordIdiomView()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .controlSize(.small)
                
                Button("Complete Quiz") {
                    userProgressService.recordQuizCompletion()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.small)
                
                Button("Add Test Favorites") {
                    addTestFavorites()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.small)
                
                Button("Clear Favorites") {
                    clearAllFavorites()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.small)
                
                Button("Learn Idiom") {
                    simulateLearnIdiom()
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 8)
        
        // Current stats
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Stats")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Viewed: \(userProgressService.totalIdiomsViewed)")
                    .font(.caption)
                Text("Learned: \(userProgressService.totalIdiomsLearned)")
                    .font(.caption)
                Text("Quizzes: \(userProgressService.totalQuizzesCompleted)")
                    .font(.caption)
                Text("Favorites: \(userProgressService.totalFavoritesAdded)")
                    .font(.caption)
                Text("Streak: \(userProgressService.currentStreak)")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        
        // Current favorites info
        VStack(alignment: .leading, spacing: 8) {
            Text("Favorites Info")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Favorites: \(userProgressService.getFavoriteIdiomCount())")
                    .font(.caption)
                Text("Favorite IDs: \(userProgressService.getFavoriteIdiomIds().joined(separator: ", "))")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        
        // Current daily idiom
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Idiom")
                .font(.subheadline)
                .fontWeight(.medium)
            
            let todaysIdiom = dailyIdiomService.getTodaysIdiom(with: userProgressService)
            VStack(alignment: .leading, spacing: 4) {
                Text("Title: \(todaysIdiom.title)")
                    .font(.caption)
                Text("Level: \(todaysIdiom.level)")
                    .font(.caption)
                Text("Premium: \(todaysIdiom.isPremium ? "Yes" : "No")")
                    .font(.caption)
                Text("Learned: \(userProgressService.hasLearnedIdiom(todaysIdiom.id) ? "Yes" : "No")")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate) {
                advanceDate(to: selectedDate)
            }
        }
    }
    
    private func advanceDate(to date: Date) {
        // Store the test date in UserDefaults
        UserDefaults.standard.set(date, forKey: "testDate")
        
        // Force refresh of daily idiom
        dailyIdiomService.currentIdiom = dailyIdiomService.getTodaysIdiom(with: userProgressService)
    }
    
    private func clearTestDate() {
        UserDefaults.standard.removeObject(forKey: "testDate")
        print("Test date cleared.")
    }
    
    private func resetAllProgress() {
        // Reset all progress data
        UserDefaults.standard.removeObject(forKey: "idiomsViewed")
        UserDefaults.standard.removeObject(forKey: "quizzesCompleted")
        UserDefaults.standard.removeObject(forKey: "favoritesAdded")
        UserDefaults.standard.removeObject(forKey: "streakDays")
        UserDefaults.standard.removeObject(forKey: "lastActiveDate")
        UserDefaults.standard.removeObject(forKey: "viewedIdioms")
        UserDefaults.standard.removeObject(forKey: "learnedIdioms")
        UserDefaults.standard.removeObject(forKey: "dailyRotationIdioms")
        UserDefaults.standard.removeObject(forKey: "milestone5Reached")
        UserDefaults.standard.removeObject(forKey: "milestone10Reached")
        UserDefaults.standard.removeObject(forKey: "milestone20Reached")
        UserDefaults.standard.removeObject(forKey: "testDate")
        
        // Reset the user progress service
        userProgressService.resetAllProgress()
    }
    
    private func simulateLearnIdiom() {
        // Get today's idiom and mark it as learned
        let todaysIdiom = dailyIdiomService.getTodaysIdiom(with: userProgressService)
        userProgressService.recordLearnedIdiom(todaysIdiom.id)
        
        // Force refresh of daily idiom to show the new one
        dailyIdiomService.currentIdiom = dailyIdiomService.getTodaysIdiom(with: userProgressService)
    }
    
    private func addTestFavorites() {
        // Add a few test idioms as favorites
        let allIdioms = dailyIdiomService.loadIdioms()
        let testIds = Array(allIdioms.prefix(3)) // First 3 idioms
        
        for idiom in testIds {
            userProgressService.addFavoriteIdiom(idiom.id)
        }
        
        print("Added \(testIds.count) test favorites")
    }
    
    private func clearAllFavorites() {
        // Clear all favorites
        userProgressService.clearAllFavorites()
        print("Cleared all favorites")
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Test Date")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                    
                    Button("Confirm") {
                        onConfirm()
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LanguageService())
        .environmentObject(PaywallManager())
} 