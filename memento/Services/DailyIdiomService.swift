//
//  DailyIdiomService.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import Foundation
import SwiftData

class DailyIdiomService: ObservableObject {
    @Published var currentIdiom: Idiom?
    private var allIdioms: [Idiom] = []
    private var isLoaded = false
    
    init() {
        print("DailyIdiomService: Initializing...")
        loadIdiomsFromJSON()
        print("DailyIdiomService: Loaded \(allIdioms.count) idioms")
    }
    
    func getTodaysIdiom() -> Idiom {
        print("DailyIdiomService: Getting today's idiom (basic)")
        // Get today's date components for consistent daily rotation
        let calendar = Calendar.current
        let today = getCurrentDate()
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
        
        // Use a default UserProgressService for basic filtering
        let isPro = UserDefaults.standard.bool(forKey: "isPro")
        
        // Filter idioms based on subscription status only (avoid circular dependency)
        let availableIdioms = getAvailableIdiomsForUser(isPro: isPro)
        
        // If no available idioms, fall back to the original method
        if availableIdioms.isEmpty {
            let index = (dayOfYear - 1) % allIdioms.count
            print("DailyIdiomService: Using fallback idiom at index \(index)")
            return allIdioms[index]
        }
        
        // Use day of year to select from available idioms
        let index = (dayOfYear - 1) % availableIdioms.count
        print("DailyIdiomService: Selected idiom at index \(index) from \(availableIdioms.count) available")
        return availableIdioms[index]
    }
    
    func getTodaysIdiom(with userProgressService: UserProgressService) -> Idiom {
        print("DailyIdiomService: Getting today's idiom (with user progress)")
        // Get today's date components for consistent daily rotation
        let calendar = Calendar.current
        let today = getCurrentDate()
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
        
        let isPro = UserDefaults.standard.bool(forKey: "isPro")
        
        // Filter idioms based on user's level and subscription status
        let availableIdioms = getAvailableIdiomsForUser(userProgressService: userProgressService, isPro: isPro)
        
        // If no available idioms, fall back to the original method
        if availableIdioms.isEmpty {
            let index = (dayOfYear - 1) % allIdioms.count
            print("DailyIdiomService: Using fallback idiom at index \(index)")
            return allIdioms[index]
        }
        
        // Use day of year to select from available idioms
        let index = (dayOfYear - 1) % availableIdioms.count
        print("DailyIdiomService: Selected idiom at index \(index) from \(availableIdioms.count) available")
        return availableIdioms[index]
    }
    
    private func getCurrentDate() -> Date {
        // Check if we're in test mode (debug builds only)
        #if DEBUG
        if let testDate = UserDefaults.standard.object(forKey: "testDate") as? Date {
            return testDate
        }
        #endif
        
        return Date()
    }
    
    private func getAvailableIdiomsForUser(isPro: Bool) -> [Idiom] {
        // Basic filtering without user progress service (avoid circular dependency)
        return allIdioms.filter { idiom in
            // Non-pro users can't access premium idioms
            if idiom.isPremium && !isPro {
                return false
            }
            
            // Non-pro users are limited to A1, A2 and B1 levels
            if !isPro {
                return idiom.level == "A1" || idiom.level == "A2" || idiom.level == "B1"
            } else {
                // Pro users can access all levels
                return true
            }
        }
    }
    
