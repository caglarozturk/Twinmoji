//
//  BannerAdView.swift
//  Twinmoji
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    
    let adUnitID: String
    
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSizeFor(cgSize: CGSize(width: 320, height: 50)))
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
        banner.load(Request())
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
}
