//
//  MainMenuScene.swift
//  europa-diver
//
//  The screen shown before gameplay starts: title plus a plain, centered
//  New Game / Continue / Shop menu.
//

import SpriteKit

class MainMenuScene: SKScene {

    private let titleLabel = SKLabelNode(text: "Europa Diver")

    private let newGameButton = SKShapeNode(rectOf: CGSize(width: 220, height: 54), cornerRadius: 8)
    private let newGameLabel = SKLabelNode()
    private let continueButton = SKShapeNode(rectOf: CGSize(width: 220, height: 54), cornerRadius: 8)
    private let continueLabel = SKLabelNode()
    private let shopButton = SKShapeNode(rectOf: CGSize(width: 220, height: 54), cornerRadius: 8)
    private let shopLabel = SKLabelNode()

    private let newGameOverlay = NewGameOverlay()
    private var isNewGameOverlayOpen = false

    private let shopOverlay = ShopOverlay()
    private var isShopOpen = false

    private let pointsManager = PointsManager()
    private let upgradeStore = UpgradeStore()
    private let surveyLog = SurveyLog()

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.02, green: 0.08, blue: 0.18, alpha: 1.0)

        setUpTitle()
        setUpButtons()
        setUpNewGameOverlay()
        setUpShopOverlay()
        reposition()
    }

    private func setUpTitle() {
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 44
        titleLabel.fontColor = .white
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        addChild(titleLabel)
    }

    private func setUpButtons() {
        configureButton(newGameButton, label: newGameLabel, title: "New Game", name: "newGameButton")
        configureButton(continueButton, label: continueLabel, title: "Continue", name: "continueButton")
        configureButton(shopButton, label: shopLabel, title: "Shop", name: "shopButton")

        addChild(newGameButton)
        addChild(continueButton)
        addChild(shopButton)
    }

    private func configureButton(_ button: SKShapeNode, label: SKLabelNode, title: String, name: String) {
        button.name = name
        button.fillColor = SKColor.white.withAlphaComponent(0.12)
        button.strokeColor = .white
        button.lineWidth = 2

        label.text = title
        label.fontName = "Helvetica-Bold"
        label.fontSize = 20
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 1
        button.addChild(label)
    }

    private func setUpNewGameOverlay() {
        addChild(newGameOverlay)
    }

    private func setUpShopOverlay() {
        addChild(shopOverlay)
    }

    private func reposition() {
        let centerX = size.width / 2
        let centerY = size.height / 2
        let spacing: CGFloat = 70

        titleLabel.position = CGPoint(x: centerX, y: centerY + 150)

        newGameButton.position = CGPoint(x: centerX, y: centerY + spacing)
        continueButton.position = CGPoint(x: centerX, y: centerY)
        shopButton.position = CGPoint(x: centerX, y: centerY - spacing)

        newGameOverlay.position = CGPoint(x: centerX, y: centerY)
        newGameOverlay.resize(to: size)

        shopOverlay.position = CGPoint(x: centerX, y: centerY)
        shopOverlay.resize(to: size)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        reposition()
    }

    private func openShop() {
        shopOverlay.refresh(points: pointsManager.points, upgradeStore: upgradeStore)
        shopOverlay.show()
        isShopOpen = true
    }

    private func closeShop() {
        shopOverlay.hide()
        isShopOpen = false
    }

    private func purchase(_ upgrade: Upgrade) {
        guard let cost = upgradeStore.nextLevelCost(upgrade) else { return }
        guard pointsManager.spendPoints(cost) else { return }

        upgradeStore.levelUp(upgrade)
        shopOverlay.refresh(points: pointsManager.points, upgradeStore: upgradeStore)
    }

    private func openNewGameOverlay() {
        newGameOverlay.show()
        isNewGameOverlayOpen = true
    }

    private func confirmNewGame(skipTutorial: Bool) {
        newGameOverlay.hide()
        isNewGameOverlayOpen = false

        pointsManager.reset()
        upgradeStore.resetAll()
        surveyLog.resetAll()
        startGame(skipTutorial: skipTutorial, showAdvisorOnStart: true)
    }

    private func startGame(skipTutorial: Bool = false, showAdvisorOnStart: Bool = false) {
        guard let view else { return }

        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .resizeFill
        gameScene.skipTutorial = skipTutorial
        gameScene.showAdvisorOnStart = showAdvisorOnStart
        view.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)

        if isShopOpen {
            let pointInOverlay = shopOverlay.convert(point, from: self)
            if shopOverlay.hitTestClose(pointInOverlay) {
                closeShop()
            } else if let upgrade = shopOverlay.hitTestUpgrade(pointInOverlay) {
                purchase(upgrade)
            }
            return
        }

        if isNewGameOverlayOpen {
            let pointInOverlay = newGameOverlay.convert(point, from: self)
            let result = newGameOverlay.handleTouch(pointInOverlay)
            if result.startGame {
                confirmNewGame(skipTutorial: result.skipTutorial)
            } else if newGameOverlay.isHidden {
                isNewGameOverlayOpen = false
            }
            return
        }

        if newGameButton.contains(point) {
            openNewGameOverlay()
        } else if continueButton.contains(point) {
            startGame()
        } else if shopButton.contains(point) {
            openShop()
        }
    }
}
