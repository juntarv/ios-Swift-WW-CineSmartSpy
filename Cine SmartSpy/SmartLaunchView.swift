import SwiftUI

struct SmartLaunchView: View {
    @State private var smartLogoScale = 1.0
    @State private var smartLogoAlpha = 1.0
    
    @State private var isMenuPresented = false
    
    var body: some View {
        ZStack {
            SmartBackgroundImageView(.smartDefBackground)
            
            SmartFitImageView(.smartViewLogo)
                .frame(width: SmartScreen.width * 0.5)
                .scaleEffect(smartLogoScale)
                .opacity(smartLogoAlpha)
                .animation(.bouncy(duration: 0.5).repeatForever(), value: smartLogoScale)
                .animation(.linear(duration: 0.4), value: smartLogoAlpha)
            
                .onAppear() {
                    smartLogoScale = 1.2
                    
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                        prepareSmartView {
                            isMenuPresented = true
                        }
                    }
                }
            
            if isMenuPresented {
                SmartMenuView()
            }
        }
    }
    
    private func prepareSmartView(_ completion: @escaping () -> ()) {
        smartLogoAlpha = 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion()
        }
    }
}

#Preview {
    SmartLaunchView()
}
