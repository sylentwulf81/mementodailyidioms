import SwiftUI

struct ExampleCard: View {
    let example: Example
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ToneTag(tone: example.tone)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(example.english)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(example.japanese)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    ExampleCard(example: Example(
        english: "Good luck with your presentation! Break a leg!",
        japanese: "プレゼンテーション頑張って！成功を祈ってるよ！",
        tone: "casual"
    ))
    .padding()
} 