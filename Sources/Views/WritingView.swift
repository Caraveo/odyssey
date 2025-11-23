import SwiftUI
import AppKit

struct WritingView: View {
    @Binding var text: String
    @State private var wordCount: Int = 0
    @State private var characterCount: Int = 0
    @State private var paragraphCount: Int = 0
    @State private var lineCount: Int = 0
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Main writing area
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    TextEditor(text: $text)
                        .font(.custom("Courier", size: 16))
                        .lineSpacing(1.2)
                        .padding(.horizontal, 24) // 1.5 * 16 = 24 points for margins
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .scrollContentBackground(.hidden)
                        .background(Color(NSColor.textBackgroundColor))
                        .focused($isFocused)
                        .onChange(of: text) { _ in
                            updateStats()
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isFocused = true
                            }
                            updateStats()
                        }
                }
            }
            .background(Color(NSColor.textBackgroundColor))
            
            // Status bar
            HStack(spacing: 8) {
                Text("\(wordCount) words")
                    .font(.custom("Courier", size: 11))
                    .foregroundColor(.secondary)
                
                Text("•")
                    .font(.custom("Courier", size: 11))
                    .foregroundColor(.secondary)
                
                Text("\(characterCount) characters")
                    .font(.custom("Courier", size: 11))
                    .foregroundColor(.secondary)
                
                Text("•")
                    .font(.custom("Courier", size: 11))
                    .foregroundColor(.secondary)
                
                Text("\(paragraphCount) paragraphs")
                    .font(.custom("Courier", size: 11))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(NSColor.separatorColor)),
                alignment: .top
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func updateStats() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Word count
        let words = trimmed.split { $0 == " " || $0.isNewline }
            .filter { !$0.isEmpty }
        wordCount = words.count
        
        // Character count (excluding newlines for display, but we show total)
        characterCount = text.count
        
        // Paragraph count
        if trimmed.isEmpty {
            paragraphCount = 0
        } else {
            let paragraphs = text.components(separatedBy: "\n\n")
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            paragraphCount = paragraphs.isEmpty ? 1 : paragraphs.count
        }
        
        // Line count
        lineCount = text.isEmpty ? 0 : text.components(separatedBy: .newlines).count
    }
}

