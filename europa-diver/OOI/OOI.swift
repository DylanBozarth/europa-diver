//
//  OOI.swift
//  europa-diver
//
//  Object of interest — a collectible the submarine can collide with.
//

import SpriteKit

class OOI: SKShapeNode {

    init(radius: CGFloat = 14) {
        super.init()
        name = "ooi"

        path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        fillColor = .cyan
        strokeColor = .white
        lineWidth = 2
        zPosition = 6

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.affectedByGravity = false
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.ooi
        body.collisionBitMask = PhysicsCategory.none
        physicsBody = body

        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.6),
            SKAction.fadeAlpha(to: 1.0, duration: 0.6)
        ])))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
