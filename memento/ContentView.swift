//
//  ContentView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @EnvironmentObject private var languageService: LanguageService
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Soft gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                DashboardView(selectedTab: $selectedTab)
                    .tabItem {
                        Label(languageService.homeTabLabel, systemImage: "house.fill")
                    }
                    .tag(0)

                IdiomLibraryView()
                    .tabItem {
                        Label(languageService.libraryTabLabel, systemImage: "character.book.closed.fill")
                    }
                    .tag(1)

                QuizView()
                    .tabItem {
                        Label(languageService.quizTabLabel, systemImage: "brain.head.profile")
                    }
                    .tag(2)

                SettingsView()
                    .tabItem {
                        Label(languageService.settingsTabLabel, systemImage: "slider.horizontal.3")
                    }
                    .tag(3)
            }
            .accentColor(.mint)
            .animation(.easeInOut(duration: 0.25), value: selectedTab)
            .font(.system(.body, design: .rounded))
            .environment(\.locale, languageService.currentLocale)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, UserProgress.self], inMemory: true)
}
