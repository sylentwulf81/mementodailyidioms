//
//  DailyIdiomView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct DailyIdiomView: View {
    @EnvironmentObject private var userProgressService: UserProgressService
    @EnvironmentObject private var languageService: LanguageService
    @StateObject private var dailyIdiomService = DailyIdiomService()
    @StateObject private var audioService = AudioService()
    @State private var isPlaying = false
    @State private var showingQuiz = false
    
    private var idiom: Idiom {
        dailyIdiomService.getTodaysIdiom()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header section with idiom title and controls
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(languageService.todaysIdiomTitle)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(idiom.title)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if audioService.isPlaying {
                                    audioService.stopAudio()
                                } else {
                                    audioService.playAudio(for: idiom)
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: audioService.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 44))
                                        .foregroundColor(.blue)
                                    Text(audioService.isPlaying ? languageService.stopButtonLabel : languageService.playButtonLabel)
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        HStack {
                            LevelBadge(level: idiom.level)
                            
                            Spacer()
                            
                            Button(action: {
                                if userProgressService.isFavoriteIdiom(idiom.id) {
                                    userProgressService.removeFavoriteIdiom(idiom.id)
                                } else {
                                    userProgressService.addFavoriteIdiom(idiom.id)
                                }
                            }) {
                                VStack(spacing: 2) {
                                    Image(systemName: userProgressService.isFavoriteIdiom(idiom.id) ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(userProgressService.isFavoriteIdiom(idiom.id) ? .red : .gray)
                                    Text(languageService.favoriteLabel)
                                        .font(.caption2)
                                        .foregroundColor(userProgressService.isFavoriteIdiom(idiom.id) ? .red : .gray)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    )
                    
                    // Meaning Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(languageService.meaningLabel)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Meaning")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(languageService.isJapanese ? idiom.jpMeaning : idiom.enMeaning)
                            .font(.body)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Nuance Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(languageService.nuanceLabel)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Nuance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(idiom.nuance)
                            .font(.body)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
                    )
                    
                    // Examples
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(languageService.examplesLabel)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Examples")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ForEach(idiom.examples, id: \.english) { example in
                            ExampleCard(example: example)
                        }
                    }
                    
                    // Tags
                    if !idiom.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(languageService.tagsLabel)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(idiom.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .onAppear {
                    // Only record the view if this idiom hasn't been viewed today
                    if !userProgressService.hasViewedIdiom(idiom.id) {
                        userProgressService.recordIdiomView(idiom.id)
                    }
                    
                    // Add this idiom to the daily rotation tracking
                    userProgressService.addToDailyRotation(idiom.id)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    DailyIdiomView()
        .environmentObject(LanguageService())
        .environmentObject(UserProgressService())
} 