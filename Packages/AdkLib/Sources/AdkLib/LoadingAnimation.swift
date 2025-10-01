import SwiftUI

public struct LoadingAnimation: View {
    @State private var loadingProgress: Double = 0.0
    @State private var loadingText: String = "LOADING..."
    @State private var isAnimating: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background image
            Image("bg_mainChickopiaEvo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                
                Spacer()
            
                Image("logo_gameChickopiaEvo")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 40)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                Spacer()
                
                SpinnerView()
                    .frame(width: 80, height: 80)
                
                Image("loading_textChickopiaEvo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .opacity(isAnimating ? 0.3 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            }
        }
        .onAppear {
            startLoadingAnimation()
        }
    }
    
    private func startLoadingAnimation() {
        isAnimating = true
        
        let randomDuration = Double.random(in: 3.0...6.0)
        let steps = 100
        let stepDuration = randomDuration / Double(steps)
        
        for step in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    loadingProgress = Double(step) / Double(steps)
                }
                
                if step < 30 {
                    loadingText = "LOADING ASSETS..."
                } else if step < 60 {
                    loadingText = "PREPARING GAME..."
                } else if step < 90 {
                    loadingText = "FINALIZING..."
                } else {
                    loadingText = "READY!"
                }
            }
        }
    }
}

public struct SpinnerView: View {
    @State private var isSpinning = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                Capsule()
                    .fill(i % 3 == 0 ? Color.yellow : Color.white.opacity(0.8))
                    .frame(width: 6, height: 18)
                    .offset(y: -30)
                    .rotationEffect(.degrees(Double(i) / 12 * 360))
            }
        }
        .rotationEffect(.degrees(isSpinning ? 360 : 0))
        .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: isSpinning)
        .onAppear { isSpinning = true }
    }
}