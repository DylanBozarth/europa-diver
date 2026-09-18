//
//  ShopOverlay.swift
//  europa-diver
//
//  Full-screen shop screen, reached from the Game Over screen.
//

import SpriteKit

class ShopOverlay: SKNode {

    private let background = SKShapeNode()
    private let titleLabel = SKLabelNode(text: "Shop")

    private let electricShockButton = SKShapeNode(rectOf: CGSize(width: 220, height: 60), cornerRadius: 10)
    private let electricShockNameLabel = SKLabelNode(text: "⚡ Electric Shock")
    private let electricShockStatusLabel = SKLabelNode()

    private let closeButton = SKShapeNode(rectOf: CGSize(width: 140, height: 50), cornerRadius: 10)
    private let closeLabel = SKLabelNode(text: "Close")

    override init() {
        super.init()
        zPosition = 300
        isHidden = true

        background.fillColor = SKColor.black.withAlphaComponent(0.9)
        background.strokeColor = .clear

        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: 80)
        titleLabel.zPosition = 1

        electricShockButton.name = "electricShockButton"
        electricShockButton.fillColor = SKColor.white.withAlphaComponent(0.15)
        electricShockButton.strokeColor = .white
        electricShockButton.lineWidth = 2
        electricShockButton.position = CGPoint(x: 0, y: 0)
        electricShockButton.zPosition = 1

        electricShockNameLabel.fontName = "Helvetica-Bold"
        electricShockNameLabel.fontSize = 18
        electricShockNameLabel.fontColor = .white
        electricShockNameLabel.verticalAlignmentMode = .center
        electricShockNameLabel.horizontalAlignmentMode = .center
        electricShockNameLabel.position = CGPoint(x: 0, y: 10)
        electricShockNameLabel.zPosition = 1

        electricShockStatusLabel.fontName = "Helvetica"
        electricShockStatusLabel.fontSize = 14
        electricShockStatusLabel.fontColor = SKColor.white.withAlphaComponent(0.7)
        electricShockStatusLabel.verticalAlignmentMode = .center
        electricShockStatusLabel.horizontalAlignmentMode = .center
        electricShockStatusLabel.position = CGPoint(x: 0, y: -12)
        electricShockStatusLabel.zPosition = 1

        electricShockButton.addChild(electricShockNameLabel)
        electricShockButton.addChild(electricShockStatusLabel)

        closeButton.name = "closeButton"
        closeButton.fillColor = SKColor.white.withAlphaComponent(0.15)
        closeButton.strokeColor = .white
        closeButton.lineWidth = 2
        closeButton.position = CGPoint(x: 0, y: -90)
        closeButton.zPosition = 1

        closeLabel.fontName = "Helvetica-Bold"
        closeLabel.fontSize = 20
        closeLabel.fontColor = .white
        closeLabel.verticalAlignmentMode = .center
        closeLabel.horizontalAlignmentMode = .center
        closeLabel.zPosition = 1
        closeButton.addChild(closeLabel)

        addChild(background)
        addChild(titleLabel)
        addChild(electricShockButton)
        addChild(closeButton)
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

    func updateElectricShock(owned: Bool, cost: Int) {
        if owned {
            electricShockStatusLabel.text = "Owned"
            electricShockButton.strokeColor = .green
        } else {
            electricShockStatusLabel.text = "\(cost) pts"
            electricShockButton.strokeColor = .white
        }
    }

    /// `point` must be in this node's own coordinate space.
    func hitTestClose(_ point: CGPoint) -> Bool {
        closeButton.contains(point)
    }

    /// `point` must be in this node's own coordinate space.
    func hitTestElectricShock(_ point: CGPoint) -> Bool {
        electricShockButton.contains(point)
    }
}
