//
//  StatsView.swift
//  Twinmoji
//

import SwiftUI

struct StatsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let stats = StatsManager.shared
    @State private var results: [GameResult] = []
    
    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    LabeledContent("Total Games", value: "\(stats.totalGames)")
                    LabeledContent("Player 1 Wins", value: "\(stats.player1Wins)")
                    LabeledContent("Player 2 Wins", value: "\(stats.player2Wins)")
                    LabeledContent("Solo High Score", value: "\(stats.soloHighScore)")
                }
                
                Section("Recent Games") {
                    if results.isEmpty {
                        Text("No games played yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(results) { result in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(result.winnerText)
                                        .font(.headline)
                                    if result.gameMode == "twoPlayer" {
                                        Text("\(result.player1Score) - \(result.player2Score)")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Text(result.date, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear", role: .destructive) {
                        stats.clearHistory()
                        results = []
                    }
                }
            }
            .onAppear {
                results = stats.loadResults()
            }
        }
    }
}

#Preview {
    StatsView()
}
