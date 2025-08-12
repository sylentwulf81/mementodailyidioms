import SwiftUI

struct QuizQuestionView: View {
    let question: QuizQuestion
    @Binding var selectedAnswer: Int?
    let onAnswerSelected: (Int) -> Void

    @EnvironmentObject private var languageService: LanguageService

    var body: some View {
        VStack(spacing: 24) {
            Text(languageService.questionTypeTitle(for: question.type))
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(10)

            Text(question.question)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()

            VStack(spacing: 12) {
                ForEach(0..<question.options.count, id: \.self) { index in
                    Button {
                        if selectedAnswer == nil {
                            selectedAnswer = index
                            onAnswerSelected(index)
                        }
                    } label: {
                        HStack {
                            Text(question.options[index])
                                .font(.body)
                                .multilineTextAlignment(.leading)

                            Spacer()

                            if let selectedAnswer = selectedAnswer {
                                Image(systemName: selectedAnswer == index ?
                                      (index == question.correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill") :
                                      (index == question.correctAnswer ? "checkmark.circle.fill" : "circle"))
                                    .foregroundColor(selectedAnswer == index ?
                                                   (index == question.correctAnswer ? .green : .red) :
                                                   (index == question.correctAnswer ? .green : .gray))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedAnswer == index ?
                                      (index == question.correctAnswer ? Color.green.opacity(0.1) : Color.red.opacity(0.1)) :
                                      Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedAnswer == index ?
                                       (index == question.correctAnswer ? Color.green : Color.red) :
                                       Color.clear, lineWidth: 2)
                        )
                    }
                    .disabled(selectedAnswer != nil)
                }
            }
            .padding(.horizontal)
        }
    }
}
