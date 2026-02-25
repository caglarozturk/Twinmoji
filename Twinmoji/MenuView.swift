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

struct MenuView: View {
    
    @State private var timeOut = 1.0
    @State private var items = 12
    @State private var emojiType = EmojiType.emoji
    @State private var gameStatus = GameStatus.settings
    
    var body: some View {
        if gameStatus == .playing {
            ContentView(itemCount: items, answerTime: timeOut, gameStatus: $gameStatus, emojiType: $emojiType)
        } else if gameStatus == .settings {
            VStack(spacing: 10) {
                Text("Twinmoji")
                    .font(.largeTitle)
                    .fontDesign(.rounded)
                
                Text("Tap the twin emojis as fast as you can!")
                    .foregroundStyle(.secondary)
                
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
            }
            .padding()
            .background(.white)
            .clipShape(.rect(cornerRadius: 20))
            .shadow(radius: 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color(white: 0.9))
        } else if gameStatus == .finished {
            FinishView(gameStatus: $gameStatus)
        }
    }
}

#Preview {
    MenuView()
}
