import SwiftUI

struct QuizStartView: View {
    @EnvironmentObject private var languageService: LanguageService
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "pencil.and.outline")
                .font(.system(size: 64))
                .foregroundColor(.blue)

            Text(languageService.quizStartTitle)
                .font(.title)
                .fontWeight(.bold)

            Text(languageService.quizStartDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(languageService.startQuizButton) {
                onStart()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}
