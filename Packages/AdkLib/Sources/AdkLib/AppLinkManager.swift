import Foundation
import OneSignalFramework

class AppLinkManager {
    static let shared = AppLinkManager()
    private let defaults = UserDefaults.standard
    
    private init() {
        print("🔗 [AppLinkManager] Initializing")
    }
    
    func createStartLink() {
        print("🔗 [AppLinkManager] Creating start link")
        if let savedUrl = defaults.string(forKey: AppConfig.Keys.targetUrl),
           !savedUrl.isEmpty {
            print("🌐 [AppLinkManager] Found saved URL: \(savedUrl), transitioning to WebView")
            AppParameters.shared.transitionToWebView(url: savedUrl)
        } else {
            print("🎮 [AppLinkManager] No saved URL, transitioning to game")
            AppParameters.shared.transitionToGame()
        }
    }
} 