//
//  SubscriptionService.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI
import StoreKit

@MainActor
class SubscriptionService: ObservableObject {
    @AppStorage("isPro") var isProUser: Bool = false
    @Published var products: [Product] = []
    
    private let productIds = ["com.memento.pro.monthly", "com.memento.pro.yearly"]
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = listenForTransactions()
    }
    
    deinit {
        updates?.cancel()
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIds)
            products.sort { $0.price < $1.price }
            print("SubscriptionService: Loaded \(products.count) products")
        } catch {
            print("SubscriptionService: Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if let transaction = try? verification.payloadValue {
                await transaction.finish()
                isProUser = true
                print("SubscriptionService: Purchase successful")
            }
        case .userCancelled:
            print("SubscriptionService: User cancelled")
        case .pending:
            print("SubscriptionService: Purchase pending")
        @unknown default:
            break
        }
    }
    
    func restorePurchases() async {
        print("SubscriptionService: Restoring purchases...")
        try? await AppStore.sync()
        await updateSubscriptionStatus()
    }
    
    func updateSubscriptionStatus() async {
        var hasActive = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? result.payloadValue {
                if transaction.revocationDate == nil {
                    hasActive = true
                }
            }
        }
        isProUser = hasActive
        print("SubscriptionService: Updated status. Pro: \(isProUser)")
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? result.payloadValue {
                    await transaction.finish()
                    await self.updateSubscriptionStatus()
                }
            }
        }
    }
} 