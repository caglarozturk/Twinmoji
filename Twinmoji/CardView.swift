//
//  CardView.swift
//  Twinmoji
//
//  Created by Çağlar ÖZTÜRK on 8.12.2025.
//

import SwiftUI

struct CardView: View {
    
    var card: [String]
    var userCanAnswer: Bool
    var onSelect: (String) -> Void
    
    var rows: Int {
        if card.count == 9 {
            3
        } else {
            4
        }
    }
    
    var columns: Int {
        if card.count == 16 {
            4
        } else {
            3
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let minSize: CGFloat = columns >= 4 ? 16 : 24
            let emojiSize = max(min(
                geo.size.width / CGFloat(columns) * 0.65,
                geo.size.height / CGFloat(rows) * 0.65,
                60
            ), minSize)
            
            Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                ForEach(0..<rows, id: \.self) { i in
                    GridRow {
                        ForEach(0..<columns, id: \.self) { j in
                            let text = card[i * columns + j]
                            
                            Button {
                                onSelect(text)
                            } label: {
                                Text(text)
                                    .font(.system(size: emojiSize))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.gray.opacity(userCanAnswer ? 0.08 : 0.03))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(6)
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(CGFloat(columns) / CGFloat(rows), contentMode: .fit)
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.gray.opacity(0.12), lineWidth: 1)
        )
        .disabled(userCanAnswer == false)
        .opacity(userCanAnswer ? 1 : 0.85)
        .transition(.push(from: .top))
        .id(card)
    }
}

#Preview {
    CardView(card: ["1", "2", "3", "4", "5", "6", "7", "8", "9"], userCanAnswer: true) { _ in }
}
