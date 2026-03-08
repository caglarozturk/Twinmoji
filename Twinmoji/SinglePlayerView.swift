//
//  SinglePlayerView.swift
//  Twinmoji
//

import SwiftUI

struct SinglePlayerView: View {
    
    var settings: GameSettings
    var engine: GameEngine
    
    @Binding var gameStatus: GameStatus
    
    // MARK: - Animation State (view-only)
    
    @State private var streakText = ""
    @State private var showStreak = false
    @State private var countdownValue = 3
    @State private var showCountdown = true
    @State private var flashColor = Color.clear
    @State private var shakeOffset: CGFloat = 0
    @State private var isPaused = false
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var body: some View {
        ZStack {
            Color(white: 0.9).ignoresSafeArea()
            
            if engine.gameOver {
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
                                engine.pauseSoloTimer()
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
                                Image(systemName: i < engine.lives ? "heart.fill" : "heart")
                                    .foregroundStyle(i < engine.lives ? .red : .gray)
                                    .font(.title3)
                            }
                        }
                        
                        Text("Score: \(engine.score)")
                            .font(.title2.bold())
                            .monospacedDigit()
                        
                        if engine.streak >= 2 {
                            HStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                Text("\(engine.streak)x")
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
                                    .frame(width: 8, height: geo.size.height * max(engine.currentAnswerTime > 0 ? engine.timeRemaining / engine.currentAnswerTime : 0, 0))
                                    .animation(.linear(duration: 0.05), value: engine.timeRemaining)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(width: 120)
                    .padding(.vertical, 16)
                    
                    // Right side: Cards
                    ZStack {
                        if engine.leftCard.isEmpty == false {
                            HStack {
                                CardView(card: engine.leftCard, userCanAnswer: true, onSelect: onCardSelect)
                                CardView(card: engine.rightCard, userCanAnswer: true, onSelect: onCardSelect)
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
                                engine.pauseSoloTimer()
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
                                Image(systemName: i < engine.lives ? "heart.fill" : "heart")
                                    .foregroundStyle(i < engine.lives ? .red : .gray)
                                    .font(.title2)
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            if engine.streak >= 2 {
                                HStack(spacing: 2) {
                                    Image(systemName: "flame.fill")
                                        .foregroundStyle(.orange)
                                    Text("\(engine.streak)x")
                                        .font(.headline.bold())
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            Text("Score: \(engine.score)")
                                .font(.title.bold())
                                .monospacedDigit()
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Timer bar
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(timerColor)
                            .frame(width: geo.size.width * max(engine.currentAnswerTime > 0 ? engine.timeRemaining / engine.currentAnswerTime : 0, 0), height: 8)
                            .animation(.linear(duration: 0.05), value: engine.timeRemaining)
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    ZStack {
                        if engine.leftCard.isEmpty == false {
                            HStack {
                                CardView(card: engine.leftCard, userCanAnswer: true, onSelect: onCardSelect)
                                CardView(card: engine.rightCard, userCanAnswer: true, onSelect: onCardSelect)
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
                            engine.resumeSoloTimer()
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
            engine.startSoloGame()
            wireEngineCallbacks()
            startCountdown()
        }
    }
    
    // MARK: - Computed Properties
    
    private var timerColor: Color {
        guard engine.currentAnswerTime > 0 else { return .red }
        let ratio = engine.timeRemaining / engine.currentAnswerTime
        if ratio > 0.5 { return .green }
        if ratio > 0.25 { return .orange }
        return .red
    }
    
    // MARK: - Solo Finish View
    
    @ViewBuilder
    private var soloFinishView: some View {
        VStack(spacing: verticalSizeClass == .compact ? 8 : 16) {
            Text("Game Over")
                .font(verticalSizeClass == .compact ? .title.bold() : .largeTitle.bold())
                .fontDesign(.rounded)
            
            Text("Score: \(engine.score)")
                .font(verticalSizeClass == .compact ? .title3 : .title)
            
            if engine.score > settings.soloHighScore {
                Text("New High Score! 🏆")
                    .font(verticalSizeClass == .compact ? .body : .title2)
                    .foregroundStyle(.orange)
            } else {
                Text("High Score: \(settings.soloHighScore)")
                    .font(verticalSizeClass == .compact ? .body : .title2)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                Button("Play Again") {
                    engine.resetSoloGame()
                    startCountdown()
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
    
    // MARK: - Engine Callback Wiring
    
    private func wireEngineCallbacks() {
        engine.onCorrectAnswer = {
            flashAnswer(correct: true)
        }
        engine.onWrongAnswer = {
            flashAnswer(correct: false)
            shakeCards()
        }
        engine.onStreakEarned = { text in
            showStreakLabel(text)
        }
        engine.onLifeLost = {
            // Visual feedback from engine (heart removal is automatic via @Observable)
        }
        engine.onGameEnd = {
            // Interstitial ad (every 3rd game)
            if AdManager.shared.gameDidFinish() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    AdManager.shared.presentInterstitial()
                }
            }
            
            // Rating prompt
            ReviewManager.registerGameAndPromptIfNeeded()
        }
        engine.onLevelCreated = {
            // Cards animate via @Observable tracking
        }
    }
    
    // MARK: - Actions
    
    private func onCardSelect(_ emoji: String) {
        engine.checkSoloAnswer(emoji)
    }
    
    // MARK: - Countdown
    
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
            engine.startSoloTimer()
        }
    }
    
    // MARK: - Animation Helpers
    
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
    SinglePlayerView(settings: GameSettings(), engine: GameEngine(settings: GameSettings()), gameStatus: .constant(.playing))
}
