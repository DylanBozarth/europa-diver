//
//  Snake.swift
//  europa-diver
//
//  A large, hostile enemy that cannot be damaged by the shock ability or
//  anything else — the only valid response to one is avoidance. Aggressively
//  chases the submarine (recomputed every frame), but stays big, slow (half
//  the submarine's speed), and awkward: it has no obstacle-avoidance smarts
//  at all, so it relies on raw physics collision to "deal with" obstacles,
//  which is what gives it its clumsy, get-stuck-in-corners movement even
//  while it's bearing straight down on the player.
//
//  Built from a head plus several trailing body segments that follow the
//  head's past path (classic "Snake" game movement), rather than one rigid
//  rectangular sprite — so turning looks like a twisting body, not a block
//  sliding sideways.
//

import SpriteKit

class Snake: SKNode {

    private let swimSpeed: CGFloat = 80 // half of the submarine's 160 moveSpeed
    private var lastDirection = CGVector(dx: 1, dy: 0)

    private let headSize = CGSize(width: 70, height: 60)
    private let head: SKSpriteNode

    private var bodySegments: [SKShapeNode] = []
    private let segmentCount = 8
    private let samplesPerSegment = 6

    /// Head's past world positions, newest first. Body segments each look
    /// back a fixed number of samples to find where they should sit — that
    /// lag is what produces the twisting, following motion through turns.
    private var trail: [CGPoint] = []

    override init() {
        head = SKSpriteNode(texture: SnakeHeadTexture.make(size: headSize), size: headSize)

        super.init()
        name = "snake"
        zPosition = 6

        head.zPosition = 0.1
        addChild(head)

        setUpBodySegments()
        setUpPhysicsBody()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpBodySegments() {
        for index in 0..<segmentCount {
            let taper = 1.0 - (CGFloat(index) / CGFloat(segmentCount)) * 0.55
            let width = headSize.height * 0.78 * taper
            let height = headSize.height * 0.62 * taper

            let segment = SKShapeNode(ellipseOf: CGSize(width: width, height: height))
            segment.fillColor = index % 2 == 0
                ? SKColor(red: 0.22, green: 0.06, blue: 0.30, alpha: 1.0)
                : SKColor(red: 0.30, green: 0.10, blue: 0.40, alpha: 1.0)
            segment.strokeColor = .clear
            segment.zPosition = -CGFloat(index) * 0.01
            addChild(segment)
            bodySegments.append(segment)
        }
    }

    private func setUpPhysicsBody() {
        let body = SKPhysicsBody(circleOfRadius: max(headSize.width, headSize.height) * 0.45)
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

    func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        let dx = playerPosition.x - position.x
        let dy = playerPosition.y - position.y
        let distance = sqrt(dx * dx + dy * dy)

        let direction = distance > 0.001 ? CGVector(dx: dx / distance, dy: dy / distance) : lastDirection
        lastDirection = direction

        physicsBody?.velocity = CGVector(dx: direction.dx * swimSpeed, dy: direction.dy * swimSpeed)
        head.xScale = direction.dx < 0 ? -abs(head.xScale) : abs(head.xScale)

        recordTrail()
        updateBodySegments()
    }

    private func recordTrail() {
        trail.insert(position, at: 0)

        let maxSamples = (segmentCount + 1) * samplesPerSegment
        if trail.count > maxSamples {
            trail.removeLast(trail.count - maxSamples)
        }
    }

    private func updateBodySegments() {
        for (index, segment) in bodySegments.enumerated() {
            let sampleIndex = (index + 1) * samplesPerSegment
            guard sampleIndex < trail.count else { continue }

            // `position` is this container's (the head's) current world spot,
            // so subtracting it converts the historical world point into a
            // local offset the segment can use directly.
            let worldPoint = trail[sampleIndex]
            segment.position = CGPoint(x: worldPoint.x - position.x, y: worldPoint.y - position.y)
        }
    }
}
