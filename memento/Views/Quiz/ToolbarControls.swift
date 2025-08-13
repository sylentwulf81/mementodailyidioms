import SwiftUI

struct QuizToolbarControls: ToolbarContent {
	let hasQuestions: Bool
	let showingResults: Bool
	let hasSelectedLevel: Bool
	let exitTitle: String
	let backTitle: String
	let onExit: () -> Void
	let onBack: () -> Void

	var body: some ToolbarContent {
		if hasQuestions && !showingResults {
			ToolbarItem(placement: .navigationBarLeading) {
				Button(exitTitle) { onExit() }
					.foregroundColor(.red)
			}
		} else if hasSelectedLevel && !hasQuestions {
			ToolbarItem(placement: .navigationBarLeading) {
				Button(backTitle) { onBack() }
					.foregroundColor(.blue)
			}
		}
	}
}

