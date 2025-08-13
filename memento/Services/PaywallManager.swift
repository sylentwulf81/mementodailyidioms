import SwiftUI

class PaywallManager: ObservableObject {
    @Published var isShowingPaywall = false
    
    var isShowingBinding: Binding<Bool> {
        Binding(
            get: { self.isShowingPaywall },
            set: { self.isShowingPaywall = $0 }
        )
    }
    
    func showPaywall() {
        guard !isShowingPaywall else { return }
        isShowingPaywall = true
    }
    
    func hidePaywall() {
        isShowingPaywall = false
    }
} 