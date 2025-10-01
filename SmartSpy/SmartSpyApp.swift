import SwiftUI
import AdkLib


@main
struct SmartSpyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate // 2 подключение апделег
    
    @StateObject private var globalManager = SmartGlobalManager()

    var body: some Scene {
        WindowGroup {
            RemoteScreen{
                SmartLaunchView()
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
