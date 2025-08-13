import SwiftUI

struct QuizScreenView: View {
	let showingResults: Bool
	let questions: [QuizQuestion]
	let currentQuestionIndex: Int
	let answeredQuestions: [Bool]
	let selectedLevel: String?
	@Binding var selectedAnswer: Int?
	let score: Int

	let onSelectLevel: (String) -> Void
	let onStartSelectedLevel: () -> Void
	let onTryAgain: () -> Void
	let onAnswer: (Int) -> Void
	let onProUpgrade: () -> Void

	var body: some View {
		VStack {
			if showingResults {
				QuizResultsView(
					score: score,
					totalQuestions: questions.count,
					onRetry: { onTryAgain() },
					onFinish: nil,
					idiom: nil,
					highestScore: nil
				)
			} else if questions.isEmpty {
				if selectedLevel == nil {
					QuizLevelSelectionView(
						onLevelSelected: { level in onSelectLevel(level) },
						onProUpgrade: { onProUpgrade() }
					)
				} else {
					QuizStartView {
						onStartSelectedLevel()
					}
				}
			} else {
				VStack {
					QuizProgressView(
						currentQuestion: currentQuestionIndex + 1,
						totalQuestions: questions.count,
						answeredQuestions: answeredQuestions
					)
					.padding(.horizontal)
					
					QuizQuestionView(
						question: questions[currentQuestionIndex],
						selectedAnswer: $selectedAnswer,
						onAnswerSelected: { index in onAnswer(index) }
					)
				}
			}
		}
	}
}

