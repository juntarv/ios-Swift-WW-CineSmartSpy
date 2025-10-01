import SwiftUI

struct SmartMenuView: View {
    @State private var initOpacity = 1.0
    
    @State private var isOnboardPresented = false
    @State private var isSettingsPresented = false
    @State private var isGamePresented = false
    @State private var isRewardsPresented = false
    @State private var isShopPresented = false
    
    var body: some View {
        ZStack {
            SmartBackgroundImageView(.smartDefBackground)
            
            VStack {
                HStack {
                    SmartButton(.smartInfoButton) {
                        isOnboardPresented.toggle()
                    }
                    .frame(width: SmartScreen.width * 0.18)
                    
                    Spacer()
                    
                    SmartButton(.smartSettingsButton) {
                        isSettingsPresented.toggle()
                    }
                    .frame(width: SmartScreen.width * 0.18)
                }
                
                Spacer()
                
                SmartFitImageView(.smartViewLogo)
                    .frame(width: SmartScreen.width * 0.6)
                
                Spacer()
                
                SmartButton(.smartPlayButton) {
                    isGamePresented.toggle()
                }
                .frame(width: SmartScreen.width * 0.7)
                
                SmartButton(.smartRewardsButton) {
                    isRewardsPresented.toggle()
                }
                .frame(width: SmartScreen.width * 0.7)
                
                SmartButton(.smartShopButton) {
                    isShopPresented.toggle()
                }
                .frame(width: SmartScreen.width * 0.7)
                
                Spacer()
            } .padding()
            
            SmartBackgroundImageView(.smartDefBackground)
                .opacity(initOpacity)
                .animation(.linear(duration: 0.5), value: initOpacity)
            
            if isOnboardPresented {
                SmartOnboardView($isOnboardPresented)
                    .transition(.move(edge: .leading))
                    .zIndex(1)
                    .id(UUID())
            }
            
            if isSettingsPresented {
                SmartSettingsView($isSettingsPresented)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                    .id(UUID())
            }
            
            if isShopPresented {
                SmartShopView($isShopPresented)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            }
            
            if isRewardsPresented {
                SmartRewardsView($isRewardsPresented)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                    .id(UUID())
            }
            
            if isGamePresented {
                SmartGameView($isGamePresented)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            }
        }
        
        .onAppear() {
            initOpacity = 0.0
            firstLaunchBoardShown()
        }
        
        .animation(.linear(duration: 0.25), value: isOnboardPresented)
        .animation(.linear(duration: 0.25), value: isSettingsPresented)
        .animation(.linear(duration: 0.25), value: isGamePresented)
        .animation(.linear(duration: 0.25), value: isRewardsPresented)
        .animation(.linear(duration: 0.25), value: isShopPresented)
    }
    
    private func firstLaunchBoardShown() {
        guard SmartDefaults.firstLaunch else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SmartDefaults.firstLaunch = false
            isOnboardPresented = true
        }
    }
}

#Preview {
    SmartMenuView()
}
