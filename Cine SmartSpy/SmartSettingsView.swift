import SwiftUI
import StoreKit

struct SmartSettingsView: View {
    @Binding private var isPresented: Bool
    
    @State private var soundValue = SmartDefaults.isSoundOn
    @State private var vibroValue = SmartDefaults.isVibroOn
    
    init(_ isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            SmartBackgroundImageView(.smartDefBackground)
            Color(.black.withAlphaComponent(0.5)).ignoresSafeArea()
            
            VStack {
                HStack {
                    SmartButton(.smartBackButton) {
                        isPresented.toggle()
                    }
                    .frame(width: SmartScreen.width * 0.18)
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(spacing: SmartScreen.width * 0.07) {
                    SmartFitImageView(.smartSettingsTitle)
                        .frame(width: SmartScreen.width * 0.5)
                    
                    ZStack {
                        SmartFitImageView(.soundFrame)
                            .frame(width: SmartScreen.width * 0.8)
                        SmartButton(soundValue ? .onButton : .offButton) {
                            soundValue.toggle()
                            SmartDefaults.isSoundOn = soundValue
                        }
                        .frame(width: SmartScreen.width * 0.17)
                        .offset(x: SmartScreen.width * 0.24)
                    }
                    
                    ZStack {
                        SmartFitImageView(.vibroFrame)
                            .frame(width: SmartScreen.width * 0.8)
                        SmartButton(vibroValue ? .onButton : .offButton) {
                            vibroValue.toggle()
                            SmartDefaults.isVibroOn = vibroValue
                        }
                        .frame(width: SmartScreen.width * 0.17)
                        .offset(x: SmartScreen.width * 0.24)
                    }
                    
                    SmartButton(.rateButton) {
                        if let windowScene = UIApplication.shared.connectedScenes
                            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }
                    .frame(width: SmartScreen.width * 0.8)
                }
                
                Spacer()
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SmartSettingsView(.constant(true))
}
