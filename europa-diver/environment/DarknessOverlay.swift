//
//  DarknessOverlay.swift
//  europa-diver
//
//  A full-viewport black layer with a soft-edged circular "porthole" cut
//  out around the player, so depth doesn't just tint the background — it
//  actually hides obstacles, fish, and everything else beyond the visible
//  radius. The hole's radius is driven by GameScene (DepthProfile.darkness
//  shrinks it toward zero by depth 10; the Light upgrade pushes back
//  against that).
//
//  The hole is baked into a texture rather than carved out with blend
//  modes (SpriteKit has no destination-out blend mode) and sized larger
//  than the viewport so it can be repositioned every frame to track the
//  player's on-screen position without ever regenerating the texture —
//  that only happens when the radius or screen size actually changes.
//

import SpriteKit
import UIKit

class DarknessOverlay: SKNode {
    private let sprite = SKSpriteNode(color: .black, size: .zero)

    override init() {
        super.init()
        zPosition = 50
        addChild(sprite)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Rebuilds the overlay texture. `maxVerticalShift` is how far the
    /// player can ever sit from the camera's vertical center (the world's
    /// half-height), so the canvas stays big enough to fully cover the
    /// viewport no matter where the hole is repositioned afterward.
    func configure(screenSize: CGSize, maxVerticalShift: CGFloat, holeRadius: CGFloat) {
        let canvasSize = CGSize(
            width: screenSize.width + 8,
            height: screenSize.height + maxVerticalShift * 2 + 8
        )
        sprite.size = canvasSize
        sprite.texture = DarknessOverlay.makeTexture(size: canvasSize, holeRadius: holeRadius)
    }

    /// `yOffset` is the player's current position in this node's own space
    /// (i.e. relative to the camera, since this overlay lives on it).
    func trackPlayer(yOffset: CGFloat) {
        sprite.position = CGPoint(x: 0, y: yOffset)
    }

    private static func makeTexture(size: CGSize, holeRadius: CGFloat) -> SKTexture {
        guard size.width > 0, size.height > 0 else { return SKTexture() }

        let image = UIGraphicsImageRenderer(size: size).image { context in
            let cgContext = context.cgContext
            UIColor.black.setFill()
            cgContext.fill(CGRect(origin: .zero, size: size))

            guard holeRadius > 0 else { return }

            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let feather = min(holeRadius * 0.6, 80)
            let innerRadius = max(holeRadius - feather, 0)

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor.black.withAlphaComponent(0).cgColor,
                UIColor.black.withAlphaComponent(1).cgColor
            ] as CFArray
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) else { return }

            // `.drawsBeforeStartLocation` fills the inner circle with the
            // gradient's first stop (fully transparent) instead of leaving
            // it as the opaque black from the fill above.
            cgContext.drawRadialGradient(
                gradient,
                startCenter: center, startRadius: innerRadius,
                endCenter: center, endRadius: holeRadius,
                options: [.drawsBeforeStartLocation]
            )
        }
        return SKTexture(image: image)
    }
}
