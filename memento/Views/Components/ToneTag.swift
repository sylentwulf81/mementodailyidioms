//
//  ToneTag.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct ToneTag: View {
    let tone: String
    
    private var displayText: String {
        switch tone {
        case "casual":
            return "カジュアル"
        case "formal":
            return "フォーマル"
        default:
            return tone
        }
    }
    
    private var backgroundColor: Color {
        switch tone {
        case "casual":
            return .orange
        case "formal":
            return .blue
        default:
            return .gray
        }
    }
    
    var body: some View {
        Text(displayText)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.1))
            .foregroundColor(backgroundColor)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 10) {
        ToneTag(tone: "casual")
        ToneTag(tone: "formal")
    }
    .padding()
} 