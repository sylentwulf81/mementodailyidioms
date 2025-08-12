//
//  QuizView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI
import SwiftData

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
            VStack {
                if showingResults {
                    QuizResultsView(score: score, totalQuestions: questions.count) {
                        startNewQuiz()
                    }
                } else if questions.isEmpty {
                    if selectedLevel == nil {
                        QuizLevelSelectionView(
                            onLevelSelected: { level in
                                selectedLevel = level
                                startNewQuiz(for: level)
                            },
                            onProUpgrade: {
                                paywallManager.showPaywall()
                            }
                        )
                    } else {
                        QuizStartView {
                            startNewQuiz(for: selectedLevel!)
                        }
                    }
                } else {
                    VStack {
                        // Progress bar at the top
                        QuizProgressView(
                            currentQuestion: currentQuestionIndex + 1,
                            totalQuestions: questions.count,
                            answeredQuestions: answeredQuestions
                        )
                        .padding(.horizontal)
                        
                        QuizQuestionView(
                            question: questions[currentQuestionIndex],
                            selectedAnswer: $selectedAnswer,
                            onAnswerSelected: { answerIndex in
                                handleAnswer(answerIndex)
                            }
                        )
                    }
                }
            }
            .navigationTitle(languageService.quizTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !questions.isEmpty && !showingResults {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(languageService.exitButton) {
                            showingExitAlert = true
                        }
                        .foregroundColor(.red)
                    }
                } else if selectedLevel != nil && questions.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(languageService.backButton) {
                            selectedLevel = nil
                        }
                        .foregroundColor(.blue)
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
            .sheet(isPresented: $paywallManager.isShowingPaywall) {
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
    
    private func generateQuizQuestions(from idioms: [Idiom], level: String? = nil) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        
        // Determine question count based on level
        let questionCount: Int
        switch level {
        case "A1":
            questionCount = 2 // Starter: very basic, fewer questions
        case "A2":
            questionCount = 3 // Beginner: fewer questions
        case "B1":
            questionCount = 4 // Elementary: standard
        case "B2":
            questionCount = 5 // Intermediate: more challenging
        case "C1", "C2":
            questionCount = 6 // Advanced: comprehensive
        default:
            questionCount = 3 // Default
        }
        
        // Generate questions for each idiom
        for idiom in idioms.prefix(questionCount) {
            let questionTypes: [QuizQuestionType] = [.meaning, .fillBlank, .context]
            
            for questionType in questionTypes {
                if let question = createQuestion(for: idiom, type: questionType, level: level) {
                    questions.append(question)
                }
            }
        }
        
        // Shuffle and limit to question count
        return questions.shuffled().prefix(questionCount).map { $0 }
    }
    
    private func createQuestion(for idiom: Idiom, type: QuizQuestionType, level: String? = nil) -> QuizQuestion? {
        switch type {
        case .meaning:
            return createMeaningQuestion(for: idiom, level: level)
        case .fillBlank:
            return createFillBlankQuestion(for: idiom, level: level)
        case .context:
            return createContextQuestion(for: idiom, level: level)
        }
    }
    
    private func createMeaningQuestion(for idiom: Idiom, level: String?) -> QuizQuestion? {
        let question = languageService.isJapanese ?
            "「\(idiom.title)」の意味は？" :
            "What does '\(idiom.title)' mean?"
        
        let correctAnswer = idiom.jpMeaning
        
        // Create level-appropriate distractors
        let distractors = generateMeaningDistractors(for: idiom, level: level)
        
        let allOptions = ([correctAnswer] + distractors).shuffled()
        let correctIndex = allOptions.firstIndex(of: correctAnswer) ?? 0
        
        return QuizQuestion(
            question: question,
            options: allOptions,
            correctAnswer: correctIndex,
            type: .meaning
        )
    }
    
    private func createFillBlankQuestion(for idiom: Idiom, level: String?) -> QuizQuestion? {
        guard let example = idiom.examples.first, !example.english.isEmpty else {
            return nil
        }

        let blankedText = example.english.replacingOccurrences(of: idiom.title, with: "_____")
        
        let question = languageService.isJapanese ?
            "空欄を埋めてください：\(blankedText)" :
            "Fill in the blank: \(blankedText)"
        
        let correctAnswer = idiom.title
        let distractors = generateFillBlankDistractors(for: idiom, level: level)
        
        let allOptions = ([correctAnswer] + distractors).shuffled()
        let correctIndex = allOptions.firstIndex(of: correctAnswer) ?? 0
        
        return QuizQuestion(
            question: question,
            options: allOptions,
            correctAnswer: correctIndex,
            type: .fillBlank
        )
    }
    
    private func createContextQuestion(for idiom: Idiom, level: String?) -> QuizQuestion? {
        // Create more sophisticated context questions based on level
        let (question, correctAnswer, distractors) = createContextQuestionContent(for: idiom, level: level)
        
        let allOptions = ([correctAnswer] + distractors).shuffled()
        let correctIndex = allOptions.firstIndex(of: correctAnswer) ?? 0
        
        return QuizQuestion(
            question: question,
            options: allOptions,
            correctAnswer: correctIndex,
            type: .context
        )
    }
    
    private func createContextQuestionContent(for idiom: Idiom, level: String?) -> (String, String, [String]) {
        // Create level-appropriate context questions
        // For B1 and higher levels, use more sophisticated questions
        if let level = level, (level == "B1" || level == "B2" || level == "C1" || level == "C2") {
            return createAdvancedContextQuestion(for: idiom, level: level)
        }
        
        switch idiom.title {
        case "Break a leg":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような場面で使われますか？" : 
                "In what context would you use '\(idiom.title)'?"
            let correctAnswer = languageService.isJapanese ? "舞台やパフォーマンスの前" : "Before a performance or show"
            let distractors = languageService.isJapanese ? [
                "病気の時",
                "スポーツの試合前",
                "仕事の面接前"
            ] : [
                "When someone is sick",
                "Before a sports game",
                "Before a job interview"
            ]
            return (question, correctAnswer, distractors)
            
        case "Piece of cake":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような状況を表しますか？" : 
                "What situation does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "非常に簡単なこと" : "Something very easy"
            let distractors = languageService.isJapanese ? [
                "おいしい食べ物",
                "困難な課題",
                "複雑な問題"
            ] : [
                "Delicious food",
                "A difficult challenge",
                "A complex problem"
            ]
            return (question, correctAnswer, distractors)
            
        case "Under the weather":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような状態を表しますか？" : 
                "What condition does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "体調が悪い状態" : "Feeling unwell"
            let distractors = languageService.isJapanese ? [
                "天気が悪い",
                "気分が良い",
                "疲れている"
            ] : [
                "Bad weather",
                "Feeling good",
                "Feeling tired"
            ]
            return (question, correctAnswer, distractors)
            
        case "Hit the books":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような行動を表しますか？" : 
                "What action does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "一生懸命勉強する" : "Study hard"
            let distractors = languageService.isJapanese ? [
                "本を投げる",
                "図書館に行く",
                "本を買う"
            ] : [
                "Throw books",
                "Go to the library",
                "Buy books"
            ]
            return (question, correctAnswer, distractors)
            
        case "Let the cat out of the bag":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような行動を表しますか？" : 
                "What action does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "秘密を漏らす" : "Reveal a secret"
            let distractors = languageService.isJapanese ? [
                "猫を逃がす",
                "袋を開ける",
                "秘密を守る"
            ] : [
                "Let a cat escape",
                "Open a bag",
                "Keep a secret"
            ]
            return (question, correctAnswer, distractors)
            
        case "Spill the beans":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような行動を表しますか？" : 
                "What action does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "秘密を暴露する" : "Reveal a secret"
            let distractors = languageService.isJapanese ? [
                "豆をこぼす",
                "情報を隠す",
                "真実を話す"
            ] : [
                "Spill actual beans",
                "Hide information",
                "Tell the truth"
            ]
            return (question, correctAnswer, distractors)
            
        case "Cost an arm and a leg":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような価格を表しますか？" : 
                "What price does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "非常に高価" : "Very expensive"
            let distractors = languageService.isJapanese ? [
                "安価",
                "適正価格",
                "無料"
            ] : [
                "Cheap",
                "Reasonable price",
                "Free"
            ]
            return (question, correctAnswer, distractors)
            
        case "On cloud nine":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような感情を表しますか？" : 
                "What emotion does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "非常に幸せ" : "Very happy"
            let distractors = languageService.isJapanese ? [
                "悲しい",
                "怒っている",
                "心配している"
            ] : [
                "Sad",
                "Angry",
                "Worried"
            ]
            return (question, correctAnswer, distractors)
            
        case "Once in a blue moon":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような頻度を表しますか？" : 
                "What frequency does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "非常に稀" : "Very rarely"
            let distractors = languageService.isJapanese ? [
                "毎日",
                "時々",
                "よく"
            ] : [
                "Every day",
                "Sometimes",
                "Often"
            ]
            return (question, correctAnswer, distractors)
            
        case "Hit the sack":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような行動を表しますか？" : 
                "What action does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "寝る" : "Go to sleep"
            let distractors = languageService.isJapanese ? [
                "袋を叩く",
                "起きる",
                "働く"
            ] : [
                "Hit a sack",
                "Wake up",
                "Work"
            ]
            return (question, correctAnswer, distractors)
            
        default:
            // Default context question for other idioms
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような場面で使われますか？" : 
                "In what context would you use '\(idiom.title)'?"
            let correctAnswer = languageService.isJapanese ? 
                "励ましの場面" : 
                "Encouraging someone"
            let distractors = languageService.isJapanese ? [
                "怒りの場面",
                "悲しみの場面", 
                "喜びの場面"
            ] : [
                "Expressing anger",
                "Expressing sadness",
                "Expressing joy"
            ]
            return (question, correctAnswer, distractors)
        }
    }
    
    // Additional sophisticated questions for higher levels
    private func createAdvancedContextQuestion(for idiom: Idiom, level: String?) -> (String, String, [String]) {
        switch idiom.title {
        case "Hit the nail on the head":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような分析を表しますか？" : 
                "What type of analysis does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "核心を突いた分析" : "Analysis that hits the core issue"
            let distractors = languageService.isJapanese ? [
                "表面的な分析",
                "間違った分析",
                "不完全な分析"
            ] : [
                "Superficial analysis",
                "Incorrect analysis",
                "Incomplete analysis"
            ]
            return (question, correctAnswer, distractors)
            
        case "Bite the bullet":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような態度を表しますか？" : 
                "What attitude does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "困難を受け入れる覚悟" : "Accepting difficult circumstances"
            let distractors = languageService.isJapanese ? [
                "困難を避ける",
                "諦める",
                "逃げる"
            ] : [
                "Avoiding difficulties",
                "Giving up",
                "Running away"
            ]
            return (question, correctAnswer, distractors)
            
        case "Bend over backwards":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような努力を表しますか？" : 
                "What type of effort does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "最大限の努力" : "Maximum effort"
            let distractors = languageService.isJapanese ? [
                "最小限の努力",
                "普通の努力",
                "怠慢"
            ] : [
                "Minimal effort",
                "Normal effort",
                "Laziness"
            ]
            return (question, correctAnswer, distractors)
            
        case "Break the ice":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような状況で使われますか？" : 
                "In what situation would you use '\(idiom.title)'?"
            let correctAnswer = languageService.isJapanese ? "緊張した場面を和らげる" : "Easing a tense situation"
            let distractors = languageService.isJapanese ? [
                "氷を割る",
                "喧嘩を始める",
                "静寂を作る"
            ] : [
                "Breaking actual ice",
                "Starting a fight",
                "Creating silence"
            ]
            return (question, correctAnswer, distractors)
            
        case "Butterflies in your stomach":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような感情を表しますか？" : 
                "What emotion does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "緊張や不安" : "Nervousness or anxiety"
            let distractors = languageService.isJapanese ? [
                "空腹感",
                "怒り",
                "喜び"
            ] : [
                "Hunger",
                "Anger",
                "Joy"
            ]
            return (question, correctAnswer, distractors)
            
        case "By the book":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような方法を表しますか？" : 
                "What method does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "規則通りに従う" : "Following rules exactly"
            let distractors = languageService.isJapanese ? [
                "本を読む",
                "自由に行動する",
                "規則を無視する"
            ] : [
                "Reading a book",
                "Acting freely",
                "Ignoring rules"
            ]
            return (question, correctAnswer, distractors)
            
        case "Cut corners":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような行動を表しますか？" : 
                "What action does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "手抜きをする" : "Taking shortcuts"
            let distractors = languageService.isJapanese ? [
                "角を切る",
                "丁寧に作業する",
                "時間をかける"
            ] : [
                "Cutting actual corners",
                "Working carefully",
                "Taking time"
            ]
            return (question, correctAnswer, distractors)
            
        case "Devil's advocate":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような役割を表しますか？" : 
                "What role does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "反対意見を述べる人" : "Someone who argues the opposite"
            let distractors = languageService.isJapanese ? [
                "悪魔の代弁者",
                "賛成意見を述べる人",
                "中立な立場の人"
            ] : [
                "Devil's spokesperson",
                "Someone who agrees",
                "Neutral person"
            ]
            return (question, correctAnswer, distractors)
            
        case "Face the music":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような行動を表しますか？" : 
                "What action does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "結果を受け入れる" : "Accepting consequences"
            let distractors = languageService.isJapanese ? [
                "音楽を聴く",
                "逃げる",
                "無視する"
            ] : [
                "Listening to music",
                "Running away",
                "Ignoring"
            ]
            return (question, correctAnswer, distractors)
            
        case "Go the extra mile":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような努力を表しますか？" : 
                "What effort does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "期待以上の努力" : "Going beyond expectations"
            let distractors = languageService.isJapanese ? [
                "一マイル歩く",
                "最小限の努力",
                "普通の努力"
            ] : [
                "Walking a mile",
                "Minimal effort",
                "Normal effort"
            ]
            return (question, correctAnswer, distractors)
            
        case "Jump the gun":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような行動を表しますか？" : 
                "What action does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "早計に行動する" : "Acting too early"
            let distractors = languageService.isJapanese ? [
                "銃を撃つ",
                "慎重に行動する",
                "待つ"
            ] : [
                "Shooting a gun",
                "Acting carefully",
                "Waiting"
            ]
            return (question, correctAnswer, distractors)
            
        case "Miss the boat":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような状況を表しますか？" : 
                "What situation does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "機会を逃す" : "Missing an opportunity"
            let distractors = languageService.isJapanese ? [
                "ボートを逃す",
                "機会を掴む",
                "待つ"
            ] : [
                "Missing a boat",
                "Seizing an opportunity",
                "Waiting"
            ]
            return (question, correctAnswer, distractors)
            
        case "Not my cup of tea":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような感情を表しますか？" : 
                "What feeling does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "好みではない" : "Not to one's liking"
            let distractors = languageService.isJapanese ? [
                "紅茶が嫌い",
                "好みである",
                "興味がある"
            ] : [
                "Disliking tea",
                "To one's liking",
                "Being interested"
            ]
            return (question, correctAnswer, distractors)
            
        case "Pull yourself together":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような状態を表しますか？" : 
                "What state does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "冷静になる" : "Getting composed"
            let distractors = languageService.isJapanese ? [
                "自分を引っ張る",
                "混乱する",
                "怒る"
            ] : [
                "Pulling yourself",
                "Getting confused",
                "Getting angry"
            ]
            return (question, correctAnswer, distractors)
            
        case "Speak of the devil":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような状況で使われますか？" : 
                "In what situation would you use '\(idiom.title)'?"
            let correctAnswer = languageService.isJapanese ? "話していた人が現れる" : "When someone you were talking about appears"
            let distractors = languageService.isJapanese ? [
                "悪魔について話す",
                "悪口を言う",
                "褒める"
            ] : [
                "Talking about the devil",
                "Speaking badly",
                "Praising"
            ]
            return (question, correctAnswer, distractors)
            
        case "Take a rain check":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような行動を表しますか？" : 
                "What action does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "延期する" : "Postponing"
            let distractors = languageService.isJapanese ? [
                "雨のチェックを取る",
                "即座に決断する",
                "断る"
            ] : [
                "Taking a weather check",
                "Deciding immediately",
                "Refusing"
            ]
            return (question, correctAnswer, distractors)
            
        case "The ball is in your court":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような状況を表しますか？" : 
                "What situation does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "あなたの番である" : "It's your turn"
            let distractors = languageService.isJapanese ? [
                "ボールがコートにある",
                "相手の番である",
                "終了である"
            ] : [
                "The ball is on the court",
                "It's the other person's turn",
                "It's finished"
            ]
            return (question, correctAnswer, distractors)
            
        case "Throw in the towel":
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような行動を表しますか？" : 
                "What action does '\(idiom.title)' describe?"
            let correctAnswer = languageService.isJapanese ? "諦める" : "Giving up"
            let distractors = languageService.isJapanese ? [
                "タオルを投げる",
                "頑張る",
                "続ける"
            ] : [
                "Throwing a towel",
                "Trying hard",
                "Continuing"
            ]
            return (question, correctAnswer, distractors)
            
        default:
            // For other idioms, use the default context question
            let question = languageService.isJapanese ? 
                "「\(idiom.title)」はどのような場面で使われますか？" : 
                "In what context would you use '\(idiom.title)'?"
            let correctAnswer = languageService.isJapanese ? 
                "励ましの場面" : 
                "Encouraging someone"
            let distractors = languageService.isJapanese ? [
                "怒りの場面",
                "悲しみの場面", 
                "喜びの場面"
            ] : [
                "Expressing anger",
                "Expressing sadness",
                "Expressing joy"
            ]
            return (question, correctAnswer, distractors)
        }
    }
    
    private func generateMeaningDistractors(for idiom: Idiom, level: String? = nil) -> [String] {
        // Get other idioms to use as distractors
        let allIdioms = dailyIdiomService.loadIdioms()
        let otherIdioms = allIdioms.filter { $0.id != idiom.id }
        
        // Filter by level if specified
        let filteredIdioms = level != nil ? otherIdioms.filter { $0.level == level } : otherIdioms
        
        let distractors = filteredIdioms.shuffled().prefix(3).map { $0.jpMeaning }
        return Array(distractors)
    }
    
    private func generateFillBlankDistractors(for idiom: Idiom, level: String? = nil) -> [String] {
        // Get other idioms to use as distractors
        let allIdioms = dailyIdiomService.loadIdioms()
        let otherIdioms = allIdioms.filter { $0.id != idiom.id }
        
        // Filter by level if specified
        let filteredIdioms = level != nil ? otherIdioms.filter { $0.level == level } : otherIdioms
        
        let distractors = filteredIdioms.shuffled().prefix(3).map { $0.title }
        return Array(distractors)
    }
}

