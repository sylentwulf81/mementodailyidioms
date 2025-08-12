import SwiftUI

struct QuizLevelSelectionView: View {
    @EnvironmentObject private var languageService: LanguageService
    @AppStorage("isPro") private var isPro = false
    let onLevelSelected: (String) -> Void
    let onProUpgrade: () -> Void

    private let levels = [
        ("A1", true),
        ("A2", true),
        ("B1", true),
        ("B2", true),
        ("C1", false),
        ("C2", false)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Add top spacing to avoid Dynamic Island
                Spacer()
                    .frame(height: 20)

                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)

                Text(languageService.quizLevelSelectionTitle)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(languageService.quizLevelSelectionDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    ForEach(levels, id: \.0) { level, isFree in
                        let info = languageService.levelInfo(for: level)
                        LevelQuizCard(
                            level: level,
                            title: info.title,
                            description: info.description,
                            isPremium: !isFree,
                            isUnlocked: isPro || isFree,
                            onTap: {
                                if !isFree && !isPro {
                                    onProUpgrade()
                                } else {
                                    onLevelSelected(level)
                                }
                            }
                        )
                    }
                }
            }
            .padding()
            .padding(.bottom, 80) // Add extra padding for bottom navigation bar
        }
    }
}
