//
//  UserProgress.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import Foundation
import SwiftData

@Model
final class UserProgress {
    var idiomId: UUID
    var seenCount: Int
    var lastSeen: Date?
    var isFavorite: Bool
    var correctAnswers: Int
    var incorrectAnswers: Int
    
    init(
        idiomId: UUID,
        seenCount: Int = 0,
        lastSeen: Date? = nil,
        isFavorite: Bool = false,
        correctAnswers: Int = 0,
        incorrectAnswers: Int = 0
    ) {
        self.idiomId = idiomId
        self.seenCount = seenCount
        self.lastSeen = lastSeen
        self.isFavorite = isFavorite
        self.correctAnswers = correctAnswers
        self.incorrectAnswers = incorrectAnswers
    }
} 