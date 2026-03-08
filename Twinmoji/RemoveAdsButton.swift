//
//  RemoveAdsButton.swift
//  Twinmoji
//

import SwiftUI
import StoreKit

struct RemoveAdsButton: View {
    
    var storeManager: StoreManager
    
    var body: some View {
        if let product = storeManager.removeAdsProduct, !storeManager.isAdsRemoved {
            Button {
                Task {
                    await storeManager.purchaseRemoveAds()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Remove Ads")
                            .font(.subheadline.weight(.semibold))
                        Text(product.displayPrice)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if storeManager.isPurchasing {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(Color.green.opacity(0.12))
                .clipShape(.rect(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(storeManager.isPurchasing)
        }
    }
}
