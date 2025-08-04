import SwiftUI

class PaywallManager: ObservableObject {
    @Published var isShowingPaywall = false
    
    func showPaywall() {
        guard !isShowingPaywall else { return }
        isShowingPaywall = true
    }
    
    func hidePaywall() {
        isShowingPaywall = false
    }
} 