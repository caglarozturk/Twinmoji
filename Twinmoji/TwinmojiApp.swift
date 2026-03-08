//
//  TwinmojiApp.swift
//  Twinmoji
//
//  Created by Çağlar ÖZTÜRK on 8.12.2025.
//

import SwiftUI
import GoogleMobileAds

@main
struct TwinmojiApp: App {
    @State private var settings = GameSettings()
    
    init() {
        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start()
        
        // Initialize store and sync ad removal state
        _ = StoreManager.shared
        if StoreManager.shared.isAdsRemoved {
            AdManager.shared.disableAds()
        }
        
        // Initialize ad manager
        AdManager.shared.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            MenuView(settings: settings)
                .preferredColorScheme(.light)
        }
    }
}
