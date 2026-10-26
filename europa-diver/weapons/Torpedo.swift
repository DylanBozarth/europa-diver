//
//  Torpedo.swift
//  europa-diver
//
//  A slow projectile fired from the front of the submarine. Just a plain
//  white dot visually — on contact (see GameScene.handleTorpedoContact) it
//  kills small fish outright, scares snakes into fleeing for a while, and
//  shoves a floating ice chunk aside (tunnel-wall obstacles aren't affected).
//

import SpriteKit

enum Torpedo {
    private static let travelDistance: CGFloat = 700
    private static let visualRadius: CGFloat = 4
    /// The torpedo only ever travels in a dead-straight horizontal line, so
    /// a hitbox matching the tiny visual dot would need near-pixel-perfect
    /// vertical alignment with a small fish's roam position to ever land a
    /// hit. This is deliberately more generous than the dot looks.
    private static let hitRadius: CGFloat = 28

    static func fire(from position: CGPoint, direction: CGFloat, speed: CGFloat, in parent: SKNode) {
        let dot = SKShapeNode(circleOfRadius: visualRadius)
        dot.name = "torpedo"
        dot.position = position
        dot.fillColor = .white
        dot.strokeColor = .white
        dot.zPosition = 9

        let body = SKPhysicsBody(circleOfRadius: hitRadius)
        body.affectedByGravity = false
        body.allowsRotation = false
        // No damping: a dynamic body driven purely by actions (no velocity)
        // can fall asleep and stop generating contacts at all, so movement
        // is velocity-based like every other moving thing in this game —
        // damping would otherwise slowly bleed off that velocity.
        body.linearDamping = 0
        body.categoryBitMask = PhysicsCategory.torpedo
        body.collisionBitMask = PhysicsCategory.none
        body.contactTestBitMask = PhysicsCategory.smallFish | PhysicsCategory.hostileFish | PhysicsCategory.snake | PhysicsCategory.smallSnake | PhysicsCategory.obstacle
        body.velocity = CGVector(dx: direction * speed, dy: 0)
        dot.physicsBody = body

        parent.addChild(dot)

        let lifetime = TimeInterval(travelDistance / speed)
        dot.run(SKAction.sequence([SKAction.wait(forDuration: lifetime), SKAction.removeFromParent()]))
    }
}
