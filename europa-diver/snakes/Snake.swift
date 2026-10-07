//
//  Snake.swift
//  europa-diver
//
//  A large, hostile enemy that cannot be damaged by the shock ability or
//  anything else — the only valid response to one is avoidance. Moves at
//  half the submarine's speed and steers with no obstacle-avoidance smarts
//  at all, so it relies on raw physics collision to "deal with" obstacles,
//  which is what gives it its awkward, get-stuck-in-corners movement.
//

import SpriteKit

class Snake: SKSpriteNode {

    private let swimSpeed: CGFloat = 80 // half of the submarine's 160 moveSpeed
    private var swimDirection = CGVector(dx: 0, dy: 0)
    private var timeUntilNextTurn: TimeInterval = 0

    init(size: CGSize = CGSize(width: 220, height: 55)) {
        let texture = SnakeTexture.make(size: size)
        super.init(texture: texture, color: .white, size: size)
        name = "snake"
        zPosition = 6

        setUpPhysicsBody(size: size)
        pickNewDirection()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpPhysicsBody(size: CGSize) {
        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.85, height: size.height * 0.6))
        body.affectedByGravity = false
        body.allowsRotation = false
        body.linearDamping = 0
        body.categoryBitMask = PhysicsCategory.snake
        // Collides with obstacles/walls the same way the player does, instead
        // of steering around them like fish — that collision is exactly what
        // produces the awkward "stuck in a corner" movement.
        body.collisionBitMask = PhysicsCategory.obstacle | PhysicsCategory.wall
        body.contactTestBitMask = PhysicsCategory.none
        physicsBody = body
    }

    private func pickNewDirection() {
        let angle = CGFloat.random(in: 0..<(2 * .pi))
        swimDirection = CGVector(dx: cos(angle), dy: sin(angle))
        timeUntilNextTurn = TimeInterval.random(in: 3.0...6.0)
    }

    func update(deltaTime: TimeInterval) {
        timeUntilNextTurn -= deltaTime
        if timeUntilNextTurn <= 0 {
            pickNewDirection()
        }

        physicsBody?.velocity = CGVector(dx: swimDirection.dx * swimSpeed, dy: swimDirection.dy * swimSpeed)
        xScale = swimDirection.dx < 0 ? -abs(xScale) : abs(xScale)
    }
}
