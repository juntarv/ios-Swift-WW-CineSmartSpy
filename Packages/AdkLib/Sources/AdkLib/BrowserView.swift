import SwiftUI
import WebKit

public struct BrowserView: UIViewRepresentable {
    let url: String
    @Binding var webView: WKWebView?
    
    public init(url: String, webView: Binding<WKWebView?>) {
        self.url = url
        self._webView = webView
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        
        if let cookieData = UserDefaults.standard.array(forKey: AppConfig.Keys.cookies) as? [Data] {
            for data in cookieData {
                if let cookie = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? HTTPCookie {
                    WKWebsiteDataStore.default().httpCookieStore.setCookie(cookie)
                }
            }
        }
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.customUserAgent = UserAgentManager.shared.userAgent
        webView.backgroundColor = .black
        webView.isOpaque = true
        webView.scrollView.backgroundColor = .black
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        DispatchQueue.main.async {
            self.webView = webView
            
            if let url = URL(string: self.url) {
                print("🌐 Loading URL: \(self.url)")
                webView.load(URLRequest(url: url))
            }
        }
        
        return webView
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {
        // No updates needed
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: BrowserView
        
        init(_ parent: BrowserView) {
            self.parent = parent
        }
        
        public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            guard let newURL = navigationAction.request.url,
                  let currentHost = webView.url?.host else { return nil }
            
            let newHost = newURL.host ?? ""
            if newHost == currentHost, newHost == "", newHost.isEmpty { return nil }
            
            if navigationAction.targetFrame == nil {
                guard let absolute = navigationAction.request.url?.absoluteString else { return nil }
                if !absolute.isEmpty {
                    webView.load(navigationAction.request)
                }
            }
            return nil
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Save cookies
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                let cookieData = cookies.compactMap {
                    try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false)
                }
                UserDefaults.standard.set(cookieData, forKey: AppConfig.Keys.cookies)
            }
            
            // Save finalLoadedUrl only once (not on every page load)
            if UserDefaults.standard.string(forKey: AppConfig.Keys.finalLoadedUrl) == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if let finalUrl = webView.url?.absoluteString {
                        print("✅ [BrowserView] Saving finalLoadedUrl: \(finalUrl)")
                        UserDefaults.standard.set(finalUrl, forKey: AppConfig.Keys.finalLoadedUrl)
                    }
                }
            }
        }
  
    }
}
