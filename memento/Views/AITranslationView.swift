//
//  AITranslationView.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import SwiftUI

struct AITranslationView: View {
    @State private var japaneseInput = ""
    @State private var englishOutput = ""
    @State private var matchingIdiom = ""
    @State private var isProcessing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @StateObject private var aiService = AITranslationService()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text("AI Translation")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Type a Japanese sentence and get an English translation with a matching idiom")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Status indicator
                    HStack {
                        Image(systemName: aiService.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(aiService.isAvailable ? .green : .red)
                        
                        Text(aiService.isAvailable ? "Apple Intelligence Available" : "Apple Intelligence Not Available")
                            .font(.caption)
                            .foregroundColor(aiService.isAvailable ? .green : .red)
                    }
                    .padding(.top, 4)
                }
                .padding(.top)
                
                // Input Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Japanese Input")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $japaneseInput)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .placeholder(when: japaneseInput.isEmpty) {
                            Text("Enter a Japanese sentence here...")
                                .foregroundColor(.secondary)
                                .padding(.leading, 16)
                                .padding(.top, 20)
                        }
                }
                
                // Translate Button
                Button(action: translateText) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18))
                        }
                        
                        Text(isProcessing ? "Translating..." : "Translate with AI")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(japaneseInput.isEmpty || isProcessing || !aiService.isAvailable)
                .opacity(japaneseInput.isEmpty || isProcessing || !aiService.isAvailable ? 0.6 : 1.0)
                
                // Output Section
                if !englishOutput.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("English Translation")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(englishOutput)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            
                            if !matchingIdiom.isEmpty {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.orange)
                                    
                                    Text("Matching Idiom:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                }
                                
                                Text(matchingIdiom)
                                    .font(.subheadline)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("AI Translation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        clearAll()
                    }
                    .disabled(japaneseInput.isEmpty && englishOutput.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func translateText() {
        guard !japaneseInput.isEmpty else { return }
        
        isProcessing = true
        englishOutput = ""
        matchingIdiom = ""
        
        aiService.translateJapaneseToEnglish(japaneseText: japaneseInput) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                
                switch result {
                case .success(let translationResult):
                    self.englishOutput = translationResult.translatedText
                    self.matchingIdiom = translationResult.matchingIdiom
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showingError = true
                }
            }
        }
    }
    
    private func clearAll() {
        japaneseInput = ""
        englishOutput = ""
        matchingIdiom = ""
    }
}

// MARK: - Supporting Views

struct PlaceholderView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .foregroundColor(.secondary)
            .padding(.leading, 16)
            .padding(.top, 20)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    AITranslationView()
} 