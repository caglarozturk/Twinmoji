//
//  MenuView.swift
//  Twinmoji
//
//  Created by Çağlar ÖZTÜRK on 8.12.2025.
//

import SwiftUI

enum EmojiType: String {
    case emoji, fruit, animal, flag, sport
}

enum GameStatus {
    case intro, playing, settings, finished
}

enum GameMode: String {
    case twoPlayer, singlePlayer
}

struct MenuView: View {
    
    @AppStorage("timeOut") private var timeOut = 1.0
    @AppStorage("soloTimeOut") private var soloTimeOut = 30.0
    @AppStorage("items") private var items = 12
    @AppStorage("emojiType") private var emojiType = EmojiType.emoji
    @AppStorage("gameMode") private var gameMode = GameMode.twoPlayer
    @AppStorage("winScore") private var winScore = 5
    @AppStorage("player1Name") private var player1Name = "Player 1"
    @AppStorage("player2Name") private var player2Name = "Player 2"
    
    @State private var gameStatus = GameStatus.intro
    @State private var finalPlayer1Score = 0
    @State private var finalPlayer2Score = 0
    @State private var showStats = false
    @State private var showSettings = false
    
    var body: some View {
        if gameStatus == .playing && gameMode == .singlePlayer {
            SinglePlayerView(itemCount: items, answerTime: soloTimeOut, gameStatus: $gameStatus, emojiType: $emojiType)
        } else if gameStatus == .playing {
            ContentView(itemCount: items, answerTime: timeOut, winScore: winScore, player1Name: player1Name, player2Name: player2Name, gameStatus: $gameStatus, emojiType: $emojiType, finalPlayer1Score: $finalPlayer1Score, finalPlayer2Score: $finalPlayer2Score)
        } else if gameStatus == .intro || gameStatus == .settings {
            IntroView(
                gameStatus: $gameStatus,
                showSettings: $showSettings,
                showStats: $showStats
            )
            .sheet(isPresented: $showSettings) {
                SettingsSheet(
                    gameMode: $gameMode,
                    timeOut: $timeOut,
                    soloTimeOut: $soloTimeOut,
                    items: $items,
                    winScore: $winScore,
                    emojiType: $emojiType,
                    player1Name: $player1Name,
                    player2Name: $player2Name
                )
            }
            .sheet(isPresented: $showStats) {
                StatsView()
            }
        } else if gameStatus == .finished {
            FinishView(gameStatus: $gameStatus, player1Score: finalPlayer1Score, player2Score: finalPlayer2Score, player1Name: player1Name, player2Name: player2Name)
                .onAppear {
                    let result = GameResult(
                        date: Date(),
                        player1Score: finalPlayer1Score,
                        player2Score: finalPlayer2Score,
                        gameMode: gameMode == .singlePlayer ? "singlePlayer" : "twoPlayer",
                        player1Name: player1Name,
                        player2Name: player2Name
                    )
                    StatsManager.shared.saveResult(result)
                }
        }
    }
}

#Preview {
    MenuView()
}
