import SwiftUI

struct RecoveryPrompt: Identifiable {
    let snapshot: RecoverySnapshot
    let savedBook: Book?
    let savedBookURL: URL?
    
    var id: String {
        snapshot.id
    }
    
    var hasSavedBookFallback: Bool {
        savedBook != nil && savedBookURL != nil
    }
}

struct RecoverySheet: View {
    let prompt: RecoveryPrompt
    let onRestore: () -> Void
    let onOpenSavedVersion: () -> Void
    let onDiscardRecovery: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(prompt.hasSavedBookFallback ? "Recovered Writing Found" : "Recovered Draft Found")
                .font(.custom("Courier", size: 20))
                .fontWeight(.bold)
            
            Text(messageText)
                .font(.custom("Courier", size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Draft")
                    .font(.custom("Courier", size: 12))
                    .foregroundColor(.secondary)
                
                Text(prompt.snapshot.book.title)
                    .font(.custom("Courier", size: 14))
                
                Text(prompt.snapshot.capturedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.custom("Courier", size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
            
            HStack {
                if prompt.hasSavedBookFallback {
                    Button("Keep Saved File") {
                        onOpenSavedVersion()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Discard Recovery") {
                        onDiscardRecovery()
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button("Start Fresh") {
                        onDiscardRecovery()
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                Button(prompt.hasSavedBookFallback ? "Restore Recovery" : "Restore Draft") {
                    onRestore()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(28)
        .frame(width: 460)
    }
    
    private var messageText: String {
        if let savedBookURL = prompt.savedBookURL {
            return "Odyssey found a newer recovery copy for \(savedBookURL.lastPathComponent). Restore it to continue from the latest writing session, or keep the saved file on disk."
        }
        
        return "Odyssey found a recovered untitled draft. Restore it to continue writing where you left off, or discard it and start fresh."
    }
}
