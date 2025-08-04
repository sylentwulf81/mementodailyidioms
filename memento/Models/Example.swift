//
//  Example.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import Foundation

struct Example: Codable, Identifiable {
    var id = UUID()
    var english: String
    var japanese: String
    var tone: String // "casual" / "formal"
    
    init(english: String, japanese: String, tone: String) {
        self.english = english
        self.japanese = japanese
        self.tone = tone
    }
} 