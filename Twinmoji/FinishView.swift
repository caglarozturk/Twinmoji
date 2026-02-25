//
//  FinishView.swift
//  Twinmoji
//
//  Created by Çağlar ÖZTÜRK on 11.12.2025.
//

import SwiftUI
import Vortex

struct FinishView: View {
    
    @Binding var gameStatus: GameStatus
    
    var body: some View {
        ZStack {
            VortexViewReader { proxy in
                VortexView(.confetti) {
                    Rectangle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .tag("square")
                    
                    Circle()
                        .fill(.white)
                        .frame(width: 16)
                        .tag("circle")
                }
                
                VStack(spacing: 10) {
                    Text("Tebrikler KÜÇÜK BOSS ALPEREN!")
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                    
                    Button("Settings") {
                        gameStatus = .settings
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("New Game") {
                        gameStatus = .playing
                    }
                    .buttonStyle(.borderedProminent)
                }
                .onAppear(perform: proxy.burst)
            }
        }
    }
}

#Preview {
    FinishView(gameStatus: .constant(.settings))
}
