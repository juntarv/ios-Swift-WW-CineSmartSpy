import SwiftUI

struct SmartResultView: View {
    @State private var appearOpacity = 0.0
    @Binding private var isPresented: Bool
    
    private let smartExitClosure: SmartClosure
    @EnvironmentObject private var globalManager: SmartGlobalManager
    
    private let earnedScore: Int
        
    init(_ isPresented: Binding<Bool>, earnedScore: Int, smartExitClosure: @escaping SmartClosure) {
        self._isPresented = isPresented
        self.smartExitClosure = smartExitClosure
        self.earnedScore = earnedScore
    }
    
    var body: some View {
        ZStack {
            Color(.black.withAlphaComponent(0.5)).ignoresSafeArea()
            
            SmartFitImageView(.smartFinalFrame)
                .frame(width: SmartScreen.width * 0.8)
            
            HStack(spacing: SmartScreen.width * 0.2) {
                Text("\(earnedScore)")
                    .font(.system(size: SmartScreen.width * 0.06, weight: .bold, design: .default))
                    .foregroundStyle(.yellow)
                
                Text("\(earnedScore)")
                    .font(.system(size: SmartScreen.width * 0.06, weight: .bold, design: .default))
                    .foregroundStyle(.yellow)
            }
            .offset(y: -SmartScreen.width * 0.107)
            .offset(x: SmartScreen.width * 0.02)
            
            VStack {
                SmartButton(.restartButton) {
                    smartExitWith(type: .restart)
                }
                .frame(width: SmartScreen.width * 0.5)
                
                SmartButton(.menuButton) {
                    smartExitWith(type: .menu)
                }
                .frame(width: SmartScreen.width * 0.5)
            }
            .offset(y: SmartScreen.width * 0.25)
        }
        .opacity(appearOpacity)
        .animation(.linear(duration: 0.4), value: appearOpacity)
        
        .onAppear() {
            appearOpacity = 1.0
            globalManager.balance += earnedScore
            SmartDefaults.balance += earnedScore
        }
    }
    
    private func smartExitWith(type: SmartReturnType) {
        appearOpacity = 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isPresented = false
            smartExitClosure(type)
        }
    }
}

#Preview {
    SmartResultView(.constant(true), earnedScore: 11) { _ in
        
    }
    .environmentObject(SmartGlobalManager())
}
