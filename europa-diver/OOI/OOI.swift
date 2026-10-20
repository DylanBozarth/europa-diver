//
//  OOI.swift
//  europa-diver
//
//  Object of interest — a rare, high-value collectible the submarine must
//  scan (see GameScene's scan system) rather than just bump into. A faint
//  gem-shaped glint rather than a bright, obvious marker — worth 1000
//  points precisely because it's easy to miss.
//

import SpriteKit

class OOI: SKShapeNode, Scannable {
    /// Every OOI shares this ID — unlike fish/snake species, there's no
    /// "already discovered" concept to track per instance; each one is
    /// independently scannable and consumed on collection.
    let speciesID = "ooi"

    init(radius: CGFloat = 22) {
        super.init()
        name = "ooi"

        path = OOI.gemPath(radius: radius)
        fillColor = SKColor(red: 0.55, green: 0.45, blue: 0.85, alpha: 1.0)
        strokeColor = SKColor(red: 0.75, green: 0.68, blue: 0.95, alpha: 1.0)
        lineWidth = 1.5
        zPosition = 6

        // Much dimmer than a normal blink — it never gets brighter than a
        // faint glint, so spotting one takes actually looking.
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.06, duration: 0.9),
            SKAction.fadeAlpha(to: 0.35, duration: 0.9)
        ])))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// An elongated diamond/gem silhouette rather than a plain circle.
    private static func gemPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: radius))
        path.addLine(to: CGPoint(x: radius * 0.6, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -radius))
        path.addLine(to: CGPoint(x: -radius * 0.6, y: 0))
        path.closeSubpath()
        return path
    }
}
