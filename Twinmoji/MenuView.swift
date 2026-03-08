//
//  MenuView.swift
//  Twinmoji
//
//  Created by Çağlar ÖZTÜRK on 8.12.2025.
//

import SwiftUI

struct MenuView: View {
    
    var settings: GameSettings
    
    @State private var gameStatus = GameStatus.intro
    @State private var engine: GameEngine?
    @State private var finalPlayer1Score = 0
    @State private var finalPlayer2Score = 0
    @State private var showStats = false
    @State private var showSettings = false
    
    var body: some View {
        Group {
            if gameStatus == .playing && settings.gameMode == .singlePlayer {
                if let engine {
                    SinglePlayerView(settings: settings, engine: engine, gameStatus: $gameStatus)
                }
            } else if gameStatus == .playing {
                if let engine {
                    ContentView(settings: settings, engine: engine, gameStatus: $gameStatus, finalPlayer1Score: $finalPlayer1Score, finalPlayer2Score: $finalPlayer2Score)
                }
            } else if gameStatus == .intro || gameStatus == .settings {
            IntroView(
                gameStatus: $gameStatus,
                showSettings: $showSettings,
                showStats: $showStats
            )
            .sheet(isPresented: $showSettings) {
                SettingsSheet(settings: settings)
            }
            .sheet(isPresented: $showStats) {
                StatsView()
            }
        } else if gameStatus == .finished {
            FinishView(gameStatus: $gameStatus, player1Score: finalPlayer1Score, player2Score: finalPlayer2Score, player1Name: settings.player1Name, player2Name: settings.player2Name)
                .onAppear {
                    let result = GameResult(
                        date: Date(),
                        player1Score: finalPlayer1Score,
                        player2Score: finalPlayer2Score,
                        gameMode: settings.gameMode == .singlePlayer ? "singlePlayer" : "twoPlayer",
                        player1Name: settings.player1Name,
                        player2Name: settings.player2Name
                    )
                    StatsManager.shared.saveResult(result)
                }
        }
        }
        .onChange(of: gameStatus) { oldValue, newValue in
            if newValue == .playing {
                engine = GameEngine(settings: settings)
            } else if oldValue == .playing && newValue != .playing {
                engine = nil
                
                // Interstitial ad (every 3rd game)
                if AdManager.shared.gameDidFinish() {
                    // Small delay so finish screen appears first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        AdManager.shared.presentInterstitial()
                    }
                }
                
                // Rating prompt
                ReviewManager.registerGameAndPromptIfNeeded()
            }
        }
    }
    
}

#Preview {
    MenuView(settings: GameSettings())
}