    private func getAvailableIdiomsForUser(userProgressService: UserProgressService, isPro: Bool) -> [Idiom] {
        print("DailyIdiomService: Getting available idioms for user")
        // Determine user's current level based on learned idioms
        let userLevel = determineUserLevel(userProgressService: userProgressService)
        print("DailyIdiomService: User level determined as \(userLevel)")
        
        // Filter idioms by user's level and subscription status
        var availableIdioms = allIdioms.filter { idiom in
            // Non-pro users can't access premium idioms
            if idiom.isPremium && !isPro {
                return false
            }
            
            // Only show idioms from user's current level or lower
            if !isPro {
                // Non-pro users are limited to A1, A2 and B1 levels
                return idiom.level == "A1" || idiom.level == "A2" || idiom.level == "B1"
            } else {
                // Pro users can access all levels, but prioritize user's current level
                // Allow idioms from user's current level and lower levels
                return isIdiomLevelAppropriate(idiom.level, forUserLevel: userLevel)
            }
        }
        
        print("DailyIdiomService: After level filtering: \(availableIdioms.count) idioms")
        
        // Filter out already learned idioms - use cached learned IDs
        let learnedIds = userProgressService.getLearnedIdiomIds()
        availableIdioms = availableIdioms.filter { idiom in
            !learnedIds.contains(idiom.id)
        }
        
        print("DailyIdiomService: After learned filtering: \(availableIdioms.count) idioms")
        
        // If no unlearned idioms at user's level, include learned ones
        if availableIdioms.isEmpty {
            print("DailyIdiomService: No unlearned idioms available, including learned ones")
            availableIdioms = allIdioms.filter { idiom in
                if idiom.isPremium && !isPro {
                    return false
                }
                if !isPro {
                    return idiom.level == "A1" || idiom.level == "A2" || idiom.level == "B1"
                }
                return isIdiomLevelAppropriate(idiom.level, forUserLevel: userLevel)
            }
            print("DailyIdiomService: Final available idioms: \(availableIdioms.count)")
        }
        
        return availableIdioms
    }
    
    private func isIdiomLevelAppropriate(_ idiomLevel: String, forUserLevel userLevel: String) -> Bool {
        // Define level hierarchy (lower index = lower level)
        let levelHierarchy = ["A1", "A2", "B1", "B2", "C1", "C2"]
        
        guard let idiomIndex = levelHierarchy.firstIndex(of: idiomLevel),
              let userIndex = levelHierarchy.firstIndex(of: userLevel) else {
            return false
        }
        
        // Allow idioms from user's current level and lower levels
        return idiomIndex <= userIndex
    }
    
    private func determineUserLevel(userProgressService: UserProgressService) -> String {
        print("DailyIdiomService: Determining user level")
        // Count learned idioms by level - cache the learned idioms to avoid repeated calls
        var levelCounts: [String: Int] = [:]
        let learnedIds = userProgressService.getLearnedIdiomIds() // New method we'll add
        
        for idiom in allIdioms {
            if learnedIds.contains(idiom.id) {
                levelCounts[idiom.level, default: 0] += 1
            }
        }
        
        print("DailyIdiomService: Level counts: \(levelCounts)")
        
        // Determine user's current level based on learning progress
        // If user has learned most A1 idioms, move to A2, etc.
        let a1Count = levelCounts["A1"] ?? 0
        let a2Count = levelCounts["A2"] ?? 0
        let b1Count = levelCounts["B1"] ?? 0
        let b2Count = levelCounts["B2"] ?? 0
        let c1Count = levelCounts["C1"] ?? 0
        
        // If user hasn't learned many A1 idioms, they're still A1 level
        if a1Count < 3 {
            print("DailyIdiomService: User level determined as A1")
            return "A1"
        }
        // If user has learned most A1 idioms but few A2, they're A2 level
        else if a2Count < 5 {
            print("DailyIdiomService: User level determined as A2")
            return "A2"
        }
        // If user has learned most A2 idioms but few B1, they're B1 level
        else if b1Count < 8 {
            print("DailyIdiomService: User level determined as B1")
            return "B1"
        }
        // If user has learned most B1 idioms but few B2, they're B2 level
        else if b2Count < 10 {
            print("DailyIdiomService: User level determined as B2")
            return "B2"
        }
        // If user has learned most B2 idioms but few C1, they're C1 level
        else if c1Count < 5 {
            print("DailyIdiomService: User level determined as C1")
            return "C1"
        }
        // Otherwise, they're C2 level
        else {
            print("DailyIdiomService: User level determined as C2")
            return "C2"
        }
    }
    
    func loadIdioms() -> [Idiom] {
        return allIdioms
    }
    
