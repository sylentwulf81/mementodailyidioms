import SwiftUI

struct QuizProgressView: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let answeredQuestions: [Bool]

    private var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentQuestion - 1) / Double(totalQuestions)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Question counter
            HStack {
                Text("\(currentQuestion)/\(totalQuestions)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                // Score indicator
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(answeredQuestions.filter { $0 }.count)")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("\(answeredQuestions.filter { !$0 }.count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    // Progress bar
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progress)

                    // Question indicators
                    HStack(spacing: 0) {
                        ForEach(0..<totalQuestions, id: \.self) { index in
                            Circle()
                                .fill(questionIndicatorColor(for: index))
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .offset(x: (geometry.size.width / CGFloat(totalQuestions)) * CGFloat(index) - 6)
                        }
                    }
                }
            }
            .frame(height: 12)
        }
        .padding(.vertical, 8)
    }

    private func questionIndicatorColor(for index: Int) -> Color {
        if index < answeredQuestions.count {
            return answeredQuestions[index] ? .green : .red
        } else if index == currentQuestion - 1 {
            return .blue
        } else {
            return .gray.opacity(0.3)
        }
    }
}