struct QuizQuestion {
    let question: String
    let options: [String]
    let correctAnswer: Int
    let type: QuizQuestionType
}

enum QuizQuestionType {
    case meaning
    case fillBlank
    case context
}

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

struct QuizQuestionView: View {
    let question: QuizQuestion
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

struct QuizResultsView: View {
    @EnvironmentObject private var languageService: LanguageService
    @EnvironmentObject private var userProgressService: UserProgressService
    let score: Int
    let totalQuestions: Int
    let onRetry: () -> Void
    @State private var showConfetti = false
    
    private var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }
    
    private var message: String {
        if languageService.isJapanese {
            switch percentage {
            case 100:
                return "完璧です！素晴らしい！"
            case 80..<100:
                return "素晴らしい！"
            case 60..<80:
                return "よくできました！"
            case 40..<60:
                return "もう少し頑張りましょう！"
            default:
                return "復習が必要ですね。"
            }
        } else {
            switch percentage {
            case 100:
                return "Perfect score! Absolutely brilliant!"
            case 80..<100:
                return "Excellent!"
            case 60..<80:
                return "Well done!"
            case 40..<60:
                return "Keep practicing!"
            default:
                return "More review needed."
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: percentage == 100 ? "crown.fill" : (percentage >= 60 ? "star.fill" : "star"))
                .font(.system(size: 64))
                .foregroundColor(percentage == 100 ? .yellow : (percentage >= 60 ? .yellow : .gray))
            
            Text(languageService.quizCompleteTitle)
                .font(.title)
                .fontWeight(.bold)
            
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
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(languageService.retryButton) {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .onAppear {
            if percentage == 100 {
                showConfetti = true
            }
            // Record quiz completion
            userProgressService.recordQuizCompletion()
        }
        .confettiCannon(isAnimating: $showConfetti)
    }
}

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

struct QuizLevelSelectionView: View {
    @EnvironmentObject private var languageService: LanguageService
    @AppStorage("isPro") private var isPro = false
    let onLevelSelected: (String) -> Void
    let onProUpgrade: () -> Void
    
    private let levels = [
        ("A1", "Starter", "Very basic expressions", false),
        ("A2", "Beginner", "Basic idioms", false),
        ("B1", "Elementary", "Common expressions", false),
        ("B2", "Intermediate", "Advanced phrases", false),
        ("C1", "Advanced", "Complex idioms", true),
        ("C2", "Expert", "Master level", true)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Add top spacing to avoid Dynamic Island
                Spacer()
                    .frame(height: 20)
                
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                Text(languageService.quizLevelSelectionTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(languageService.quizLevelSelectionDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 8) {
                    ForEach(levels, id: \.0) { level, title, description, isPremium in
                        LevelQuizCard(
                            level: level,
                            title: title,
                            description: description,
                            isPremium: isPremium,
                            isUnlocked: isPro || !isPremium,
                            onTap: {
                                if isPremium && !isPro {
                                    onProUpgrade()
                                } else {
                                    onLevelSelected(level)
                                }
                            }
                        )
                    }
                }
            }
            .padding()
            .padding(.bottom, 80) // Add extra padding for bottom navigation bar
        }
    }
}

struct LevelQuizCard: View {
    let level: String
    let title: String
    let description: String
    let isPremium: Bool
    let isUnlocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("Level \(level)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(isUnlocked ? .primary : .secondary)
                        
                        if isPremium {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text("PRO")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        if !isUnlocked {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                Text("LOCKED")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isUnlocked ? .primary : .secondary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(isUnlocked ? .secondary : .secondary.opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(isUnlocked ? .blue : .secondary.opacity(0.5))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isUnlocked ? Color(.systemBackground) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isUnlocked ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
            .shadow(color: isUnlocked ? Color.black.opacity(0.05) : Color.clear, radius: 2, x: 0, y: 1)
        }
        .disabled(!isUnlocked)
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}

#Preview {
    QuizView()
        .environmentObject(LanguageService())
        .environmentObject(UserProgressService())
        .environmentObject(PaywallManager())
} 