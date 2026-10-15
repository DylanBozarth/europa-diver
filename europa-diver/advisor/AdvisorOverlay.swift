//
//  AdvisorOverlay.swift
//  europa-diver
//
//  A dialogue-style text box that delivers a message, dismissed with a
//  green "continue" arrow. Gameplay is dimmed but still visible behind it,
//  unlike the full-screen menus (Shop, Game Over, etc). See
//  GameScene.showAdvisorMessage for how this pauses the player, fish, and
//  snakes while shown.
//

import SpriteKit

class AdvisorOverlay: SKNode {

    private let dimBackground = SKShapeNode()
    private let box = SKShapeNode()
    private let messageLabel = SKLabelNode()
    private let continueButton = SKShapeNode()

    private var boxWidth: CGFloat = 300
    private let boxHeight: CGFloat = 120

    override init() {
        super.init()
        zPosition = 400
        isHidden = true

        dimBackground.fillColor = SKColor.black.withAlphaComponent(0.55)
        dimBackground.strokeColor = .clear

        box.fillColor = SKColor(red: 0.05, green: 0.1, blue: 0.2, alpha: 0.97)
        box.strokeColor = .white
        box.lineWidth = 2
        box.zPosition = 1

        messageLabel.fontName = "Helvetica"
        messageLabel.fontSize = 18
        messageLabel.fontColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.horizontalAlignmentMode = .left
        messageLabel.verticalAlignmentMode = .center
        messageLabel.zPosition = 1

        continueButton.name = "advisorContinue"
        continueButton.fillColor = .clear
        continueButton.strokeColor = .clear
        continueButton.zPosition = 1

        let arrowNode = SKShapeNode(path: AdvisorOverlay.arrowPath(size: 26))
        arrowNode.fillColor = SKColor(red: 0.2, green: 0.85, blue: 0.3, alpha: 1.0)
        arrowNode.strokeColor = .clear
        continueButton.addChild(arrowNode)

        // Generous invisible hit area, bigger than the arrow glyph itself
        // so it's easy to tap without needing pixel-perfect precision.
        let hitArea = SKShapeNode(circleOfRadius: 26)
        hitArea.fillColor = .clear
        hitArea.strokeColor = .clear
        continueButton.addChild(hitArea)

        addChild(dimBackground)
        addChild(box)
        box.addChild(messageLabel)
        box.addChild(continueButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resize(to size: CGSize) {
        dimBackground.path = CGPath(
            rect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height),
            transform: nil
        )

        boxWidth = min(size.width - 80, 520)
        box.path = CGPath(
            roundedRect: CGRect(x: -boxWidth / 2, y: -boxHeight / 2, width: boxWidth, height: boxHeight),
            cornerWidth: 14,
            cornerHeight: 14,
            transform: nil
        )
        box.position = CGPoint(x: 0, y: -size.height / 2 + boxHeight / 2 + 40)

        messageLabel.preferredMaxLayoutWidth = boxWidth - 90
        messageLabel.position = CGPoint(x: -boxWidth / 2 + 24, y: 0)

        continueButton.position = CGPoint(x: boxWidth / 2 - 36, y: 0)
    }

    func show(message: String) {
        messageLabel.text = message
        isHidden = false
    }

    func hide() {
        isHidden = true
    }

    /// `point` must be in this node's own coordinate space.
    func hitTestContinue(_ point: CGPoint) -> Bool {
        let pointInBox = box.convert(point, from: self)
        return continueButton.contains(pointInBox)
    }

    private static func arrowPath(size: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -size * 0.4, y: size * 0.5))
        path.addLine(to: CGPoint(x: size * 0.5, y: 0))
        path.addLine(to: CGPoint(x: -size * 0.4, y: -size * 0.5))
        path.closeSubpath()
        return path
    }
}
