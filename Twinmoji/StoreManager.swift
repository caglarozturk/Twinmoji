//
//  StoreManager.swift
//  Twinmoji
//

import Foundation
import StoreKit

@Observable
class StoreManager {
    
    static let shared = StoreManager()
    
    // MARK: - Replace this with your real product ID from App Store Connect
    static let removeAdsProductID = "com.twinmoji.removeads"
    
    private(set) var removeAdsProduct: Product?
    private(set) var isAdsRemoved: Bool = false
    private(set) var isPurchasing: Bool = false
    private(set) var errorMessage: String?
    
    private var transactionListener: Task<Void, Error>?
    
    private init() {
        // Check cached state first for instant UI (avoids ad flash on launch)
        isAdsRemoved = UserDefaults.standard.bool(forKey: "adsRemoved")
        
        transactionListener = listenForTransactions()
        
        Task {
            await fetchProducts()
            await updatePurchaseStatus()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: - Fetch Products
    
    func fetchProducts() async {
        do {
            let products = try await Product.products(for: [Self.removeAdsProductID])
            removeAdsProduct = products.first
        } catch {
            errorMessage = "Failed to load products."
        }
    }
    
    // MARK: - Purchase
    
    func purchaseRemoveAds() async {
        guard let product = removeAdsProduct else { return }
        isPurchasing = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchaseStatus()
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
        
        isPurchasing = false
    }
    
    // MARK: - Restore
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchaseStatus()
    }
    
    // MARK: - Transaction Listener
    
    nonisolated private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { @MainActor in
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchaseStatus()
                    await transaction.finish()
                } catch {
                    // Transaction verification failed
                }
            }
        }
    }
    
    // MARK: - Verification & Status
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreError.verificationFailed
        }
    }
    
    func updatePurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.removeAdsProductID {
                isAdsRemoved = true
                UserDefaults.standard.set(true, forKey: "adsRemoved")
                return
            }
        }
    }
    
    enum StoreError: Error {
        case verificationFailed
    }
}
