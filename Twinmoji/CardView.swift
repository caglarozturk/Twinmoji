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
                geo.size.width / CGFloat(columns) * 0.7,
                geo.size.height / CGFloat(rows) * 0.7,
                64
            ), minSize)
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0..<rows, id: \.self) { i in
                    GridRow {
                        ForEach(0..<columns, id: \.self) { j in
                            let text = card[i * columns + j]
                            
                            Button(text) {
                                onSelect(text)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
            .font(.system(size: emojiSize))
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(CGFloat(columns) / CGFloat(rows), contentMode: .fit)
        .padding(8)
        .background(.white)
        .clipShape(.rect(cornerRadius: 20))
        .shadow(radius: 10)
        .disabled(userCanAnswer == false)
        .transition(.push(from: .top))
        .id(card)
    }
}

#Preview {
    CardView(card: ["1", "2", "3", "4", "5", "6", "7", "8", "9"], userCanAnswer: true) { _ in }
}
