//
//  SubscriptionService.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import Foundation
import SwiftUI

class SubscriptionService: ObservableObject {
    @AppStorage("isPro") var isProUser: Bool = false
    
    // Mock data for development - will be replaced with StoreKit2
    var hasActiveSubscription: Bool {
        return isProUser
    }
    
    func upgradeToPro() {
        // TODO: Implement StoreKit2 purchase flow
        isProUser = true
    }
    
    func restorePurchases() {
        // TODO: Implement StoreKit2 restore
        print("Restoring purchases...")
    }
    
    func checkSubscriptionStatus() {
        // TODO: Implement StoreKit2 status check
        print("Checking subscription status...")
    }
} 