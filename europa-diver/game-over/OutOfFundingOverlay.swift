//
//  OutOfFundingOverlay.swift
//  europa-diver
//
//  Terminal game-over screen, shown instead of GameOverOverlay when the
//  player dies without enough points left to pay for a replacement drone.
//  There's no Retry or Shop here — the only way forward is starting over.
//

import SpriteKit

class OutOfFundingOverlay: SKNode {

    private let background = SKShapeNode()
    private let titleLabel = SKLabelNode(text: "Out of Funding")
    private let messageLabel = SKLabelNode()
    private let newGameButton = SKShapeNode(rectOf: CGSize(width: 200, height: 54), cornerRadius: 10)
    private let newGameLabel = SKLabelNode(text: "New Game")

    override init() {
        super.init()
        zPosition = 300
        isHidden = true

        background.fillColor = SKColor.black.withAlphaComponent(0.9)
        background.strokeColor = .clear

        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .white
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: 60)
        titleLabel.zPosition = 1

        messageLabel.text = "NASA has pulled the funding! Game over."
        messageLabel.fontName = "Helvetica"
        messageLabel.fontSize = 24
        messageLabel.fontColor = SKColor.white.withAlphaComponent(0.85)
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.preferredMaxLayoutWidth = 320
        messageLabel.verticalAlignmentMode = .center
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.zPosition = 1

        newGameButton.name = "newGameButton"
        newGameButton.fillColor = SKColor.red.withAlphaComponent(0.8)
        newGameButton.strokeColor = .white
        newGameButton.lineWidth = 2
        newGameButton.position = CGPoint(x: 0, y: -80)
        newGameButton.zPosition = 1

        newGameLabel.fontName = "Helvetica-Bold"
        newGameLabel.fontSize = 20
        newGameLabel.fontColor = .white
        newGameLabel.verticalAlignmentMode = .center
        newGameLabel.horizontalAlignmentMode = .center
        newGameLabel.zPosition = 1
        newGameButton.addChild(newGameLabel)

        addChild(background)
        addChild(titleLabel)
        addChild(messageLabel)
        addChild(newGameButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resize(to size: CGSize) {
        background.path = CGPath(
            rect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height),
            transform: nil
        )
        messageLabel.position = CGPoint(x: 0, y: 0)
    }

    func show() { isHidden = false }

    func hide() { isHidden = true }

    /// `point` must be in this node's own coordinate space.
    func hitTestNewGame(_ point: CGPoint) -> Bool {
        newGameButton.contains(point)
    }
}
