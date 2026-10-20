//
//  ElectricShockEffect.swift
//  europa-diver
//
//  A burst of jagged lightning bolts radiating outward from the submarine
//  when Electric Shock fires, out to the same radius the shock actually
//  reaches.
//

import SpriteKit

enum ElectricShockEffect {
    private static let boltCount = 10

    static func spawn(at center: CGPoint, radius: CGFloat, in parent: SKNode) {
        for index in 0..<boltCount {
            let angle = (CGFloat(index) / CGFloat(boltCount)) * 2 * .pi + CGFloat.random(in: -0.15...0.15)

            let bolt = SKShapeNode(path: boltPath(length: radius, angle: angle))
            bolt.position = center
            bolt.strokeColor = SKColor(red: 0.65, green: 0.9, blue: 1.0, alpha: 1.0)
            bolt.lineWidth = 2.5
            bolt.glowWidth = 3
            bolt.zPosition = 11
            parent.addChild(bolt)

            bolt.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.1),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
        }
    }

    /// A zigzagging line from the center out to `length` along `angle`,
    /// jittered perpendicular to its own direction so it reads as a bolt
    /// rather than a straight ray.
    private static func boltPath(length: CGFloat, angle: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: .zero)

        let direction = CGVector(dx: cos(angle), dy: sin(angle))
        let perpendicular = CGVector(dx: -direction.dy, dy: direction.dx)
        let segments = 5

        for index in 1...segments {
            let t = CGFloat(index) / CGFloat(segments)
            let jitter = index == segments ? 0 : CGFloat.random(in: -10...10)
            let point = CGPoint(
                x: direction.dx * length * t + perpendicular.dx * jitter,
                y: direction.dy * length * t + perpendicular.dy * jitter
            )
            path.addLine(to: point)
        }
        return path
    }
}