    private func loadIdiomsFromJSON() {
        // Prevent repeated loading
        if isLoaded {
            return
        }
        
        guard let url = Bundle.main.url(forResource: "idioms", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            // Fallback to sample data if JSON loading fails
            allIdioms = createSampleIdioms()
            isLoaded = true
            return
        }
        
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            allIdioms = jsonArray.compactMap { (json: [String: Any]) -> Idiom? in
                guard let title = json["title"] as? String,
                      let jpMeaning = json["jpMeaning"] as? String,
                      let nuance = json["nuance"] as? String,
                      let level = json["level"] as? String,
                      let isPremium = json["isPremium"] as? Bool,
                      let examplesArray = json["examples"] as? [[String: Any]],
                      let tags = json["tags"] as? [String] else {
                    return nil
                }
                
                let examples = examplesArray.compactMap { (exampleJson: [String: Any]) -> Example? in
                    guard let english = exampleJson["english"] as? String,
                          let japanese = exampleJson["japanese"] as? String,
                          let tone = exampleJson["tone"] as? String else {
                        return nil
                    }
                    return Example(english: english, japanese: japanese, tone: tone)
                }
                
                // Extract the ID for audio file mapping
                let idiomId = json["id"] as? String ?? ""
                
                // Map audio file based on idiom ID
                let localAudioFile = mapAudioFileForIdiom(id: idiomId, title: title)
                
                // Debug logging - only for specific idioms that have audio files
                if let audioFile = localAudioFile, (idiomId == "A1-1" || idiomId == "A1-2") {
                    print("DailyIdiomService: Mapped idiom '\(title)' (ID: \(idiomId)) to audio file: \(audioFile)")
                }
                
                return Idiom(
                    id: idiomId,
                    title: title,
                    jpMeaning: jpMeaning,
                    nuance: nuance,
                    examples: examples,
                    tags: tags,
                    level: level,
                    isPremium: isPremium,
                    localAudioFile: localAudioFile
                )
            }
        } catch {
            print("Error loading idioms from JSON: \(error)")
            allIdioms = createSampleIdioms()
        }
        
        isLoaded = true
    }
    
    private func mapAudioFileForIdiom(id: String, title: String) -> String? {
        // Map specific idioms to their audio files
        switch id {
        case "A1-1":
            return "A1-1_long_time_no_see"
        case "A1-2":
            return "A1-2_whats_up"
        default:
            // For other idioms, try to construct the filename based on title
            let audioFileName = "\(id)_\(title.lowercased().replacingOccurrences(of: " ", with: "_"))"
            
            // Check if the audio file exists in the bundle
            if Bundle.main.url(forResource: audioFileName, withExtension: "mp3") != nil {
                return audioFileName
            }
            
            // If not found, return nil (will fall back to speech synthesis)
            return nil
        }
    }
    
    private func createSampleIdioms() -> [Idiom] {
        return [
            Idiom(
                title: "Break a leg",
                jpMeaning: "頑張って！成功を祈る！",
                nuance: "舞台芸術の世界で「幸運を祈る」という意味で使われる表現。直訳すると「足を折る」ですが、実際には逆の意味で、成功を願う気持ちを表します。",
                examples: [
                    Example(
                        english: "Good luck with your presentation! Break a leg!",
                        japanese: "プレゼンテーション頑張って！成功を祈ってるよ！",
                        tone: "casual"
                    ),
                    Example(
                        english: "I hope your interview goes well. Break a leg!",
                        japanese: "面接がうまくいくことを願っています。頑張ってください！",
                        tone: "formal"
                    )
                ],
                tags: ["舞台", "成功", "励まし"],
                level: "B1"
            ),
            Idiom(
                title: "Piece of cake",
                jpMeaning: "簡単だよ！朝飯前！",
                nuance: "「ケーキ一切れ」から派生した表現で、とても簡単なことを表します。",
                examples: [
                    Example(
                        english: "This test was a piece of cake!",
                        japanese: "このテストは簡単だったよ！",
                        tone: "casual"
                    ),
                    Example(
                        english: "The project was a piece of cake to complete.",
                        japanese: "そのプロジェクトは簡単に完了できました。",
                        tone: "formal"
                    )
                ],
                tags: ["簡単", "成功"],
                level: "A2"
            )
        ]
    }
} 