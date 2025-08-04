//
//  DashboardView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var userProgressService: UserProgressService
    @EnvironmentObject private var languageService: LanguageService
    @StateObject private var dailyIdiomService = DailyIdiomService()
    @State private var showingOnboarding = false
    @State private var showingFavorites = false
    @Binding var selectedTab: Int
    
    private var todaysIdiom: Idiom {
        dailyIdiomService.getTodaysIdiom(with: userProgressService)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with greeting and streak
                    HeaderSection()
                    
                    // Today's idiom card
                    TodaysIdiomCard(idiom: todaysIdiom)
                    
                    // Progress stats
                    ProgressStatsSection(selectedTab: $selectedTab, showingFavorites: $showingFavorites)
                    
                    // Recent activity
                    RecentActivitySection()
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.secondarySystemBackground).opacity(0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle(languageService.dashboardTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingOnboarding = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingOnboarding) {
                OnboardingView()
            }
            .sheet(isPresented: $showingFavorites) {
                FavoritesView()
            }
        }
    }
}

struct HeaderSection: View {
    @EnvironmentObject private var userProgressService: UserProgressService
    @EnvironmentObject private var languageService: LanguageService
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if languageService.isJapanese {
            switch hour {
            case 5..<12: return languageService.greetingMorning
            case 12..<17: return languageService.greetingAfternoon
            case 17..<22: return languageService.greetingEvening
            default: return languageService.greetingNight
            }
        } else {
            switch hour {
            case 5..<12: return languageService.greetingMorning
            case 12..<17: return languageService.greetingAfternoon
            case 17..<22: return languageService.greetingEvening
            default: return languageService.greetingNight
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(languageService.keepLearningMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Streak indicator
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        
                        Text("\(userProgressService.currentStreak)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Text(languageService.dayStreakLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct TodaysIdiomCard: View {
    let idiom: Idiom
    @EnvironmentObject private var languageService: LanguageService
    @State private var showingDetail = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(languageService.isJapanese ? "今日のイディオム" : "Today's Idiom")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(idiom.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(languageService.isJapanese ? idiom.jpMeaning : idiom.enMeaning)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    LevelBadge(level: idiom.level)
                    
                    Button(action: {
                        showingDetail = true
                    }) {
                        Text(languageService.isJapanese ? "学習" : "Learn")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                }
            }
            
            // Tags
            if !idiom.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(idiom.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
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
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            NavigationView {
                VStack(spacing: 0) {
                    // Handlebar indicator for sheet presentation
                    HandlebarIndicator()
                        .padding(.top, 8)
                    
                    IdiomDetailView(idiom: idiom, presentationMode: .sheet)
                }
            }
        }
    }
}

struct ProgressStatsSection: View {
    @EnvironmentObject private var userProgressService: UserProgressService
    @EnvironmentObject private var languageService: LanguageService
    @Binding var selectedTab: Int
    @Binding var showingFavorites: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(languageService.learningStatsTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: languageService.learnedLabel,
                    value: "\(userProgressService.totalIdiomsLearned)",
                    icon: "book.fill",
                    color: .blue,
                    action: {
                        selectedTab = 1 // Navigate to Library
                    }
                )
                
                StatCard(
                    title: languageService.quizzesLabel,
                    value: "\(userProgressService.totalQuizzesCompleted)",
                    icon: "brain.head.profile",
                    color: .green,
                    action: {
                        selectedTab = 2 // Navigate to Quiz
                    }
                )
                
                StatCard(
                    title: languageService.favoritesLabel,
                    value: "\(userProgressService.totalFavoritesAdded)",
                    icon: "heart.fill",
                    color: .red,
                    action: {
                        showingFavorites = true
                    }
                )
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let action: (() -> Void)?
    
    init(title: String, value: String, icon: String, color: Color, action: (() -> Void)? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.08),
                                color.opacity(0.03)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: color.opacity(0.2), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentActivitySection: View {
    @EnvironmentObject private var userProgressService: UserProgressService
    @EnvironmentObject private var languageService: LanguageService
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(languageService.recentActivityTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                if userProgressService.totalQuizzesCompleted > 0 {
                    ActivityRow(
                        icon: "brain.head.profile",
                        title: languageService.completedQuiz,
                        subtitle: languageService.yesterdayLabel,
                        color: .green
                    )
                }
                
                if userProgressService.totalFavoritesAdded > 0 {
                    ActivityRow(
                        icon: "heart.fill",
                        title: languageService.addedToFavorites,
                        subtitle: "2 \(languageService.daysAgoLabel)",
                        color: .red
                    )
                }
                
                // Show empty state if no activity
                if userProgressService.totalQuizzesCompleted == 0 && 
                   userProgressService.totalFavoritesAdded == 0 {
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text(languageService.isJapanese ? 
                             "今日から学習を始めましょう！" : 
                             "Start learning today!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    DashboardView(selectedTab: .constant(0))
        .environmentObject(LanguageService())
        .environmentObject(UserProgressService())
} 