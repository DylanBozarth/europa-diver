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

    /// Radius of the tappable area around the continue arrow — deliberately
    /// much bigger than the glyph so it doesn't need a precise tap.
    private static let continueHitRadius: CGFloat = 34
    /// Built with real circle geometry (not a bare SKShapeNode) so the node
    /// has a frame of its own; a path-less shape node has a zero-sized frame
    /// and can't be hit-tested, even if it has visible children.
    private let continueButton: SKShapeNode

    private var boxWidth: CGFloat = 300
    private let boxHeight: CGFloat = 120

    override init() {
        continueButton = SKShapeNode(circleOfRadius: Self.continueHitRadius)

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

    /// `point` must be in this node's own coordinate space. Uses a plain
    /// distance check against the button's center rather than
    /// SKNode.contains(_:), so it can't depend on how SpriteKit happens to
    /// compute a shape node's bounding box.
    func hitTestContinue(_ point: CGPoint) -> Bool {
        guard !isHidden else { return false }
        let pointInBox = box.convert(point, from: self)
        let dx = pointInBox.x - continueButton.position.x
        let dy = pointInBox.y - continueButton.position.y
        return dx * dx + dy * dy <= Self.continueHitRadius * Self.continueHitRadius
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
