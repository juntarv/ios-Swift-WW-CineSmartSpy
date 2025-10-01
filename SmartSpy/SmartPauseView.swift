import SwiftUI

struct SmartPauseView: View {
    @State private var appearOpacity = 0.0
    @Binding private var isPresented: Bool
    
    private let smartExitClosure: SmartClosure
        
    init(_ isPresented: Binding<Bool>, smartExitClosure: @escaping SmartClosure) {
        self._isPresented = isPresented
        self.smartExitClosure = smartExitClosure
    }
    
    var body: some View {
        ZStack {
            Color(.black.withAlphaComponent(0.5)).ignoresSafeArea()
            
            VStack(spacing: SmartScreen.width * 0.06) {
                SmartButton(.continueButton) {
                    smartExitWith(type: .resume)
                }
                .frame(width: SmartScreen.width * 0.7)
                
                SmartButton(.menuButton) {
                    smartExitWith(type: .menu)
                }
                .frame(width: SmartScreen.width * 0.7)
            }
        }
        .opacity(appearOpacity)
        .animation(.linear(duration: 0.4), value: appearOpacity)
        
        .onAppear() {
            appearOpacity = 1.0
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

enum SmartReturnType {
    case resume
    case menu
    case restart
}

typealias SmartClosure = (SmartReturnType)-> ()

#Preview {
    SmartPauseView(.constant(true)) { type in
        
    }
}
