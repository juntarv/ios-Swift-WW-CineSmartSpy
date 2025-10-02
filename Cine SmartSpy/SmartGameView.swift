import SwiftUI
import SpriteKit

struct SmartGameView: View {
    @State private var transitOpacity = 1.0
    @State private var isPausePresented = false
    @State private var isResultPresented = false
    @State private var smartScene = SmartGameScene()
    @State private var smartId = UUID()
    
    @State private var lifesLeft = 3
    @State private var earnedScore = 0
    
    @Binding private var isPresented: Bool
    @Environment(\.scenePhase) private var scenePhase
        
    init(_ isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: smartScene)
                .id(smartId)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    HStack {
                        SmartFitImageView(lifesLeft >= 1 ? .smartFullLife : .smartEmptyLife)
                            .frame(width: SmartScreen.width * 0.1)
                            .animation(.linear, value: lifesLeft)
                        SmartFitImageView(lifesLeft >= 2 ? .smartFullLife : .smartEmptyLife)
                            .frame(width: SmartScreen.width * 0.1)
                            .animation(.linear, value: lifesLeft)
                        SmartFitImageView(lifesLeft >= 3 ? .smartFullLife : .smartEmptyLife)
                            .frame(width: SmartScreen.width * 0.1)
                            .animation(.linear, value: lifesLeft)
                    }
                    Spacer()
                    SmartButton(.smartPauseButton) {
                        isPausePresented = true
                        smartSetPause()
                    }
                    .frame(width: SmartScreen.width * 0.18)
                }
                Spacer()
            }
            .padding()
            
            if isPausePresented {
                SmartPauseView($isPausePresented) { type in
                    switch type {
                        case .menu: smartHomeExit()
                        default:    smartGameResume()
                    }
                }
            }
            
            if isResultPresented {
                SmartResultView($isResultPresented, earnedScore: earnedScore) { type in
                    switch type {
                        case .menu: smartHomeExit()
                        default:    smartRestart()
                    }
                }
            }
            
            SmartBackgroundImageView(.smartSceneBack)
                .opacity(transitOpacity)
                .animation(.linear(duration: 0.25), value: transitOpacity)
        }
        
        .onAppear() {
            smartScene.setGame(view: self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                transitOpacity = 0.0
            }
        }
        
        .onChange(of: scenePhase) { newValue in
            if newValue == .inactive {
                isPausePresented = true
                smartSetPause()
            }
        }
    }
    
    private func smartHomeExit() {
        isPresented.toggle()
    }
    
    private func smartGameResume() {
        smartScene.smartScenePaused = false
    }
    
    private func smartSetPause() {
        smartScene.smartScenePaused = true
    }
    
    private func smartRestart() {
        transitOpacity = 1.0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            smartScene = SmartGameScene()
            smartId = UUID()
            smartScene.setGame(view: self)
            earnedScore = 0
            lifesLeft = 3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                transitOpacity = 0.0
            }
        }
    }
    
    func updateLifes(_ lifes: Int) {
        lifesLeft = lifes
    }
    
    func updateScore(_ scores: Int) {
        earnedScore = scores
    }
    
    func setGameOverState() {
        isResultPresented = true
    }
}

#Preview {
    SmartGameView(.constant(true))
}
