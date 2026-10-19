//
//  PointsHUD.swift
//  europa-diver
//
//  Top-right points display, driven by PointsManager, with the current
//  depth (level number) underneath so the player can see the descent.
//

import SpriteKit

class PointsHUD: SKNode {
    private let label = SKLabelNode()
    private let depthLabel = SKLabelNode()

    override init() {
        super.init()
        zPosition = 100

        label.fontName = "Helvetica-Bold"
        label.fontSize = 16
        label.fontColor = .white
        label.horizontalAlignmentMode = .right
        label.verticalAlignmentMode = .top
        label.zPosition = 1

        depthLabel.fontName = "Helvetica"
        depthLabel.fontSize = 13
        depthLabel.fontColor = SKColor.white.withAlphaComponent(0.8)
        depthLabel.horizontalAlignmentMode = .right
        depthLabel.verticalAlignmentMode = .top
        depthLabel.position = CGPoint(x: 0, y: -22)
        depthLabel.zPosition = 1

        addChild(label)
        addChild(depthLabel)
        update(points: 0, depth: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(points: Int, depth: Int) {
        label.text = "Points: \(points)"
        depthLabel.text = "Depth \(depth) km"
    }
}
