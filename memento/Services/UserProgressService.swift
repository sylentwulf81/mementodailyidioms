import Foundation
import SwiftData
import SwiftUI

class UserProgressService: ObservableObject {
    @AppStorage("idiomsViewed") private var idiomsViewed: Int = 0
    @AppStorage("quizzesCompleted") private var quizzesCompleted: Int = 0
    @AppStorage("favoritesAdded") private var favoritesAdded: Int = 0
    @AppStorage("firstLaunchDate") private var firstLaunchDate: Date = Date()
    @AppStorage("lastActiveDate") private var lastActiveDate: Date = Date()
    @AppStorage("streakDays") private var streakDays: Int = 0
    
    // Individual idiom tracking
    @AppStorage("viewedIdioms") private var viewedIdiomsData: Data = Data()
    
    // Learned idioms tracking (idioms that have been successfully quizzed)
    @AppStorage("learnedIdioms") private var learnedIdiomsData: Data = Data()
    
    // Favorite idioms tracking
    @AppStorage("favoriteIdioms") private var favoriteIdiomsData: Data = Data()
    
    // Daily rotation tracking
    @AppStorage("dailyRotationIdioms") private var dailyRotationIdiomsData: Data = Data()
    
    // Learning milestones
    @AppStorage("milestone5Reached") private var milestone5Reached: Bool = false
    @AppStorage("milestone10Reached") private var milestone10Reached: Bool = false
    @AppStorage("milestone20Reached") private var milestone20Reached: Bool = false
    
