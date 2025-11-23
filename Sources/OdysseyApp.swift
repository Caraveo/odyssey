import SwiftUI
import AppKit

@main
struct OdysseyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1200, minHeight: 800)
                .onAppear {
                    // Activate the app and bring window to front
                    NSApp.setActivationPolicy(.regular)
                    NSApp.activate(ignoringOtherApps: true)
                    
                    // Bring all windows to front
                    if let window = NSApplication.shared.windows.first {
                        window.makeKeyAndOrderFront(nil)
                        window.level = .floating
                        window.level = .normal
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    var contentView: ContentView?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        // Activate the app when it finishes launching
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // Handle file opening from command line
        if CommandLine.arguments.count > 1 {
            let filePath = CommandLine.arguments[1]
            if filePath.hasSuffix(".book") {
                let url = URL(fileURLWithPath: filePath)
                openBook(url: url)
            }
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows {
                window.makeKeyAndOrderFront(nil)
            }
        }
        return true
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)
        if url.pathExtension == "book" {
            openBook(url: url)
            return true
        }
        return false
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        for filename in filenames {
            let url = URL(fileURLWithPath: filename)
            if url.pathExtension == "book" {
                openBook(url: url)
                break
            }
        }
    }
    
    private func openBook(url: URL) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenBook"),
                object: nil,
                userInfo: ["url": url]
            )
        }
    }
}

