//
//  StatsView.swift
//  Twinmoji
//

import SwiftUI

struct StatsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let stats = StatsManager.shared
    @State private var results: [GameResult] = []
    @State private var showClearAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Overview Grid
                    statsCard {
                        VStack(spacing: 12) {
                            statsLabel("Overview", icon: "chart.bar.fill", color: .purple)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                statTile(
                                    value: "\(stats.totalGames)",
                                    title: "Total Games",
                                    icon: "gamecontroller.fill",
                                    color: .blue
                                )
                                
                                statTile(
                                    value: "\(stats.soloHighScore)",
                                    title: "Solo Best",
                                    icon: "trophy.fill",
                                    color: .yellow
                                )
                                
                                statTile(
                                    value: "\(stats.player1Wins)",
                                    title: "P1 Wins",
                                    icon: "person.fill",
                                    color: .blue
                                )
                                
                                statTile(
                                    value: "\(stats.player2Wins)",
                                    title: "P2 Wins",
                                    icon: "person.fill",
                                    color: .red
                                )
                            }
                        }
                    }
                    
                    // MARK: - Recent Games
                    statsCard {
                        VStack(spacing: 12) {
                            statsLabel("Recent Games", icon: "clock.fill", color: .orange)
                            
                            if results.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "gamecontroller")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.secondary.opacity(0.5))
                                    Text("No games played yet")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                                        if index > 0 {
                                            Divider()
                                                .padding(.horizontal, 4)
                                        }
                                        
                                        resultRow(result)
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: - Clear History
                    if !results.isEmpty {
                        Button(role: .destructive) {
                            showClearAlert = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                    .font(.subheadline)
                                Text("Clear History")
                                    .font(.subheadline.weight(.medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial)
                            .clipShape(.rect(cornerRadius: 16))
                        }
                        .alert("Clear History", isPresented: $showClearAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Clear", role: .destructive) {
                                withAnimation {
                                    stats.clearHistory()
                                    results = []
                                }
                            }
                        } message: {
                            Text("This will permanently delete all game history.")
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.15), Color.orange.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                results = stats.loadResults()
            }
        }
    }
    
    // MARK: - Components
    
    private func statsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 16))
    }
    
    private func statsLabel(_ title: String, icon: String, color: Color) -> some View {
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
    
    private func statTile(value: String, title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2.bold())
                .monospacedDigit()
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white.opacity(0.5))
        .clipShape(.rect(cornerRadius: 12))
    }
    
    private func resultRow(_ result: GameResult) -> some View {
        HStack(spacing: 12) {
            // Mode icon
            Image(systemName: result.gameMode == "singlePlayer" ? "person.fill" : "person.2.fill")
                .font(.subheadline)
                .foregroundStyle(resultColor(result))
                .frame(width: 28, height: 28)
                .background(resultColor(result).opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(result.winnerText)
                    .font(.subheadline.weight(.semibold))
                
                if result.gameMode == "twoPlayer" {
                    HStack(spacing: 4) {
                        Text("\(result.player1Score)")
                            .foregroundStyle(.blue)
                        Text("-")
                            .foregroundStyle(.secondary)
                        Text("\(result.player2Score)")
                            .foregroundStyle(.red)
                    }
                    .font(.caption.weight(.medium))
                }
            }
            
            Spacer()
            
            Text(result.date, style: .relative)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
    
    private func resultColor(_ result: GameResult) -> Color {
        if result.gameMode == "singlePlayer" { return .purple }
        if result.player1Score > result.player2Score { return .blue }
        if result.player2Score > result.player1Score { return .red }
        return .gray
    }
}

#Preview {
    StatsView()
}
