//
//  DarknessOverlay.swift
//  europa-diver
//
//  A full-viewport black layer that uniformly tints everything underneath
//  it — fish, rocks, and the submarine itself included, not just the empty
//  background — darker as depth increases (DepthProfile.darkness, 0 at the
//  surface, 1 — fully opaque, nothing visible — by depth 10). There's no
//  free pass around the player: without the Light upgrade switched on,
//  the submarine gets just as hard to see as everything else.
//
//  Switching Light on cuts a soft-edged circular "porthole" into that tint
//  around the player, fading from fully revealed at the center back to the
//  ambient darkness at its edge, so it blends into the surrounding tint
//  rather than leaving a visible seam.
//
//  The hole is baked into a texture rather than carved out with blend
//  modes (SpriteKit has no destination-out blend mode) and sized larger
//  than the viewport so it can be repositioned every frame to track the
//  player's on-screen position without ever regenerating the texture —
//  that only happens when the darkness, light radius, or screen size
//  actually changes.
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
    /// `ambientDarkness` (0...1) is the uniform tint applied everywhere;
    /// `lightRadius` (0 when Light is off or not owned) cuts a reveal hole
    /// into that tint around the player.
    func configure(screenSize: CGSize, maxVerticalShift: CGFloat, ambientDarkness: CGFloat, lightRadius: CGFloat) {
        let canvasSize = CGSize(
            width: screenSize.width + 8,
            height: screenSize.height + maxVerticalShift * 2 + 8
        )
        sprite.size = canvasSize
        sprite.texture = DarknessOverlay.makeTexture(
            size: canvasSize,
            ambientDarkness: ambientDarkness,
            lightRadius: lightRadius
        )
    }

    /// `yOffset` is the player's current position in this node's own space
    /// (i.e. relative to the camera, since this overlay lives on it).
    func trackPlayer(yOffset: CGFloat) {
        sprite.position = CGPoint(x: 0, y: yOffset)
    }

    private static func makeTexture(size: CGSize, ambientDarkness: CGFloat, lightRadius: CGFloat) -> SKTexture {
        guard size.width > 0, size.height > 0 else { return SKTexture() }

        let image = UIGraphicsImageRenderer(size: size).image { context in
            let cgContext = context.cgContext
            UIColor.black.withAlphaComponent(ambientDarkness).setFill()
            cgContext.fill(CGRect(origin: .zero, size: size))

            guard lightRadius > 0 else { return }

            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let feather = min(lightRadius * 0.6, 80)
            let innerRadius = max(lightRadius - feather, 0)

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor.black.withAlphaComponent(0).cgColor,
                UIColor.black.withAlphaComponent(ambientDarkness).cgColor
            ] as CFArray
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) else { return }

            // Default compositing (source-over) can only paint on top of
            // what's there, so it can't reduce the opaque fill's alpha.
            // `.copy` replaces the destination pixel outright, so the
            // gradient's own alpha (0 at the center) really does cut
            // through it.
            cgContext.setBlendMode(.copy)

            // `.drawsBeforeStartLocation` fills the inner circle with the
            // gradient's first stop (fully revealed) instead of leaving it
            // as the ambient tint from the fill above. The gradient's end
            // color matches that same ambient tint, so the hole's outer
            // edge blends seamlessly into the surrounding darkness.
            cgContext.drawRadialGradient(
                gradient,
                startCenter: center, startRadius: innerRadius,
                endCenter: center, endRadius: lightRadius,
                options: [.drawsBeforeStartLocation]
            )
        }
        return SKTexture(image: image)
    }
}
