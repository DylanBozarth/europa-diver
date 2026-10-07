//
//  SmallSnake.swift
//  europa-diver
//
//  A small, fast, skittish creature — the opposite of the big hostile Snake.
//  It's harmless (no contact damage, no collision with the player at all),
//  but actively flees once it notices the player, and steers cleanly around
//  obstacles the same way Fish does, so — unlike the big snake — it never
//  looks clumsy or gets stuck. "Noticing" the player only happens while the
//  snake itself is within the camera's visible area (see GameScene.isOnScreen),
//  so you can sneak up on one that's currently off-screen.
//

import SpriteKit

class SmallSnake: SKSpriteNode {

    // Faster than the submarine's 160 moveSpeed, so it can't be run down head-on.
    private let swimSpeed: CGFloat = 200
    private let fleeRadius: CGFloat = 220
    private let avoidRadius: CGFloat = 70
    private let avoidStrength: CGFloat = 1.5
    private let bodyRadius: CGFloat

    private var roamDirection = CGVector(dx: 0, dy: 0)
    private var timeUntilNextTurn: TimeInterval = 0

    init(size: CGSize = CGSize(width: 60, height: 18)) {
        bodyRadius = max(size.width, size.height) / 2

        let texture = SmallSnakeTexture.make(size: size)
        super.init(texture: texture, color: .white, size: size)
        name = "smallSnake"
        zPosition = 6

        setUpPhysicsBody()
        pickNewDirection()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpPhysicsBody() {
        let body = SKPhysicsBody(circleOfRadius: bodyRadius)
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = PhysicsCategory.smallSnake
        body.collisionBitMask = PhysicsCategory.none
        body.contactTestBitMask = PhysicsCategory.none
        physicsBody = body
    }

    private func pickNewDirection() {
        let angle = CGFloat.random(in: 0..<(2 * .pi))
        roamDirection = CGVector(dx: cos(angle), dy: sin(angle))
        timeUntilNextTurn = TimeInterval.random(in: 2.0...4.0)
    }

    func update(
        deltaTime: TimeInterval,
        playerPosition: CGPoint,
        isOnScreen: Bool,
        nearbyObstacles: [CGPoint],
        worldMinX: CGFloat,
        worldMaxX: CGFloat,
        worldBottom: CGFloat,
        worldTop: CGFloat
    ) {
        timeUntilNextTurn -= deltaTime
        if timeUntilNextTurn <= 0 {
            pickNewDirection()
        }

        var primaryDirection = roamDirection

        let dx = position.x - playerPosition.x
        let dy = position.y - playerPosition.y
        let distanceToPlayer = sqrt(dx * dx + dy * dy)

        if isOnScreen, distanceToPlayer < fleeRadius, distanceToPlayer > 0.001 {
            // Flee directly away from the player instead of roaming.
            primaryDirection = CGVector(dx: dx / distanceToPlayer, dy: dy / distanceToPlayer)
        }

        let avoidance = avoidanceVector(obstacles: nearbyObstacles)
        let direction = normalized(
            CGVector(
                dx: primaryDirection.dx + avoidance.dx * avoidStrength,
                dy: primaryDirection.dy + avoidance.dy * avoidStrength
            ),
            fallback: primaryDirection
        )

        let destination = CGPoint(
            x: position.x + direction.dx * swimSpeed * CGFloat(deltaTime),
            y: position.y + direction.dy * swimSpeed * CGFloat(deltaTime)
        )

        var resolved = moveTowards(destination, avoiding: nearbyObstacles)
        resolved.x = min(max(resolved.x, worldMinX + 20), worldMaxX - 20)
        resolved.y = min(max(resolved.y, worldBottom + 20), worldTop - 20)

        position = resolved
        xScale = direction.dx < 0 ? -abs(xScale) : abs(xScale)
    }

    // MARK: - Steering (mirrors Fish's avoidance + hard-clamp backstop)

    private func avoidanceVector(obstacles: [CGPoint]) -> CGVector {
        var avoid = CGVector(dx: 0, dy: 0)
        for obstacle in obstacles {
            let dx = position.x - obstacle.x
            let dy = position.y - obstacle.y
            let distance = sqrt(dx * dx + dy * dy)
            guard distance < avoidRadius, distance > 0.001 else { continue }

            let strength = (avoidRadius - distance) / avoidRadius
            avoid.dx += (dx / distance) * strength
            avoid.dy += (dy / distance) * strength
        }
        return avoid
    }

    private func normalized(_ vector: CGVector, fallback: CGVector) -> CGVector {
        let length = sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
        guard length > 0.001 else { return fallback }
        return CGVector(dx: vector.dx / length, dy: vector.dy / length)
    }

    private func resolvedPosition(for proposed: CGPoint, avoiding obstacles: [CGPoint]) -> CGPoint {
        var resolved = proposed
        let minDistance = WorldConstants.obstacleRadius + bodyRadius

        for obstacle in obstacles {
            let dx = resolved.x - obstacle.x
            let dy = resolved.y - obstacle.y
            let distance = sqrt(dx * dx + dy * dy)
            guard distance < minDistance else { continue }

            if distance > 0.001 {
                let scale = minDistance / distance
                resolved = CGPoint(x: obstacle.x + dx * scale, y: obstacle.y + dy * scale)
            } else {
                resolved = CGPoint(x: obstacle.x + minDistance, y: obstacle.y)
            }
        }
        return resolved
    }

    private func moveTowards(_ destination: CGPoint, avoiding obstacles: [CGPoint]) -> CGPoint {
        let dx = destination.x - position.x
        let dy = destination.y - position.y
        let totalDistance = sqrt(dx * dx + dy * dy)
        guard totalDistance > 0.001 else { return position }

        let maxStep: CGFloat = 4
        let steps = max(1, Int((totalDistance / maxStep).rounded(.up)))
        let stepVector = CGVector(dx: dx / CGFloat(steps), dy: dy / CGFloat(steps))

        var current = position
        for _ in 0..<steps {
            let stepped = CGPoint(x: current.x + stepVector.dx, y: current.y + stepVector.dy)
            current = resolvedPosition(for: stepped, avoiding: obstacles)
        }
        return current
    }
}
