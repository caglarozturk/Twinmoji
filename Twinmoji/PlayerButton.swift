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
    var streak: Int = 0
    var side: PlayerSide = .leading
    var scorePop: String = ""
    var showScorePop: Bool = false
    var onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            color
                .overlay {
                    GeometryReader { geo in
                        let insets = geo.safeAreaInsets
                        let safeInset = side == .leading ? insets.leading : insets.trailing
                        // The visible content area is the total width minus the safe area inset
                        let contentWidth = geo.size.width - safeInset
                        let fontSize = min(contentWidth * 0.45, 48)
                        
                        HStack(spacing: 0) {
                            if side == .leading {
                                // Safe area spacer on the left
                                Color.clear.frame(width: safeInset)
                            }
                            
                            // Content area
                            VStack(spacing: 4) {
                                Text(name)
                                    .font(.system(size: max(min(fontSize * 0.35, 16), 10), weight: .semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                
                                ZStack {
                                    Text("\(score)")
                                        .font(.system(size: max(fontSize, 20), weight: .bold))
                                        .contentTransition(.numericText())
                                    
                                    if showScorePop {
                                        Text(scorePop)
                                            .font(.system(size: max(fontSize * 0.45, 12), weight: .heavy))
                                            .transition(.asymmetric(
                                                insertion: .scale(scale: 0.5).combined(with: .opacity),
                                                removal: .opacity.combined(with: .offset(y: -30))
                                            ))
                                    }
                                }
                                
                                if streak >= 2 {
                                    HStack(spacing: 2) {
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: max(min(fontSize * 0.3, 14), 10)))
                                        Text("\(streak)")
                                            .font(.system(size: max(min(fontSize * 0.3, 14), 10), weight: .bold))
                                    }
                                    .foregroundStyle(.yellow)
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(width: contentWidth)
                            .frame(maxHeight: .infinity)
                            .padding(.top, insets.top)
                            .padding(.bottom, insets.bottom)
                            
                            if side == .trailing {
                                // Safe area spacer on the right
                                Color.clear.frame(width: safeInset)
                            }
                        }
                    }
                }
        }
        .disabled(answerState != .waiting)
    }
}

#Preview {
    PlayerButton(answerState: .waiting, score: 5, name: "Alice", color: .blue, streak: 3) { }
}
