//
//  GameSettings.swift
//  Twinmoji
//

import Foundation

// MARK: - Enums

enum EmojiType: String {
    case emoji, fruit, animal, flag, sport
}

enum GameStatus {
    case intro, playing, settings, finished
}

enum GameMode: String {
    case twoPlayer, singlePlayer
}

// MARK: - Settings Model

@Observable
class GameSettings {
    var timeOut: Double {
        didSet { UserDefaults.standard.set(timeOut, forKey: "timeOut") }
    }
    var soloTimeOut: Double {
        didSet { UserDefaults.standard.set(soloTimeOut, forKey: "soloTimeOut") }
    }
    var items: Int {
        didSet { UserDefaults.standard.set(items, forKey: "items") }
    }
    var emojiType: EmojiType {
        didSet { UserDefaults.standard.set(emojiType.rawValue, forKey: "emojiType") }
    }
    var gameMode: GameMode {
        didSet { UserDefaults.standard.set(gameMode.rawValue, forKey: "gameMode") }
    }
    var winScore: Int {
        didSet { UserDefaults.standard.set(winScore, forKey: "winScore") }
    }
    var player1Name: String {
        didSet { UserDefaults.standard.set(player1Name, forKey: "player1Name") }
    }
    var player2Name: String {
        didSet { UserDefaults.standard.set(player2Name, forKey: "player2Name") }
    }
    var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled") }
    }
    var musicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(musicEnabled, forKey: "musicEnabled")
            MusicManager.shared.musicEnabled = musicEnabled
        }
    }
    var soloHighScore: Int {
        didSet { UserDefaults.standard.set(soloHighScore, forKey: "soloHighScore") }
    }
    
    init() {
        let defaults = UserDefaults.standard
        self.timeOut = defaults.object(forKey: "timeOut") as? Double ?? 1.0
        self.soloTimeOut = defaults.object(forKey: "soloTimeOut") as? Double ?? 30.0
        self.items = defaults.object(forKey: "items") as? Int ?? 12
        self.winScore = defaults.object(forKey: "winScore") as? Int ?? 5
        self.player1Name = defaults.string(forKey: "player1Name") ?? "Player 1"
        self.player2Name = defaults.string(forKey: "player2Name") ?? "Player 2"
        self.soundEnabled = defaults.object(forKey: "soundEnabled") as? Bool ?? true
        self.musicEnabled = defaults.object(forKey: "musicEnabled") as? Bool ?? true
        self.soloHighScore = defaults.object(forKey: "soloHighScore") as? Int ?? 0
        
        if let raw = defaults.string(forKey: "emojiType"), let type = EmojiType(rawValue: raw) {
            self.emojiType = type
        } else {
            self.emojiType = .emoji
        }
        
        if let raw = defaults.string(forKey: "gameMode"), let mode = GameMode(rawValue: raw) {
            self.gameMode = mode
        } else {
            self.gameMode = .twoPlayer
        }
    }
}
