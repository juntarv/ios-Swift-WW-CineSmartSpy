import Foundation
import SwiftUI
import OneSignalFramework

public enum AppScreenState {
    case loading
    case webView
    case game
}

public class AppParameters: ObservableObject {
    public static let shared = AppParameters()
    private let defaults = UserDefaults.standard
    
    @Published public var currentScreen: AppScreenState = .loading
    @Published public var webViewURL: String?
    
    private init() {
        print("📱 [AppParameters] Initializing")
        loadValues()
    }
    
    public func loadValues() {
        print("📱 [AppParameters] Loading saved values")
        
        // Check for finalLoadedUrl first (like in the example)
        if let savedLoadedUrl = defaults.string(forKey: AppConfig.Keys.finalLoadedUrl),
           !savedLoadedUrl.isEmpty {
            print("🌐 [AppParameters] Found finalLoadedUrl: \(savedLoadedUrl)")
            webViewURL = savedLoadedUrl
            currentScreen = .webView
            return
        }
        
        // Then check for targetUrl
        if let savedUrl = defaults.string(forKey: AppConfig.Keys.targetUrl),
           !savedUrl.isEmpty {
            print("🌐 [AppParameters] Found saved URL: \(savedUrl)")
            webViewURL = savedUrl
            currentScreen = .webView
        } else if defaults.integer(forKey: AppConfig.Keys.appStatus) == 2 {
            print("🎮 [AppParameters] Found game mode status")
            currentScreen = .game
        }
    }
    
    public func transitionToWebView(url: String) {
        print("🌐 [AppParameters] Transitioning to WebView with URL: \(url)")
        DispatchQueue.main.async {
            self.webViewURL = url
            self.currentScreen = .webView
            self.defaults.set(url, forKey: AppConfig.Keys.targetUrl)
            self.defaults.set(1, forKey: AppConfig.Keys.appStatus)
            print("✅ [AppParameters] WebView transition complete")
        }
    }
    
    public func transitionToGame() {
        print("🎮 [AppParameters] Transitioning to game")
        DispatchQueue.main.async {
            self.currentScreen = .game
            self.defaults.set(false, forKey: AppConfig.Keys.webViewShown)
            self.defaults.set("", forKey: AppConfig.Keys.targetUrl)
            self.defaults.set(2, forKey: AppConfig.Keys.appStatus)
            print("✅ [AppParameters] Game transition complete")
        }
    }
} 
