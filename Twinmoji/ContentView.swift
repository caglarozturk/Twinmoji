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
    
    @State private var currentItemCount = 0
    @State private var roundsPlayed = 0
    @State private var player1Streak = 0
    @State private var player2Streak = 0
    @State private var streakText = ""
    @State private var showStreak = false
    @State private var countdownValue = 3
    @State private var showCountdown = true
    @State private var flashColor = Color.clear
    @State private var shakeOffset: CGFloat = 0
    @State private var isPaused = false
    
    var itemCount: Int
    var answerTime: Double
    var winScore: Int = 5
    var enableProgression: Bool = true
    
    @Binding var gameStatus: GameStatus
    @Binding var emojiType: EmojiType
    @Binding var finalPlayer1Score: Int
    @Binding var finalPlayer2Score: Int
    
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
                        .offset(x: shakeOffset)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(flashColor)
                                .allowsHitTesting(false)
                                .padding(.horizontal, 10)
                        )
                    }
                    
                    if showStreak {
                        Text(streakText)
                            .font(.system(size: 36, weight: .heavy))
                            .foregroundStyle(.orange)
                            .shadow(color: .black.opacity(0.3), radius: 4)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                PlayerButton(answerState: answerState, score: player2Score, color: .red, onSelect: selectPlayer2)
            }
            
            HStack(spacing: 12) {
                Button("Pause", systemImage: "pause.circle") {
                    isPaused = true
                }
                .symbolVariant(.fill)
                .labelStyle(.iconOnly)
                .font(.largeTitle)
                .tint(.white)
                
                Button("End Game", systemImage: "xmark.circle") {
                    gameStatus = .settings
                }
                .symbolVariant(.fill)
                .labelStyle(.iconOnly)
                .font(.largeTitle)
                .tint(.white)
            }
            .padding(40)
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.9))
        .overlay {
            if isPaused {
                ZStack {
                    Color.black.opacity(0.7)
                    VStack(spacing: 20) {
                        Text("Paused")
                            .font(.system(size: 48, weight: .heavy))
                            .foregroundStyle(.white)
                            .fontDesign(.rounded)
                        
                        Button("Resume") {
                            isPaused = false
                        }
                        .font(.title2.bold())
                        .buttonStyle(.borderedProminent)
                        
                        Button("End Game") {
                            gameStatus = .settings
                        }
                        .font(.title3)
                        .buttonStyle(.bordered)
                        .tint(.white)
                    }
                }
                .ignoresSafeArea()
            }
        }
        .overlay {
            if showCountdown {
                ZStack {
                    Color.black.opacity(0.6)
                    Text("\(countdownValue)")
                        .font(.system(size: 120, weight: .heavy))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
                .ignoresSafeArea()
            }
        }
        .persistentSystemOverlays(.hidden)
        .onAppear {
            startCountdown()
        }
    }
    
    func startCountdown() {
        showCountdown = true
        countdownValue = 3
        
        Task {
            for i in stride(from: 2, through: 0, by: -1) {
                try? await Task.sleep(for: .seconds(1))
                SoundManager.playCountdownTick()
                withAnimation(.spring(duration: 0.3)) {
                    countdownValue = i
                }
            }
            try? await Task.sleep(for: .seconds(0.5))
            withAnimation {
                showCountdown = false
            }
            createLevel()
        }
    }
    
    func createLevel() {
        if currentItemCount == 0 {
            currentItemCount = itemCount
        }
        
        // Difficulty progression: increase card size every 2 rounds
        if enableProgression && roundsPlayed > 0 && roundsPlayed % 2 == 0 {
            let maxItems = 16
            if currentItemCount < maxItems {
                // Move from 9 -> 12 -> 16
                if currentItemCount == 9 {
                    currentItemCount = 12
                } else if currentItemCount == 12 {
                    currentItemCount = 16
                }
            }
        }
        
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
            leftCard = Array(currentEmoji[0..<currentItemCount]).shuffled()
            rightCard = Array(currentEmoji[currentItemCount + 1..<currentItemCount + currentItemCount] + [currentEmoji[0]]).shuffled()
        }
    }
    
    func selectPlayer1() {
        guard answerState == .waiting else { return }
        
        SoundManager.playBuzzIn()
        answerColor = .blue
        answerAnchor = .leading
        answerState = .player1
        
        runClock()
    }
    
    func selectPlayer2() {
        guard answerState == .waiting else { return }
        
        SoundManager.playBuzzIn()
        answerColor = .red
        answerAnchor = .trailing
        answerState = .player2
        
        runClock()
    }
    
    func timeOut(for emoji: [String]) {
        guard currentEmoji == emoji else { return }
        
        SoundManager.playTimeout()
        
        if answerState == .player1 {
            player1Score -= 1
            player1Streak = 0
        } else if answerState == .player2 {
            player2Score -= 1
            player2Streak = 0
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
            SoundManager.playCorrect()
            flashAnswer(correct: true)
            var bonus = 0
            
            if answerState == .player1 {
                player1Streak += 1
                player2Streak = 0
                if player1Streak >= 3 {
                    bonus = player1Streak - 2
                }
                player1Score += 1 + bonus
            } else if answerState == .player2 {
                player2Streak += 1
                player1Streak = 0
                if player2Streak >= 3 {
                    bonus = player2Streak - 2
                }
                player2Score += 1 + bonus
            }
            
            if bonus > 0 {
                let streak = answerState == .player1 ? player1Streak : player2Streak
                showStreakLabel("\(streak)x Streak! +\(1 + bonus)")
            }
            
            roundsPlayed += 1
            
            if player1Score >= winScore || player2Score >= winScore {
                SoundManager.playGameEnd()
                finalPlayer1Score = player1Score
                finalPlayer2Score = player2Score
                gameStatus = .finished
            } else {
                createLevel()
            }
        } else {
            SoundManager.playWrong()
            flashAnswer(correct: false)
            shakeCards()
            if answerState == .player1 {
                player1Score -= 1
                player1Streak = 0
            } else if answerState == .player2 {
                player2Score -= 1
                player2Streak = 0
            }
        }
        
        answerColor = .clear
        answerScale = 0
        answerState = .waiting
    }
    
    func flashAnswer(correct: Bool) {
        withAnimation(.easeIn(duration: 0.1)) {
            flashColor = correct ? Color.green.opacity(0.3) : Color.red.opacity(0.3)
        }
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            withAnimation(.easeOut(duration: 0.2)) {
                flashColor = .clear
            }
        }
    }
    
    func shakeCards() {
        withAnimation(.default) {
            shakeOffset = 10
        }
        Task {
            try? await Task.sleep(for: .milliseconds(80))
            withAnimation(.default) { shakeOffset = -8 }
            try? await Task.sleep(for: .milliseconds(80))
            withAnimation(.default) { shakeOffset = 6 }
            try? await Task.sleep(for: .milliseconds(80))
            withAnimation(.default) { shakeOffset = -4 }
            try? await Task.sleep(for: .milliseconds(80))
            withAnimation(.default) { shakeOffset = 0 }
        }
    }
    
    func showStreakLabel(_ text: String) {
        streakText = text
        withAnimation(.spring(duration: 0.3)) {
            showStreak = true
        }
        
        Task {
            try? await Task.sleep(for: .seconds(1))
            withAnimation {
                showStreak = false
            }
        }
    }
}

#Preview {
    ContentView(itemCount: 9, answerTime: 1, gameStatus: .constant(.settings), emojiType: .constant(.emoji), finalPlayer1Score: .constant(0), finalPlayer2Score: .constant(0))
}
