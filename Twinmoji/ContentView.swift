//
//  ContentView.swift
//  Twinmoji
//
//  Created by Çağlar ÖZTÜRK on 8.12.2025.
//

import SwiftUI

struct ContentView: View {
    
    var settings: GameSettings
    var engine: GameEngine
    
    @Binding var gameStatus: GameStatus
    @Binding var finalPlayer1Score: Int
    @Binding var finalPlayer2Score: Int
    
    // MARK: - Animation State (view-only)
    
    @State private var answerColor = Color.clear
    @State private var answerScale = 1.0
    @State private var answerAnchor = UnitPoint.center
    
    @State private var streakText = ""
    @State private var showStreak = false
    @State private var countdownValue = 3
    @State private var showCountdown = true
    @State private var flashColor = Color.clear
    @State private var shakeOffset: CGFloat = 0
    @State private var isPaused = false
    
    // Score pop animation state
    @State private var player1ScorePop = ""
    @State private var showPlayer1ScorePop = false
    @State private var player2ScorePop = ""
    @State private var showPlayer2ScorePop = false
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var body: some View {
        let isLandscape = verticalSizeClass == .compact
        
        HStack(spacing: 0) {
            // MARK: - Player 1 Button
            PlayerButton(
                answerState: engine.answerState,
                score: engine.player1Score,
                name: settings.player1Name,
                color: .blue,
                winScore: settings.winScore,
                streak: engine.player1Streak,
                side: .leading,
                scorePop: player1ScorePop,
                showScorePop: showPlayer1ScorePop,
                onSelect: selectPlayer1
            )
            .frame(width: isLandscape ? 90 : 80)
            
            // MARK: - Center Area
            VStack(spacing: 0) {
                // Top bar: timer + controls
                HStack(spacing: 0) {
                    // Timer bar
                    GeometryReader { timerGeo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(.gray.opacity(0.2))
                            
                            Rectangle()
                                .fill(engine.answerState == .player1 ? Color.blue : engine.answerState == .player2 ? Color.red : Color.gray.opacity(0.3))
                                .frame(width: timerGeo.size.width * answerScale)
                        }
                    }
                    .frame(height: isLandscape ? 5 : 6)
                    .clipShape(Capsule())
                    .padding(.leading, 12)
                    
                    // Pause / End buttons
                    HStack(spacing: 8) {
                        Button {
                            isPaused = true
                        } label: {
                            Image(systemName: "pause.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.gray)
                                .frame(width: isLandscape ? 28 : 32, height: isLandscape ? 28 : 32)
                                .background(.gray.opacity(0.12))
                                .clipShape(Circle())
                        }
                        
                        Button {
                            gameStatus = .intro
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.gray)
                                .frame(width: isLandscape ? 28 : 32, height: isLandscape ? 28 : 32)
                                .background(.gray.opacity(0.12))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.top, isLandscape ? 6 : 10)
                
                // Cards area
                ZStack {
                    if engine.leftCard.isEmpty == false {
                        HStack(spacing: isLandscape ? 8 : 12) {
                            CardView(card: engine.leftCard, userCanAnswer: engine.answerState != .waiting, onSelect: onCardSelect)
                            CardView(card: engine.rightCard, userCanAnswer: engine.answerState != .waiting, onSelect: onCardSelect)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, isLandscape ? 6 : 10)
                        .offset(x: shakeOffset)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(flashColor)
                                .allowsHitTesting(false)
                                .padding(.horizontal, 10)
                        )
                    }
                    
                    // Streak label
                    if showStreak {
                        Text(streakText)
                            .font(.system(size: isLandscape ? 24 : 32, weight: .heavy, design: .rounded))
                            .foregroundStyle(.orange)
                            .shadow(color: .black.opacity(0.2), radius: 4)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color(white: 0.93))
            
            // MARK: - Player 2 Button
            PlayerButton(
                answerState: engine.answerState,
                score: engine.player2Score,
                name: settings.player2Name,
                color: .red,
                winScore: settings.winScore,
                streak: engine.player2Streak,
                side: .trailing,
                scorePop: player2ScorePop,
                showScorePop: showPlayer2ScorePop,
                onSelect: selectPlayer2
            )
            .frame(width: isLandscape ? 90 : 80)
        }
        .background(Color(white: 0.93))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // MARK: - Pause Overlay
        .overlay {
            if isPaused {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: verticalSizeClass == .compact ? 40 : 56))
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Text("Paused")
                            .font(.system(size: verticalSizeClass == .compact ? 28 : 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        
                        VStack(spacing: 10) {
                            Button {
                                isPaused = false
                            } label: {
                                Text("Resume")
                                    .font(.headline)
                                    .frame(width: 180, height: 44)
                                    .background(.white)
                                    .foregroundStyle(.primary)
                                    .clipShape(.rect(cornerRadius: 14))
                            }
                            
                            Button {
                                gameStatus = .intro
                            } label: {
                                Text("End Game")
                                    .font(.headline)
                                    .frame(width: 180, height: 44)
                                    .background(.white.opacity(0.2))
                                    .foregroundStyle(.white)
                                    .clipShape(.rect(cornerRadius: 14))
                            }
                        }
                    }
                    .padding(32)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 28))
                    .shadow(color: .black.opacity(0.3), radius: 20)
                }
            }
        }
        // MARK: - Countdown Overlay
        .overlay {
            if showCountdown {
                ZStack {
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 8) {
                        Text(countdownValue > 0 ? "\(countdownValue)" : "GO!")
                            .font(.system(size: verticalSizeClass == .compact ? 72 : 100, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                            .shadow(color: .white.opacity(0.3), radius: 20)
                    }
                }
            }
        }
        .persistentSystemOverlays(.hidden)
        .onAppear {
            MusicManager.shared.stop()
            wireEngineCallbacks()
            startCountdown()
        }
    }
    
    // MARK: - Engine Callback Wiring
    
    private func wireEngineCallbacks() {
        engine.onCorrectAnswer = {
            flashAnswer(correct: true)
        }
        engine.onWrongAnswer = {
            flashAnswer(correct: false)
            shakeCards()
        }
        engine.onTimeout = {
            // Visual feedback handled via score pop
        }
        engine.onStreakEarned = { text in
            showStreakLabel(text)
        }
        engine.onScorePop = { player, text in
            showScorePop(player: player, text: text)
        }
        engine.onGameEnd = {
            finalPlayer1Score = engine.player1Score
            finalPlayer2Score = engine.player2Score
            gameStatus = .finished
        }
        engine.onLevelCreated = {
            // Transition is handled by wrapping createLevel in withAnimation
        }
    }
    
    // MARK: - Player Actions
    
    private func selectPlayer1() {
        guard engine.answerState == .waiting else { return }
        
        SoundManager.playBuzzIn()
        answerColor = .blue
        answerAnchor = .leading
        engine.selectPlayer(.player1)
        
        runClock()
    }
    
    private func selectPlayer2() {
        guard engine.answerState == .waiting else { return }
        
        SoundManager.playBuzzIn()
        answerColor = .red
        answerAnchor = .trailing
        engine.selectPlayer(.player2)
        
        runClock()
    }
    
    private func onCardSelect(_ emoji: String) {
        answerColor = .clear
        answerScale = 0
        engine.checkTwoPlayerAnswer(emoji)
    }
    
    // MARK: - Timer & Countdown
    
    private func runClock() {
        answerScale = 1
        let checkEmoji = engine.currentEmoji
        
        withAnimation(.linear(duration: settings.timeOut)) {
            answerScale = 0
        } completion: {
            engine.handleTimeout(for: checkEmoji)
        }
    }
    
    private func startCountdown() {
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
            withAnimation(.spring(duration: 0.75)) {
                engine.createLevel()
            }
        }
    }
    
    // MARK: - Animation Helpers
    
    private func showScorePop(player: Int, text: String) {
        if player == 1 {
            player1ScorePop = text
            withAnimation(.spring(duration: 0.3)) {
                showPlayer1ScorePop = true
            }
            Task {
                try? await Task.sleep(for: .seconds(0.8))
                withAnimation(.easeOut(duration: 0.3)) {
                    showPlayer1ScorePop = false
                }
            }
        } else {
            player2ScorePop = text
            withAnimation(.spring(duration: 0.3)) {
                showPlayer2ScorePop = true
            }
            Task {
                try? await Task.sleep(for: .seconds(0.8))
                withAnimation(.easeOut(duration: 0.3)) {
                    showPlayer2ScorePop = false
                }
            }
        }
    }
    
    private func flashAnswer(correct: Bool) {
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
    
    private func shakeCards() {
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
    
    private func showStreakLabel(_ text: String) {
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
    ContentView(settings: GameSettings(), engine: GameEngine(settings: GameSettings()), gameStatus: .constant(.intro), finalPlayer1Score: .constant(0), finalPlayer2Score: .constant(0))
}
