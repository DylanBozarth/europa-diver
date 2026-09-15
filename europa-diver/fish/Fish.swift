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

class Fish: SKShapeNode {

    let kind: FishKind
    let normalColor: SKColor
    private let swimSpeed: CGFloat

    private var swimDirection = CGVector(dx: 0, dy: 0)
    private var timeUntilNextTurn: TimeInterval = 0

    private let roamTop: CGFloat
    private let roamBottom: CGFloat
    private let roamLeft: CGFloat
    private let roamRight: CGFloat

    init(kind: FishKind, roamLeft: CGFloat, roamRight: CGFloat, roamBottom: CGFloat, roamTop: CGFloat) {
        self.kind = kind
        self.roamLeft = roamLeft
        self.roamRight = roamRight
        self.roamBottom = roamBottom
        self.roamTop = roamTop

        let size: CGFloat
        switch kind {
        case .small:
            size = 10
            swimSpeed = 50
        case .large:
            size = 26
            swimSpeed = 30
        case .hostile:
            size = 16
            swimSpeed = 75
        }

        normalColor = Fish.color(for: kind)

        super.init()
        name = "fish"

        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: -size / 2, y: -size / 4, width: size, height: size / 2))
        self.path = path
        fillColor = normalColor
        strokeColor = .yellow
        zPosition = 5

        setUpPhysicsBody(radius: size / 2)
        pickNewDirection()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func color(for kind: FishKind) -> SKColor {
        switch kind {
        case .small: return .orange
        case .large: return SKColor(red: 0.55, green: 0.35, blue: 0.2, alpha: 1.0)
        case .hostile: return .purple
        }
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

    func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        switch kind {
        case .small, .large:
            roam(deltaTime: deltaTime)
        case .hostile:
            chase(playerPosition, deltaTime: deltaTime)
        }
    }

    private func roam(deltaTime: TimeInterval) {
        timeUntilNextTurn -= deltaTime
        if timeUntilNextTurn <= 0 {
            pickNewDirection()
        }

        var newPosition = CGPoint(
            x: position.x + swimDirection.dx * swimSpeed * CGFloat(deltaTime),
            y: position.y + swimDirection.dy * swimSpeed * CGFloat(deltaTime)
        )

        if newPosition.x < roamLeft || newPosition.x > roamRight {
            swimDirection.dx *= -1
            newPosition.x = position.x
        }
        if newPosition.y < roamBottom || newPosition.y > roamTop {
            swimDirection.dy *= -1
            newPosition.y = position.y
        }

        move(to: newPosition, facing: swimDirection.dx)
    }

    private func chase(_ target: CGPoint, deltaTime: TimeInterval) {
        let dx = target.x - position.x
        let dy = target.y - position.y
        let distance = sqrt(dx * dx + dy * dy)
        guard distance > 1 else { return }

        let direction = CGVector(dx: dx / distance, dy: dy / distance)
        let newPosition = CGPoint(
            x: position.x + direction.dx * swimSpeed * CGFloat(deltaTime),
            y: position.y + direction.dy * swimSpeed * CGFloat(deltaTime)
        )

        move(to: newPosition, facing: direction.dx)
    }

    private func move(to newPosition: CGPoint, facing dx: CGFloat) {
        position = newPosition
        xScale = dx < 0 ? -abs(xScale) : abs(xScale)
    }
}
