//
//  PlayerButton.swift
//  Twinmoji
//
//  Created by Çağlar ÖZTÜRK on 8.12.2025.
//

import SwiftUI

struct PlayerButton: View {
    var answerState: AnswerState
    var score: Int
    var color: Color
    var onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            Rectangle()
                .fill(color)
                .frame(minWidth: 60)
                .overlay(
                    Text("\(score)")
                        .fixedSize()
                        .foregroundStyle(.white)
                        .font(.system(size: 48).bold())
                )
        }
        .disabled(answerState != .waiting)
    }
}

#Preview {
    PlayerButton(answerState: .waiting, score: 5, color: .blue) { }
}
