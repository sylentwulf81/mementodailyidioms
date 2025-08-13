import Foundation

enum QuizQuestionType {
	case meaning
	case fillBlank
	case context
}

struct QuizQuestion {
	let question: String
	let options: [String]
	let correctAnswer: Int
	let type: QuizQuestionType
}

