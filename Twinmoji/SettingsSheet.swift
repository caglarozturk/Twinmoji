//
//  SettingsSheet.swift
//  Twinmoji
//

import SwiftUI

struct SettingsSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var gameMode: GameMode
    @Binding var timeOut: Double
    @Binding var soloTimeOut: Double
    @Binding var items: Int
    @Binding var winScore: Int
    @Binding var emojiType: EmojiType
    @Binding var player1Name: String
    @Binding var player2Name: String
    
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Game Mode
                    settingsCard {
                        VStack(spacing: 12) {
                            settingsLabel("Game Mode", icon: "person.2.fill", color: .purple)
                            
                            HStack(spacing: 10) {
                                modeButton(
                                    title: "2 Players",
                                    icon: "person.2.fill",
                                    isSelected: gameMode == .twoPlayer,
                                    color: .purple
                                ) {
                                    withAnimation(.spring(duration: 0.3)) { gameMode = .twoPlayer }
                                }
                                
                                modeButton(
                                    title: "Solo",
                                    icon: "person.fill",
                                    isSelected: gameMode == .singlePlayer,
                                    color: .purple
                                ) {
                                    withAnimation(.spring(duration: 0.3)) { gameMode = .singlePlayer }
                                }
                            }
                        }
                    }
                    
                    // MARK: - Player Names (2-player only)
                    if gameMode == .twoPlayer {
                        settingsCard {
                            VStack(spacing: 12) {
                                settingsLabel("Players", icon: "pencil", color: .gray)
                                
                                HStack(spacing: 10) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(.blue)
                                            .frame(width: 10, height: 10)
                                        TextField("Player 1", text: $player1Name)
                                            .font(.subheadline)
                                    }
                                    .padding(10)
                                    .background(.white.opacity(0.6))
                                    .clipShape(.rect(cornerRadius: 10))
                                    
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(.red)
                                            .frame(width: 10, height: 10)
                                        TextField("Player 2", text: $player2Name)
                                            .font(.subheadline)
                                    }
                                    .padding(10)
                                    .background(.white.opacity(0.6))
                                    .clipShape(.rect(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    
                    // MARK: - Gameplay Settings
                    settingsCard {
                        VStack(spacing: 16) {
                            // Difficulty
                            VStack(spacing: 8) {
                                settingsLabel("Difficulty", icon: "chart.bar.fill", color: .orange)
                                
                                HStack(spacing: 8) {
                                    difficultyButton(title: "Easy", subtitle: "3×3", value: 9, color: .green)
                                    difficultyButton(title: "Normal", subtitle: "3×4", value: 12, color: .orange)
                                    difficultyButton(title: "Hard", subtitle: "4×4", value: 16, color: .red)
                                }
                            }
                            
                            Divider()
                            
                            // Answer Time
                            VStack(spacing: 8) {
                                settingsLabel("Speed", icon: "timer", color: .blue)
                                
                                if gameMode == .singlePlayer {
                                    HStack(spacing: 8) {
                                        speedButton(title: "Relaxed", subtitle: "60s", tag: 60.0, binding: $soloTimeOut)
                                        speedButton(title: "Normal", subtitle: "30s", tag: 30.0, binding: $soloTimeOut)
                                        speedButton(title: "Rush", subtitle: "15s", tag: 15.0, binding: $soloTimeOut)
                                    }
                                } else {
                                    HStack(spacing: 8) {
                                        speedButton(title: "Relaxed", subtitle: "2s", tag: 2.0, binding: $timeOut)
                                        speedButton(title: "Normal", subtitle: "1s", tag: 1.0, binding: $timeOut)
                                        speedButton(title: "Blitz", subtitle: "0.5s", tag: 0.5, binding: $timeOut)
                                    }
                                }
                            }
                            
                            if gameMode == .twoPlayer {
                                Divider()
                                
                                // Win Score
                                VStack(spacing: 8) {
                                    settingsLabel("First to", icon: "trophy.fill", color: .yellow)
                                    
                                    HStack(spacing: 8) {
                                        ForEach([3, 5, 7, 10], id: \.self) { score in
                                            Button {
                                                withAnimation(.spring(duration: 0.2)) { winScore = score }
                                            } label: {
                                                Text("\(score)")
                                                    .font(.headline.bold())
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 10)
                                                    .background(winScore == score ? Color.yellow : .white.opacity(0.5))
                                                    .foregroundStyle(winScore == score ? .white : .primary)
                                                    .clipShape(.rect(cornerRadius: 10))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: - Emoji Type
                    settingsCard {
                        VStack(spacing: 10) {
                            settingsLabel("Category", icon: "face.smiling.fill", color: .pink)
                            
                            let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                            
                            LazyVGrid(columns: columns, spacing: 8) {
                                emojiCategoryButton(title: "Faces", preview: "😎🥰😂", type: .emoji)
                                emojiCategoryButton(title: "Fruits", preview: "🍓🍊🍉", type: .fruit)
                                emojiCategoryButton(title: "Animals", preview: "🦋🐸🦚", type: .animal)
                                emojiCategoryButton(title: "Flags", preview: "🇹🇷🇬🇧🇫🇷", type: .flag)
                                emojiCategoryButton(title: "Sports", preview: "⚽️🏀🎾", type: .sport)
                            }
                        }
                    }
                    
                    // MARK: - Audio
                    settingsCard {
                        VStack(spacing: 4) {
                            HStack {
                                Label {
                                    Text("Sound Effects")
                                        .font(.subheadline)
                                } icon: {
                                    Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                        .foregroundStyle(soundEnabled ? .blue : .gray)
                                        .frame(width: 20)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $soundEnabled)
                                    .labelsHidden()
                            }
                            
                            Divider()
                            
                            HStack {
                                Label {
                                    Text("Music")
                                        .font(.subheadline)
                                } icon: {
                                    Image(systemName: musicEnabled ? "music.note" : "music.note.slash")
                                        .foregroundStyle(musicEnabled ? .purple : .gray)
                                        .frame(width: 20)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $musicEnabled)
                                    .labelsHidden()
                                    .onChange(of: musicEnabled) { _, newValue in
                                        MusicManager.shared.musicEnabled = newValue
                                    }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.15), Color.orange.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Components
    
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 16))
    }
    
    private func settingsLabel(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
    
    private func modeButton(title: String, icon: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? color : .white.opacity(0.5))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private func difficultyButton(title: String, subtitle: String, value: Int, color: Color) -> some View {
        Button {
            withAnimation(.spring(duration: 0.2)) { items = value }
        } label: {
            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption2)
                    .opacity(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(items == value ? color : .white.opacity(0.5))
            .foregroundStyle(items == value ? .white : .primary)
            .clipShape(.rect(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
    
    private func speedButton(title: String, subtitle: String, tag: Double, binding: Binding<Double>) -> some View {
        Button {
            withAnimation(.spring(duration: 0.2)) { binding.wrappedValue = tag }
        } label: {
            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption2)
                    .opacity(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(binding.wrappedValue == tag ? Color.blue : .white.opacity(0.5))
            .foregroundStyle(binding.wrappedValue == tag ? .white : .primary)
            .clipShape(.rect(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
    
    private func emojiCategoryButton(title: String, preview: String, type: EmojiType) -> some View {
        Button {
            withAnimation(.spring(duration: 0.2)) { emojiType = type }
        } label: {
            VStack(spacing: 4) {
                Text(preview)
                    .font(.title3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(emojiType == type ? Color.pink : .white.opacity(0.5))
            .foregroundStyle(emojiType == type ? .white : .primary)
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsSheet(
        gameMode: .constant(.twoPlayer),
        timeOut: .constant(1.0),
        soloTimeOut: .constant(10.0),
        items: .constant(12),
        winScore: .constant(5),
        emojiType: .constant(.emoji),
        player1Name: .constant("Player 1"),
        player2Name: .constant("Player 2")
    )
}
