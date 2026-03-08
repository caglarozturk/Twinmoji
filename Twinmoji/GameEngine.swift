//
//  GameEngine.swift
//  Twinmoji
//

import SwiftUI

enum AnswerState {
    case waiting
    case player1
    case player2
}

@Observable
class GameEngine {
    
    // MARK: - Shared State
    
    private(set) var leftCard = [String]()
    private(set) var rightCard = [String]()
    private(set) var currentEmoji = [String]()
    private(set) var currentItemCount = 0
    private(set) var answerState = AnswerState.waiting
    
    // MARK: - Two-Player State
    
    private(set) var player1Score = 0
    private(set) var player2Score = 0
    private(set) var player1Streak = 0
    private(set) var player2Streak = 0
    
    // MARK: - Solo State
    
    private(set) var score = 0
    private(set) var lives = 5
    private(set) var streak = 0
    private(set) var roundsPlayed = 0
    private(set) var gameOver = false
    private(set) var timeRemaining = 0.0
    private(set) var currentAnswerTime = 0.0
    private(set) var timerActive = false
    
    // MARK: - Callbacks (wired by views for animations)
    
    var onCorrectAnswer: (() -> Void)?
    var onWrongAnswer: (() -> Void)?
    var onTimeout: (() -> Void)?
    var onStreakEarned: ((String) -> Void)?
    var onScorePop: ((Int, String) -> Void)?  // (player 1 or 2, text)
    var onGameEnd: (() -> Void)?
    var onLifeLost: (() -> Void)?
    var onLevelCreated: (() -> Void)?
    
    // MARK: - Private
    
    private let settings: GameSettings
    private var timerGeneration = 0
    
    init(settings: GameSettings) {
        self.settings = settings
    }
    
    // MARK: - Shared Logic
    
    func createLevel(animated: Bool = false) {
        let update = {
            self.currentItemCount = self.settings.items
            self.currentEmoji = EmojiData.emojis(for: self.settings.emojiType).shuffled()
            
            self.leftCard = Array(self.currentEmoji[0..<self.currentItemCount]).shuffled()
            self.rightCard = Array(self.currentEmoji[self.currentItemCount + 1..<self.currentItemCount + self.currentItemCount] + [self.currentEmoji[0]]).shuffled()
            
            self.onLevelCreated?()
        }
        
        if animated {
            withAnimation(.spring(duration: 0.5)) {
                update()
            }
        } else {
            update()
        }
    }
    
    private func calculateBonus(streak: Int) -> Int {
        streak >= 3 ? streak - 2 : 0
    }
    
    // MARK: - Two-Player Methods
    
    func selectPlayer(_ player: AnswerState) {
        guard answerState == .waiting else { return }
        answerState = player
    }
    
    func checkTwoPlayerAnswer(_ emoji: String) {
        if emoji == currentEmoji[0] {
            SoundManager.playCorrect()
            onCorrectAnswer?()
            
            var bonus = 0
            
            if answerState == .player1 {
                player1Streak += 1
                player2Streak = 0
                bonus = calculateBonus(streak: player1Streak)
                player1Score += 1 + bonus
                onScorePop?(1, "+\(1 + bonus)")
            } else if answerState == .player2 {
                player2Streak += 1
                player1Streak = 0
                bonus = calculateBonus(streak: player2Streak)
                player2Score += 1 + bonus
                onScorePop?(2, "+\(1 + bonus)")
            }
            
            if bonus > 0 {
                let currentStreak = answerState == .player1 ? player1Streak : player2Streak
                onStreakEarned?("\(currentStreak)x Streak! +\(1 + bonus)")
            }
            
            if player1Score >= settings.winScore || player2Score >= settings.winScore {
                SoundManager.playGameEnd()
                onGameEnd?()
            } else {
                createLevel(animated: true)
            }
        } else {
            SoundManager.playWrong()
            onWrongAnswer?()
            
            if answerState == .player1 {
                player1Score -= 1
                player1Streak = 0
                onScorePop?(1, "-1")
            } else if answerState == .player2 {
                player2Score -= 1
                player2Streak = 0
                onScorePop?(2, "-1")
            }
        }
        
        answerState = .waiting
    }
    
    func handleTimeout(for emoji: [String]) {
        guard currentEmoji == emoji else { return }
        
        SoundManager.playTimeout()
        onTimeout?()
        
        if answerState == .player1 {
            player1Score -= 1
            player1Streak = 0
            onScorePop?(1, "-1")
        } else if answerState == .player2 {
            player2Score -= 1
            player2Streak = 0
            onScorePop?(2, "-1")
        }
        
        answerState = .waiting
    }
    
    // MARK: - Solo Methods
    
    func startSoloGame() {
        currentItemCount = settings.items
        currentAnswerTime = settings.soloTimeOut
        score = 0
        lives = 5
        streak = 0
        roundsPlayed = 0
        gameOver = false
    }
    
    func checkSoloAnswer(_ emoji: String) {
        timerActive = false
        
        if emoji == currentEmoji[0] {
            SoundManager.playCorrect()
            onCorrectAnswer?()
            streak += 1
            var bonus = 0
            if streak >= 3 {
                bonus = calculateBonus(streak: streak)
                onStreakEarned?("\(streak)x Streak! +\(1 + bonus)")
            }
            score += 1 + bonus
            roundsPlayed += 1
            createLevel(animated: true)
            startSoloTimer()
        } else {
            onWrongAnswer?()
            streak = 0
            loseLife()
        }
    }
    
    func startSoloTimer() {
        timerGeneration += 1
        let myGeneration = timerGeneration
        
        timeRemaining = currentAnswerTime
        timerActive = true
        
        Task { @MainActor in
            while timerActive && timeRemaining > 0 && timerGeneration == myGeneration {
                try? await Task.sleep(for: .milliseconds(50))
                if timerActive && timerGeneration == myGeneration {
                    timeRemaining -= 0.05
                }
            }
            
            if timerActive && timeRemaining <= 0 && timerGeneration == myGeneration {
                loseLife()
            }
        }
    }
    
    func pauseSoloTimer() {
        timerActive = false
    }
    
    func resumeSoloTimer() {
        timerGeneration += 1
        let myGeneration = timerGeneration
        timerActive = true
        
        Task { @MainActor in
            while timerActive && timeRemaining > 0 && timerGeneration == myGeneration {
                try? await Task.sleep(for: .milliseconds(50))
                if timerActive && timerGeneration == myGeneration {
                    timeRemaining -= 0.05
                }
            }
            
            if timerActive && timeRemaining <= 0 && timerGeneration == myGeneration {
                loseLife()
            }
        }
    }
    
    func resetSoloGame() {
        startSoloGame()
    }
    
    private func loseLife() {
        timerActive = false
        lives -= 1
        streak = 0
        onLifeLost?()
        
        if lives <= 0 {
            SoundManager.playGameEnd()
            if score > settings.soloHighScore {
                settings.soloHighScore = score
            }
            let result = GameResult(date: Date(), player1Score: score, player2Score: 0, gameMode: "singlePlayer")
            StatsManager.shared.saveResult(result)
            gameOver = true
            onGameEnd?()
        } else {
            SoundManager.playWrong()
            createLevel(animated: true)
            startSoloTimer()
        }
    }
}
