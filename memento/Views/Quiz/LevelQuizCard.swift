import SwiftUI

struct LevelQuizCard: View {
    let level: String
    let title: String
    let description: String
    let isPremium: Bool
    let isUnlocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("Level \(level)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(isUnlocked ? .primary : .secondary)

                        if isPremium {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text("PRO")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                        }

                        if !isUnlocked {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                Text("LOCKED")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isUnlocked ? .primary : .secondary)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(isUnlocked ? .secondary : .secondary.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(isUnlocked ? .blue : .secondary.opacity(0.5))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isUnlocked ? Color(.systemBackground) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isUnlocked ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
            .shadow(color: isUnlocked ? Color.black.opacity(0.05) : Color.clear, radius: 2, x: 0, y: 1)
        }
        .disabled(!isUnlocked)
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}
