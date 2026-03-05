//
//  FinishView.swift
//  Twinmoji
//
//  Created by Çağlar ÖZTÜRK on 11.12.2025.
//

import SwiftUI
import Vortex

struct FinishView: View {
    
    @Binding var gameStatus: GameStatus
    var player1Score: Int
    var player2Score: Int
    
    var winnerText: String {
        if player1Score > player2Score {
            return "Player 1 Wins!"
        } else if player2Score > player1Score {
            return "Player 2 Wins!"
        } else {
            return "It's a Tie!"
        }
    }
    
    var winnerColor: Color {
        if player1Score > player2Score {
            return .blue
        } else if player2Score > player1Score {
            return .red
        } else {
            return .purple
        }
    }
    
    var body: some View {
        ZStack {
            VortexViewReader { proxy in
                VortexView(.confetti) {
                    Rectangle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .tag("square")
                    
                    Circle()
                        .fill(.white)
                        .frame(width: 16)
                        .tag("circle")
                }
                
                VStack(spacing: 16) {
                    Text(winnerText)
                        .font(.system(size: 42, weight: .heavy))
                        .fontDesign(.rounded)
                        .foregroundStyle(winnerColor)
                    
                    HStack(spacing: 40) {
                        VStack {
                            Text("Player 1")
                                .font(.headline)
                                .foregroundStyle(.blue)
                            Text("\(player1Score)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.blue)
                        }
                        
                        Text("vs")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        
                        VStack {
                            Text("Player 2")
                                .font(.headline)
                                .foregroundStyle(.red)
                            Text("\(player2Score)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.red)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        Button("Settings") {
                            gameStatus = .settings
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Rematch") {
                            gameStatus = .playing
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(30)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 24))
                .shadow(radius: 10)
                .onAppear(perform: proxy.burst)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.9))
    }
}

#Preview {
    FinishView(gameStatus: .constant(.settings), player1Score: 5, player2Score: 3)
}
