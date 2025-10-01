import SwiftUI
import AVFoundation

final class SmartDefaults {
    static var isSoundOn: Bool {
        get { UserDefaults.standard.value(forKey: #function) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var isVibroOn: Bool {
        get { UserDefaults.standard.value(forKey: #function) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var firstLaunch: Bool {
        get { UserDefaults.standard.value(forKey: #function) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var balance: Int {
        get { UserDefaults.standard.value(forKey: #function) as? Int ?? 0 }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var selectedModel: Int {
        get { UserDefaults.standard.value(forKey: #function) as? Int ?? 0 }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var buyedModels: [Int] {
        get { UserDefaults.standard.value(forKey: #function) as? [Int] ?? [0] }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static var openedRewards: [Int] {
        get { UserDefaults.standard.value(forKey: #function) as? [Int] ?? [0] }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }
    
    static func append(reward: SmartRewardsEnum) {
        if !openedRewards.contains(reward.rawValue) {
            openedRewards.append(reward.rawValue)
        }
    }
}

struct SmartBackgroundImageView: View {
    private let image: UIImage
    
    init(_ image: UIImage) {
        self.image = image
    }
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        } .ignoresSafeArea()
    }
}

struct SmartFitImageView: View {
    private let image: UIImage
    
    init(_ image: UIImage) {
        self.image = image
    }
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct SmartButton: View {
    @State private var smartScaleValue = 1.0

    private let smartImage: UIImage
    private let smartClosure: () -> ()
    
    init(_ smartImage: UIImage, smartClosure: @escaping () -> ()) {
        self.smartImage = smartImage
        self.smartClosure = smartClosure
    }
    
    var body: some View {
        Button {} label: {
            SmartFitImageView(smartImage)
                .scaleEffect(smartScaleValue)
                .animation(.easeInOut(duration: 0.08), value: smartScaleValue)
                .onLongPressGesture {} onPressingChanged: { isStarted in
                    isStarted ? holdDownAction() : holdUpAction()
                }
        }
        .buttonStyle(.plain)
    }
    
    private func holdUpAction() {
        SmartEffectsManager.shared.smartButtonFull()
        smartScaleValue = 1.0
        smartClosure()
    }
    
    private func holdDownAction() {
        smartScaleValue = 0.96
    }
}

final class SmartEffectsManager {
    private let smartGenerator: UIImpactFeedbackGenerator
    static let shared = SmartEffectsManager()
    
    private init() {
        self.smartGenerator = UIImpactFeedbackGenerator()
    }
    
    private func smartTapSound() {
        if SmartDefaults.isSoundOn {
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    func smartTapVibro() {
        if SmartDefaults.isVibroOn {
            smartGenerator.impactOccurred()
        }
    }
    
    func smartButtonFull() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.smartTapSound()
            self.smartTapVibro()
        }
    }
}

struct SmartScreen {
    static let isIpad = UIDevice.current.model.contains("iPad")
    static let width = isIpad ? 375 : UIScreen.main.bounds.width
    static let height = isIpad ? 667 : UIScreen.main.bounds.height
    static let size = CGSize(width: width, height: height)
}
