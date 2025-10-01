import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    static private(set) var instance: AppDelegate?
    var orientationMask: UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.instance = self
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationMask
    }
}
