//
//  HowToPlayView.swift
//  Twinmoji
//

import SwiftUI

struct HowToPlayView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var isTurkish = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.15), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    Text(isTurkish ? "Nasıl Oynanır?" : "How to Play")
                        .font(.title2.bold())
                        .fontDesign(.rounded)
                    
                    Spacer()
                    
                    // Language toggle
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            isTurkish.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(isTurkish ? "🇹🇷" : "🇬🇧")
                                .font(.title3)
                            Text(isTurkish ? "TR" : "EN")
                                .font(.caption.bold())
                                .foregroundStyle(.primary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                // Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        if isTurkish {
                            turkishContent
                        } else {
                            englishContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    // MARK: - English Content
    
    @ViewBuilder
    private var englishContent: some View {
        // Goal
        infoCard(
            icon: "🎯",
            title: "Goal",
            text: "Two cards are shown side by side. Each card has emojis on it. Find the one emoji that appears on both cards!"
        )
        
        // Two Player Mode
        infoCard(
            icon: "👥",
            title: "Two Player Mode",
            text: "Two players compete head-to-head. When a new round starts, tap your side of the screen to buzz in first. Then find and tap the matching emoji on either card. Score points to win!"
        )
        
        // Solo Mode
        infoCard(
            icon: "🧑",
            title: "Solo Mode",
            text: "Play alone against the clock! Find the matching emoji before time runs out. Each correct answer earns points and keeps the game going. You have 5 lives — a wrong answer or timeout costs a life."
        )
        
        // Streaks
        infoCard(
            icon: "🔥",
            title: "Streaks",
            text: "Get multiple correct answers in a row to build a streak. Streaks earn bonus points — the longer your streak, the more you score!"
        )
        
        // Settings
        infoCard(
            icon: "⚙️",
            title: "Settings",
            text: "Customize your game! Change emoji categories (faces, fruits, animals, flags, sports), adjust the number of emojis per card, set the timer speed, and personalize player names."
        )
        
        // Tips
        infoCard(
            icon: "💡",
            title: "Tips",
            text: "There is always exactly one matching emoji between the two cards. Look quickly but carefully — speed matters, but a wrong answer can cost you!"
        )
    }
    
    // MARK: - Turkish Content
    
    @ViewBuilder
    private var turkishContent: some View {
        // Amaç
        infoCard(
            icon: "🎯",
            title: "Amaç",
            text: "Yan yana iki kart gösterilir. Her kartta emojiler bulunur. İki kartta da ortak olan tek emojiyi bul!"
        )
        
        // İki Kişilik Mod
        infoCard(
            icon: "👥",
            title: "İki Kişilik Mod",
            text: "İki oyuncu karşı karşıya yarışır. Yeni bir tur başladığında, önce butona bas ve eşleşen emojiyi bul! Puan toplayarak oyunu kazan!"
        )
        
        // Tek Kişilik Mod
        infoCard(
            icon: "🧑",
            title: "Tek Kişilik Mod",
            text: "Zamana karşı tek başına oyna! Süre dolmadan eşleşen emojiyi bul. Her doğru cevap puan kazandırır. 5 canın var — yanlış cevap veya süre dolması bir canına mal olur."
        )
        
        // Seriler
        infoCard(
            icon: "🔥",
            title: "Seriler",
            text: "Arka arkaya doğru cevaplar vererek seri oluştur. Seriler bonus puan kazandırır — serin ne kadar uzunsa, o kadar çok puan kazanırsın!"
        )
        
        // Ayarlar
        infoCard(
            icon: "⚙️",
            title: "Ayarlar",
            text: "Oyununu özelleştir! Emoji kategorisini değiştir (yüzler, meyveler, hayvanlar, bayraklar, sporlar), kart başına emoji sayısını ayarla, zamanlayıcı hızını belirle ve oyuncu isimlerini kişiselleştir."
        )
        
        // İpuçları
        infoCard(
            icon: "💡",
            title: "İpuçları",
            text: "İki kart arasında her zaman tam olarak bir eşleşen emoji vardır. Hızlı ama dikkatli bak — hız önemli, ama yanlış cevap sana pahalıya mal olabilir!"
        )
    }
    
    // MARK: - Card Builder
    
    private func infoCard(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(icon)
                .font(.title)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontDesign(.rounded)
                
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 14))
    }
}

#Preview {
    HowToPlayView()
}
