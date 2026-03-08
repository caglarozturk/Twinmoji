//
//  MusicManager.swift
//  Twinmoji
//

import AVFoundation
import UIKit

class MusicManager {
    static let shared = MusicManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    var musicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(musicEnabled, forKey: "musicEnabled")
            if musicEnabled {
                play()
            } else {
                stop()
            }
        }
    }
    
    private init() {
        self.musicEnabled = UserDefaults.standard.object(forKey: "musicEnabled") as? Bool ?? true
    }
    
    func play() {
        guard !isPlaying, musicEnabled else { return }
        
        // Load background_music.mp3 from the asset catalog
        guard let asset = NSDataAsset(name: "background_music") else { return }
        
        do {
            let player = try AVAudioPlayer(data: asset.data, fileTypeHint: AVFileType.mp3.rawValue)
            player.numberOfLoops = -1 // Loop indefinitely
            player.volume = 0.3
            player.prepareToPlay()
            player.play()
            
            self.audioPlayer = player
            self.isPlaying = true
        } catch {
            // Audio playback failed silently
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
}
