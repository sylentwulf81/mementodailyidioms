//
//  QuizQuestionService.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import Foundation

// MARK: - Quiz Question Models

struct QuizQuestionData: Codable {
    let quiz_questions: [String: [String: IdiomQuizData]]
}

struct IdiomQuizData: Codable {
    let meaning: QuestionData
    let fill_blank: QuestionData
    let context: QuestionData
}

struct QuestionData: Codable {
    let question: String
    let question_jp: String
    let correct_answer: String
    let correct_answer_jp: String
    let distractors: [String]
    let distractors_jp: [String]
}

class QuizQuestionService: ObservableObject {
    private var quizData: QuizQuestionData?
    
    init() {
        loadQuizQuestions()
    }
    
    // MARK: - Data Loading
    
    private func loadQuizQuestions() {
        guard let url = Bundle.main.url(forResource: "quiz_questions", withExtension: "json") else {
            print("Error: Could not find quiz_questions.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            quizData = try JSONDecoder().decode(QuizQuestionData.self, from: data)
        } catch {
            print("Error decoding quiz questions: \(error)")
        }
    }
    
    // MARK: - Question Generation
    
    func getQuestionsForIdiom(_ idiom: Idiom, languageService: LanguageService) -> [IdiomQuizQuestion] {
        guard let quizData = quizData,
              let levelData = quizData.quiz_questions[idiom.level],
              let idiomData = levelData[idiom.title] else {
            // Fallback to default questions if not found in JSON
            return generateDefaultQuestions(for: idiom, languageService: languageService)
        }
        
        var questions: [IdiomQuizQuestion] = []
        
        // Meaning question
        questions.append(createQuestionFromData(
            idiomData.meaning,
            type: .meaning,
            languageService: languageService
        ))
        
        // Fill blank question
        questions.append(createQuestionFromData(
            idiomData.fill_blank,
            type: .fillBlank,
            languageService: languageService
        ))
        
        // Context question
        questions.append(createQuestionFromData(
            idiomData.context,
            type: .context,
            languageService: languageService
        ))
        
        return questions.shuffled()
    }
    
    private func createQuestionFromData(
        _ data: QuestionData,
        type: IdiomQuizQuestionType,
        languageService: LanguageService
    ) -> IdiomQuizQuestion {
        let question = languageService.isJapanese ? data.question_jp : data.question
        let correctAnswer = languageService.isJapanese ? data.correct_answer_jp : data.correct_answer
        let distractors = languageService.isJapanese ? data.distractors_jp : data.distractors
        
        let allOptions = ([correctAnswer] + distractors).shuffled()
        let correctIndex = allOptions.firstIndex(of: correctAnswer) ?? 0
        
        return IdiomQuizQuestion(
            question: question,
            options: allOptions,
            correctAnswer: correctIndex,
            type: type
        )
    }
    
    // MARK: - Fallback Question Generation
    
    private func generateDefaultQuestions(for idiom: Idiom, languageService: LanguageService) -> [IdiomQuizQuestion] {
        var questions: [IdiomQuizQuestion] = []
        
        // Meaning question
        let meaningQuestion = languageService.isJapanese ? 
            "「\(idiom.title)」の意味は？" : 
            "What does '\(idiom.title)' mean?"
        
        let correctAnswer = languageService.isJapanese ? idiom.jpMeaning : idiom.enMeaning
        let distractors = generateMeaningDistractors(for: idiom, languageService: languageService)
        
        let meaningOptions = ([correctAnswer] + distractors).shuffled()
        let meaningCorrectIndex = meaningOptions.firstIndex(of: correctAnswer) ?? 0
        
        questions.append(IdiomQuizQuestion(
            question: meaningQuestion,
            options: meaningOptions,
            correctAnswer: meaningCorrectIndex,
            type: .meaning
        ))
        
        // Fill blank question
        let example = idiom.examples.first ?? Example(english: "", japanese: "", tone: "casual")
        let blankedText = example.english.replacingOccurrences(of: idiom.title, with: "_____")
        
        let fillBlankQuestion = languageService.isJapanese ? 
            "空欄を埋めてください：\(blankedText)" : 
            "Fill in the blank: \(blankedText)"
        
        let fillBlankCorrectAnswer = idiom.title
        let fillBlankDistractors = generateFillBlankDistractors(for: idiom, languageService: languageService)
        
        let fillBlankOptions = ([fillBlankCorrectAnswer] + fillBlankDistractors).shuffled()
        let fillBlankCorrectIndex = fillBlankOptions.firstIndex(of: fillBlankCorrectAnswer) ?? 0
        
        questions.append(IdiomQuizQuestion(
            question: fillBlankQuestion,
            options: fillBlankOptions,
            correctAnswer: fillBlankCorrectIndex,
            type: .fillBlank
        ))
        
        // Context question
        let contextQuestion = languageService.isJapanese ? 
            "「\(idiom.title)」はどのような場面で使われますか？" : 
            "In what context would you use '\(idiom.title)'?"
        
        let contextCorrectAnswer = languageService.isJapanese ? 
            "励ましの場面" : 
            "Encouraging someone"
        
        let contextDistractors = languageService.isJapanese ? [
            "怒りの場面",
            "悲しみの場面",
            "喜びの場面"
        ] : [
            "Expressing anger",
            "Expressing sadness",
            "Expressing joy"
        ]
        
        let contextOptions = ([contextCorrectAnswer] + contextDistractors).shuffled()
        let contextCorrectIndex = contextOptions.firstIndex(of: contextCorrectAnswer) ?? 0
        
        questions.append(IdiomQuizQuestion(
            question: contextQuestion,
            options: contextOptions,
            correctAnswer: contextCorrectIndex,
            type: .context
        ))
        
        return questions.shuffled()
    }
    
    private func generateMeaningDistractors(for idiom: Idiom, languageService: LanguageService) -> [String] {
        // Get other idioms to use as distractors
        let dailyIdiomService = DailyIdiomService()
        let allIdioms = dailyIdiomService.loadIdioms()
        let otherIdioms = allIdioms.filter { $0.id != idiom.id }
        
        return otherIdioms.shuffled().prefix(3).map { 
            languageService.isJapanese ? $0.jpMeaning : $0.enMeaning 
        }
    }
    
    private func generateFillBlankDistractors(for idiom: Idiom, languageService: LanguageService) -> [String] {
        // Get other idioms to use as distractors
        let dailyIdiomService = DailyIdiomService()
        let allIdioms = dailyIdiomService.loadIdioms()
        let otherIdioms = allIdioms.filter { $0.id != idiom.id }
        
        return otherIdioms.shuffled().prefix(3).map { $0.title }
    }
    
    // MARK: - Level-based Question Access
    
    func getQuestionsForLevel(_ level: String, languageService: LanguageService) -> [IdiomQuizQuestion] {
        // Get actual idioms for this level
        let dailyIdiomService = DailyIdiomService()
        let idiomsForLevel = dailyIdiomService.loadIdioms().filter { $0.level == level }
        
        var allQuestions: [IdiomQuizQuestion] = []
        
        for idiom in idiomsForLevel {
            let questions = getQuestionsForIdiom(idiom, languageService: languageService)
            allQuestions.append(contentsOf: questions)
        }
        
        // Limit to a reasonable number of questions (3-6 depending on level)
        let questionCount: Int
        switch level {
        case "A1", "A2":
            questionCount = 3
        case "B1", "B2":
            questionCount = 4
        case "C1", "C2":
            questionCount = 5
        default:
            questionCount = 3
        }
        
        return Array(allQuestions.shuffled().prefix(questionCount))
    }
    
    // MARK: - Available Levels
    
    func getAvailableLevels() -> [String] {
        guard let quizData = quizData else { return [] }
        return Array(quizData.quiz_questions.keys).sorted()
    }
    
    func getAvailableIdiomsForLevel(_ level: String) -> [String] {
        guard let quizData = quizData,
              let levelData = quizData.quiz_questions[level] else {
            return []
        }
        return Array(levelData.keys).sorted()
    }
} 