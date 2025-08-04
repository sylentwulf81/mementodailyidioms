//
//  PaywallView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isPro") var isPro = false
    @EnvironmentObject private var paywallManager: PaywallManager
    
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
                            
                            Text("アメリカ英語のイディオムを深く理解する")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Features
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Pro会員の特典")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                FeatureRow(icon: "book.fill", title: "全イディオムライブラリ", description: "120以上のイディオムにアクセス")
                                FeatureRow(icon: "speaker.wave.2.fill", title: "自然な音声", description: "ElevenLabsの高品質音声")
                                FeatureRow(icon: "wifi.slash", title: "オフライン音声", description: "ダウンロードしてオフラインで利用")
                                FeatureRow(icon: "pencil.and.outline", title: "無制限クイズ", description: "好きなだけ練習できます")
                            }
                        }
                        
                        // Pricing
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
                                Text("月額 ¥360")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("7日間無料トライアル")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Button("Pro会員になる") {
                                // TODO: Implement StoreKit2 purchase
                                isPro = true
                                paywallManager.hidePaywall()
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            
                            Button("購入を復元") {
                                // TODO: Implement StoreKit2 restore
                            }
                            .font(.caption)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        paywallManager.hidePaywall()
                        dismiss()
                    }
                }
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
} 