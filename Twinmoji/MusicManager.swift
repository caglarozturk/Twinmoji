//
//  MusicManager.swift
//  Twinmoji
//

import AVFoundation

class MusicManager {
    static let shared = MusicManager()
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
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
        
        // Clean up any previous engine before creating a new one
        cleanupEngine()
        
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)
        
        let sampleRate: Double = 44100
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.15
        
        // Generate a simple cheerful melody loop
        let bpm = 140.0
        let beatDuration = 60.0 / bpm
        
        // Notes as frequencies (C major pentatonic scale melody)
        let melody: [(freq: Double, beats: Double)] = [
            (523.25, 0.5), // C5
            (587.33, 0.5), // D5
            (659.25, 0.5), // E5
            (783.99, 0.5), // G5
            (659.25, 0.5), // E5
            (587.33, 0.5), // D5
            (523.25, 1.0), // C5
            (783.99, 0.5), // G5
            (880.00, 0.5), // A5
            (783.99, 0.5), // G5
            (659.25, 0.5), // E5
            (523.25, 1.0), // C5
            (392.00, 0.5), // G4
            (440.00, 0.5), // A4
            (523.25, 0.5), // C5
            (587.33, 0.5), // D5
            (523.25, 1.0), // C5
            (0, 0.5),      // rest
            (659.25, 0.5), // E5
            (783.99, 0.5), // G5
            (880.00, 0.5), // A5
            (783.99, 1.0), // G5
            (659.25, 0.5), // E5
            (587.33, 0.5), // D5
            (523.25, 1.0), // C5
            (0, 0.5),      // rest
        ]
        
        // Calculate total duration
        let totalBeats = melody.reduce(0.0) { $0 + $1.beats }
        let totalDuration = totalBeats * beatDuration
        let totalFrames = AVAudioFrameCount(totalDuration * sampleRate)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames) else { return }
        buffer.frameLength = totalFrames
        
        guard let floatData = buffer.floatChannelData?[0] else { return }
        
        var frameIndex: AVAudioFrameCount = 0
        
        for note in melody {
            let noteFrames = AVAudioFrameCount(note.beats * beatDuration * sampleRate)
            let fadeFrames = min(AVAudioFrameCount(0.02 * sampleRate), noteFrames / 4) // 20ms fade
            
            for i in 0..<noteFrames {
                guard frameIndex < totalFrames else { break }
                
                if note.freq > 0 {
                    let t = Double(frameIndex) / sampleRate
                    // Combine sine with a softer square-ish wave for a chiptune feel
                    let sine = sin(2.0 * .pi * note.freq * t)
                    let harmonic = sin(2.0 * .pi * note.freq * 2.0 * t) * 0.3
                    var sample = Float(sine + harmonic) * 0.4
                    
                    // Apply fade in/out envelope
                    if i < fadeFrames {
                        sample *= Float(i) / Float(fadeFrames)
                    } else if i > noteFrames - fadeFrames {
                        sample *= Float(noteFrames - i) / Float(fadeFrames)
                    }
                    
                    floatData[Int(frameIndex)] = sample
                } else {
                    floatData[Int(frameIndex)] = 0
                }
                
                frameIndex += 1
            }
        }
        
        do {
            try engine.start()
            player.play()
            player.scheduleBuffer(buffer, at: nil, options: .loops)
            
            self.audioEngine = engine
            self.playerNode = player
            self.isPlaying = true
        } catch {
            // Audio playback failed silently
        }
    }
    
    func stop() {
        cleanupEngine()
    }
    
    private func cleanupEngine() {
        playerNode?.stop()
        audioEngine?.stop()
        
        if let player = playerNode, let engine = audioEngine {
            engine.detach(player)
        }
        
        playerNode = nil
        audioEngine = nil
        isPlaying = false
    }
}
