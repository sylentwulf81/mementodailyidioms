//
//  IdiomLibraryView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI
import SwiftData

struct IdiomLibraryView: View {
    @StateObject private var dailyIdiomService = DailyIdiomService()
    @EnvironmentObject private var userProgressService: UserProgressService
    @EnvironmentObject private var languageService: LanguageService
    @EnvironmentObject private var paywallManager: PaywallManager
    @AppStorage("isPro") private var isPro = false
    @State private var searchText = ""
    @State private var selectedIdiom: Idiom?
    @State private var showingUnlockPrompt = false
    @State private var showingLibraryInfo = false
    
    // Cached data to avoid repeated computations
    @State private var allIdioms: [Idiom] = []
    @State private var filteredIdioms: [Idiom] = []
    @State private var idiomsByLevel: [String: [Idiom]] = [:]
    @State private var sortedLevels: [String] = []
    
    private func loadAndCacheIdioms() {
        allIdioms = dailyIdiomService.loadIdioms()
        updateFilteredData()
    }
    
    private func updateFilteredData() {
        // Filter idioms based on search text
        if searchText.isEmpty {
            filteredIdioms = allIdioms
        } else {
            filteredIdioms = allIdioms.filter { idiom in
                idiom.title.localizedCaseInsensitiveContains(searchText) ||
                idiom.jpMeaning.localizedCaseInsensitiveContains(searchText) ||
                idiom.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Group by level
        idiomsByLevel = Dictionary(grouping: filteredIdioms) { $0.level }
        
        // Sort levels
        sortedLevels = ["A1", "A2", "B1", "B2", "C1", "C2"].filter { idiomsByLevel[$0] != nil }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(sortedLevels, id: \.self) { level in
                        LevelSection(
                            level: level,
                            idioms: idiomsByLevel[level] ?? [],
                            onIdiomTap: { idiom in
                                handleIdiomTap(idiom)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .searchable(text: $searchText, prompt: languageService.searchPrompt)
            .navigationTitle(languageService.libraryTitle)
            .onAppear {
                loadAndCacheIdioms()
            }
            .onChange(of: searchText) { _, _ in
                updateFilteredData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingLibraryInfo = true
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $paywallManager.isShowingPaywall) {
                PaywallView()
                    .environmentObject(paywallManager)
            }
            .sheet(isPresented: $showingUnlockPrompt) {
                if let idiom = selectedIdiom {
                    UnlockPromptView(
                        idiom: idiom,
                        onUnlock: {
                            showingUnlockPrompt = false
                            // Small delay to ensure the unlock prompt is dismissed before showing paywall
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                paywallManager.showPaywall()
                            }
                        },
                        onDismiss: {
                            showingUnlockPrompt = false
                        }
                    )
                }
            }
            .sheet(isPresented: $showingLibraryInfo) {
                LibraryInfoView()
            }
        }
    }
    
    private func handleIdiomTap(_ idiom: Idiom) {
        if userProgressService.shouldUnlockIdiom(idiom) {
            // Unlocked idiom - allow access
            selectedIdiom = idiom
        } else if idiom.isPremium {
            // Premium idiom - show unlock prompt
            selectedIdiom = idiom
            showingUnlockPrompt = true
        } else {
            // Locked non-premium idiom - show unlock prompt
            selectedIdiom = idiom
            showingUnlockPrompt = true
        }
    }
    
    private func navigateToDetail() {
        guard selectedIdiom != nil else { return }
        
        // Reset selection
        selectedIdiom = nil
        
        // Navigate to detail view
        // This will be handled by the parent view
    }
}

struct LevelSection: View {
    let level: String
    let idioms: [Idiom]
    let onIdiomTap: (Idiom) -> Void
    @EnvironmentObject private var userProgressService: UserProgressService
    @AppStorage("isPro") private var isPro = false
    
    // Cache unlock status to avoid repeated shouldUnlockIdiom calls
    private var idiomUnlockStatus: [String: Bool] {
        Dictionary(uniqueKeysWithValues: idioms.map { ($0.id, userProgressService.shouldUnlockIdiom($0)) })
    }
    
    private var unlockedIdioms: [Idiom] {
        idioms.filter { idiom in
            idiomUnlockStatus[idiom.id] ?? false
        }
    }
    
    private var lockedIdioms: [Idiom] {
        idioms.filter { idiom in
            !(idiomUnlockStatus[idiom.id] ?? false)
        }
    }
    
    var body: some View {
        LevelThemedSection(level: level) {
            VStack(alignment: .leading, spacing: 16) {
                // Progress indicator
                LevelProgressIndicator(
                    level: level,
                    progress: userProgressService.getQuizProgressForLevel(level),
                    total: userProgressService.getTotalQuizzesForLevel(level),
                    completed: userProgressService.getQuizCompletionCountForLevel(level)
                )
                
                // Idioms list
                LazyVStack(spacing: 8) {
                    ForEach(idioms, id: \.id) { idiom in
                        IdiomCard(
                            idiom: idiom,
                            isUnlocked: userProgressService.shouldUnlockIdiom(idiom),
                            isPremium: idiom.isPremium,
                            onTap: {
                                onIdiomTap(idiom)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                // Bottom spacing
                Spacer(minLength: 16)
            }
        }
    }
}

struct IdiomCard: View {
    let idiom: Idiom
    let isUnlocked: Bool
    let isPremium: Bool
    let onTap: () -> Void
    @EnvironmentObject private var languageService: LanguageService
    @EnvironmentObject private var userProgressService: UserProgressService
    
    var body: some View {
        Group {
            if isUnlocked {
                NavigationLink(destination: IdiomDetailView(idiom: idiom, presentationMode: .navigation)) {
                    cardContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Button(action: onTap) {
                    cardContent
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var cardContent: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(idiom.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(isUnlocked ? .primary : .secondary)
                        
                        Text(languageService.isJapanese ? idiom.jpMeaning : idiom.enMeaning)
                            .font(.subheadline)
                            .foregroundColor(isUnlocked ? .secondary : .secondary.opacity(0.6))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        if isPremium {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                        } else if !isUnlocked {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .font(.title3)
                        }
                        LevelBadge(level: idiom.level)
                    }
                }
                
                if !idiom.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(idiom.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(LevelTheme.color(for: idiom.level).opacity(0.1))
                                    .foregroundColor(LevelTheme.color(for: idiom.level))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isUnlocked ? LevelTheme.backgroundColor(for: idiom.level) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isUnlocked ? LevelTheme.color(for: idiom.level).opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
            // Completion checkmark
            if isUnlocked && userProgressService.isIdiomCompleted(idiom) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                    .padding(8)
            }
        }
    }
}

struct UnlockPromptView: View {
    let idiom: Idiom
    let onUnlock: () -> Void
    let onDismiss: () -> Void
    @EnvironmentObject private var languageService: LanguageService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Handlebar indicator
                HandlebarIndicator()
                
                VStack(spacing: 24) {
                    Image(systemName: idiom.isPremium ? "crown.fill" : "lock.fill")
                        .font(.system(size: 48))
                        .foregroundColor(idiom.isPremium ? .yellow : .orange)
                    
                    Text(idiom.isPremium ? 
                         languageService.thisIdiomIsProOnly : 
                         languageService.proFeatureTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(idiom.isPremium ?
                         languageService.proFeatureDescription :
                         languageService.proFeatureDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 12) {
                        Button(languageService.tryProButton) {
                            onUnlock()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button(languageService.laterButton) {
                            onDismiss()
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("✕") {
                        onDismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    IdiomLibraryView()
        .environmentObject(LanguageService())
        .environmentObject(UserProgressService())
        .environmentObject(PaywallManager())
}

struct LibraryInfoView: View {
    @EnvironmentObject private var languageService: LanguageService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Handlebar indicator
                HandlebarIndicator()
                
                VStack(spacing: 24) {
                    Image(systemName: "character.book.closed.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 16) {
                        Text(languageService.libraryInfoTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(languageService.libraryInfoMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                    }
                    
                    Spacer()
                    
                    Button(languageService.gotItButton) {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("✕") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
} 