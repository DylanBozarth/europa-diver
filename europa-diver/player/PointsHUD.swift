//
//  PointsHUD.swift
//  europa-diver
//
//  Top-right points display, driven by PointsManager.
//

import SpriteKit

class PointsHUD: SKNode {
    private let label = SKLabelNode()

    override init() {
        super.init()
        zPosition = 100

        label.fontName = "Helvetica-Bold"
        label.fontSize = 16
        label.fontColor = .white
        label.horizontalAlignmentMode = .right
        label.verticalAlignmentMode = .top
        label.zPosition = 1

        addChild(label)
        update(points: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(points: Int) {
        label.text = "Points: \(points)"
    }
}
