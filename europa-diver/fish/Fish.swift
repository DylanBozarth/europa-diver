//
//  Fish.swift
//  europa-diver
//

import SpriteKit

enum FishKind {
    case small
    case large
    case hostile
}

class Fish: SKSpriteNode {

    let kind: FishKind
    private let swimSpeed: CGFloat
    private let radius: CGFloat

    private var swimDirection = CGVector(dx: 0, dy: 0)
    private var timeUntilNextTurn: TimeInterval = 0

    private let roamTop: CGFloat
    private let roamBottom: CGFloat
    private let roamLeft: CGFloat
    private let roamRight: CGFloat

    private let avoidRadius: CGFloat = 70
    private let avoidStrength: CGFloat = 1.5

    init(kind: FishKind, roamLeft: CGFloat, roamRight: CGFloat, roamBottom: CGFloat, roamTop: CGFloat) {
        self.kind = kind
        self.roamLeft = roamLeft
        self.roamRight = roamRight
        self.roamBottom = roamBottom
        self.roamTop = roamTop

        let width: CGFloat
        switch kind {
        case .small:
            width = 26
            swimSpeed = 50
        case .large:
            width = 46
            swimSpeed = 30
        case .hostile:
            width = 32
            swimSpeed = 75
        }

        let displaySize = CGSize(width: width, height: width * 0.8)
        radius = width / 2

        super.init(texture: FishTexture.make(for: kind, size: displaySize), color: .white, size: displaySize)
        name = "fish"
        zPosition = 5

        setUpPhysicsBody(radius: radius)
        pickNewDirection()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpPhysicsBody(radius: CGFloat) {
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.affectedByGravity = false
        body.allowsRotation = false
        body.collisionBitMask = PhysicsCategory.none

        switch kind {
        case .small:
            body.categoryBitMask = PhysicsCategory.smallFish
        case .large:
            body.categoryBitMask = PhysicsCategory.largeFish
        case .hostile:
            body.categoryBitMask = PhysicsCategory.hostileFish
        }

        physicsBody = body
    }

    private func pickNewDirection() {
        let angle = CGFloat.random(in: 0..<(2 * .pi))
        swimDirection = CGVector(dx: cos(angle), dy: sin(angle))
        timeUntilNextTurn = TimeInterval.random(in: 1.5...4.0)
    }

    func update(deltaTime: TimeInterval, playerPosition: CGPoint, nearbyObstacles: [CGPoint]) {
        switch kind {
        case .small, .large:
            roam(deltaTime: deltaTime, obstacles: nearbyObstacles)
        case .hostile:
            chase(playerPosition, deltaTime: deltaTime, obstacles: nearbyObstacles)
        }
    }

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

    /// Hard backstop: guarantees a fish's position never ends up inside an obstacle,
    /// regardless of how strong the steering avoidance above was.
    private func resolvedPosition(for proposed: CGPoint, avoiding obstacles: [CGPoint]) -> CGPoint {
        var resolved = proposed
        let minDistance = WorldConstants.obstacleRadius + radius

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

    /// Walks toward `destination` in small increments, resolving obstacle overlap after
    /// each one, so a fast fish can't cover enough distance in a single frame to land on
    /// the far side of an obstacle before the collision check ever sees it (tunneling).
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

    private func roam(deltaTime: TimeInterval, obstacles: [CGPoint]) {
        timeUntilNextTurn -= deltaTime
        if timeUntilNextTurn <= 0 {
            pickNewDirection()
        }

        let avoidance = avoidanceVector(obstacles: obstacles)
        let direction = normalized(
            CGVector(dx: swimDirection.dx + avoidance.dx * avoidStrength,
                      dy: swimDirection.dy + avoidance.dy * avoidStrength),
            fallback: swimDirection
        )

        var newPosition = CGPoint(
            x: position.x + direction.dx * swimSpeed * CGFloat(deltaTime),
            y: position.y + direction.dy * swimSpeed * CGFloat(deltaTime)
        )

        if newPosition.x < roamLeft || newPosition.x > roamRight {
            swimDirection.dx *= -1
            newPosition.x = position.x
        }
        if newPosition.y < roamBottom || newPosition.y > roamTop {
            swimDirection.dy *= -1
            newPosition.y = position.y
        }

        let resolved = moveTowards(newPosition, avoiding: obstacles)

        move(to: resolved, facing: direction.dx)
    }

    private func chase(_ target: CGPoint, deltaTime: TimeInterval, obstacles: [CGPoint]) {
        let dx = target.x - position.x
        let dy = target.y - position.y
        let distance = sqrt(dx * dx + dy * dy)
        guard distance > 1 else { return }

        let toTarget = CGVector(dx: dx / distance, dy: dy / distance)
        let avoidance = avoidanceVector(obstacles: obstacles)
        let direction = normalized(
            CGVector(dx: toTarget.dx + avoidance.dx * avoidStrength,
                      dy: toTarget.dy + avoidance.dy * avoidStrength),
            fallback: toTarget
        )

        let destination = CGPoint(
            x: position.x + direction.dx * swimSpeed * CGFloat(deltaTime),
            y: position.y + direction.dy * swimSpeed * CGFloat(deltaTime)
        )
        let resolved = moveTowards(destination, avoiding: obstacles)

        move(to: resolved, facing: direction.dx)
    }

    private func move(to newPosition: CGPoint, facing dx: CGFloat) {
        position = newPosition
        xScale = dx < 0 ? -abs(xScale) : abs(xScale)
    }
}