    init() {
        print("UserProgressService: Initializing...")
        // Check if this is the first launch
        if UserDefaults.standard.object(forKey: "hasLaunchedBefore") == nil {
            print("UserProgressService: First launch detected, resetting progress")
            resetAllProgress()
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
        
        print("UserProgressService: Updating last active date")
        updateLastActiveDate()
        print("UserProgressService: Initialization complete")
    }
    
    // MARK: - Progress Tracking
    
    func recordIdiomView() {
        idiomsViewed += 1
        updateLastActiveDate()
        checkMilestones()
        clearUnlockCache()
    }
    
    func recordIdiomView(_ idiomId: String) {
        idiomsViewed += 1
        updateLastActiveDate()
        checkMilestones()
        
        // Track individual idiom view
        var viewedIds = viewedIdiomIds
        if !viewedIds.contains(idiomId) {
            viewedIds.insert(idiomId)
            viewedIdiomIds = viewedIds
        }
        
        clearUnlockCache()
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
    
    func recordQuizCompletion() {
        quizzesCompleted += 1
        updateLastActiveDate()
    }
    
    // MARK: - Learned Idioms Tracking
    
    func recordLearnedIdiom(_ idiomId: String) {
        var learnedIds = learnedIdiomIds
        if !learnedIds.contains(idiomId) {
            learnedIds.insert(idiomId)
            learnedIdiomIds = learnedIds
            recordQuizCompletion() // Also increment quiz completion count
        }
    }
    
    func hasLearnedIdiom(_ idiomId: String) -> Bool {
        return learnedIdiomIds.contains(idiomId)
    }
    
    func getLearnedIdiomIds() -> Set<String> {
        return learnedIdiomIds
    }
    
    func getLearnedIdiomCount() -> Int {
        return learnedIdiomIds.count
    }
    
    private var learnedIdiomIds: Set<String> {
        get {
            guard !learnedIdiomsData.isEmpty else { return Set() }
            guard let data = try? JSONDecoder().decode([String].self, from: learnedIdiomsData) else {
                print("UserProgressService: Failed to decode learned idioms, returning empty set")
                return Set()
            }
            return Set(data)
        }
        set {
            let stringIds = Array(newValue)
            learnedIdiomsData = (try? JSONEncoder().encode(stringIds)) ?? Data()
            print("UserProgressService: Saved \(newValue.count) learned idioms")
        }
    }
    
    func recordFavoriteAdded() {
        updateLastActiveDate()
    }
    
    func recordFavoriteAdded(_ idiomId: String) {
        updateLastActiveDate()
        addFavoriteIdiom(idiomId)
    }
    
    private func updateLastActiveDate() {
        let today = getCurrentDate()
        let calendar = Calendar.current
        
        // Check if this is a consecutive day
        if let lastDate = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(lastActiveDate, inSameDayAs: lastDate) {
            streakDays += 1
        } else if !calendar.isDate(lastActiveDate, inSameDayAs: today) {
            // Reset streak if more than one day has passed
            // Only set to 1 if user has actually done something today
            if idiomsViewed > 0 {
                streakDays = 1
            } else {
                streakDays = 0
            }
        }
        
        lastActiveDate = today
    }
    
    // MARK: - Milestone Tracking
    
    private func checkMilestones() {
        if idiomsViewed >= 5 && !milestone5Reached {
            milestone5Reached = true
            showMilestoneCelebration(count: 5)
        }
        
        if idiomsViewed >= 10 && !milestone10Reached {
            milestone10Reached = true
            showMilestoneCelebration(count: 10)
        }
        
        if idiomsViewed >= 20 && !milestone20Reached {
            milestone20Reached = true
            showMilestoneCelebration(count: 20)
        }
    }
    
    private func showMilestoneCelebration(count: Int) {
        // This will be implemented in the UI layer
        // For now, we just track the milestone
    }
    
    // MARK: - Progress Getters
    
    var totalIdiomsViewed: Int {
        return idiomsViewed
    }
    
    // This is the correct "Learned" count - idioms that have been successfully quizzed
    var totalIdiomsLearned: Int {
        return getLearnedIdiomCount()
    }
    
    var totalQuizzesCompleted: Int {
        return quizzesCompleted
    }
    
    var totalFavoritesAdded: Int {
        return getFavoriteIdiomCount()
    }
    
    var currentStreak: Int {
        return streakDays
    }
    
    var daysSinceFirstLaunch: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
    }
    
    func resetAllProgress() {
        idiomsViewed = 0
        quizzesCompleted = 0
        favoritesAdded = 0
        streakDays = 0
        
        // Clear individual tracking data
        viewedIdiomsData = Data()
        learnedIdiomsData = Data()
        favoriteIdiomsData = Data()
        dailyRotationIdiomsData = Data()
        
        // Reset milestones
        milestone5Reached = false
        milestone10Reached = false
        milestone20Reached = false
    }
    
    var averageIdiomsPerDay: Double {
        let days = max(daysSinceFirstLaunch, 1)
        return Double(idiomsViewed) / Double(days)
    }
    
    // MARK: - Pro Conversion Metrics
    
    var shouldShowProPrompt: Bool {
        // Only show Pro prompt when user tries to access locked content
        // This will be handled by individual views when they detect locked content
        return false
    }
    
    var proPromptReason: String {
        if idiomsViewed >= 20 {
            return "You've explored 20 idioms! Unlock 80 more with Pro."
        } else if quizzesCompleted >= 3 {
            return "You're a quiz master! Unlock advanced questions with Pro."
        } else if favoritesAdded >= 5 {
            return "You've found 5 favorites! Access unlimited favorites with Pro."
        } else {
            return "You're making great progress! Unlock all features with Pro."
        }
    }
    
    func markProPromptShown() {
        UserDefaults.standard.set(true, forKey: "hasShownProPrompt")
    }
    
    // MARK: - Learning Analytics
    
    var learningEfficiency: Double {
        // Calculate learning efficiency based on engagement
        let engagementScore = Double(idiomsViewed) + Double(quizzesCompleted * 2) + Double(Double(favoritesAdded) * 0.5)
        let timeScore = max(daysSinceFirstLaunch, 1)
        return engagementScore / Double(timeScore)
    }
    
    var isActiveLearner: Bool {
        return averageIdiomsPerDay >= 1.0 || currentStreak >= 3
    }
    
    var shouldShowEncouragement: Bool {
        return daysSinceFirstLaunch >= 3 && averageIdiomsPerDay < 0.5
    }
    
    // MARK: - Individual Idiom Tracking
    
    private var viewedIdiomIds: Set<String> {
        get {
            guard !viewedIdiomsData.isEmpty else { return Set() }
            guard let data = try? JSONDecoder().decode([String].self, from: viewedIdiomsData) else {
                print("UserProgressService: Failed to decode viewed idioms, returning empty set")
                return Set()
            }
            return Set(data)
        }
        set {
            let stringIds = Array(newValue)
            viewedIdiomsData = (try? JSONEncoder().encode(stringIds)) ?? Data()
            print("UserProgressService: Saved \(newValue.count) viewed idioms")
        }
    }
    
    func hasViewedIdiom(_ idiomId: String) -> Bool {
        return viewedIdiomIds.contains(idiomId)
    }
    
    func getViewedIdiomCount() -> Int {
        return viewedIdiomIds.count
    }
    
    // MARK: - Favorite Idioms Tracking (Simplified)
    
    // Store favorite idiom IDs as Data (JSON encoded)
    @AppStorage("favoriteIdiomIdsData") private var favoriteIdiomIdsData: Data = Data()
    
    private var favoriteIdiomIds: [String] {
        get {
            guard !favoriteIdiomIdsData.isEmpty else { return [] }
            guard let data = try? JSONDecoder().decode([String].self, from: favoriteIdiomIdsData) else {
                print("UserProgressService: Failed to decode favorite idioms, returning empty array")
                return []
            }
            return data
        }
        set {
            favoriteIdiomIdsData = (try? JSONEncoder().encode(newValue)) ?? Data()
            print("UserProgressService: Saved \(newValue.count) favorite idioms")
        }
    }
    
    func addFavoriteIdiom(_ idiomId: String) {
        var favoriteIds = favoriteIdiomIds
        if !favoriteIds.contains(idiomId) {
            favoriteIds.append(idiomId)
            favoriteIdiomIds = favoriteIds
            print("UserProgressService: Added favorite idiom: \(idiomId)")
            objectWillChange.send()
        }
    }
    
    func removeFavoriteIdiom(_ idiomId: String) {
        var favoriteIds = favoriteIdiomIds
        favoriteIds.removeAll { $0 == idiomId }
        favoriteIdiomIds = favoriteIds
        print("UserProgressService: Removed favorite idiom: \(idiomId)")
        objectWillChange.send()
    }
    
    func isFavoriteIdiom(_ idiomId: String) -> Bool {
        return favoriteIdiomIds.contains(idiomId)
    }
    
    func getFavoriteIdiomCount() -> Int {
        return favoriteIdiomIds.count
    }
    
    func getFavoriteIdiomIds() -> [String] {
        return favoriteIdiomIds
    }
    
    func clearAllFavorites() {
        favoriteIdiomIds = []
        objectWillChange.send()
    }
    
    // MARK: - Daily Rotation Tracking
    
    private var dailyRotationIdiomIds: Set<String> {
        get {
            guard let data = try? JSONDecoder().decode([String].self, from: dailyRotationIdiomsData) else {
                return Set()
            }
            return Set(data)
        }
        set {
            let stringIds = Array(newValue)
            dailyRotationIdiomsData = (try? JSONEncoder().encode(stringIds)) ?? Data()
        }
    }
    
    func addToDailyRotation(_ idiomId: String) {
        var rotationIds = dailyRotationIdiomIds
        rotationIds.insert(idiomId)
        dailyRotationIdiomIds = rotationIds
    }
    
    func hasAppearedInDailyRotation(_ idiomId: String) -> Bool {
        return dailyRotationIdiomIds.contains(idiomId)
    }
    
    // MARK: - Level-based Access Control
    
    func canAccessLevel(_ level: String) -> Bool {
        // A2 and B1 are accessible to all users
        // B2 and above require Pro membership
        return level == "A2" || level == "B1"
    }
    
    func shouldShowProPromptForLevel(_ level: String) -> Bool {
        // Show pro prompt for B2+ levels
        return level == "B2" || level == "C1" || level == "C2"
    }
    
    // MARK: - Daily Rotation Unlocking
    
    private var _cachedUnlockStatus: [String: Bool] = [:]
    
    func shouldUnlockIdiom(_ idiom: Idiom) -> Bool {
        // Check cache first
        if let cached = _cachedUnlockStatus[idiom.id] {
            return cached
        }
        
        // Calculate unlock status
        let isUnlocked: Bool
        if UserDefaults.standard.bool(forKey: "isPro") {
            isUnlocked = true
        } else if hasViewedIdiom(idiom.id) {
            isUnlocked = true
        } else {
            isUnlocked = false
        }
        
        // Cache the result
        _cachedUnlockStatus[idiom.id] = isUnlocked
        return isUnlocked
    }
    
    // Clear cache when user progress changes
    private func clearUnlockCache() {
        _cachedUnlockStatus.removeAll()
    }

    func isIdiomCompleted(_ idiom: Idiom) -> Bool {
        return hasLearnedIdiom(idiom.id)
    }
    
    // MARK: - Level-based Quiz Progress
    
    func getQuizCompletionCountForLevel(_ level: String) -> Int {
        let dailyIdiomService = DailyIdiomService()
        let idiomsInLevel = dailyIdiomService.loadIdioms().filter { $0.level == level }
        
        return idiomsInLevel.filter { hasLearnedIdiom($0.id) }.count
    }
    
    func getTotalQuizzesForLevel(_ level: String) -> Int {
        let dailyIdiomService = DailyIdiomService()
        let idiomsInLevel = dailyIdiomService.loadIdioms().filter { $0.level == level }
        return idiomsInLevel.count
    }
    
    func getQuizProgressForLevel(_ level: String) -> Double {
        let completed = getQuizCompletionCountForLevel(level)
        let total = getTotalQuizzesForLevel(level)
        return total > 0 ? Double(completed) / Double(total) : 0.0
    }
} 