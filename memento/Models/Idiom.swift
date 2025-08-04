//
//  Idiom.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import Foundation

struct Idiom: Codable, Identifiable {
    var id: String
    var title: String
    var jpMeaning: String
    var enMeaning: String
    var nuance: String
    var examples: [Example]
    var tags: [String]
    var level: String // A1–C1
    var isPremium: Bool
    var localAudioFile: String? // for cached ElevenLabs voice
    
    init(
        id: String = UUID().uuidString,
        title: String,
        jpMeaning: String,
        enMeaning: String = "",
        nuance: String,
        examples: [Example] = [],
        tags: [String] = [],
        level: String = "B1",
        isPremium: Bool = false,
        localAudioFile: String? = nil
    ) {
        self.id = id
        self.title = title
        self.jpMeaning = jpMeaning
        self.enMeaning = enMeaning
        self.nuance = nuance
        self.examples = examples
        self.tags = tags
        self.level = level
        self.isPremium = isPremium
        self.localAudioFile = localAudioFile
    }
} 