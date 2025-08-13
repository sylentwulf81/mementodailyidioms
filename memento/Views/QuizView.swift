//
//  QuizView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var dailyIdiomService = DailyIdiomService()
    @StateObject private var quizQuestionService = QuizQuestionService()
    @EnvironmentObject private var languageService: LanguageService
    @EnvironmentObject private var userProgressService: UserProgressService
    @EnvironmentObject private var paywallManager: PaywallManager
    @AppStorage("isPro") private var isPro = false
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var score = 0
    @State private var showingResults = false
    @State private var questions: [QuizQuestion] = []
    @State private var answeredQuestions: [Bool] = [] // Track correct/incorrect answers
    @State private var showingExitAlert = false
    @State private var selectedLevel: String? = nil
    @State private var showingLevelSelection = false
    
    var body: some View {
        NavigationView {
            QuizScreenView(
                showingResults: showingResults,
                questions: questions,
                currentQuestionIndex: currentQuestionIndex,
                answeredQuestions: answeredQuestions,
                selectedLevel: selectedLevel,
                selectedAnswer: $selectedAnswer,
                score: score,
                onSelectLevel: { level in
                    selectedLevel = level
                    startNewQuiz(for: level)
                },
                onStartSelectedLevel: { startNewQuiz(for: selectedLevel!) },
                onTryAgain: { startNewQuiz(for: selectedLevel) },
                onAnswer: { answerIndex in handleAnswer(answerIndex) },
                onProUpgrade: { paywallManager.showPaywall() }
            )
            .navigationTitle(languageService.quizTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                QuizToolbarControls(
                    hasQuestions: !questions.isEmpty,
                    showingResults: showingResults,
                    hasSelectedLevel: selectedLevel != nil,
                    exitTitle: languageService.exitButton,
                    backTitle: languageService.backButton,
                    onExit: { showingExitAlert = true },
                    onBack: { selectedLevel = nil }
                )
            }
            .alert(languageService.quizExitTitle, isPresented: $showingExitAlert) {
                Button(languageService.exitButton, role: .destructive) {
                    exitQuiz()
                }
                Button(languageService.cancelButton, role: .cancel) { }
            } message: {
                Text(languageService.quizExitMessage)
            }
            .sheet(isPresented: paywallManager.isShowingBinding) {
                PaywallView()
                    .environmentObject(paywallManager)
            }
        }
    }
    
    private func startNewQuiz(for level: String? = nil) {
        // Check premium restrictions
        if let level = level, !isPro && (level == "C1" || level == "C2") {
            paywallManager.showPaywall()
            return
        }
        
        if let level = level {
            // Use the new service for level-based questions
            let idiomQuestions = quizQuestionService.getQuestionsForLevel(level, languageService: languageService)
            questions = idiomQuestions.map { idiomQuestion in
                QuizQuestion(
                    question: idiomQuestion.question,
                    options: idiomQuestion.options,
                    correctAnswer: idiomQuestion.correctAnswer,
                    type: convertToQuizQuestionType(idiomQuestion.type)
                )
            }
        } else {
            // Fallback to old method for general quizzes
            let idioms = dailyIdiomService.loadIdioms()
            questions = generateQuizQuestions(from: idioms, level: nil)
        }
        
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showingResults = false
        answeredQuestions = []
    }
    
    private func convertToQuizQuestionType(_ idiomType: IdiomQuizQuestionType) -> QuizQuestionType {
        switch idiomType {
        case .meaning:
            return .meaning
        case .fillBlank:
            return .fillBlank
        case .context:
            return .context
        }
    }

    private func generateQuizQuestions(from idioms: [Idiom], level: String?) -> [QuizQuestion] {
        let selectedIdioms = Array(idioms.shuffled().prefix(3))
        var generated: [QuizQuestion] = []
        for idiom in selectedIdioms {
            let idiomQuestions = quizQuestionService.getQuestionsForIdiom(idiom, languageService: languageService)
            let mapped = idiomQuestions.map { iq in
                QuizQuestion(
                    question: iq.question,
                    options: iq.options,
                    correctAnswer: iq.correctAnswer,
                    type: convertToQuizQuestionType(iq.type)
                )
            }
            generated.append(contentsOf: mapped)
        }
        return Array(generated.shuffled().prefix(3))
    }
    
    private func exitQuiz() {
        questions = []
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showingResults = false
        answeredQuestions = []
        selectedLevel = nil
    }
    
    private func handleAnswer(_ answerIndex: Int) {
        selectedAnswer = answerIndex
        
        let isCorrect = answerIndex == questions[currentQuestionIndex].correctAnswer
        if isCorrect {
            score += 1
        }
        
        // Track the answer result
        answeredQuestions.append(isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if currentQuestionIndex < questions.count - 1 {
                currentQuestionIndex += 1
                selectedAnswer = nil
            } else {
                showingResults = true
            }
        }
    }
}

#Preview {
    QuizView()
        .environmentObject(LanguageService())
        .environmentObject(UserProgressService())
        .environmentObject(PaywallManager())
} 