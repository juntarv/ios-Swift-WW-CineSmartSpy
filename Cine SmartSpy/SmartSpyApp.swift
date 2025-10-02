import SwiftUI
import AdkLib

@main
struct SmartSpyApp: App {
    @UIApplicationDelegateAdaptor(AdkLib.AppDelegate.self) private var appDelegate
    
    @StateObject private var globalManager = SmartGlobalManager()

    var body: some Scene {
        WindowGroup {
            RemoteScreen {
                SmartMenuView()
                    .environmentObject(globalManager)
            }
        }
    }
}

final class SmartGlobalManager: ObservableObject {
    @Published var balance = SmartDefaults.balance
    @Published var selectedModel = SmartDefaults.selectedModel
    @Published var buyedModels = SmartDefaults.buyedModels
}
