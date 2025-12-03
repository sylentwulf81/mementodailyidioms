//
//  mementoApp.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI
import SwiftData

@main
struct mementoApp: App {
    @State private var showingOnboarding = false
    @StateObject private var subscriptionService = SubscriptionService()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LanguageService())
                .environmentObject(UserProgressService())
                .environmentObject(UserProgressService())
                .environmentObject(PaywallManager())
                .environmentObject(subscriptionService)
                .onAppear {
                    // Check if user has seen onboarding
                    let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
                    if !hasSeenOnboarding {
                        showingOnboarding = true
                    }
                }
                .sheet(isPresented: $showingOnboarding) {
                    OnboardingView()
                        .environmentObject(LanguageService())
                        .environmentObject(PaywallManager())
                        .environmentObject(subscriptionService)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
