//
//  AutoRepairEffect.swift
//  europa-diver
//
//  A wrench that pops up over the submarine and fades out when Auto Repair
//  is used.
//

import SpriteKit

enum AutoRepairEffect {
    static func spawn(at position: CGPoint, in parent: SKNode) {
        let wrench = SKLabelNode(text: "🔧")
        wrench.fontSize = 26
        wrench.verticalAlignmentMode = .center
        wrench.horizontalAlignmentMode = .center
        wrench.position = position
        wrench.zPosition = 11
        wrench.alpha = 0
        parent.addChild(wrench)

        wrench.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.group([
                SKAction.moveBy(x: 0, y: 22, duration: 0.7),
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.25),
                    SKAction.fadeOut(withDuration: 0.45)
                ])
            ]),
            SKAction.removeFromParent()
        ]))
    }
}
