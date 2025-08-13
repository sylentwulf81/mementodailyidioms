//
//  ProFeatureGate.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct ProFeatureGate<Content: View>: View {
    @AppStorage("isPro") var isPro = false
    @EnvironmentObject private var paywallManager: PaywallManager
    let content: () -> Content

    var body: some View {
        if isPro {
            content()
        } else {
            VStack(spacing: 16) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.yellow)
                
                Text("この機能はPro会員限定です")
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
		.sheet(isPresented: paywallManager.isShowingBinding) {
                PaywallView()
                    .environmentObject(paywallManager)
            }
        }
    }
}

#Preview {
    ProFeatureGate {
        Text("Pro Content")
    }
    .environmentObject(PaywallManager())
} 