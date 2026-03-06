//
//  EmojiData.swift
//  Twinmoji
//

import Foundation

enum EmojiData {
    static let allEmoji = Array("😎🥹🥰😔😂😳🧐🙂😇😅😆😙😬🙃😍🥸😣😶🙄🤨😩😉🥲😋😛🤓😏😭😯😵😐😘😢😠").map(String.init)
    
    static let allFruit = Array("🍓🍊🍋🍍🍉🍇🍎🍌🍑🥭🥝🍒🍈🍐🍏🥥🫐🍅🧅🧄🥔🍆🌽🫛🥬🥦🥒🥕🫑🌶️🥑🌰🍠🥜").map(String.init)
    
    static let allAnimal = Array("🐓🦃🕊🦅🦆🦉🦢🦤🦩🦚🦜🐁🐿🦇🐕🐈🐇🐝🐛🐞🐜🕷🦋🦂🪳🦟🪰🐍🐢🐊🦎🐸🐌🦑🐙").map(String.init)
    
    static let allFlag = Array("🇦🇩🇦🇱🇦🇹🇧🇦🇧🇪🇧🇬🇨🇿🇩🇪🇩🇰🇪🇦🇪🇪🇫🇮🇫🇷🇬🇧🇬🇷🇭🇷🇭🇺🇮🇪🇮🇸🇮🇹🇱🇹🇱🇺🇱🇻🇲🇨🇲🇰🇳🇱🇳🇴🇵🇱🇵🇹🇷🇴🇷🇸🇷🇺🇸🇪🇸🇮🇸🇰🇺🇦🏴󠁧󠁢󠁳󠁣󠁴󠁿🏴󠁧󠁢󠁷󠁬󠁳󠁿🇹🇷").map(String.init)
    
    static let allSport = Array("⚽️🏀🏈⚾️🎾🏐🏉🥏🎱🏓🏸🏒🥊🥋⛳️🏹🥅🤿🛹🏋️🤸🤺🏄🚴🏊🤽🤾⛷🏂🪂🧗🏇🛷⛸").map(String.init)
    
    static func emojis(for type: EmojiType) -> [String] {
        switch type {
        case .emoji: return allEmoji
        case .fruit: return allFruit
        case .animal: return allAnimal
        case .flag: return allFlag
        case .sport: return allSport
        }
    }
}
