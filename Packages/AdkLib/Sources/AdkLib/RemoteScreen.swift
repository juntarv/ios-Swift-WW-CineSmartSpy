import SwiftUI
import WebKit

fileprivate struct NavigationBar: View {
    let webView: WKWebView
    
    var body: some View {
        HStack {
            Button(action: {
                webView.goBack()
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
            .padding(.leading, 20)
            .padding(.top, 13)
            
            Spacer()
        }
        .frame(height: 50)
        .background(Color.black)
        .ignoresSafeArea()
    }
}

public struct RemoteScreen<Content: View>: View {
    private let content: Content
    @StateObject private var appParameters = AppParameters.shared
    @State private var webView: WKWebView?
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            switch appParameters.currentScreen {
            case .loading:
                LoadingAnimation()
                    .onAppear {
                        checkInitialStatus()
                    }
                
            case .webView:
                if let url = appParameters.webViewURL {
                    VStack(spacing: 0) {
                        if let wv = webView {
                            NavigationBar(webView: wv)
                        }
                        
                        BrowserView(url: url, webView: $webView)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear {
                                AppDelegate.shared?.orientationMask = .all
                                AppDelegate.shared?.updateScreenOrientation()
                            }
                            .onDisappear {
                                AppDelegate.shared?.orientationMask = .portrait
                                AppDelegate.shared?.updateScreenOrientation()
                            }
                    }
                    .edgesIgnoringSafeArea(.all)
                }
                
            case .game:
                content
                    .onAppear {
                        AppDelegate.shared?.orientationMask = .portrait
                        AppDelegate.shared?.updateScreenOrientation()
                    }
            }
        }
    }
    
    private func checkInitialStatus() {
        print("🔍 [RemoteScreen] Checking initial status")
        
        // Check if we already have a final URL
        if let finalUrl = UserDefaults.standard.string(forKey: AppConfig.Keys.finalUrl) {
            print("✅ [RemoteScreen] Found final URL, transitioning to web view")
            appParameters.transitionToWebView(url: finalUrl)
            return
        }
        
        // Check if main logic should be shown
        if UserDefaults.standard.bool(forKey: AppConfig.Keys.showMainLogic) {
            print("✅ [RemoteScreen] Main logic should be shown")
            appParameters.transitionToGame()
            return
        }
    }
}
