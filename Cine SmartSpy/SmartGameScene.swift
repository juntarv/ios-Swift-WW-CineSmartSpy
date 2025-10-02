import SpriteKit

final class SmartGameScene: SKScene {
    private var gameView: SmartGameView?
    
    private let smartBackNode = SmartBackNode()
    
    private var lifesCount = 3 { didSet { setupLifes() }}
    private var mainDuration = 6.0
    private var earnedScores = 0 { didSet { setupEarnedScore() }}
    private var isGameEnded = false
    
    private let smartFinalSound = SKAction.playSoundFileNamed("smartFinalSound", waitForCompletion: false)
    private let smartMainSound = SKAction.playSoundFileNamed("smartMainSound", waitForCompletion: false)
    private let smartPersonCollectSound = SKAction.playSoundFileNamed("smartPersonCollectSound", waitForCompletion: false)
    
    var smartScenePaused: Bool = false {
        didSet {
            self.isPaused = smartScenePaused
        }
    }
    
    override var isPaused: Bool {
        didSet {
            if self.isPaused != self.smartScenePaused {
                self.isPaused = self.smartScenePaused
            }
        }
    }
    
    override init() {
        super.init(size: SmartScreen.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupSmartScene()
    }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        startSpawnAction()
        startSpawnMainPerson()
    }
    
    private func setupEarnedScore() {
        gameView?.updateScore(earnedScores)
    }
    
    private func setupLifes() {
        gameView?.updateLifes(lifesCount)
        if lifesCount == 0 {
            setGameOverState()
        }
    }
    
    private func setGameOverState() {
        guard !isGameEnded else { return }
        isGameEnded = true
        gameView?.setGameOverState()
        if earnedScores == 0 {
            SmartDefaults.append(reward: .smartRewardSix)
        }
        if SmartDefaults.isSoundOn {
            run(smartFinalSound)
        }
    }
    
    func setGame(view: SmartGameView) {
        self.gameView = view
    }
    
    private func setupSmartScene() {
        addChild(smartBackNode)
        
        smartBackNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    private func startSpawnMainPerson() {
        let action = SKAction.run { [weak self] in
            guard let self else { return }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let leftPosition = self.frame.minX - SmartScreen.width * 0.2
                let rightPosition = self.frame.maxX + SmartScreen.width * 0.2
                let randomYStart = CGFloat.random(in: self.frame.maxY * 0.1...self.frame.maxY * 0.65)
                let randomYFinish = CGFloat.random(in: self.frame.maxY * 0.1...self.frame.maxY * 0.65)

                let mainPerson = SmartMainPerson()
                
                self.mainDuration -= 0.2
                if self.mainDuration < 2 {
                    self.mainDuration = 2
                }
                
                if mainPerson.isLeft {
                    mainPerson.position = CGPoint(x: leftPosition, y: randomYStart)
                    
                    DispatchQueue.main.async {
                        self.addChild(mainPerson)
                        mainPerson.run(.move(to: CGPoint(x: rightPosition, y: randomYFinish), duration: self.mainDuration)) {
                            mainPerson.removeFromParent()
                            self.lifesCount -= 1
                        }
                    }
                } else {
                    mainPerson.position = CGPoint(x: rightPosition, y: randomYStart)
                    DispatchQueue.main.async {
                        self.addChild(mainPerson)
                        mainPerson.run(.move(to: CGPoint(x: leftPosition, y: randomYFinish), duration: self.mainDuration)) {
                            mainPerson.removeFromParent()
                            self.lifesCount -= 1
                        }
                    }
                }
            }
        }
        
        run(.repeatForever(.sequence([.wait(forDuration: 3), action])))
    }
    
