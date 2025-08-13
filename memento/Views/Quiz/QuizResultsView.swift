import SwiftUI

struct QuizResultsView: View {
    @EnvironmentObject private var languageService: LanguageService
    @EnvironmentObject private var userProgressService: UserProgressService
    let score: Int
    let totalQuestions: Int
    let onRetry: () -> Void
    let onFinish: (() -> Void)?
    let idiom: Idiom?
    let highestScore: Int?

    @State private var showConfetti = false

    private var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }

    private var message: String {
        if languageService.isJapanese {
            switch percentage {
            case 100:
                return "完璧です！素晴らしい！"
            case 80..<100:
                return "素晴らしい！"
            case 60..<80:
                return "よくできました！"
            case 40..<60:
                return "もう少し頑張りましょう！"
            default:
                return "復習が必要ですね。"
            }
        } else {
            switch percentage {
            case 100:
                return "Perfect score! Absolutely brilliant!"
            case 80..<100:
                return "Excellent!"
            case 60..<80:
                return "Well done!"
            case 40..<60:
                return "Keep practicing!"
            default:
                return "More review needed."
            }
        }
    }

    private var isNewRecord: Bool {
        if let highestScore = highestScore {
            return score > highestScore
        }
        return false
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: percentage == 100 ? "crown.fill" : (percentage >= 60 ? "star.fill" : "star"))
                .font(.system(size: 64))
                .foregroundColor(percentage == 100 ? .yellow : (percentage >= 60 ? .yellow : .gray))

            Text(languageService.quizCompleteTitle)
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 8) {
                Text(languageService.isJapanese ?
                     "\(score)/\(totalQuestions) 正解" :
                     "\(score)/\(totalQuestions) correct")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("\(Int(percentage))%")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(percentage >= 60 ? .green : .orange)
            }

            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)

            if isNewRecord {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text(languageService.isJapanese ?
                         "新しい記録！" :
                         "New record!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }

            VStack(spacing: 12) {
                Button(languageService.retryButton) {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(idiom.map { LevelTheme.color(for: $0.level) } ?? .blue)

                if let onFinish = onFinish {
                    Button(languageService.isJapanese ? "戻る" : "Back") {
                        onFinish()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .onAppear {
            if percentage == 100 {
                showConfetti = true
            }
            if let idiom = idiom, percentage >= 60 {
                userProgressService.recordLearnedIdiom(idiom.id)
            } else {
                userProgressService.recordQuizCompletion()
            }
        }
        .confettiCannon(isAnimating: $showConfetti)
    }
}
