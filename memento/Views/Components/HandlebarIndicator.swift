import SwiftUI

struct HandlebarIndicator: View {
    var body: some View {
        // Handlebar
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Color(.systemGray3))
            .frame(width: 36, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }
}

#Preview {
    VStack {
        HandlebarIndicator()
        Spacer()
        Text("Content goes here")
        Spacer()
    }
    .background(Color(.systemBackground))
} 