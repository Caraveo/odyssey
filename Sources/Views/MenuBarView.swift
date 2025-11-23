import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: NodeCanvasViewModel
    @State private var showingAddNode = false
    @State private var newNodeTitle = ""
    @State private var newNodeCategory: NodeCategory = .character
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        HStack {
            // File Menu
            Menu {
                Button("New Book") {
                    handleNewBook()
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("Open Book...") {
                    handleOpenBook()
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Divider()
                
                Button("Save") {
                    handleSave()
                }
                .keyboardShortcut("s", modifiers: .command)
                .disabled(viewModel.currentBookURL == nil)
                
                Button("Save As...") {
                    handleSaveAs()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            } label: {
                Label("File", systemImage: "doc")
            }
            
            // Add Node Menu
            Menu {
                Button("Add Character") {
                    newNodeCategory = .character
                    showingAddNode = true
                }
                Button("Add Plot") {
                    newNodeCategory = .plot
                    showingAddNode = true
                }
                Button("Add Conflict") {
                    newNodeCategory = .conflict
                    showingAddNode = true
                }
                Button("Add Concept") {
                    newNodeCategory = .concept
                    showingAddNode = true
                }
            } label: {
                Label("Add Node", systemImage: "plus.circle")
            }
            
            // Book Title
            Text(viewModel.bookTitle + (viewModel.hasUnsavedChanges ? " •" : ""))
                .font(.custom("Courier", size: 12))
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .alert("Error", isPresented: $showingError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingAddNode) {
            AddNodeSheet(
                title: $newNodeTitle,
                category: $newNodeCategory,
                onAdd: {
                    let center = CGPoint(x: 600, y: 400) // Default center position
                    viewModel.addNode(
                        title: newNodeTitle,
                        category: newNodeCategory,
                        at: center
                    )
                    newNodeTitle = ""
                    showingAddNode = false
                }
            )
        }
    }
    
    private func handleNewBook() {
        viewModel.newBook()
    }
    
    private func handleOpenBook() {
        guard let url = BookService.shared.showOpenPanel() else { return }
        do {
            let book = try BookService.shared.loadBook(from: url)
            viewModel.loadBook(book)
            viewModel.currentBookURL = url
            if let fileName = url.deletingPathExtension().lastPathComponent as String? {
                viewModel.bookTitle = fileName
            }
        } catch {
            errorMessage = "Failed to open book: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func handleSave() {
        if let url = viewModel.currentBookURL {
            do {
                let book = viewModel.createBook()
                try BookService.shared.saveBook(book, to: url)
                viewModel.hasUnsavedChanges = false
            } catch {
                errorMessage = "Failed to save book: \(error.localizedDescription)"
                showingError = true
            }
        } else {
            handleSaveAs()
        }
    }
    
    private func handleSaveAs() {
        guard let url = BookService.shared.showSavePanel(title: "Save Book") else { return }
        do {
            let book = viewModel.createBook()
            try BookService.shared.saveBook(book, to: url)
            viewModel.currentBookURL = url
            if let fileName = url.deletingPathExtension().lastPathComponent as String? {
                viewModel.bookTitle = fileName
            }
            viewModel.hasUnsavedChanges = false
        } catch {
            errorMessage = "Failed to save book: \(error.localizedDescription)"
            showingError = true
        }
    }
}

struct AddNodeSheet: View {
    @Binding var title: String
    @Binding var category: NodeCategory
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Node")
                .font(.custom("Courier", size: 18))
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.custom("Courier", size: 12))
                
                TextField("Enter node title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom("Courier", size: 14))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.custom("Courier", size: 12))
                
                Picker("Category", selection: $category) {
                    ForEach(NodeCategory.allCases) { cat in
                        Text(cat.rawValue.capitalized).tag(cat)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            HStack {
                Button("Cancel") {
                    title = ""
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Add") {
                    onAdd()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 400)
    }
}

