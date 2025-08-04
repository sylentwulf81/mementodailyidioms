import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageService: LanguageService
    @EnvironmentObject private var paywallManager: PaywallManager
    
    private var pages: [OnboardingPage] {
        [
            OnboardingPage(
                title: languageService.isJapanese ? "Mementoへようこそ" : "Welcome to Memento",
                subtitle: languageService.isJapanese ? "日本語の解説で英語のイディオムをマスター" : "Master English idioms with Japanese context",
                description: languageService.isJapanese ? 
                    "100以上の厳選された英語イディオムを、詳細な日本語解説、文化的背景、自然な例文と共に学習します。" :
                    "Learn 100+ carefully curated English idioms with detailed Japanese explanations, cultural context, and natural examples.",
                imageName: "book.fill",
                accentColor: .blue
            ),
            OnboardingPage(
                title: languageService.isJapanese ? "毎日の学習" : "Daily Learning",
                subtitle: languageService.isJapanese ? "1日1つのイディオム、最適なペース" : "One idiom per day, perfectly paced",
                description: languageService.isJapanese ?
                    "毎日新しいイディオムで始めましょう。私たちのアルゴリズムが、長期的な記憶に最適なペースで学習できるようサポートします。" :
                    "Start each day with a new idiom. Our algorithm ensures you learn at the optimal pace for long-term retention.",
                imageName: "sun.max.fill",
                accentColor: .orange
            ),
            OnboardingPage(
                title: languageService.isJapanese ? "スマートクイズ" : "Smart Quizzes",
                subtitle: languageService.isJapanese ? "適応型問題で知識をテスト" : "Test your knowledge with adaptive questions",
                description: languageService.isJapanese ?
                    "進捗に合わせて適応し、注意が必要な分野に焦点を当てたパーソナライズされたクイズで学習を強化します。" :
                    "Reinforce your learning with personalized quizzes that adapt to your progress and focus on areas that need attention.",
                imageName: "pencil.and.outline",
                accentColor: .green
            ),
            OnboardingPage(
                title: languageService.isJapanese ? "Pro機能" : "Pro Features",
                subtitle: languageService.isJapanese ? "あなたの可能性を最大限に引き出す" : "Unlock your full potential",
                description: languageService.isJapanese ?
                    "Proにアップグレードして、100のイディオムすべてへの無制限アクセス、オフライン音声、高度なクイズ、優先サポートを利用できます。" :
                    "Upgrade to Pro for unlimited access to all 100 idioms, offline audio, advanced quizzes, and priority support.",
                imageName: "crown.fill",
                accentColor: .yellow
            )
        ]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Handlebar indicator
                    HandlebarIndicator()
                    
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    // Bottom controls
                    VStack(spacing: 20) {
                        // Page indicators
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .animation(.easeInOut, value: currentPage)
                            }
                        }
                        
                        // Action buttons
                        HStack(spacing: 16) {
                            if currentPage < pages.count - 1 {
                                Button(languageService.isJapanese ? "スキップ" : "Skip") {
                                    completeOnboarding()
                                }
                                .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button(languageService.isJapanese ? "次へ" : "Next") {
                                    withAnimation {
                                        currentPage += 1
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            } else {
                                Button(languageService.isJapanese ? "スキップ" : "Skip") {
                                    completeOnboarding()
                                }
                                .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button(languageService.isJapanese ? "始める" : "Get Started") {
                                    completeOnboarding()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $paywallManager.isShowingPaywall) {
            PaywallView()
                .environmentObject(paywallManager)
        }
    }
    
    private func completeOnboarding() {
        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        // Always dismiss the onboarding
        dismiss()
        
        // Optionally show paywall on last page (but don't block dismissal)
        if currentPage == pages.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                paywallManager.showPaywall()
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let accentColor: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80))
                .foregroundColor(page.accentColor)
                .padding(.bottom, 20)
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(LanguageService())
        .environmentObject(PaywallManager())
} 