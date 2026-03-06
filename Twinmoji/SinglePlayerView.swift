//
//  SinglePlayerView.swift
//  Twinmoji
//

import SwiftUI

struct SinglePlayerView: View {
    
    @State private var currentEmoji = [String]()
    @State private var leftCard = [String]()
    @State private var rightCard = [String]()
    
    @State private var score = 0
    @State private var lives = 5
    @State private var currentItemCount = 0
    @State private var roundsPlayed = 0
    @State private var timeRemaining = 0.0
    @State private var currentAnswerTime = 0.0
    @State private var timerActive = false
    @State private var gameOver = false
    @State private var streak = 0
    @State private var streakText = ""
    @State private var showStreak = false
    @State private var countdownValue = 3
    @State private var showCountdown = true
    @State private var flashColor = Color.clear
    @State private var shakeOffset: CGFloat = 0
    @State private var isPaused = false
    @State private var timerGeneration = 0
    
    var itemCount: Int
    var answerTime: Double
    
    @Binding var gameStatus: GameStatus
    @Binding var emojiType: EmojiType
    
    @AppStorage("soloHighScore") private var highScore = 0
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var body: some View {
        ZStack {
            Color(white: 0.9).ignoresSafeArea()
            
            if gameOver {
                LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3), Color.orange.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                soloFinishView
            } else if verticalSizeClass == .compact {
                // Landscape layout
                HStack(spacing: 0) {
                    // Left side: HUD
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Button("Pause", systemImage: "pause.circle") {
                                isPaused = true
                                timerActive = false
                            }
                            .symbolVariant(.fill)
                            .labelStyle(.iconOnly)
                            .font(.title)
                            .tint(.gray)
                            
                            Button("End Game", systemImage: "xmark.circle") {
                                gameStatus = .intro
                            }
                            .symbolVariant(.fill)
                            .labelStyle(.iconOnly)
                            .font(.title)
                            .tint(.gray)
                        }
                        
                        HStack(spacing: 4) {
                            ForEach(0..<5, id: \.self) { i in
                                Image(systemName: i < lives ? "heart.fill" : "heart")
                                    .foregroundStyle(i < lives ? .red : .gray)
                                    .font(.title3)
                            }
                        }
                        
                        Text("Score: \(score)")
                            .font(.title2.bold())
                            .monospacedDigit()
                        
                        if streak >= 2 {
                            HStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                Text("\(streak)x")
                                    .font(.headline.bold())
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Timer bar (vertical in landscape)
                        GeometryReader { geo in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(timerColor)
                                    .frame(width: 8, height: geo.size.height * max(currentAnswerTime > 0 ? timeRemaining / currentAnswerTime : 0, 0))
                                    .animation(.linear(duration: 0.05), value: timeRemaining)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(width: 120)
                    .padding(.vertical, 16)
                    
                    // Right side: Cards
                    ZStack {
                        if leftCard.isEmpty == false {
                            HStack {
                                CardView(card: leftCard, userCanAnswer: true, onSelect: checkAnswer)
                                CardView(card: rightCard, userCanAnswer: true, onSelect: checkAnswer)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
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
                                .font(.system(size: 28, weight: .heavy))
                                .foregroundStyle(.orange)
                                .shadow(color: .black.opacity(0.3), radius: 4)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                // Portrait layout
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
                                gameStatus = .intro
                            }
                            .symbolVariant(.fill)
                            .labelStyle(.iconOnly)
                            .font(.largeTitle)
                            .tint(.gray)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            ForEach(0..<5, id: \.self) { i in
                                Image(systemName: i < lives ? "heart.fill" : "heart")
                                    .foregroundStyle(i < lives ? .red : .gray)
                                    .font(.title2)
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            if streak >= 2 {
                                HStack(spacing: 2) {
                                    Image(systemName: "flame.fill")
                                        .foregroundStyle(.orange)
                                    Text("\(streak)x")
                                        .font(.headline.bold())
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            Text("Score: \(score)")
                                .font(.title.bold())
                                .monospacedDigit()
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Timer bar
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(timerColor)
                            .frame(width: geo.size.width * max(currentAnswerTime > 0 ? timeRemaining / currentAnswerTime : 0, 0), height: 8)
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
                    VStack(spacing: verticalSizeClass == .compact ? 12 : 20) {
                        Text("Paused")
                            .font(.system(size: verticalSizeClass == .compact ? 32 : 48, weight: .heavy))
                            .foregroundStyle(.white)
                            .fontDesign(.rounded)
                        
                        Button("Resume") {
                            isPaused = false
                            startTimer()
                        }
                        .font(.title2.bold())
                        .buttonStyle(.borderedProminent)
                        
                        Button("End Game") {
                            gameStatus = .intro
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
                        .font(.system(size: verticalSizeClass == .compact ? 80 : 120, weight: .heavy))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
                .ignoresSafeArea()
            }
        }
        .persistentSystemOverlays(.hidden)
        .onAppear {
            MusicManager.shared.stop()
            currentItemCount = itemCount
            currentAnswerTime = answerTime
            startCountdown()
        }
    }
    
    var timerColor: Color {
        guard currentAnswerTime > 0 else { return .red }
        let ratio = timeRemaining / currentAnswerTime
        if ratio > 0.5 { return .green }
        if ratio > 0.25 { return .orange }
        return .red
    }
    
    @ViewBuilder
    var soloFinishView: some View {
        VStack(spacing: verticalSizeClass == .compact ? 8 : 16) {
            Text("Game Over")
                .font(verticalSizeClass == .compact ? .title.bold() : .largeTitle.bold())
                .fontDesign(.rounded)
            
            Text("Score: \(score)")
                .font(verticalSizeClass == .compact ? .title3 : .title)
            
            if score > highScore {
                Text("New High Score! 🏆")
                    .font(verticalSizeClass == .compact ? .body : .title2)
                    .foregroundStyle(.orange)
                    .onAppear { highScore = score }
            } else {
                Text("High Score: \(highScore)")
                    .font(verticalSizeClass == .compact ? .body : .title2)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                Button("Play Again") {
                    resetGame()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Settings") {
                    gameStatus = .intro
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(verticalSizeClass == .compact ? 16 : 24)
        .background(.ultraThinMaterial)
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
        lives = 5
        roundsPlayed = 0
        streak = 0
        currentItemCount = itemCount
        currentAnswerTime = answerTime
        gameOver = false
        startCountdown()
    }
    
    func createLevel() {
        currentEmoji = EmojiData.emojis(for: emojiType).shuffled()
        
        withAnimation(.spring(duration: 0.75)) {
            leftCard = Array(currentEmoji[0..<currentItemCount]).shuffled()
            rightCard = Array(currentEmoji[currentItemCount + 1..<currentItemCount + currentItemCount] + [currentEmoji[0]]).shuffled()
        }
    }
    
    func startTimer() {
        // Increment generation to invalidate any previous timer task
        timerGeneration += 1
        let myGeneration = timerGeneration
        
        // Only reset timeRemaining if starting fresh (not resuming from pause)
        if !isPaused {
            timeRemaining = currentAnswerTime
        }
        timerActive = true
        
        Task {
            while timerActive && timeRemaining > 0 && timerGeneration == myGeneration {
                try? await Task.sleep(for: .milliseconds(50))
                if timerActive && timerGeneration == myGeneration {
                    timeRemaining -= 0.05
                }
            }
            
            if timerActive && timeRemaining <= 0 && timerGeneration == myGeneration {
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
