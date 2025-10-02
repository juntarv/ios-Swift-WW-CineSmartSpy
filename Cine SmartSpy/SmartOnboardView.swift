import SwiftUI

struct SmartOnboardView: View {
    @Binding private var isPresented: Bool
    
    @State private var currentPage: UIImage = .onboardOne
    @State private var firstMode = true
    
    init(_ isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    
    var body: some View {
        ZStack {
            SmartBackgroundImageView(.smartDefBackground)
            Color(.black.withAlphaComponent(0.5)).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack {
                    SmartButton(.smartSkipButton) {
                        isPresented.toggle()
                    }
                    .frame(width: SmartScreen.width * 0.18)
                    
                    Spacer()
                    
                    SmartButton(.smartNextButton) {
                        nextAction()
                    }
                    .frame(width: SmartScreen.width * 0.18)
                }
            }
            .padding()
            .opacity(firstMode ? 1.0 : 0.0)
            
            VStack {
                Spacer()
                
                SmartButton(.smartStartButton) {
                    nextAction()
                }
                .frame(width: SmartScreen.width * 0.75)
            }
            .padding()
            .opacity(firstMode ? 0.0 : 1.0)
            
            SmartFitImageView(currentPage)
                .frame(width: SmartScreen.width * 0.75)
                .offset(y: -SmartScreen.width * 0.1)
        }
    }
    
    private func nextAction() {
        if currentPage == .onboardOne {
            currentPage = .onboardTwo
        } else if currentPage == .onboardTwo {
            currentPage = .onboardThree
            firstMode = false
        } else {
            isPresented.toggle()
        }
    }
}

#Preview {
    SmartOnboardView(.constant(true))
}
