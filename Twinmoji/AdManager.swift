//
//  AdManager.swift
//  Twinmoji
//

import Foundation
import GoogleMobileAds
import UIKit

@Observable
class AdManager: NSObject {
    
    static let shared = AdManager()
    
    static let bannerAdUnitID = "ca-app-pub-6739169691159101/8781809156"
    static let interstitialAdUnitID = "ca-app-pub-6739169691159101/3561272068"
    
    // State
    private(set) var isInterstitialReady = false
    private(set) var adsRemoved = false
    
    // Game counter for interstitial frequency
    private var gamesCompletedCount = 0
    private let interstitialFrequency = 3  // Show every 3rd game
    
    // Ad objects
    private var interstitialAd: InterstitialAd?
    
    private override init() {
        super.init()
    }
    
    func initialize() {
        guard !adsRemoved else { return }
        // Pre-load the first interstitial
        loadInterstitial()
    }
    
    // MARK: - Interstitial
    
    func loadInterstitial() {
        guard !adsRemoved else { return }
        InterstitialAd.load(
            with: Self.interstitialAdUnitID,
            request: Request()
        ) { [weak self] ad, error in
            guard let self else { return }
            self.interstitialAd = ad
            self.isInterstitialReady = (ad != nil)
        }
    }
    
    /// Call when a game finishes. Returns true if an interstitial should be shown.
    func gameDidFinish() -> Bool {
        guard !adsRemoved else { return false }
        gamesCompletedCount += 1
        return gamesCompletedCount % interstitialFrequency == 0 && isInterstitialReady
    }
    
    func presentInterstitial() {
        guard let ad = interstitialAd,
              let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController
        else { return }
        
        ad.present(from: rootVC)
        interstitialAd = nil
        isInterstitialReady = false
        loadInterstitial()  // Pre-load the next one
    }
    
    func disableAds() {
        adsRemoved = true
        interstitialAd = nil
        isInterstitialReady = false
    }
}
