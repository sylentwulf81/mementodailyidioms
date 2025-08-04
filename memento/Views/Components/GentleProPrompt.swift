import SwiftUI

struct GentleProPrompt: View {
    let title: String
    let message: String
    let actionText: String
    let dismissText: String
    let onAction: () -> Void
    let onDismiss: () -> Void
    
    @EnvironmentObject private var paywallManager: PaywallManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: "crown.fill")
                .font(.system(size: 32))
                .foregroundColor(.yellow)
            
            // Content
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            
            // Action buttons
            VStack(spacing: 12) {
                Button(actionText) {
                    paywallManager.showPaywall()
                }
                .buttonStyle(.borderedProminent)
                
                Button(dismissText) {
                    onDismiss()
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .sheet(isPresented: $paywallManager.isShowingPaywall) {
            PaywallView()
                .environmentObject(paywallManager)
        }
    }
}

// MARK: - Predefined Prompts

extension GentleProPrompt {
    static func libraryLimitPrompt(onAction: @escaping () -> Void, onDismiss: @escaping () -> Void) -> GentleProPrompt {
        return GentleProPrompt(
            title: "Explore More Idioms",
            message: "You've seen 20 great idioms! Unlock 80 more with Pro and discover advanced expressions.",
            actionText: "Try Pro",
            dismissText: "Maybe Later",
            onAction: onAction,
            onDismiss: onDismiss
        )
    }
    
    static func quizVarietyPrompt(onAction: @escaping () -> Void, onDismiss: @escaping () -> Void) -> GentleProPrompt {
        return GentleProPrompt(
            title: "Advanced Quizzes",
            message: "You're mastering the basics! Pro unlocks 3x more question types and personalized challenges.",
            actionText: "Unlock Advanced",
            dismissText: "Continue Learning",
            onAction: onAction,
            onDismiss: onDismiss
        )
    }
    
    static func audioQualityPrompt(onAction: @escaping () -> Void, onDismiss: @escaping () -> Void) -> GentleProPrompt {
        return GentleProPrompt(
            title: "Natural Audio",
            message: "Experience natural pronunciation with ElevenLabs AI voice. Pro members get premium audio quality.",
            actionText: "Upgrade Audio",
            dismissText: "Keep Basic",
            onAction: onAction,
            onDismiss: onDismiss
        )
    }
    
    static func progressCelebrationPrompt(count: Int, onAction: @escaping () -> Void, onDismiss: @escaping () -> Void) -> GentleProPrompt {
        return GentleProPrompt(
            title: "🎉 Great Progress!",
            message: "You've learned \(count) idioms! Ready to unlock all 100 idioms and advanced features?",
            actionText: "Unlock Everything",
            dismissText: "Keep Learning",
            onAction: onAction,
            onDismiss: onDismiss
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        GentleProPrompt.libraryLimitPrompt(
            onAction: { print("Pro action") },
            onDismiss: { print("Dismiss") }
        )
        
        GentleProPrompt.progressCelebrationPrompt(
            count: 10,
            onAction: { print("Pro action") },
            onDismiss: { print("Dismiss") }
        )
    }
    .padding()
    .environmentObject(PaywallManager())
} 