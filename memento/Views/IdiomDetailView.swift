//
//  IdiomDetailView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct IdiomDetailView: View {
    let idiom: Idiom
    let presentationMode: PresentationMode
    @EnvironmentObject private var userProgressService: UserProgressService
    @EnvironmentObject private var languageService: LanguageService
    @EnvironmentObject private var paywallManager: PaywallManager
    @StateObject private var audioService = AudioService()
    @State private var isPlaying = false
    @State private var showingQuiz = false
    @AppStorage("isPro") private var isPro = false
    @Environment(\.dismiss) private var dismiss
    
    enum PresentationMode {
        case sheet
        case navigation
    }
    
    init(idiom: Idiom, presentationMode: PresentationMode = .navigation) {
        self.idiom = idiom
        self.presentationMode = presentationMode
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if idiom.isPremium && !isPro {
                // Show Pro gate for premium content
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.yellow)
                    
                    Text("このイディオムはPro会員限定です")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Text("Pro会員になると、すべてのイディオムにアクセスでき、オフライン音声やクイズ機能も利用できます。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Proを試す") {
                        paywallManager.showPaywall()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                // Show the idiom content
                ScrollView {
                    VStack(spacing: 24) {
                        // Header section with idiom title and controls
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    // Show the idiom title
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
                                        Text(audioService.isPlaying ? "停止" : "再生")
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
                                Text("意味")
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
                                Text("ニュアンス")
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
                                Text("例文")
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
                        
                        // Quiz Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(languageService.idiomQuizTitle)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Test")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                        .font(.title2)
                                        .foregroundColor(LevelTheme.color(for: idiom.level))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(languageService.takeQuizAboutIdiom)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text(languageService.testUnderstandingWithQuestions)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showingQuiz = true
                                    }) {
                                        Text(languageService.startButton)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(LevelTheme.color(for: idiom.level))
                                            .cornerRadius(20)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(LevelTheme.backgroundColor(for: idiom.level))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(LevelTheme.color(for: idiom.level).opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        // Tags
                        if !idiom.tags.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("タグ")
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
                }
                .onAppear {
                    // Record that this idiom has been viewed
                    userProgressService.recordIdiomView(idiom.id)
                }
            }
        }
        .sheet(isPresented: $paywallManager.isShowingPaywall) {
            PaywallView()
                .environmentObject(paywallManager)
        }
        .sheet(isPresented: $showingQuiz) {
            IdiomQuizView(idiom: idiom)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(languageService.isJapanese ? "戻る" : "Back") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        IdiomDetailView(idiom: Idiom(
            title: "Break a leg",
            jpMeaning: "頑張って！成功を祈る！",
            nuance: "舞台芸術の世界で「幸運を祈る」という意味で使われる表現。",
            examples: [
                Example(english: "Good luck!", japanese: "頑張って！", tone: "casual")
            ],
            tags: ["舞台", "成功"],
            level: "B1",
            isPremium: false
        ), presentationMode: .navigation)
        .environmentObject(LanguageService())
        .environmentObject(UserProgressService())
        .environmentObject(PaywallManager())
    }
} 
