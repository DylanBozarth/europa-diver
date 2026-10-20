//
//  SpeedTrailEffect.swift
//  europa-diver
//
//  A streak of water spawned behind the submarine, repeatedly, while Speed
//  Thrust is active — GameScene calls `spawn` on a timer rather than every
//  frame, so the trail reads as a wake rather than a solid blur.
//

import SpriteKit

enum SpeedTrailEffect {
    static func spawn(at position: CGPoint, facing: CGFloat, in parent: SKNode) {
        let streak = SKShapeNode(ellipseOf: CGSize(width: 16, height: 6))
        streak.position = position
        streak.fillColor = SKColor.white.withAlphaComponent(0.55)
        streak.strokeColor = .clear
        streak.zPosition = 4 // behind the player (10) and fish (5)
        parent.addChild(streak)

        let drift = SKAction.moveBy(x: -facing * 36, y: CGFloat.random(in: -5...5), duration: 0.45)
        let shrink = SKAction.scale(to: 0.2, duration: 0.45)
        let fade = SKAction.fadeOut(withDuration: 0.45)
        streak.run(SKAction.sequence([
            SKAction.group([drift, shrink, fade]),
            SKAction.removeFromParent()
        ]))
    }
}
