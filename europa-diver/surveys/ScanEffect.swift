//
//  ScanEffect.swift
//  europa-diver
//
//  A brief blue pulse of light, spawned in front of the submarine when a
//  new fish species is scanned.
//

import SpriteKit

enum ScanEffect {
    static func spawn(at position: CGPoint, in parent: SKNode) {
        let light = SKShapeNode(circleOfRadius: 6)
        light.position = position
        light.fillColor = SKColor.cyan.withAlphaComponent(0.8)
        light.strokeColor = .cyan
        light.lineWidth = 2
        light.zPosition = 11
        light.alpha = 0.9
        parent.addChild(light)

        let expand = SKAction.scale(to: 8, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        light.run(SKAction.sequence([
            SKAction.group([expand, fadeOut]),
            SKAction.removeFromParent()
        ]))
    }
}
