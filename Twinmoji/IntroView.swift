//
//  IntroView.swift
//  Twinmoji
//

import SwiftUI

struct FloatingEmoji: Identifiable {
    let id = UUID()
    let emoji: String
    let x: CGFloat
    let size: CGFloat
    let duration: Double
    let delay: Double
}

struct IntroView: View {
    
    @Binding var gameStatus: GameStatus
    @Binding var showSettings: Bool
    @Binding var showStats: Bool
    
    @State private var floatingEmojis: [FloatingEmoji] = []
    @State private var titleScale = 0.5
    @State private var titleOpacity = 0.0
    @State private var buttonsOpacity = 0.0
    @State private var pulsePlay = false
    @State private var showHowToPlay = false
    
    private let emojiPool = ["😎", "🥰", "😂", "🍓", "🍊", "🐓", "🦋", "🍉", "🥝", "😇", "🍎", "🐸", "🦚", "🍌", "😍", "🐢", "🍒", "😛", "🦜", "🍑"]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3), Color.orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating emojis in background
            ForEach(floatingEmojis) { emoji in
                FloatingEmojiView(emoji: emoji)
            }
            
            // Main content — landscape layout
            VStack(spacing: 0) {
                HStack(spacing: 40) {
                    // Title on the left
                    VStack(spacing: 6) {
                        Text("🔍")
                            .font(.system(size: 44))
                        
                        Text("Twinmoji")
                            .font(.system(size: 42, weight: .heavy))
                            .fontDesign(.rounded)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Find the matching emoji!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fontDesign(.rounded)
                    }
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)
                    
                    // Buttons on the right
                    VStack(spacing: 12) {
                        Button {
                            gameStatus = .playing
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Play")
                            }
                            .font(.title3.bold())
                            .fontDesign(.rounded)
                            .frame(maxWidth: 200)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .scaleEffect(pulsePlay ? 1.05 : 1.0)
                        
                        HStack(spacing: 12) {
                            Button {
                                showHowToPlay = true
                            } label: {
                                HStack {
                                    Image(systemName: "questionmark.circle.fill")
                                    Text("How to Play")
                                }
                                .font(.body.bold())
                                .fontDesign(.rounded)
                                .frame(maxWidth: 130)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                            .tint(.secondary)
                        }
                        
                        HStack(spacing: 12) {
                            Button {
                                showSettings = true
                            } label: {
                                HStack {
                                    Image(systemName: "gearshape.fill")
                                    Text("Settings")
                                }
                                .font(.body.bold())
                                .fontDesign(.rounded)
                                .frame(maxWidth: 100)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                            .tint(.secondary)
                            
                            Button {
                                showStats = true
                            } label: {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                    Text("Stats")
                                }
                                .font(.body.bold())
                                .fontDesign(.rounded)
                                .frame(maxWidth: 100)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                            .tint(.secondary)
                        }
                    }
                    .opacity(buttonsOpacity)
                }
                .padding(.horizontal, 40)
                
                Spacer().frame(minHeight: 4, maxHeight: 12)
                
                // Banner Ad — pinned to the bottom, outside main content
                if !StoreManager.shared.isAdsRemoved {
                    BannerAdView(adUnitID: AdManager.bannerAdUnitID)
                        .frame(height: 50)
                        .frame(maxWidth: 320)
                        .padding(.bottom, 4)
                }
            }
        }
        .sheet(isPresented: $showHowToPlay) {
            HowToPlayView()
        }
        .persistentSystemOverlays(.hidden)
        .onAppear {
            generateFloatingEmojis()
            
            withAnimation(.spring(duration: 0.8, bounce: 0.4)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                buttonsOpacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.8)) {
                pulsePlay = true
            }
            
            MusicManager.shared.play()
        }
    }
    
    func generateFloatingEmojis() {
        floatingEmojis = (0..<15).map { i in
            FloatingEmoji(
                emoji: emojiPool[i % emojiPool.count],
                x: CGFloat.random(in: 0.05...0.95),
                size: CGFloat.random(in: 28...48),
                duration: Double.random(in: 4...8),
                delay: Double.random(in: 0...3)
            )
        }
    }
}

struct FloatingEmojiView: View {
    let emoji: FloatingEmoji
    
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            Text(emoji.emoji)
                .font(.system(size: emoji.size))
                .position(x: geo.size.width * emoji.x, y: geo.size.height + 50 + yOffset)
                .opacity(opacity)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: emoji.duration)
                        .repeatForever(autoreverses: false)
                        .delay(emoji.delay)
                    ) {
                        yOffset = -(geo.size.height + 150)
                    }
                    
                    withAnimation(
                        .easeIn(duration: emoji.duration * 0.3)
                        .repeatForever(autoreverses: false)
                        .delay(emoji.delay)
                    ) {
                        opacity = 0.6
                    }
                }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    IntroView(
        gameStatus: .constant(.intro),
        showSettings: .constant(false),
        showStats: .constant(false)
    )
}
