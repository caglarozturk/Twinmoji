//
//  SoundManager.swift
//  Twinmoji
//

import SwiftUI
import AudioToolbox

struct SoundManager {
    
    static func playCorrect() {
        AudioServicesPlaySystemSound(1025) // positive ding
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func playWrong() {
        AudioServicesPlaySystemSound(1053) // error sound
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func playBuzzIn() {
        AudioServicesPlaySystemSound(1104) // tap
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func playCountdownTick() {
        AudioServicesPlaySystemSound(1103) // tock
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func playGameEnd() {
        AudioServicesPlaySystemSound(1335) // celebration
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func playTimeout() {
        AudioServicesPlaySystemSound(1052) // warning
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
