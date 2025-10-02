import Foundation
import OneSignalFramework

class AppLinkManager {
    static let shared = AppLinkManager()
    private let defaults = UserDefaults.standard
    
    private init() {
    }
    
    func createStartLink() {
        if let savedUrl = defaults.string(forKey: AppConfig.Keys.targetUrl),
           !savedUrl.isEmpty {
            AppParameters.shared.transitionToWebView(url: savedUrl)
        } else {

            AppParameters.shared.transitionToGame()
        }
    }
} 
