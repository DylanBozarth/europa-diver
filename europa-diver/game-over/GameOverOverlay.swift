//
//  GameOverOverlay.swift
//  europa-diver
//
//  Full-screen "Game Over" cover with tappable retry and shop buttons, shown
//  when the submarine's durability reaches zero.
//

import SpriteKit

class GameOverOverlay: SKNode {

    private let background = SKShapeNode()
    private let titleLabel = SKLabelNode(text: "Game Over")
    private let retryButton = SKShapeNode(rectOf: CGSize(width: 140, height: 50), cornerRadius: 10)
    private let retryLabel = SKLabelNode(text: "Retry")
    private let shopButton = SKShapeNode(rectOf: CGSize(width: 140, height: 50), cornerRadius: 10)
    private let shopLabel = SKLabelNode(text: "Shop")

    override init() {
        super.init()
        zPosition = 300
        isHidden = true

        background.fillColor = SKColor.black.withAlphaComponent(0.85)
        background.strokeColor = .clear

        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: 60)
        titleLabel.zPosition = 1

        retryButton.name = "retryButton"
        retryButton.fillColor = SKColor.red.withAlphaComponent(0.8)
        retryButton.strokeColor = .white
        retryButton.lineWidth = 2
        retryButton.position = CGPoint(x: 0, y: -10)
        retryButton.zPosition = 1

        retryLabel.fontName = "Helvetica-Bold"
        retryLabel.fontSize = 20
        retryLabel.fontColor = .white
        retryLabel.verticalAlignmentMode = .center
        retryLabel.horizontalAlignmentMode = .center
        retryLabel.zPosition = 1
        retryButton.addChild(retryLabel)

        shopButton.name = "shopButton"
        shopButton.fillColor = SKColor.white.withAlphaComponent(0.15)
        shopButton.strokeColor = .white
        shopButton.lineWidth = 2
        shopButton.position = CGPoint(x: 0, y: -70)
        shopButton.zPosition = 1

        shopLabel.fontName = "Helvetica-Bold"
        shopLabel.fontSize = 20
        shopLabel.fontColor = .white
        shopLabel.verticalAlignmentMode = .center
        shopLabel.horizontalAlignmentMode = .center
        shopLabel.zPosition = 1
        shopButton.addChild(shopLabel)

        addChild(background)
        addChild(titleLabel)
        addChild(retryButton)
        addChild(shopButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resize(to size: CGSize) {
        background.path = CGPath(
            rect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height),
            transform: nil
        )
    }

    func show() { isHidden = false }
    func hide() { isHidden = true }

    /// `point` must be in this node's own coordinate space.
    func hitTestRetry(_ point: CGPoint) -> Bool {
        retryButton.contains(point)
    }

    /// `point` must be in this node's own coordinate space.
    func hitTestShop(_ point: CGPoint) -> Bool {
        shopButton.contains(point)
    }
}
