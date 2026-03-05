//
//  StatsManager.swift
//  Twinmoji
//

import Foundation

struct GameResult: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let player1Score: Int
    let player2Score: Int
    let gameMode: String // "twoPlayer" or "singlePlayer"
    
    var winnerText: String {
        if gameMode == "singlePlayer" {
            return "Solo - Score: \(player1Score)"
        }
        if player1Score > player2Score {
            return "Player 1 Won"
        } else if player2Score > player1Score {
            return "Player 2 Won"
        }
        return "Tie"
    }
}

class StatsManager {
    static let shared = StatsManager()
    
    private let key = "gameHistory"
    
    func saveResult(_ result: GameResult) {
        var results = loadResults()
        results.insert(result, at: 0)
        // Keep last 50 results
        if results.count > 50 {
            results = Array(results.prefix(50))
        }
        if let data = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func loadResults() -> [GameResult] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let results = try? JSONDecoder().decode([GameResult].self, from: data) else {
            return []
        }
        return results
    }
    
    var totalGames: Int {
        loadResults().count
    }
    
    var player1Wins: Int {
        loadResults().filter { $0.gameMode == "twoPlayer" && $0.player1Score > $0.player2Score }.count
    }
    
    var player2Wins: Int {
        loadResults().filter { $0.gameMode == "twoPlayer" && $0.player2Score > $0.player1Score }.count
    }
    
    var soloHighScore: Int {
        loadResults().filter { $0.gameMode == "singlePlayer" }.map(\.player1Score).max() ?? 0
    }
    
    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
