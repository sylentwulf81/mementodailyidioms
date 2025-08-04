//
//  LanguageService.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import Foundation
import SwiftUI

class LanguageService: ObservableObject {
    @AppStorage("useJapaneseInterface") private var useJapaneseInterface = true
    
    var currentLocale: Locale {
        return useJapaneseInterface ? Locale(identifier: "ja_JP") : Locale(identifier: "en_US")
    }
    
    var isJapanese: Bool {
        return useJapaneseInterface
    }
    
    // MARK: - UI Text Translations
    
    // Tab Labels
    var homeTabLabel: String {
        return isJapanese ? "ホーム" : "Home"
    }
    
    var libraryTabLabel: String {
        return isJapanese ? "ライブラリ" : "Library"
    }
    
    var quizTabLabel: String {
        return isJapanese ? "クイズ" : "Quiz"
    }
    
    var settingsTabLabel: String {
        return isJapanese ? "設定" : "Settings"
    }
    
    // Daily Idiom View
    var todaysIdiomTitle: String {
        return isJapanese ? "今日のイディオム" : "Today's Idiom"
    }
    
    var idiomDetailsTitle: String {
        return isJapanese ? "イディオム詳細" : "Idiom Details"
    }
    
    var meaningLabel: String {
        return isJapanese ? "意味" : "Meaning"
    }
    
    var nuanceLabel: String {
        return isJapanese ? "ニュアンス" : "Nuance"
    }
    
    var examplesLabel: String {
        return isJapanese ? "例文" : "Examples"
    }
    
    var tagsLabel: String {
        return isJapanese ? "タグ" : "Tags"
    }
    
    var favoriteLabel: String {
        return isJapanese ? "お気に入り" : "Favorite"
    }
    
    var playButtonLabel: String {
        return isJapanese ? "再生" : "Play"
    }
    
    var stopButtonLabel: String {
        return isJapanese ? "停止" : "Stop"
    }
    
    // Library View
    var searchPrompt: String {
        return isJapanese ? "イディオムを検索" : "Search idioms"
    }
    
    var libraryTitle: String {
        return isJapanese ? "ライブラリ" : "Library"
    }
    
    // Quiz View
    var quizTitle: String {
        return isJapanese ? "クイズ" : "Quiz"
    }
    
    var quizStartTitle: String {
        return isJapanese ? "クイズに挑戦" : "Take Quiz"
    }
    
    var quizStartDescription: String {
        return isJapanese ? "最近学習したイディオムでクイズを行います。3問中何問正解できるでしょうか？" : "Test your knowledge with recently learned idioms. How many can you get right out of 3?"
    }
    
    var startQuizButton: String {
        return isJapanese ? "クイズを開始" : "Start Quiz"
    }
    
    var quizCompleteTitle: String {
        return isJapanese ? "クイズ完了！" : "Quiz Complete!"
    }
    
    var retryButton: String {
        return isJapanese ? "もう一度挑戦" : "Try Again"
    }
    
    var quizLevelSelectionTitle: String {
        return isJapanese ? "レベルを選択" : "Select Level"
    }
    
    var quizLevelSelectionDescription: String {
        return isJapanese ? "あなたのレベルに合ったクイズを選択してください" : "Choose a quiz level that matches your proficiency"
    }
    
    var quizExitTitle: String {
        return isJapanese ? "クイズを終了しますか？" : "Exit Quiz?"
    }
    
    var quizExitMessage: String {
        return isJapanese ? "現在の進捗は保存されません。本当に終了しますか？" : "Your current progress will not be saved. Are you sure you want to exit?"
    }
    
    var exitButton: String {
        return isJapanese ? "終了" : "Exit"
    }
    
    var cancelButton: String {
        return isJapanese ? "キャンセル" : "Cancel"
    }
    
    // Settings View
    var settingsTitle: String {
        return isJapanese ? "設定" : "Settings"
    }
    
    var audioSettingsSection: String {
        return isJapanese ? "音声設定" : "Audio Settings"
    }
    
    var useSystemVoiceLabel: String {
        return isJapanese ? "オフライン時にシステム音声を使用" : "Use system voice when offline"
    }
    
    var interfaceSection: String {
        return isJapanese ? "インターフェース" : "Interface"
    }
    
    var japaneseInterfaceLabel: String {
        return isJapanese ? "日本語インターフェース" : "Japanese Interface"
    }
    
