//
//  SinglePlayerView.swift
//  Twinmoji
//

import SwiftUI

struct SinglePlayerView: View {
    
    let allEmoji = Array("😎🥹🥰😔😂😳🧐🙂😇😅😆😙😬🙃😍🥸😣😶🙄🤨😩😉🥲😋😛🤓😏😭😯😵😐😘😢😠").map(String.init)
    let allFruit = Array("🍓🍊🍋🍍🍉🍇🍎🍌🍑🥭🥝🍒🍈🍐🍏🥥🫐🍅🧅🧄🥔🍆🌽🫛🥬🥦🥒🥕🫑🌶️🥑🌰🍠🥜").map(String.init)
    let allAnimal = Array("🐓🦃🕊🦅🦆🦉🦢🦤🦩🦚🦜🐁🐿🦇🐕🐈🐇🐝🐛🐞🐜🕷🦋🦂🪳🦟🪰🐍🐢🐊🦎🐸🐌🦑🐙").map(String.init)
    let allFlag = Array("🇦🇩🇦🇱🇦🇹🇧🇦🇧🇪🇧🇬🇨🇿🇩🇪🇩🇰🇪🇦🇪🇪🇫🇮🇫🇷🇬🇧🇬🇷🇭🇷🇭🇺🇮🇪🇮🇸🇮🇹🇱🇹🇱🇺🇱🇻🇲🇨🇲🇰🇳🇱🇳🇴🇵🇱🇵🇹🇷🇴🇷🇸🇷🇺🇸🇪🇸🇮🇸🇰🇺🇦🏴󠁧󠁢󠁳󠁣󠁴󠁿🏴󠁧󠁢󠁷󠁬󠁳󠁿🇹🇷").map(String.init)
    
    @State private var currentEmoji = [String]()
    @State private var leftCard = [String]()
    @State private var rightCard = [String]()
    
    @State private var score = 0
    @State private var lives = 3
    @State private var currentItemCount = 0
    @State private var roundsPlayed = 0
    @State private var timeRemaining = 0.0
    @State private var timerActive = true
    @State private var gameOver = false
    @State private var streak = 0
    @State private var streakText = ""
    @State private var showStreak = false
    @State private var countdownValue = 3
    @State private var showCountdown = true
    @State private var flashColor = Color.clear
    @State private var shakeOffset: CGFloat = 0
    @State private var isPaused = false
    
    var itemCount: Int
    var answerTime: Double
    
    @Binding var gameStatus: GameStatus
    @Binding var emojiType: EmojiType
    
    @AppStorage("soloHighScore") private var highScore = 0
    
    var body: some View {
        ZStack {
            Color(white: 0.9).ignoresSafeArea()
            
            if gameOver {
                soloFinishView
            } else {
                VStack(spacing: 16) {
                    HStack {
                        HStack(spacing: 12) {
                            Button("Pause", systemImage: "pause.circle") {
                                isPaused = true
                                timerActive = false
                            }
                            .symbolVariant(.fill)
                            .labelStyle(.iconOnly)
                            .font(.largeTitle)
                            .tint(.gray)
                            
                            Button("End Game", systemImage: "xmark.circle") {
                                gameStatus = .settings
                            }
                            .symbolVariant(.fill)
                            .labelStyle(.iconOnly)
                            .font(.largeTitle)
                            .tint(.gray)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { i in
                                Image(systemName: i < lives ? "heart.fill" : "heart")
                                    .foregroundStyle(i < lives ? .red : .gray)
                                    .font(.title2)
                            }
                        }
                        
                        Spacer()
                        
                        Text("Score: \(score)")
                            .font(.title.bold())
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 20)
                    
                    // Timer bar
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(timerColor)
                            .frame(width: geo.size.width * max(timeRemaining / answerTime, 0), height: 8)
                            .animation(.linear(duration: 0.05), value: timeRemaining)
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    ZStack {
                        if leftCard.isEmpty == false {
                            HStack {
                                CardView(card: leftCard, userCanAnswer: true, onSelect: checkAnswer)
                                CardView(card: rightCard, userCanAnswer: true, onSelect: checkAnswer)
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
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
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
                            startTimer()
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
            currentItemCount = itemCount
            startCountdown()
        }
    }
    
    var timerColor: Color {
        let ratio = timeRemaining / answerTime
        if ratio > 0.5 { return .green }
        if ratio > 0.25 { return .orange }
        return .red
    }
    
    var soloFinishView: some View {
        VStack(spacing: 16) {
            Text("Game Over")
                .font(.largeTitle.bold())
                .fontDesign(.rounded)
            
            Text("Score: \(score)")
                .font(.title)
            
            if score > highScore {
                Text("New High Score! 🏆")
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .onAppear { highScore = score }
            } else {
                Text("High Score: \(highScore)")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            
            Button("Play Again") {
                resetGame()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Settings") {
                gameStatus = .settings
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.white)
        .clipShape(.rect(cornerRadius: 20))
        .shadow(radius: 10)
    }
    
    func startCountdown() {
        showCountdown = true
        countdownValue = 3
        timerActive = false
        
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
            startTimer()
        }
    }
    
    func resetGame() {
        score = 0
        lives = 3
        roundsPlayed = 0
        streak = 0
        currentItemCount = itemCount
        gameOver = false
        startCountdown()
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
        
        // Difficulty progression every 3 rounds
        if roundsPlayed > 0 && roundsPlayed % 3 == 0 {
            if currentItemCount == 9 {
                currentItemCount = 12
            } else if currentItemCount == 12 {
                currentItemCount = 16
            }
        }
        
        withAnimation(.spring(duration: 0.75)) {
            leftCard = Array(currentEmoji[0..<currentItemCount]).shuffled()
            rightCard = Array(currentEmoji[currentItemCount + 1..<currentItemCount + currentItemCount] + [currentEmoji[0]]).shuffled()
        }
    }
    
    func startTimer() {
        timeRemaining = answerTime
        timerActive = true
        
        Task {
            while timerActive && timeRemaining > 0 {
                try? await Task.sleep(for: .milliseconds(50))
                if timerActive {
                    timeRemaining -= 0.05
                }
            }
            
            if timerActive && timeRemaining <= 0 {
                loseLife()
            }
        }
    }
    
    func loseLife() {
        timerActive = false
        lives -= 1
        streak = 0
        
        if lives <= 0 {
            SoundManager.playGameEnd()
            let result = GameResult(date: Date(), player1Score: score, player2Score: 0, gameMode: "singlePlayer")
            StatsManager.shared.saveResult(result)
            gameOver = true
        } else {
            SoundManager.playWrong()
            createLevel()
            startTimer()
        }
    }
    
    func checkAnswer(_ emoji: String) {
        timerActive = false
        
        if emoji == currentEmoji[0] {
            SoundManager.playCorrect()
            flashAnswer(correct: true)
            streak += 1
            var bonus = 0
            if streak >= 3 {
                bonus = streak - 2
                showStreakLabel("\(streak)x Streak! +\(1 + bonus)")
            }
            score += 1 + bonus
            roundsPlayed += 1
            createLevel()
            startTimer()
        } else {
            flashAnswer(correct: false)
            shakeCards()
            streak = 0
            loseLife()
        }
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
    SinglePlayerView(itemCount: 9, answerTime: 2.0, gameStatus: .constant(.playing), emojiType: .constant(.emoji))
}
