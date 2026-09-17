//
//  HUDButton.swift
//  europa-diver
//
//  A simple round HUD button (icon on a translucent circle). Visual only —
//  no tap handling or behavior wired up yet.
//

import SpriteKit

class HUDButton: SKNode {

    init(icon: String, diameter: CGFloat = 50) {
        super.init()
        zPosition = 100

        let background = SKShapeNode(circleOfRadius: diameter / 2)
        background.fillColor = SKColor.white.withAlphaComponent(0.15)
        background.strokeColor = SKColor.white.withAlphaComponent(0.4)
        background.lineWidth = 2

        let label = SKLabelNode(text: icon)
        label.fontSize = diameter * 0.5
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 1

        addChild(background)
        addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