    var subscriptionSection: String {
        return isJapanese ? "サブスクリプション" : "Subscription"
    }
    
    var proMemberLabel: String {
        return isJapanese ? "Pro会員" : "Pro Member"
    }
    
    var freePlanLabel: String {
        return isJapanese ? "無料プラン" : "Free Plan"
    }
    
    var allFeaturesAvailable: String {
        return isJapanese ? "すべての機能が利用可能" : "All features available"
    }
    
    var basicFeaturesOnly: String {
        return isJapanese ? "基本機能のみ利用可能" : "Basic features only"
    }
    
    var upgradeButton: String {
        return isJapanese ? "アップグレード" : "Upgrade"
    }
    
    var restorePurchasesButton: String {
        return isJapanese ? "購入を復元" : "Restore Purchases"
    }
    
    var appInfoSection: String {
        return isJapanese ? "アプリ情報" : "App Info"
    }
    
    var versionLabel: String {
        return isJapanese ? "バージョン" : "Version"
    }
    
    var sendFeedbackButton: String {
        return isJapanese ? "フィードバックを送信" : "Send Feedback"
    }
    
    var rateAppButton: String {
        return isJapanese ? "App Storeで評価" : "Rate on App Store"
    }
    
    var developerInfoSection: String {
        return isJapanese ? "開発者情報" : "Developer Info"
    }
    
    var appDescription: String {
        return isJapanese ? "アメリカ英語のイディオムを深く理解するためのアプリです。" : "An app to deeply understand American English idioms."
    }
    
    // Settings View - Additional strings
    var subscriptionLabel: String {
        return isJapanese ? "サブスクリプション" : "SUBSCRIPTION"
    }
    
    var interfaceLabel: String {
        return isJapanese ? "インターフェース" : "INTERFACE"
    }
    
    var feedbackSupportLabel: String {
        return isJapanese ? "フィードバックとサポート" : "FEEDBACK & SUPPORT"
    }
    
    var appInfoLabel: String {
        return isJapanese ? "アプリ情報" : "APP INFO"
    }
    
    var languageInterfaceLabel: String {
        return isJapanese ? "言語インターフェース" : "Language Interface"
    }
    
    var audioSettingsLabel: String {
        return isJapanese ? "音声設定" : "Audio Settings"
    }
    
    var sendFeedbackLabel: String {
        return isJapanese ? "フィードバックを送信" : "Send Feedback"
    }
    
    var rateAppLabel: String {
        return isJapanese ? "アプリを評価" : "Rate App"
    }
    
    var aboutMementoLabel: String {
        return isJapanese ? "Mementoについて" : "About Memento"
    }
    
    var privacyPolicyLabel: String {
        return isJapanese ? "プライバシーポリシー" : "Privacy Policy"
    }
    
    var termsOfServiceLabel: String {
        return isJapanese ? "利用規約" : "Terms of Service"
    }
    
    var restorePurchasesLabel: String {
        return isJapanese ? "購入を復元" : "Restore Purchases"
    }
    
    var weLoveToHearFromYou: String {
        return isJapanese ? "ご意見をお聞かせください" : "We'd love to hear from you"
    }
    
    var thankYouForSupport: String {
        return isJapanese ? "ご支援ありがとうございます！" : "Thank you for your support!"
    }
    
    // Pro Gate
    var proFeatureTitle: String {
        return isJapanese ? "この機能はPro会員限定です" : "This feature is Pro member only"
    }
    
    var proFeatureDescription: String {
        return isJapanese ? "Pro会員になると、すべてのイディオムにアクセスでき、オフライン音声やクイズ機能も利用できます。" : "Become a Pro member to access all idioms, offline audio, and quiz features."
    }
    
    var tryProButton: String {
        return isJapanese ? "Proを試す" : "Try Pro"
    }
    
    var thisIdiomIsProOnly: String {
        return isJapanese ? "このイディオムはPro会員限定です" : "This idiom is Pro member only"
    }
    
    var laterButton: String {
        return isJapanese ? "後で" : "Later"
    }
    
    var libraryInfoTitle: String {
        return isJapanese ? "ライブラリの使い方" : "How to Use the Library"
    }
    
