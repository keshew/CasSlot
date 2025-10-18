import Foundation

struct Game: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    let unlockScore: Int
    var isUnlocked: Bool
}

struct Achievement: Identifiable {
    let id: Int
    let title: String
    let description: String
    let rewardPoints: Int
    var isUnlocked: Bool
}

struct Bonus: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    var isActive: Bool
    var expiresAt: Date?
}

struct UserData: Codable {
    var points: Int
    var coins: Int
    var unlockedGameIDs: [Int]
    var activeBonuses: [Bonus]
    var claimedAchievements: [Int]
}

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userDefaults = UserDefaults.standard
    private let userDataKey = "userData"
    
    func saveUserData(_ data: UserData) {
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: userDataKey)
        }
    }
    
    func loadUserData() -> UserData {
        guard let savedData = userDefaults.data(forKey: userDataKey),
              let decoded = try? JSONDecoder().decode(UserData.self, from: savedData) else {
            return UserData(points: 0, coins: 1000, unlockedGameIDs: [1], activeBonuses: [], claimedAchievements: [])
        }
        return decoded
    }
}
