import SwiftUI

@main
struct CAssistantApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(appState.isDarkMode ? .dark : nil)
        }
    }
}