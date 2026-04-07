import SwiftUI
import AppKit

struct ContentView: View {
    private let detailSidebarWidth: CGFloat = 400
    @StateObject private var viewModel = NodeCanvasViewModel()
    @State private var promptText: String = ""
    @State private var selectedAIService: AIServiceType = .mlx
    @State private var aiModel: String = "mistral-7b"
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String?
    @State private var showingWritingMode: Bool = false
    @State private var writingModeNodeId: UUID?
    @State private var writingModeContent: String = ""
    @State private var showingSettings: Bool = false
    @State private var isNodeListCollapsed: Bool = false
    @State private var recoveryPrompt: RecoveryPrompt?
    @State private var hasScheduledRecoveryCheck = false
    
    var body: some View {
        HStack(spacing: 0) {
            if !isNodeListCollapsed {
                NodeHierarchyView(
                    viewModel: viewModel,
                    onCollapse: {
                        isNodeListCollapsed = true
                    },
                    onSelectNode: handleHierarchySelection
                )
                .transition(.move(edge: .leading))
            } else {
                VStack {
                    Button {
                        isNodeListCollapsed = false
                    } label: {
                        Image(systemName: "sidebar.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                    .help("Show Node List")
                    
                    Spacer()
                }
                .frame(width: 40)
                .padding(.top, 10)
                .background(Color(NSColor.windowBackgroundColor))
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color(NSColor.separatorColor)),
                    alignment: .trailing
                )
                .transition(.move(edge: .leading))
            }
            
            ZStack {
                Color(NSColor.textBackgroundColor)
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    NodeCanvasView(viewModel: viewModel)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    VStack {
                        HStack {
                            VStack(spacing: 12) {
                                AddNodeButton(viewModel: viewModel)
                                LinkNodesButton(viewModel: viewModel)
                            }
                            .padding(.top, 20)
                            .padding(.leading, 20)
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    if viewModel.isLinkingMode {
                        VStack {
                            HStack {
                                Label(linkingModeMessage, systemImage: "link")
                                    .font(.custom("Courier", size: 12))
                                    .foregroundColor(.blue)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.blue.opacity(0.1))
                                    )
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(.top, 20)
                        .padding(.leading, 96)
                    }
                    
                    VStack {
                        Spacer()
                        
                        if viewModel.isAutoSaving || !viewModel.saveStatusMessage.isEmpty {
                            HStack(spacing: 8) {
                                if viewModel.isAutoSaving {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                    Text("Auto-saving...")
                                        .font(.custom("Courier", size: 10))
                                        .foregroundColor(.secondary)
                                } else {
                                    Image(systemName: viewModel.currentBookURL == nil ? "clock.arrow.circlepath" : "checkmark.circle")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                    Text(viewModel.saveStatusMessage)
                                        .font(.custom("Courier", size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(NSColor.controlBackgroundColor))
                            )
                            .padding(.bottom, 8)
                        }
                        
                        PromptInputView(
                            promptText: $promptText,
                            selectedAIService: $selectedAIService,
                            aiModel: $aiModel,
                            isGenerating: $isGenerating,
                            onGenerate: generateContent
                        )
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                    .padding(.bottom, 20)
                    .offset(x: promptInputHorizontalOffset)
                    .animation(.easeInOut(duration: 0.22), value: promptInputHorizontalOffset)
                }
                
                if let selectedNode = viewModel.selectedNode, !showingWritingMode {
                    NodeDetailSidebar(
                        node: selectedNode,
                        viewModel: viewModel
                    )
                    .id(selectedNode.id)
                }
                
                if showingWritingMode {
                    WritingModeView(
                        content: $writingModeContent,
                        nodeId: writingModeNodeId,
                        viewModel: viewModel,
                        onClose: {
                            showingWritingMode = false
                        }
                    )
                }
            }
        }
        .font(.custom("Courier", size: 14))
        .focusable()
        .environmentObject(viewModel)
        .onAppear {
            let savedDarkMode = UserDefaults.standard.bool(forKey: "darkMode")
            if savedDarkMode {
                NSApp.appearance = NSAppearance(named: .darkAqua)
            } else {
                NSApp.appearance = NSAppearance(named: .aqua)
            }
            
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApplication.shared.windows.first {
                    window.makeKeyAndOrderFront(nil)
                }
            }
            
            viewModel.startAutoSave()
            scheduleStartupRecoveryCheck()
        }
        .onDisappear {
            viewModel.stopAutoSave()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenBook"))) { notification in
            guard let url = notification.userInfo?["url"] as? URL else { return }
            viewModel.flushPendingAutosave()
            openBook(at: url)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            viewModel.flushPendingAutosave()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            viewModel.flushPendingAutosave()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenWritingMode"))) { notification in
            if let nodeId = notification.userInfo?["nodeId"] as? UUID,
               let content = notification.userInfo?["content"] as? String {
                writingModeNodeId = nodeId
                writingModeContent = content
                showingWritingMode = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewBook"))) { _ in
            handleNewBook()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenBookMenu"))) { _ in
            handleOpenBook()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SaveBook"))) { _ in
            handleSave()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SaveBookAs"))) { _ in
            handleSaveAs()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AddNode"))) { notification in
            if let category = notification.userInfo?["category"] as? NodeCategory {
                let center = CGPoint(x: 600, y: 400)
                viewModel.addNode(title: "New \(category.rawValue.capitalized)", category: category, at: center)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowSettings"))) { _ in
            showingSettings = true
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(selectedAIService: $selectedAIService, aiModel: $aiModel)
        }
        .sheet(item: $recoveryPrompt) { prompt in
            RecoverySheet(
                prompt: prompt,
                onRestore: {
                    handleRecoveryRestore(prompt)
                },
                onOpenSavedVersion: {
                    handleRecoveryFallback(prompt)
                },
                onDiscardRecovery: {
                    handleRecoveryDiscard(prompt)
                }
            )
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }
    
    private func generateContent() {
        guard !promptText.isEmpty else { return }
        
        isGenerating = true
        errorMessage = nil
        
        Task {
            do {
                let context: String
                let selectedNodeId: UUID?
                
                if let nodeId = viewModel.selectedNodeId {
                    context = viewModel.getContextForPrompt()
                    selectedNodeId = nodeId
                } else {
                    context = "Generate creative content based on the following prompt."
                    selectedNodeId = nil
                }
                
                let response = try await AIService.shared.generateText(
                    prompt: promptText,
                    context: context,
                    service: selectedAIService,
                    model: aiModel
                )
                
                await MainActor.run {
                    isGenerating = false
                    
                    if let nodeId = selectedNodeId {
                        viewModel.updateNode(nodeId, aiResults: response)
                    } else {
                        let nodeTitle = promptText.count > 50 ? String(promptText.prefix(47)) + "..." : promptText
                        let existingNodes = viewModel.nodes
                        let centerX: CGFloat = 600
                        let centerY: CGFloat = 400
                        let offsetX = CGFloat(existingNodes.count % 5) * 50
                        let offsetY = CGFloat((existingNodes.count / 5) % 5) * 50
                        let position = CGPoint(x: centerX + offsetX, y: centerY + offsetY)
                        
                        viewModel.addNode(
                            title: nodeTitle,
                            category: .prompt,
                            at: position
                        )
                        
                        if let newNode = viewModel.nodes.last {
                            viewModel.updateNode(newNode.id, content: response)
                            viewModel.selectNode(newNode.id)
                        }
                    }
                    
                    promptText = ""
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isGenerating = false
                }
            }
        }
    }
    
    private func handleNewBook() {
        viewModel.flushPendingAutosave()
        recoveryPrompt = nil
        viewModel.newBook()
    }
    
    private func handleOpenBook() {
        viewModel.flushPendingAutosave()
        guard let url = BookService.shared.showOpenPanel() else { return }
        openBook(at: url)
    }
    
    private func handleSave() {
        if let url = viewModel.currentBookURL {
            do {
                try viewModel.saveBook(to: url)
            } catch {
                errorMessage = "Failed to save book: \(error.localizedDescription)"
            }
        } else {
            handleSaveAs()
        }
    }
    
    private func handleSaveAs() {
        viewModel.flushPendingAutosave()
        guard let url = BookService.shared.showSavePanel(title: "Save Book") else { return }
        
        do {
            try viewModel.saveBook(to: url)
        } catch {
            errorMessage = "Failed to save book: \(error.localizedDescription)"
        }
    }
    
    private func handleHierarchySelection(_ nodeId: UUID) {
        viewModel.selectNode(nodeId)
        
        guard showingWritingMode,
              let node = viewModel.nodes.first(where: { $0.id == nodeId }) else {
            return
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            writingModeNodeId = nodeId
            writingModeContent = node.content
        }
    }
    
    private var linkingModeMessage: String {
        if let sourceId = viewModel.linkingFromNodeId,
           let sourceNode = viewModel.nodes.first(where: { $0.id == sourceId }) {
            return "Linking from \(sourceNode.title). Hover another node to preview the arrow, then click to connect, or click the source again to cancel."
        }
        
        return "Linking mode: click a source node, then click the node you want to connect."
    }
    
    private var isShowingDetailSidebar: Bool {
        viewModel.selectedNode != nil && !showingWritingMode
    }
    
    private var promptInputHorizontalOffset: CGFloat {
        isShowingDetailSidebar ? -(detailSidebarWidth / 2) : 0
    }
    
    private func openBook(at url: URL) {
        do {
            let book = try BookService.shared.loadBook(from: url)
            
            if let snapshot = try RecoveryService.shared.loadSnapshot(for: url) {
                recoveryPrompt = RecoveryPrompt(
                    snapshot: snapshot,
                    savedBook: book,
                    savedBookURL: url
                )
                return
            }
            
            recoveryPrompt = nil
            viewModel.loadBook(book, from: url)
        } catch {
            errorMessage = "Failed to open book: \(error.localizedDescription)"
        }
    }
    
    private func scheduleStartupRecoveryCheck() {
        guard !hasScheduledRecoveryCheck else { return }
        hasScheduledRecoveryCheck = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            checkForUntitledRecoveryIfNeeded()
        }
    }
    
    private func checkForUntitledRecoveryIfNeeded() {
        guard recoveryPrompt == nil else { return }
        guard viewModel.currentBookURL == nil, viewModel.nodes.isEmpty else { return }
        
        do {
            if let snapshot = try RecoveryService.shared.mostRecentUntitledSnapshot() {
                recoveryPrompt = RecoveryPrompt(
                    snapshot: snapshot,
                    savedBook: nil,
                    savedBookURL: nil
                )
            }
        } catch {
            errorMessage = "Failed to check recovery drafts: \(error.localizedDescription)"
        }
    }
    
    private func handleRecoveryRestore(_ prompt: RecoveryPrompt) {
        recoveryPrompt = nil
        viewModel.loadRecoveredSnapshot(prompt.snapshot)
    }
    
    private func handleRecoveryFallback(_ prompt: RecoveryPrompt) {
        recoveryPrompt = nil
        
        if let savedBook = prompt.savedBook, let savedBookURL = prompt.savedBookURL {
            viewModel.loadBook(savedBook, from: savedBookURL)
        }
    }
    
    private func handleRecoveryDiscard(_ prompt: RecoveryPrompt) {
        recoveryPrompt = nil
        
        do {
            try RecoveryService.shared.deleteSnapshot(prompt.snapshot)
        } catch {
            errorMessage = "Failed to discard recovery: \(error.localizedDescription)"
        }
        
        if let savedBook = prompt.savedBook, let savedBookURL = prompt.savedBookURL {
            viewModel.loadBook(savedBook, from: savedBookURL)
        } else {
            viewModel.newBook()
        }
    }
}