    private func startSpawnAction() {
        let action = SKAction.run { [weak self] in
            guard let self else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                let leftPosition = self.frame.minX - SmartScreen.width * 0.2
                let rightPosition = self.frame.maxX + SmartScreen.width * 0.2
                
                for i in 0...6 {
                    let person = SmartDefPerson()
                    let randomYStart = CGFloat.random(in: self.frame.maxY * 0.1...self.frame.maxY * 0.65)
                    let randomYFinish = CGFloat.random(in: self.frame.maxY * 0.1...self.frame.maxY * 0.65)
                    
                    if person.isLeft {
                        person.position = CGPoint(x: leftPosition, y: randomYStart)
                        DispatchQueue.main.async {
                            self.addChild(person)
                            person.run(.move(to: CGPoint(x: rightPosition, y: randomYFinish), duration: 10 + Double(i) * 0.5)) {
                                person.removeFromParent()
                            }
                        }
                    } else {
                        person.position = CGPoint(x: rightPosition, y: randomYStart)
                        DispatchQueue.main.async {
                            self.addChild(person)
                            person.run(.move(to: CGPoint(x: leftPosition, y: randomYFinish), duration: 10 + Double(i) * 0.5)) {
                                person.removeFromParent()
                            }
                        }
                    }
                }
            }
        }
        run(.repeatForever(.sequence([.wait(forDuration: 1), action])))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        if let touchedDefPerson = nodes(at: location).compactMap({ $0 as? SmartDefPerson }).first {
            touchedDefPerson.collect()
            if SmartDefaults.isSoundOn {
                run(smartPersonCollectSound)
            }
        }
        
        if let touchedMainPerson = nodes(at: location).compactMap({ $0 as? SmartMainPerson }).first {
            touchedMainPerson.collect { [weak self] in
                guard let self else { return }
                self.earnedScores += 1
                SmartDefaults.append(reward: .smartRewardThree)
                SmartDefaults.append(reward: .smartRewardFour)

                if SmartDefaults.isSoundOn {
                    run(smartMainSound)
                }
            }
        }
    }
}

final class SmartBackNode: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let texture = SKTexture(image: .smartSceneBack)
        let size = texture.size(width: SmartScreen.width)
        super.init(texture: texture, color: .clear, size: size)
        zPosition = -1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class SmartMainPerson: SKSpriteNode {
    private(set) var isLeft: Bool
    private var isNotCollected = true

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        isLeft = Bool.random()
        let selectedModel = SmartModelsEnum(rawValue: SmartDefaults.selectedModel) ?? .modelOne
        let texture = SKTexture(image: selectedModel.image)
        let size = texture.size(width: SmartScreen.width * 0.2)
        super.init(texture: texture, color: .clear, size: size)
        setupPerson()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPerson() {
        xScale = isLeft ? 1 : -1
        
        let upAction = SKAction.move(by: CGVector(dx: 0, dy: SmartScreen.height * 0.01), duration: 0.2)
        let dawnAction = SKAction.move(by: CGVector(dx: 0, dy: -SmartScreen.height * 0.005), duration: 0.2)
        let sequence = SKAction.sequence([upAction, dawnAction])
        run(SKAction.repeatForever(sequence))
    }
    
    func collect(handler: @escaping () -> ()) {
        guard isNotCollected else { return }
        isNotCollected = false
        removeAllActions()
        handler()
        run(.scale(to: 0.0, duration: 0.15)) { [weak self] in
            self?.removeFromParent()
        }
    }
}

final class SmartDefPerson: SKSpriteNode {
    private(set) var isLeft: Bool
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        isLeft = Bool.random()
        let texture = SKTexture(image: .defPerson)
        let size = texture.size(width: SmartScreen.width * 0.2)
        super.init(texture: texture, color: .clear, size: size)
        zPosition = 1
        setupPerson()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPerson() {
        xScale = isLeft ? -1 : 1
        
        let upAction = SKAction.move(by: CGVector(dx: 0, dy: SmartScreen.height * 0.01), duration: 0.2)
        let dawnAction = SKAction.move(by: CGVector(dx: 0, dy: -SmartScreen.height * 0.005), duration: 0.2)
        let sequence = SKAction.sequence([upAction, dawnAction])
        run(SKAction.repeatForever(sequence))
    }
    
    func collect() {
        removeAllActions()
        
        run(.scale(to: 0.0, duration: 0.15)) { [weak self] in
            self?.removeFromParent()
        }
    }
}

extension SKTexture {
    func size(width: CGFloat) -> CGSize {
        let ratio = size().height / size().width
        let newHeight = width * ratio
        return CGSize(width: width, height: newHeight)
    }
}

import SwiftUI

#Preview {
    SmartGameView(.constant(true))
}

