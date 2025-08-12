import SwiftUI

struct ConfettiCannon: ViewModifier {
    @Binding var isAnimating: Bool
    let amount: Int
    let duration: TimeInterval

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    if isAnimating {
                        ForEach(0..<amount, id: \.self) { _ in
                            ConfettiPiece(isAnimating: $isAnimating, duration: duration)
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        isAnimating = false
                    }
                }
            )
    }
}

struct ConfettiPiece: View {
    @Binding var isAnimating: Bool
    let duration: TimeInterval

    @State private var x: CGFloat = .random(in: -0.5...0.5)
    @State private var y: CGFloat = .random(in: -0.5...0.5)
    @State private var rotation: Angle = .degrees(.random(in: 0...360))
    @State private var scale: CGFloat = .random(in: 0.5...1.5)
    @State private var opacity: Double = 1.0

    private let color: Color = [.red, .green, .blue, .yellow, .purple, .orange].randomElement()!

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 10, height: 10)
            .scaleEffect(scale)
            .rotationEffect(rotation)
            .offset(x: x * 500, y: y * 500)
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: duration)) {
                    opacity = 0
                }
            }
    }
}

extension View {
    func confettiCannon(isAnimating: Binding<Bool>, amount: Int = 100, duration: TimeInterval = 3.0) -> some View {
        self.modifier(ConfettiCannon(isAnimating: isAnimating, amount: amount, duration: duration))
    }
}
