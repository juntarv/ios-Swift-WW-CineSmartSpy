import Foundation
import UIKit

public class UserAgentManager {
    public static let shared = UserAgentManager()
    private let userAgentKey = "savedUserAgent"
    
    private init() {}
    
    public var userAgent: String {
        if let savedAgent = UserDefaults.standard.string(forKey: userAgentKey) {
            return savedAgent
        }
        let newAgent = generateUserAgent()
        UserDefaults.standard.set(newAgent, forKey: userAgentKey)
        return newAgent
    }
    
    private func generateUserAgent() -> String {
        let device = UIDevice.current
        let osVersion = device.systemVersion.replacingOccurrences(of: ".", with: "_")
        
        return """
        Mozilla/5.0 (\(device.model); CPU \(device.model) OS \(osVersion) like Mac OS X) \
        AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(device.systemVersion) Mobile/15E148 Safari/604.1
        """
    }
} 