import SwiftUI

struct SmartRewardsView: View {
    @Binding private var isPresented: Bool
        
    init(_ isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            SmartBackgroundImageView(.sleepyAddBackground)
            
            ScrollView {
                ForEach(SmartRewardsEnum.allCases, id: \.self) { reward in
                    RewardCellView(reward)
                }
                .padding(.top, SmartScreen.width * 0.23)
                .padding(.bottom, SmartScreen.width * 0.05)
            }
            .scrollIndicators(.hidden)

            VStack {
                HStack {
                    SmartButton(.smartBackButton) {
                        isPresented.toggle()
                    }
                    .frame(width: SmartScreen.width * 0.18)
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct RewardCellView: View {
    private let reward: SmartRewardsEnum
    
    init(_ reward: SmartRewardsEnum) {
        self.reward = reward
    }
    
    var body: some View {
        ZStack {
            HStack {
                SmartFitImageView(SmartDefaults.openedRewards.contains(reward.rawValue) ? reward.image : .closedReward)
                    .frame(width: SmartScreen.width * 0.2)
                Spacer()
            }.padding()

            HStack {
                Text(reward.description)
                    .font(.system(size: SmartScreen.width * 0.05))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, SmartScreen.width * 0.27)
            }
            
            Spacer()

        }
    }
}

enum SmartRewardsEnum: Int, CaseIterable {
    case smartRewardOne
    case smartRewardTwo
    case smartRewardThree
    case smartRewardFour
    case smartRewardFive
    case smartRewardSix
    case smartRewardSeven
    
    var image: UIImage {
        switch self {
            case .smartRewardOne:
                    .firstReward
            case .smartRewardFour, .smartRewardTwo:
                    .secondReward
            default: .thirdReward
        }
    }
    
    var description: String {
        switch self {
            case .smartRewardOne:
                "Complete the onboarding process."
            case .smartRewardTwo:
                "Purchase your first skin."
            case .smartRewardThree:
                "Catch your first rooster."
            case .smartRewardFour:
                "Catch a rooster in less than 1 second."
            case .smartRewardFive:
                "Purchase all skins."
            case .smartRewardSix:
                "Do not catch any roosters for an entire round."
            case .smartRewardSeven:
                "Collect all achievements."
        }
    }
}

#Preview {
    SmartRewardsView(.constant(true))
}
