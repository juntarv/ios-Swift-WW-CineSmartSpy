import SwiftUI

struct SmartShopView: View {
    @Binding private var isPresented: Bool
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    @EnvironmentObject private var globalManager: SmartGlobalManager
    @State private var showAlert = false
    
    init(_ isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            SmartBackgroundImageView(.sleepyAddBackground)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: SmartScreen.width * 0.05) {
                    ForEach(SmartModelsEnum.allCases, id: \.self) { model in
                        SmartShopCell(model) {
                            showAlert = true
                        }
                    }
                }
                .padding(.top, SmartScreen.width * 0.26)
                .padding(.horizontal, SmartScreen.width * 0.04)
                .padding(.bottom, SmartScreen.width * 0.04)
            }
            
            
            VStack {
                HStack {
                    SmartButton(.smartBackButton) {
                        isPresented.toggle()
                    }
                    .frame(width: SmartScreen.width * 0.18)
                    
                    Spacer()
                    
                    ZStack {
                        SmartFitImageView(.balanceFrame)
                            .frame(width: SmartScreen.width * 0.45)
                        Text("\(globalManager.balance)")
                            .foregroundStyle(Color.yellow)
                            .font(.system(size: SmartScreen.width * 0.08, weight: .bold, design: .monospaced))
                            .offset(x: SmartScreen.width * 0.07)
                    }
                }
                Spacer()
            }
            .padding()
        }
        
        .alert("Oops! You need more coins to get this skin.", isPresented: $showAlert) {
            Button("Ok", role: .cancel) {}
        }
    }
}

struct SmartShopCell: View {
    @EnvironmentObject private var globalManager: SmartGlobalManager
    private let smartModel: SmartModelsEnum
    
    @State private var stateImage: UIImage = .buyCell
    private let alertClosure: () -> ()
    
    init(_ smartModel: SmartModelsEnum, alertClosure: @escaping () -> ()) {
        self.alertClosure = alertClosure
        self.smartModel = smartModel
    }

    var body: some View {
        ZStack {
            SmartFitImageView(stateImage)
                .frame(width: SmartScreen.width * 0.4)
            
            SmartFitImageView(smartModel.image)
                .frame(height: SmartScreen.width * 0.25)
                .offset(y: -SmartScreen.width * 0.12)
        }
        
        .onTapGesture {
            smartTapAction()
        }
        
        .onReceive(globalManager.$selectedModel) { _ in
            setupState()
        }
    }
    
    private func setupState() {
        if globalManager.buyedModels.contains(smartModel.rawValue) {
            if globalManager.selectedModel == smartModel.rawValue {
                stateImage = .selectedCell
            } else {
                stateImage = .selectCell
            }
        } else {
            stateImage = .buyCell
        }
    }
    
    private func smartTapAction() {
        if globalManager.buyedModels.contains(smartModel.rawValue) {
            globalManager.selectedModel = smartModel.rawValue
            SmartDefaults.selectedModel = smartModel.rawValue
        } else {
            guard globalManager.balance >= 25 else { return alertClosure() }
            globalManager.balance -= 25
            SmartDefaults.balance -= 25
            SmartDefaults.append(reward: .smartRewardTwo)
            globalManager.buyedModels.append(smartModel.rawValue)
            SmartDefaults.buyedModels.append(smartModel.rawValue)
            
            globalManager.selectedModel = smartModel.rawValue
            SmartDefaults.selectedModel = smartModel.rawValue
        }
    }
}

enum SmartModelsEnum: Int, CaseIterable {
    case modelOne
    case modelTwo
    case modelThree
    case modelFour
    case modelFive
    case modelSix
    
    var image: UIImage {
        switch self {
            case .modelOne:
                    .sleepyModelOne
            case .modelTwo:
                    .sleepyModelTwo
            case .modelThree:
                    .sleepyModelThree
            case .modelFour:
                    .sleepyModelFour
            case .modelFive:
                    .sleepyModelFive
            case .modelSix:
                    .sleepyModelSix
        }
    }
}

#Preview {
    SmartShopView(.constant(true))
        .environmentObject(SmartGlobalManager())
}