    var libraryInfoMessage: String {
        return isJapanese ? 
            "• A1、A2とB1レベルのイディオムは、毎日のイディオムとして表示された時にアンロックされます\n• 今日のイディオムは自動的にアンロックされます\n• 過去に毎日のイディオムとして表示されたものもアンロックされています\n• B2以上のレベルはPro会員限定です\n• お気に入りに追加して後で復習できます" :
            "• A1, A2 and B1 level idioms unlock when they appear as the daily idiom\n• Today's idiom is automatically unlocked\n• Previously shown daily idioms remain unlocked\n• B2+ levels require Pro membership\n• Add to favorites to review later"
    }
    
    var gotItButton: String {
        return isJapanese ? "了解" : "Got it"
    }
    
    // Dashboard translations
    var dashboardTitle: String {
        return isJapanese ? "ダッシュボード" : "Dashboard"
    }
    
    var greetingMorning: String {
        return isJapanese ? "おはようございます！" : "Good morning!"
    }
    
    var greetingAfternoon: String {
        return isJapanese ? "こんにちは！" : "Good afternoon!"
    }
    
    var greetingEvening: String {
        return isJapanese ? "こんばんは！" : "Good evening!"
    }
    
    var greetingNight: String {
        return isJapanese ? "お疲れ様です！" : "Good night!"
    }
    
    var keepLearningMessage: String {
        return isJapanese ? "今日も頑張りましょう！" : "Let's keep learning!"
    }
    
    var dayStreakLabel: String {
        return isJapanese ? "日連続" : "day streak"
    }
    
    var todaysGoalLabel: String {
        return isJapanese ? "今日の目標" : "Today's Goal"
    }
    
    var learningStatsTitle: String {
        return isJapanese ? "学習統計" : "Learning Stats"
    }
    
    var learnedLabel: String {
        return isJapanese ? "学習済み" : "Learned"
    }
    
    var quizzesLabel: String {
        return isJapanese ? "クイズ完了" : "Quizzes"
    }
    
    var favoritesLabel: String {
        return isJapanese ? "お気に入り" : "Favorites"
    }
    
    var quickActionsTitle: String {
        return isJapanese ? "クイックアクション" : "Quick Actions"
    }
    
    var librarySubtitle: String {
        return isJapanese ? "すべてのイディオム" : "All idioms"
    }
    
    var quizSubtitle: String {
        return isJapanese ? "知識をテスト" : "Test knowledge"
    }
    
    var recentActivityTitle: String {
        return isJapanese ? "最近の活動" : "Recent Activity"
    }
    
    var learnedNewIdiom: String {
        return isJapanese ? "新しいイディオムを学習" : "Learned new idiom"
    }
    
    var completedQuiz: String {
        return isJapanese ? "クイズを完了" : "Completed quiz"
    }
    
    var addedToFavorites: String {
        return isJapanese ? "お気に入りに追加" : "Added to favorites"
    }
    
    var todayLabel: String {
        return isJapanese ? "今日" : "Today"
    }
    
    var yesterdayLabel: String {
        return isJapanese ? "昨日" : "Yesterday"
    }
    
    var daysAgoLabel: String {
        return isJapanese ? "日前" : "days ago"
    }
    
    // Individual idiom quiz translations
    var idiomQuizTitle: String {
        return isJapanese ? "クイズ" : "Quiz"
    }
    
    var takeQuizAboutIdiom: String {
        return isJapanese ? "このイディオムについてクイズに挑戦" : "Take a quiz about this idiom"
    }
    
    var testUnderstandingWithQuestions: String {
        return isJapanese ? "3つの質問で理解度をテスト" : "Test your understanding with 3 questions"
    }
    
    var startButton: String {
        return isJapanese ? "開始" : "Start"
    }
    
    var bestScoreLabel: String {
        return isJapanese ? "最高スコア" : "Best score"
    }
    
    var newRecordLabel: String {
        return isJapanese ? "新しい記録！" : "New record!"
    }
    
    var finishButton: String {
        return isJapanese ? "完了" : "Finish"
    }
    
    var progressLabel: String {
        return isJapanese ? "進捗" : "Progress"
    }
    
    var favoritesTitle: String {
        return isJapanese ? "お気に入り" : "Favorites"
    }
    
    var noFavoritesTitle: String {
        return isJapanese ? "お気に入りがありません" : "No Favorites Yet"
    }
    
    var noFavoritesMessage: String {
        return isJapanese ? "お気に入りに追加したイディオムがここに表示されます" : "Idioms you add to favorites will appear here"
    }
    
    var backButton: String {
        return isJapanese ? "戻る" : "Back"
    }
    
} 