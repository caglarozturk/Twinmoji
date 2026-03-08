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
    var player1Name: String = "Player 1"
    var player2Name: String = "Player 2"
    
    var winnerText: String {
        if player1Score > player2Score {
            return "\(player1Name) Wins!"
        } else if player2Score > player1Score {
            return "\(player2Name) Wins!"
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
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var body: some View {
        let isLandscape = verticalSizeClass == .compact
        
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
                
                VStack(spacing: isLandscape ? 10 : 16) {
                    Text(winnerText)
                        .font(.system(size: isLandscape ? 30 : 42, weight: .heavy))
                        .fontDesign(.rounded)
                        .foregroundStyle(winnerColor)
                    
                    HStack(spacing: isLandscape ? 24 : 40) {
                        VStack {
                            Text(player1Name)
                                .font(isLandscape ? .subheadline : .headline)
                                .foregroundStyle(.blue)
                            Text("\(player1Score)")
                                .font(.system(size: isLandscape ? 32 : 48, weight: .bold))
                                .foregroundStyle(.blue)
                        }
                        
                        Text("vs")
                            .font(isLandscape ? .body : .title2)
                            .foregroundStyle(.secondary)
                        
                        VStack {
                            Text(player2Name)
                                .font(isLandscape ? .subheadline : .headline)
                                .foregroundStyle(.red)
                            Text("\(player2Score)")
                                .font(.system(size: isLandscape ? 32 : 48, weight: .bold))
                                .foregroundStyle(.red)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        Button("Settings") {
                            gameStatus = .intro
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Rematch") {
                            gameStatus = .playing
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(isLandscape ? 20 : 30)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 24))
                .shadow(radius: 10)
                .onAppear {
                    proxy.burst()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3), Color.orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

#Preview {
    FinishView(gameStatus: .constant(.intro), player1Score: 5, player2Score: 3)
}
