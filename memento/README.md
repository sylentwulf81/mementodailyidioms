# Memento v1.1

アメリカ英語のイディオムを深く理解するためのiOSアプリ

## 🏗️ アーキテクチャ

### ファイル構造
```
Memento/
├── Models/
│   ├── Idiom.swift
│   ├── Example.swift
│   └── UserProgress.swift
├── Views/
│   ├── DailyIdiomView.swift
│   ├── QuizView.swift
│   ├── IdiomLibraryView.swift
│   ├── SettingsView.swift
│   ├── PaywallView.swift
│   └── Components/
│       ├── LevelBadge.swift
│       ├── ToneTag.swift
│       └── ProFeatureGate.swift
├── Services/
│   ├── AudioService.swift
│   ├── DailyIdiomService.swift
│   └── SubscriptionService.swift
├── Resources/
│   └── idioms.json
└── ContentView.swift
```

## 🎯 機能

### タブナビゲーション
- **今日のイディオム**: 日替わりのイディオム表示
- **ライブラリ**: イディオムの検索・閲覧（Pro制限あり）
- **クイズ**: 3問のクイズ機能
- **設定**: アプリ設定とサブスクリプション管理

### Pro機能
- 全イディオムライブラリへのアクセス
- 自然な音声（ElevenLabs）
- オフライン音声サポート
- 無制限クイズ

### 視覚的改善
- カードベースのデザイン
- レベルバッジ（A1-C2）
- トーンバッジ（カジュアル/フォーマル）
- アニメーションとトランジション

## 🛠️ 技術仕様

- **フレームワーク**: SwiftUI (iOS 16+)
- **データ永続化**: SwiftData
- **音声**: AVPlayer + AVSpeechSynthesizer
- **モニタリング**: StoreKit2（将来実装予定）

## 📦 データ

- JSONファイルからイディオムデータを読み込み
- 日付ベースのローテーション
- Pro制限の実装

## 🚀 次のステップ

1. StoreKit2統合
2. ElevenLabs音声API統合
3. より多くのイディオムデータ追加
4. ユーザー進捗追跡の改善 