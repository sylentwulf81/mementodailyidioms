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

        var correctAnswer: String
        var distractors: [String]

        switch type {
        case .meaning, .context:
            correctAnswer = data.correct_answer_jp
            distractors = data.distractors_jp
        case .fillBlank:
            correctAnswer = data.correct_answer
            distractors = data.distractors
        }
        
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
        let allIdioms = DailyIdiomService().loadIdioms()

        // Meaning question
        let meaningQuestionText = languageService.isJapanese ?
            "「\(idiom.title)」の意味は？" :
            "What does '\(idiom.title)' mean?"
        
        let meaningCorrectAnswer = idiom.jpMeaning
        let meaningDistractors = generateMeaningDistractors(for: idiom, allIdioms: allIdioms)
        
        let meaningOptions = ([meaningCorrectAnswer] + meaningDistractors).shuffled()
        let meaningCorrectIndex = meaningOptions.firstIndex(of: meaningCorrectAnswer) ?? 0
        
        questions.append(IdiomQuizQuestion(
            question: meaningQuestionText,
            options: meaningOptions,
            correctAnswer: meaningCorrectIndex,
            type: .meaning
        ))
        
        // Fill blank question
        if let example = idiom.examples.first, !example.english.isEmpty {
            let blankedText = example.english.replacingOccurrences(of: idiom.title, with: "_____")

            let fillBlankQuestionText = languageService.isJapanese ?
                "空欄を埋めてください：\(blankedText)" :
                "Fill in the blank: \(blankedText)"

            let fillBlankCorrectAnswer = idiom.title
            let fillBlankDistractors = generateFillBlankDistractors(for: idiom, allIdioms: allIdioms)

            let fillBlankOptions = ([fillBlankCorrectAnswer] + fillBlankDistractors).shuffled()
            let fillBlankCorrectIndex = fillBlankOptions.firstIndex(of: fillBlankCorrectAnswer) ?? 0

            questions.append(IdiomQuizQuestion(
                question: fillBlankQuestionText,
                options: fillBlankOptions,
                correctAnswer: fillBlankCorrectIndex,
                type: .fillBlank
            ))
        }
        
        // Dynamic Context question
        if let contextQuestion = createDynamicContextQuestion(for: idiom, allIdioms: allIdioms, languageService: languageService) {
            questions.append(contextQuestion)
        }
        
        return questions.shuffled()
    }
    
    private func generateMeaningDistractors(for idiom: Idiom, allIdioms: [Idiom]) -> [String] {
        let otherIdioms = allIdioms.filter { $0.id != idiom.id && $0.title != idiom.title }
        return otherIdioms.shuffled().prefix(3).map { $0.jpMeaning }
    }
    
    private func generateFillBlankDistractors(for idiom: Idiom, allIdioms: [Idiom]) -> [String] {
        let otherIdioms = allIdioms.filter { $0.id != idiom.id && $0.title != idiom.title }
        return otherIdioms.shuffled().prefix(3).map { $0.title }
    }

    private func createDynamicContextQuestion(for idiom: Idiom, allIdioms: [Idiom], languageService: LanguageService) -> IdiomQuizQuestion? {
        let tagToCategory: [String: String] = [
            "挨拶": "Greetings", "励まし": "Encouragement", "成功": "Success", "簡単": "Simplicity",
            "体調": "Health", "勉強": "Studying", "秘密": "Secrecy", "高価": "Cost",
            "幸せ": "Happiness", "稀": "Rarity", "睡眠": "Rest", "努力": "Effort",
            "トラブル": "Trouble", "終了": "Completion", "利益": "Profit", "問題回避": "Problem-solving",
            "突然": "Suddenness", "理解": "Understanding", "怖気": "Hesitation", "冗談": "Joking",
            "正確": "Accuracy", "覚悟": "Determination", "死亡": "Endings", "尽力": "Diligence",
            "緊張": "Nervousness", "規則": "Rules", "手抜き": "Carelessness", "反対": "Disagreement",
            "責任": "Responsibility", "サービス": "Service", "時期": "Timing", "免除": "Exemption",
            "機会": "Opportunity", "好み": "Preference", "冷静": "Calmness", "偶然": "Coincidence",
            "延期": "Postponement", "決定": "Decision-making", "諦め": "Giving up", "過労": "Overworking",
            "リスク": "Risk", "流行": "Trends", "窮地": "Dilemmas", "習慣": "Habits",
            "能力": "Ability", "問題": "Problems", "幸運": "Luck", "開始": "Beginnings",
            "台無し": "Spoiling", "要点": "Main points", "状況": "Situations", "真意": "True meaning",
            "犠牲": "Sacrifice", "実行": "Action", "再設計": "Redesign", "矛盾": "Contradiction",
            "方向": "Direction", "悪化": "Worsening", "不利": "Disadvantage", "見破り": "Seeing through",
            "対処": "Dealing with", "感情": "Emotion", "危険": "Danger", "知識": "Knowledge",
            "回復": "Recovery", "誇張": "Exaggeration", "独特": "Uniqueness", "沈黙": "Silence",
            "支え": "Support", "後悔": "Regret", "慎重": "Caution", "継続": "Continuation",
            "イライラ": "Annoyance", "深入り": "Getting deep", "即興": "Improvisation", "侮辱": "Insult",
            "迅速": "Speed", "ギリギリ": "Barely", "制御不能": "Out of control", "無視": "Ignoring",
            "出発": "Departure", "要約": "Summarizing", "難しくない": "Not difficult", "監視": "Watching",
            "一石二鳥": "Efficiency", "天気": "Weather", "一致": "Agreement", "早起き": "Waking up early",
            "把握": "Grasping", "先進的": "Advanced", "原点": "Basics", "余裕": "Capacity",
            "革新的": "Innovative", "戻る": "Returning", "詳しく調べる": "Investigating", "影響": "Impact",
            "創造的": "Creative", "メッセージ": "Messaging", "すぐに使える": "Ready to use", "境界を押し広げる": "Pushing boundaries",
            "反応": "Reaction", "相乗効果": "Synergy", "非公開": "Private", "手伝う": "Helping",
            "注意深い": "Alertness", "最後": "The end", "時間": "Time"
        ]

        guard let primaryTag = idiom.tags.first, let correctAnswerCategory = tagToCategory[primaryTag] else {
            return nil
        }

        let allCategories = Array(Set(tagToCategory.values))
        var distractors = allCategories.filter { $0 != correctAnswerCategory }

        guard distractors.count >= 3 else { return nil }
        distractors = Array(distractors.shuffled().prefix(3))

        let questionText = languageService.isJapanese ? "このイディオムは主にどのような文脈で使われますか？" : "In what primary context is this idiom used?"

        let options = ([correctAnswerCategory] + distractors).shuffled()
        let correctIndex = options.firstIndex(of: correctAnswerCategory) ?? 0

        return IdiomQuizQuestion(
            question: questionText,
            options: options,
            correctAnswer: correctIndex,
            type: .context
        )
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