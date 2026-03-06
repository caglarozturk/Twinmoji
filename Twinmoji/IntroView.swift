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
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    private let emojiPool = ["😎", "🥰", "😂", "🍓", "🍊", "🐓", "🦋", "🍉", "🥝", "😇", "🍎", "🐸", "🦚", "🍌", "😍", "🐢", "🍒", "😛", "🦜", "🍑"]
    
    private var isLandscape: Bool { verticalSizeClass == .compact }
    
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
            
            // Main content
            if isLandscape {
                // Landscape: side-by-side layout
                HStack(spacing: 40) {
                    // Title on the left
                    VStack(spacing: 6) {
                        Text("🔍")
                            .font(.system(size: 40))
                        
                        Text("Twinmoji")
                            .font(.system(size: 38, weight: .heavy))
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
                            .frame(maxWidth: 180)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .scaleEffect(pulsePlay ? 1.05 : 1.0)
                        
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
            } else {
                // Portrait: vertical layout
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("🔍")
                            .font(.system(size: 60))
                        
                        Text("Twinmoji")
                            .font(.system(size: 52, weight: .heavy))
                            .fontDesign(.rounded)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Find the matching emoji!")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .fontDesign(.rounded)
                    }
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 16) {
                        Button {
                            gameStatus = .playing
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Play")
                            }
                            .font(.title2.bold())
                            .fontDesign(.rounded)
                            .frame(maxWidth: 220)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .scaleEffect(pulsePlay ? 1.05 : 1.0)
                        
                        HStack(spacing: 16) {
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
                                .padding(.vertical, 10)
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
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(.bordered)
                            .tint(.secondary)
                        }
                    }
                    .opacity(buttonsOpacity)
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
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
