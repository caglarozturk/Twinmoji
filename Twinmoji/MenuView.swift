//
//  MenuView.swift
//  Twinmoji
//
//  Created by Çağlar ÖZTÜRK on 8.12.2025.
//

import SwiftUI

enum EmojiType {
    case emoji, fruit, animal, flag
}

enum GameStatus {
    case playing, settings, finished
}

enum GameMode {
    case twoPlayer, singlePlayer
}

struct MenuView: View {
    
    @State private var timeOut = 1.0
    @State private var items = 12
    @State private var emojiType = EmojiType.emoji
    @State private var gameStatus = GameStatus.settings
    @State private var gameMode = GameMode.twoPlayer
    @State private var finalPlayer1Score = 0
    @State private var finalPlayer2Score = 0
    @State private var showStats = false
    @State private var winScore = 5
    
    var body: some View {
        if gameStatus == .playing && gameMode == .singlePlayer {
            SinglePlayerView(itemCount: items, answerTime: timeOut, gameStatus: $gameStatus, emojiType: $emojiType)
        } else if gameStatus == .playing {
            ContentView(itemCount: items, answerTime: timeOut, winScore: winScore, gameStatus: $gameStatus, emojiType: $emojiType, finalPlayer1Score: $finalPlayer1Score, finalPlayer2Score: $finalPlayer2Score)
        } else if gameStatus == .settings {
            VStack(spacing: 10) {
                Text("Twinmoji")
                    .font(.largeTitle)
                    .fontDesign(.rounded)
                
                Text("Tap the twin emojis as fast as you can!")
                    .foregroundStyle(.secondary)
                
                Text("Game Mode")
                    .font(.headline)
                
                Picker("Game Mode", selection: $gameMode) {
                    Text("2 Players").tag(GameMode.twoPlayer)
                    Text("Solo").tag(GameMode.singlePlayer)
                }
                .pickerStyle(.segmented)
                
                Text("Answer Time")
                    .font(.headline)
                
                Picker("Timeout", selection: $timeOut) {
                    Text("Slow").tag(2.0)
                    Text("Medium").tag(1.0)
                    Text("Fast").tag(0.5)
                }
                .pickerStyle(.segmented)
                
                Text("Difficulty")
                    .font(.headline)
                
                Picker("Difficulty", selection: $items) {
                    Text("Easy").tag(9)
                    Text("Normal").tag(12)
                    Text("Hard").tag(16)
                }
                .pickerStyle(.segmented)
                
                if gameMode == .twoPlayer {
                    Text("Win Score")
                        .font(.headline)
                    
                    Picker("Win Score", selection: $winScore) {
                        Text("3").tag(3)
                        Text("5").tag(5)
                        Text("7").tag(7)
                        Text("10").tag(10)
                    }
                    .pickerStyle(.segmented)
                }
                
                Text("Emoji Type")
                    .font(.headline)
                
                Picker("Emoji Type", selection: $emojiType) {
                    Text("Emoji").tag(EmojiType.emoji)
                    Text("Fruit").tag(EmojiType.fruit)
                    Text("Animal").tag(EmojiType.animal)
                    Text("Flag").tag(EmojiType.flag)
                }
                .pickerStyle(.segmented)
                
                Button("Start Game") {
                    gameStatus = .playing
                }
                .buttonStyle(.borderedProminent)
                
                Button("Stats") {
                    showStats = true
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(.white)
            .clipShape(.rect(cornerRadius: 20))
            .shadow(radius: 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color(white: 0.9))
            .sheet(isPresented: $showStats) {
                StatsView()
            }
        } else if gameStatus == .finished {
            FinishView(gameStatus: $gameStatus, player1Score: finalPlayer1Score, player2Score: finalPlayer2Score)
                .onAppear {
                    let result = GameResult(
                        date: Date(),
                        player1Score: finalPlayer1Score,
                        player2Score: finalPlayer2Score,
                        gameMode: gameMode == .singlePlayer ? "singlePlayer" : "twoPlayer"
                    )
                    StatsManager.shared.saveResult(result)
                }
        }
    }
}

#Preview {
    MenuView()
}
