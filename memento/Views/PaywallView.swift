//
//  PaywallView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var paywallManager: PaywallManager
    @EnvironmentObject private var subscriptionService: SubscriptionService
    @EnvironmentObject private var languageService: LanguageService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Handlebar indicator
                HandlebarIndicator()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.yellow)
                            
                            Text("Memento Pro")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(languageService.isJapanese ? "アメリカ英語のイディオムを深く理解する" : "Deeply understand American English idioms")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Features
                        VStack(alignment: .leading, spacing: 16) {
                            Text(languageService.isJapanese ? "Pro会員の特典" : "Pro Benefits")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                FeatureRow(icon: "book.fill", 
                                          title: languageService.isJapanese ? "全イディオムライブラリ" : "Full Idiom Library", 
                                          description: languageService.isJapanese ? "120以上のイディオムにアクセス" : "Access 120+ idioms")
                                FeatureRow(icon: "speaker.wave.2.fill", 
                                          title: languageService.isJapanese ? "自然な音声" : "Natural Audio", 
                                          description: languageService.isJapanese ? "ElevenLabsの高品質音声" : "High-quality ElevenLabs audio")
                                FeatureRow(icon: "wifi.slash", 
                                          title: languageService.isJapanese ? "オフライン音声" : "Offline Audio", 
                                          description: languageService.isJapanese ? "ダウンロードしてオフラインで利用" : "Download for offline use")
                                FeatureRow(icon: "pencil.and.outline", 
                                          title: languageService.isJapanese ? "無制限クイズ" : "Unlimited Quizzes", 
                                          description: languageService.isJapanese ? "好きなだけ練習できます" : "Practice as much as you want")
                            }
                        }
                        
                        // Pricing & Purchase Buttons
                        VStack(spacing: 16) {
                            if subscriptionService.products.isEmpty {
                                ProgressView()
                                    .padding()
                            } else {
                                ForEach(subscriptionService.products) { product in
                                    Button(action: {
                                        Task {
                                            try? await subscriptionService.purchase(product)
                                            if subscriptionService.isProUser {
                                                paywallManager.hidePaywall()
                                                dismiss()
                                            }
                                        }
                                    }) {
                                        VStack(spacing: 4) {
                                            Text(product.displayName)
                                                .font(.headline)
                                            Text(product.displayPrice)
                                                .font(.subheadline)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            
                            Button(languageService.restorePurchasesButton) {
                                Task {
                                    await subscriptionService.restorePurchases()
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageService.isJapanese ? "閉じる" : "Close") {
                        paywallManager.hidePaywall()
                        dismiss()
                    }
                }
            }
            .task {
                await subscriptionService.loadProducts()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(LanguageService())
        .environmentObject(PaywallManager())
        .environmentObject(SubscriptionService())
} 