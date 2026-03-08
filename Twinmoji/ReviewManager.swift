//
//  ReviewManager.swift
//  Twinmoji
//

import StoreKit
import UIKit

struct ReviewManager {
    
    private static let winsForFirstPrompt = 3
    private static let winsForSecondPrompt = 10
    private static let winsBetweenPrompts = 15
    
    private static let lastPromptWinCountKey = "lastReviewPromptWinCount"
    private static let totalPromptsKey = "totalReviewPrompts"
    
    /// Call this after a game finishes (either mode).
    static func registerGameAndPromptIfNeeded() {
        let defaults = UserDefaults.standard
        let totalGames = StatsManager.shared.totalGames
        let lastPromptAt = defaults.integer(forKey: lastPromptWinCountKey)
        let totalPrompts = defaults.integer(forKey: totalPromptsKey)
        
        var shouldPrompt = false
        
        if totalPrompts == 0 && totalGames >= winsForFirstPrompt {
            shouldPrompt = true
        } else if totalPrompts == 1 && totalGames >= winsForSecondPrompt {
            shouldPrompt = true
        } else if totalPrompts >= 2 && (totalGames - lastPromptAt) >= winsBetweenPrompts {
            shouldPrompt = true
        }
        
        if shouldPrompt {
            defaults.set(totalGames, forKey: lastPromptWinCountKey)
            defaults.set(totalPrompts + 1, forKey: totalPromptsKey)
            requestReview()
        }
    }
    
    private static func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }
        
        // Delay so it doesn't collide with game-end animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            AppStore.requestReview(in: scene)
        }
    }
}
