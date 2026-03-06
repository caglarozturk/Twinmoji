//
//  SoundManager.swift
//  Twinmoji
//

import SwiftUI
import AudioToolbox

struct SoundManager {
    
    static var soundEnabled: Bool {
        UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
    }
    
    private static var isAppActive: Bool {
        UIApplication.shared.applicationState == .active
    }
    
    static func playCorrect() {
        guard isAppActive else { return }
        if soundEnabled {
            AudioServicesPlaySystemSound(1025)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    static func playWrong() {
        guard isAppActive else { return }
        if soundEnabled {
            AudioServicesPlaySystemSound(1053)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    static func playBuzzIn() {
        guard isAppActive else { return }
        if soundEnabled {
            AudioServicesPlaySystemSound(1104)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    static func playCountdownTick() {
        guard isAppActive else { return }
        if soundEnabled {
            AudioServicesPlaySystemSound(1103)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    static func playGameEnd() {
        guard isAppActive else { return }
        if soundEnabled {
            AudioServicesPlaySystemSound(1335)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    static func playTimeout() {
        guard isAppActive else { return }
        if soundEnabled {
            AudioServicesPlaySystemSound(1052)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
}
