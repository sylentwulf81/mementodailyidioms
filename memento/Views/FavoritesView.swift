//
//  FavoritesView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var userProgressService: UserProgressService
    @EnvironmentObject private var languageService: LanguageService
    @EnvironmentObject private var paywallManager: PaywallManager
    @StateObject private var dailyIdiomService = DailyIdiomService()
    @State private var selectedIdiom: Idiom?
    @State private var showingUnlockPrompt = false
    
    @State private var favoriteIdioms: [Idiom] = []
    
    private func loadFavoriteIdioms() {
        let allIdioms = dailyIdiomService.loadIdioms()
        let favoriteIds = userProgressService.getFavoriteIdiomIds()
        let filteredIdioms = allIdioms.filter { favoriteIds.contains($0.id) }
        favoriteIdioms = filteredIdioms
        
        print("FavoritesView: Loaded \(filteredIdioms.count) favorite idioms")
        print("FavoritesView: Favorite IDs: \(favoriteIds)")
        print("FavoritesView: Favorite titles: \(filteredIdioms.map { $0.title })")
    }
    
    // Cache unlock status to avoid repeated calls
    private func getUnlockStatus(for idiom: Idiom) -> Bool {
        return userProgressService.shouldUnlockIdiom(idiom)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if favoriteIdioms.isEmpty {
                    EmptyFavoritesView()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(favoriteIdioms, id: \.id) { idiom in
                            FavoriteIdiomCard(
                                idiom: idiom,
                                onTap: {
                                    handleIdiomTap(idiom)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(languageService.favoritesTitle)
            .onAppear {
                loadFavoriteIdioms()
            }
            .onReceive(userProgressService.objectWillChange) {
                loadFavoriteIdioms()
            }
            .sheet(isPresented: $paywallManager.isShowingPaywall) {
                PaywallView()
                    .environmentObject(paywallManager)
            }
            .popover(isPresented: $showingUnlockPrompt) {
                if let idiom = selectedIdiom {
                    UnlockPromptView(
                        idiom: idiom,
                        onUnlock: {
                            paywallManager.showPaywall()
                        },
                        onDismiss: {
                            showingUnlockPrompt = false
                        }
                    )
                }
            }
        }
    }
    
    private func handleIdiomTap(_ idiom: Idiom) {
        let isUnlocked = getUnlockStatus(for: idiom)
        if isUnlocked {
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
}

struct FavoriteIdiomCard: View {
    let idiom: Idiom
    let onTap: () -> Void
    @EnvironmentObject private var languageService: LanguageService
    @EnvironmentObject private var userProgressService: UserProgressService
    
    var body: some View {
        Group {
            let isUnlocked = userProgressService.shouldUnlockIdiom(idiom)
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
                        let isUnlocked = userProgressService.shouldUnlockIdiom(idiom)
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
                        if idiom.isPremium {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                        } else if !userProgressService.shouldUnlockIdiom(idiom) {
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
                    .fill(userProgressService.shouldUnlockIdiom(idiom) ? LevelTheme.backgroundColor(for: idiom.level) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(userProgressService.shouldUnlockIdiom(idiom) ? LevelTheme.color(for: idiom.level).opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
            
            // Favorite heart icon
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .font(.title2)
                .padding(8)
        }
    }
}

struct EmptyFavoritesView: View {
    @EnvironmentObject private var languageService: LanguageService
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart")
                .font(.system(size: 48))
                .foregroundColor(.red.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(languageService.noFavoritesTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(languageService.noFavoritesMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FavoritesView()
        .environmentObject(LanguageService())
        .environmentObject(UserProgressService())
        .environmentObject(PaywallManager())
} 