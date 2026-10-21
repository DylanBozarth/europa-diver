//
//  LevelEntrance.swift
//  europa-diver
//
//  A dark hole punched through the ice, marking the way down into the next
//  generated level. Colliding with it (see GameScene.didBegin(_:))
//  regenerates the map.
//

import SpriteKit
import UIKit

class LevelEntrance: SKNode {

    init(diameter: CGFloat = 50) {
        super.init()
        name = "levelEntrance"
        zPosition = 6

        let rim = SKShapeNode(path: LevelEntrance.jaggedRimPath(radius: diameter / 2))
        rim.fillColor = SKColor(red: 0.75, green: 0.92, blue: 1.0, alpha: 0.9)
        rim.strokeColor = SKColor.white.withAlphaComponent(0.9)
        rim.lineWidth = 2
        rim.zPosition = 0
        addChild(rim)

        let holeDiameter = diameter * 0.8
        let hole = SKSpriteNode(
            texture: LevelEntrance.holeTexture(diameter: holeDiameter),
            size: CGSize(width: holeDiameter, height: holeDiameter)
        )
        hole.zPosition = 1
        addChild(hole)

        // A slow pulse reads as an opening the current is pulling through,
        // rather than a static prop.
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.08, duration: 1.2),
            SKAction.scale(to: 1.0, duration: 1.2)
        ])
        pulse.timingMode = .easeInEaseOut
        hole.run(SKAction.repeatForever(pulse))

        let body = SKPhysicsBody(circleOfRadius: diameter / 2)
        body.affectedByGravity = false
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.levelEntrance
        body.collisionBitMask = PhysicsCategory.none
        physicsBody = body
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// A jagged, broken-ice-edge ring rather than a perfect circle, so the
    /// hole reads as punched through the shelf instead of a clean cutout.
    private static func jaggedRimPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let pointCount = 14
        let irregularity: CGFloat = 0.18

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

    /// A dark void, soft at the center and fading to pitch black at the
    /// edge, sized a little smaller than the rim so the ice shows as a ring
    /// around it.
    private static func holeTexture(diameter: CGFloat) -> SKTexture {
        let size = CGSize(width: diameter, height: diameter)
        let image = UIGraphicsImageRenderer(size: size).image { context in
            let rect = CGRect(origin: .zero, size: size)
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2

            let colors = [
                UIColor(white: 0.12, alpha: 0.85).cgColor,
                UIColor.black.cgColor
            ] as CFArray
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) else { return }

            context.cgContext.addEllipse(in: rect)
            context.cgContext.clip()
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: center, startRadius: 0,
                endCenter: center, endRadius: radius,
                options: []
            )
        }
        return SKTexture(image: image)
    }
}
