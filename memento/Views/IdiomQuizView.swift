//
//  IdiomQuizView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct IdiomQuizView: View {
    let idiom: Idiom
    @EnvironmentObject private var languageService: LanguageService
    @EnvironmentObject private var userProgressService: UserProgressService
    @StateObject private var quizQuestionService = QuizQuestionService()
    @State private var questions: [IdiomQuizQuestion] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var score = 0
    @State private var showingResults = false
    @State private var answeredQuestions: [Bool] = []
    @State private var showingExitAlert = false
    @State private var highestScore: Int = 0
    
    private let questionCount = 3
    
    var body: some View {
        NavigationView {
            VStack {
                if showingResults {
                    IdiomQuizResultsView(
                        idiom: idiom,
                        score: score,
                        totalQuestions: questions.count,
                        highestScore: highestScore,
                        onRetry: {
                            startNewQuiz()
                        },
                        onFinish: {
                            exitQuiz()
                        }
                    )
                } else if questions.isEmpty {
                    IdiomQuizStartView(idiom: idiom) {
                        startNewQuiz()
                    }
                } else {
                    VStack {
                        // Progress indicator
                        IdiomQuizProgressView(
                            currentQuestion: currentQuestionIndex + 1,
                            totalQuestions: questions.count,
                            answeredQuestions: answeredQuestions
                        )
                        .padding(.horizontal)
                        
                        IdiomQuizQuestionView(
                            question: questions[currentQuestionIndex],
                            selectedAnswer: $selectedAnswer,
                            onAnswerSelected: { answerIndex in
                                handleAnswer(answerIndex)
                            }
                        )
                    }
                }
            }
            .navigationTitle(languageService.isJapanese ? "\(idiom.title) クイズ" : "\(idiom.title) Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !questions.isEmpty && !showingResults {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(languageService.exitButton) {
                            showingExitAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .alert(languageService.quizExitTitle, isPresented: $showingExitAlert) {
                Button(languageService.exitButton, role: .destructive) {
                    exitQuiz()
                }
                Button(languageService.cancelButton, role: .cancel) { }
            } message: {
                Text(languageService.quizExitMessage)
            }
            .onAppear {
                loadHighestScore()
            }
        }
    }
    
    private func startNewQuiz() {
        questions = quizQuestionService.getQuestionsForIdiom(idiom, languageService: languageService)
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showingResults = false
        answeredQuestions = []
    }
    
    private func exitQuiz() {
        questions = []
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showingResults = false
        answeredQuestions = []
    }
    
    private func handleAnswer(_ answerIndex: Int) {
        selectedAnswer = answerIndex
        
        let isCorrect = answerIndex == questions[currentQuestionIndex].correctAnswer
        if isCorrect {
            score += 1
        }
        
        answeredQuestions.append(isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if currentQuestionIndex < questions.count - 1 {
                currentQuestionIndex += 1
                selectedAnswer = nil
            } else {
                showingResults = true
                updateHighestScore()
            }
        }
    }
    

    
    private func loadHighestScore() {
        let key = "highestScore_\(idiom.id)"
        highestScore = UserDefaults.standard.integer(forKey: key)
    }
    
    private func updateHighestScore() {
        let key = "highestScore_\(idiom.id)"
        if score > highestScore {
            highestScore = score
            UserDefaults.standard.set(highestScore, forKey: key)
        }
    }
}

struct IdiomQuizQuestion {
    let question: String
    let options: [String]
    let correctAnswer: Int
    let type: IdiomQuizQuestionType
}

enum IdiomQuizQuestionType {
    case meaning
    case fillBlank
    case context
}

struct IdiomQuizStartView: View {
    let idiom: Idiom
    let onStart: () -> Void
    @EnvironmentObject private var languageService: LanguageService
    @State private var highestScore: Int = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // Idiom preview card
            VStack(spacing: 16) {
                Text(idiom.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(idiom.jpMeaning)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                LevelBadge(level: idiom.level)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LevelTheme.backgroundColor(for: idiom.level))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(LevelTheme.color(for: idiom.level).opacity(0.3), lineWidth: 1)
                    )
            )
            
            VStack(spacing: 16) {
                Image(systemName: "pencil.and.outline")
                    .font(.system(size: 48))
                    .foregroundColor(LevelTheme.color(for: idiom.level))
                
                Text(languageService.isJapanese ? 
                     "\(idiom.title) クイズ" : 
                     "\(idiom.title) Quiz")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(languageService.isJapanese ? 
                     "このイディオムについて3つの質問に答えてください" : 
                     "Answer 3 questions about this idiom")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if highestScore > 0 {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text(languageService.isJapanese ? 
                             "最高スコア: \(highestScore)/3" : 
                             "Best score: \(highestScore)/3")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Button(languageService.startQuizButton) {
                onStart()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(LevelTheme.color(for: idiom.level))
        }
        .padding()
        .onAppear {
            loadHighestScore()
        }
    }
    
    private func loadHighestScore() {
        let key = "highestScore_\(idiom.id)"
        highestScore = UserDefaults.standard.integer(forKey: key)
    }
}

struct IdiomQuizQuestionView: View {
    let question: IdiomQuizQuestion
    @Binding var selectedAnswer: Int?
    let onAnswerSelected: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
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

struct IdiomQuizProgressView: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let answeredQuestions: [Bool]
    
    private var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentQuestion - 1) / Double(totalQuestions)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(currentQuestion)/\(totalQuestions)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
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
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
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
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 8)
    }
}

struct IdiomQuizResultsView: View {
    let idiom: Idiom
    let score: Int
    let totalQuestions: Int
    let highestScore: Int
    let onRetry: () -> Void
    let onFinish: () -> Void
    @EnvironmentObject private var languageService: LanguageService
    @EnvironmentObject private var userProgressService: UserProgressService
    
    private var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }
    
    private var message: String {
        if languageService.isJapanese {
            switch percentage {
            case 80...100:
                return "素晴らしい！完璧です！"
            case 60..<80:
                return "よくできました！"
            case 40..<60:
                return "もう少し頑張りましょう！"
            default:
                return "復習が必要ですね。"
            }
        } else {
            switch percentage {
            case 80...100:
                return "Excellent! Perfect score!"
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
        return score > highestScore
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Result icon
            Image(systemName: percentage >= 60 ? "star.fill" : "star")
                .font(.system(size: 64))
                .foregroundColor(percentage >= 60 ? .yellow : .gray)

            // Score display
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
            
            // Message
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Record indicator
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
            
            // Action buttons
            VStack(spacing: 12) {
                Button(languageService.retryButton) {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(LevelTheme.color(for: idiom.level))
                
                Button(languageService.isJapanese ? "戻る" : "Back") {
                    onFinish()
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .onAppear {
            // Record that this idiom has been learned if the user passed the quiz (60% or higher)
            if percentage >= 60 {
                userProgressService.recordLearnedIdiom(idiom.id)
            }
        }
    }
}

#Preview {
    IdiomQuizView(idiom: Idiom(
        title: "Break a leg",
        jpMeaning: "頑張って！成功を祈る！",
        nuance: "舞台芸術の世界で「幸運を祈る」という意味で使われる表現。",
        examples: [
            Example(english: "Good luck!", japanese: "頑張って！", tone: "casual")
        ],
        tags: ["舞台", "成功"],
        level: "B1",
        isPremium: false
    ))
    .environmentObject(LanguageService())
    .environmentObject(UserProgressService())
} 