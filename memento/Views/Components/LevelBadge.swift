//
//  LevelBadge.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct LevelBadge: View {
    let level: String
    
    private var backgroundColor: Color {
        switch level {
        case "A1", "A2":
            return .green
        case "B1", "B2":
            return .blue
        case "C1", "C2":
            return .purple
        default:
            return .gray
        }
    }
    
    var body: some View {
        Text(level)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor.opacity(0.1))
            .foregroundColor(backgroundColor)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 10) {
        LevelBadge(level: "A1")
        LevelBadge(level: "B1")
        LevelBadge(level: "C1")
    }
    .padding()
} 