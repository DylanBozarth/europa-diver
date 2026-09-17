//
//  LevelEntrance.swift
//  europa-diver
//
//  A yellow square marking the way into the next generated level. Colliding
//  with it (see GameScene.didBegin(_:)) regenerates the map.
//

import SpriteKit

class LevelEntrance: SKShapeNode {

    init(size: CGFloat = 30) {
        super.init()
        name = "levelEntrance"

        path = CGPath(rect: CGRect(x: -size / 2, y: -size / 2, width: size, height: size), transform: nil)
        fillColor = .yellow
        strokeColor = .white
        lineWidth = 2
        zPosition = 6

        let body = SKPhysicsBody(rectangleOf: CGSize(width: size, height: size))
        body.affectedByGravity = false
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.levelEntrance
        body.collisionBitMask = PhysicsCategory.none
        physicsBody = body
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
