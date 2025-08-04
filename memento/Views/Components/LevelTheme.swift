//
//  LevelTheme.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct LevelTheme {
    static func color(for level: String) -> Color {
        switch level {
        case "A2":
            return Color(red: 0.2, green: 0.8, blue: 0.4) // Light green
        case "B1":
            return Color(red: 0.0, green: 0.6, blue: 1.0) // Blue
        case "B2":
            return Color(red: 1.0, green: 0.6, blue: 0.0) // Orange
        case "C1":
            return Color(red: 0.8, green: 0.2, blue: 0.8) // Purple
        case "C2":
            return Color(red: 0.9, green: 0.2, blue: 0.2) // Red
        default:
            return .blue
        }
    }
    
    static func gradient(for level: String) -> LinearGradient {
        let color = color(for: level)
        return LinearGradient(
            colors: [color, color.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func backgroundColor(for level: String) -> Color {
        return color(for: level).opacity(0.1)
    }
    
    static func title(for level: String) -> String {
        switch level {
        case "A1":
            return "Starter"
        case "A2":
            return "Beginner"
        case "B1":
            return "Elementary"
        case "B2":
            return "Intermediate"
        case "C1":
            return "Advanced"
        case "C2":
            return "Expert / Native"
        default:
            return "Unknown"
        }
    }
    
    static func description(for level: String) -> String {
        switch level {
        case "A1":
            return "Basic words and phrases for beginners"
        case "A2":
            return "Basic idioms for beginners"
        case "B1":
            return "Common expressions for daily use"
        case "B2":
            return "Advanced phrases for intermediate learners"
        case "C1":
            return "Complex idioms for advanced learners"
        case "C2":
            return "Master level expressions"
        default:
            return "Unknown level"
        }
    }
}

struct LevelThemedCard<Content: View>: View {
    let level: String
    let content: Content
    
    init(level: String, @ViewBuilder content: () -> Content) {
        self.level = level
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LevelTheme.backgroundColor(for: level))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(LevelTheme.color(for: level).opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: LevelTheme.color(for: level).opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

struct LevelThemedSection<Content: View>: View {
    let level: String
    let content: Content
    
    init(level: String, @ViewBuilder content: () -> Content) {
        self.level = level
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Level \(level)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(LevelTheme.color(for: level))
                
                Spacer()
                
                Text(LevelTheme.title(for: level))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LevelTheme.color(for: level))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            content
        }
    }
}

struct LevelProgressIndicator: View {
    let level: String
    let progress: Double
    let total: Int
    let completed: Int
    @EnvironmentObject private var userProgressService: UserProgressService
    @EnvironmentObject private var languageService: LanguageService
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Level \(level)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(LevelTheme.color(for: level))
                
                Spacer()
                
                Text("\(level) \(languageService.progressLabel)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("\(completed)/\(total)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LevelTheme.gradient(for: level))
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: LevelTheme.color(for: level).opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        LevelThemedCard(level: "A2") {
            Text("A2 Level Card")
                .font(.headline)
        }
        
        LevelThemedCard(level: "B1") {
            Text("B1 Level Card")
                .font(.headline)
        }
        
        LevelThemedCard(level: "B2") {
            Text("B2 Level Card")
                .font(.headline)
        }
        
        LevelProgressIndicator(
            level: "B1",
            progress: 0.7,
            total: 10,
            completed: 7
        )
        .environmentObject(UserProgressService())
        .environmentObject(LanguageService())
    }
    .padding()
} 