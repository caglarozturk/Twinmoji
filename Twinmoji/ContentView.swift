//
//  ContentView.swift
//  Twinmoji
//
//  Created by Çağlar ÖZTÜRK on 8.12.2025.
//

import SwiftUI

enum AnswerState {
    case waiting
    case player1
    case player2
}

struct ContentView: View {
    
    let allEmoji = Array("😎🥹🥰😔😂😳🧐🙂😇😅😆😙😬🙃😍🥸😣😶🙄🤨😩😉🥲😋😛🤓😏😭😯😵😐😘😢😠").map(String.init)
    
    let allFruit = Array("🍓🍊🍋🍍🍉🍇🍎🍌🍑🥭🥝🍒🍈🍐🍏🥥🫐🍅🧅🧄🥔🍆🌽🫛🥬🥦🥒🥕🫑🌶️🥑🌰🍠🥜").map(String.init)
    
    let allAnimal = Array("🐓🦃🕊🦅🦆🦉🦢🦤🦩🦚🦜🐁🐿🦇🐕🐈🐇🐝🐛🐞🐜🕷🦋🦂🪳🦟🪰🐍🐢🐊🦎🐸🐌🦑🐙").map(String.init)
    
    let allFlag = Array("🇦🇩🇦🇱🇦🇹🇧🇦🇧🇪🇧🇬🇨🇿🇩🇪🇩🇰🇪🇦🇪🇪🇫🇮🇫🇷🇬🇧🇬🇷🇭🇷🇭🇺🇮🇪🇮🇸🇮🇹🇱🇹🇱🇺🇱🇻🇲🇨🇲🇰🇳🇱🇳🇴🇵🇱🇵🇹🇷🇴🇷🇸🇷🇺🇸🇪🇸🇮🇸🇰🇺🇦🏴󠁧󠁢󠁳󠁣󠁴󠁿🏴󠁧󠁢󠁷󠁬󠁳󠁿🇹🇷").map(String.init)
    
    @State private var currentEmoji = [String]()
    
    @State private var leftCard = [String]()
    @State private var rightCard = [String]()
    
    @State private var answerState = AnswerState.waiting
    @State private var player1Score = 0
    @State private var player2Score = 0
    
    @State private var answerColor = Color.clear
    @State private var answerScale = 1.0
    @State private var answerAnchor = UnitPoint.center
    
    var itemCount: Int
    var answerTime: Double
    
    @Binding var gameStatus: GameStatus
    @Binding var emojiType: EmojiType
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 0) {
                PlayerButton(answerState: answerState, score: player1Score, color: .blue, onSelect: selectPlayer1)
                
                ZStack {
                    answerColor
                        .scaleEffect(x: answerScale, anchor: answerAnchor)
                    
                    if leftCard.isEmpty == false {
                        HStack {
                            CardView(card: leftCard, userCanAnswer: answerState != .waiting, onSelect: checkAnswer)
                            CardView(card: rightCard, userCanAnswer: answerState != .waiting, onSelect: checkAnswer)
                        }
                        .padding(.horizontal, 10)
                    }
                }
                
                PlayerButton(answerState: answerState, score: player2Score, color: .red, onSelect: selectPlayer2)
            }
            
            Button("End Game", systemImage: "xmark.circle") {
                gameStatus = .settings
            }
            .symbolVariant(.fill)
            .labelStyle(.iconOnly)
            .font(.largeTitle)
            .tint(.white)
            .padding(40)
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.9))
        .persistentSystemOverlays(.hidden)
        .onAppear(perform: createLevel)
    }
    
    func createLevel() {
        if emojiType == .emoji {
            currentEmoji = allEmoji.shuffled()
        } else if emojiType == .fruit {
            currentEmoji = allFruit.shuffled()
        } else if emojiType == .animal {
            currentEmoji = allAnimal.shuffled()
        } else if emojiType == .flag {
            currentEmoji = allFlag.shuffled()
        }

        withAnimation(.spring(duration: 0.75)) {
            leftCard = Array(currentEmoji[0..<itemCount]).shuffled()
            rightCard = Array(currentEmoji[itemCount + 1..<itemCount + itemCount] + [currentEmoji[0]]).shuffled()
        }
    }
    
    func selectPlayer1() {
        guard answerState == .waiting else { return }
        
        answerColor = .blue
        answerAnchor = .leading
        answerState = .player1
        
        runClock()
    }
    
    func selectPlayer2() {
        guard answerState == .waiting else { return }
        
        answerColor = .red
        answerAnchor = .trailing
        answerState = .player2
        
        runClock()
    }
    
    func timeOut(for emoji: [String]) {
        guard currentEmoji == emoji else { return }
        
        if answerState == .player1 {
            player1Score -= 1
        } else if answerState == .player2 {
            player2Score -= 1
        }
        
        answerState = .waiting
    }
    
    func runClock() {
        answerScale = 1
        
        let checkEmoji = currentEmoji
        
        withAnimation(.linear(duration: answerTime)) {
            answerScale = 0
        } completion: {
            timeOut(for: checkEmoji)
        }
    }
    
    func checkAnswer(_ emoji: String) {
        if emoji == currentEmoji[0] {
            if answerState == .player1 {
                player1Score += 1
            } else if answerState == .player2 {
                player2Score += 1
            }
            
            if player1Score == 5 || player2Score == 5 {
                gameStatus = .finished
            } else {
                createLevel()
            }
        } else {
            if answerState == .player1 {
                player1Score -= 1
            } else if answerState == .player2 {
                player2Score -= 1
            }
        }
        
        answerColor = .clear
        answerScale = 0
        answerState = .waiting
        
    }
}

#Preview {
    ContentView(itemCount: 9, answerTime: 1, gameStatus: .constant(.settings), emojiType: .constant(.emoji))
}
