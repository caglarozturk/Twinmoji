//
//  PlayerButton.swift
//  Twinmoji
//
//  Created by Çağlar ÖZTÜRK on 8.12.2025.
//

import SwiftUI

enum PlayerSide {
    case leading
    case trailing
}

struct PlayerButton: View {
    var answerState: AnswerState
    var score: Int
    var name: String
    var color: Color
    var winScore: Int = 5
    var streak: Int = 0
    var side: PlayerSide = .leading
    var scorePop: String = ""
    var showScorePop: Bool = false
    var onSelect: () -> Void
    
    private var isActive: Bool {
        (side == .leading && answerState == .player1) ||
        (side == .trailing && answerState == .player2)
    }
    
    var body: some View {
        Button(action: onSelect) {
            // Content stays in safe area naturally
            VStack(spacing: 6) {
                // Player name
                Text(name)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .opacity(0.85)
                
                // Score
                ZStack {
                    Text("\(score)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .contentTransition(.numericText())
                    
                    // Score pop
                    if showScorePop {
                        Text(scorePop)
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundStyle(scorePop.hasPrefix("+") ? .green : .yellow)
                            .shadow(color: .black.opacity(0.4), radius: 2)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.5).combined(with: .opacity),
                                removal: .opacity.combined(with: .offset(y: -25))
                            ))
                    }
                }
                
                // Win progress dots
                HStack(spacing: 3) {
                    ForEach(0..<winScore, id: \.self) { i in
                        Circle()
                            .fill(i < score ? .white : .white.opacity(0.3))
                            .frame(width: min(max(60 / CGFloat(winScore), 4), 8),
                                   height: min(max(60 / CGFloat(winScore), 4), 8))
                    }
                }
                .padding(.top, 2)
                
                // Streak
                if streak >= 2 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                        Text("\(streak)x")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(.yellow)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                color
                    .brightness(isActive ? -0.1 : 0)
                    .ignoresSafeArea()
            )
        }
        .disabled(answerState != .waiting)
    }
}

#Preview {
    HStack(spacing: 0) {
        PlayerButton(answerState: .waiting, score: 3, name: "Alice", color: .blue, winScore: 5, streak: 3, side: .leading) { }
            .frame(width: 80)
        Spacer()
        PlayerButton(answerState: .waiting, score: 1, name: "Bob", color: .red, winScore: 5, side: .trailing) { }
            .frame(width: 80)
    }
    .frame(height: 300)
}
