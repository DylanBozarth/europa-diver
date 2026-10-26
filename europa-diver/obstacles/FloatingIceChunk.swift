//
//  FloatingIceChunk.swift
//  europa-diver
//
//  A single drifting ice chunk, scattered independently of the tunnel
//  walls (see LevelGenerator.IceChunkSlot). Unlike the uniform tunnel-wall
//  chunks, these vary a lot in size, and each one slowly wanders within a
//  small radius of its spawn point — noticeably slower than any fish
//  (the slowest swims at 30pt/s; these drift at single digits), but never
//  fully still.
//

import SpriteKit

class FloatingIceChunk: SKShapeNode {
    private static let radiusRange: ClosedRange<CGFloat> = 10...42
    private static let driftRadius: CGFloat = 25
    private static let driftSpeed: ClosedRange<CGFloat> = 4...9
    private static let shoveDistance: CGFloat = 50
    private static let shoveDuration: TimeInterval = 0.25

    /// Where this chunk wanders around — not its current (drifting)
    /// position. Shifts permanently when shoved by a torpedo (see `shove`),
    /// rather than snapping back to where it originally spawned.
    private var basePosition: CGPoint

    init(at spawnPosition: CGPoint) {
        basePosition = spawnPosition
        super.init()
        name = "obstacle"
        position = spawnPosition
        zPosition = 2

        let radius = CGFloat.random(in: Self.radiusRange)
        path = FloatingIceChunk.jaggedPath(radius: radius)
        zRotation = CGFloat.random(in: 0..<(2 * .pi))
        fillColor = SKColor(red: 0.75, green: 0.92, blue: 1.0, alpha: 0.9)
        strokeColor = SKColor.white.withAlphaComponent(0.9)
        lineWidth = 1

        // Physics stays a plain circle regardless of the jagged visual
        // silhouette, matching every other obstacle in the game. Non-dynamic
        // bodies still track the node's position each frame, so the drift
        // below collides correctly even though nothing is pushing it.
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        physicsBody = body

        scheduleNextDrift()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Knocked aside by a torpedo hit (see GameScene.handleTorpedoContact) —
    /// interrupts the current drift, punches the chunk a short distance in
    /// the hit direction, then resumes the normal wander from its new
    /// resting spot rather than snapping back to where it started.
    func shove(direction: CGFloat) {
        removeAllActions()

        let offset = CGVector(dx: Self.shoveDistance * (direction < 0 ? -1 : 1), dy: 0)
        basePosition = CGPoint(x: basePosition.x + offset.dx, y: basePosition.y + offset.dy)

        let punch = SKAction.move(by: offset, duration: Self.shoveDuration)
        punch.timingMode = .easeOut
        run(punch) { [weak self] in self?.scheduleNextDrift() }
    }

    /// Picks a new random point within `driftRadius` of the spawn position
    /// and eases toward it at a random (slow) speed, then repeats forever —
    /// an endless, gentle wander rather than a fixed loop.
    private func scheduleNextDrift() {
        let angle = CGFloat.random(in: 0..<(2 * .pi))
        let distance = CGFloat.random(in: 0...Self.driftRadius)
        let target = CGPoint(
            x: basePosition.x + cos(angle) * distance,
            y: basePosition.y + sin(angle) * distance
        )

        let travel = max(hypot(target.x - position.x, target.y - position.y), 1)
        let speed = CGFloat.random(in: Self.driftSpeed)
        let duration = TimeInterval(travel / speed)

        let move = SKAction.move(to: target, duration: duration)
        move.timingMode = .easeInEaseOut
        run(move) { [weak self] in self?.scheduleNextDrift() }
    }

    private static func jaggedPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let pointCount = 9
        let irregularity: CGFloat = 0.3

        for index in 0..<pointCount {
            let angle = (CGFloat(index) / CGFloat(pointCount)) * 2 * .pi
            let pointRadius = radius * (1 - irregularity / 2 + CGFloat.random(in: 0...irregularity))
            let point = CGPoint(x: cos(angle) * pointRadius, y: sin(angle) * pointRadius)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}
