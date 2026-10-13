//
//  FishTexture.swift
//  europa-diver
//
//  Renders fish icons into SKTextures so they can be used as sprites.
//  `appearanceIndex` picks which look to use — a FishPalette index for
//  passive (small/large) fish, or a hostile variant index for hostile fish —
//  and is chosen once at spawn (see LevelGenerator) so it stays fixed for
//  that fish's lifetime and can double as its scan-species identity.
//

import SwiftUI
import SpriteKit
import UIKit

enum FishTexture {
    static let hostileVariantCount = 3

    static func make(for kind: FishKind, appearanceIndex: Int, size: CGSize) -> SKTexture {
        switch kind {
        case .small:
            let palette = FishPalette.all[appearanceIndex % FishPalette.all.count]
            return render(SlimFishIcon(palette: palette), size: size)
        case .large:
            let palette = FishPalette.all[appearanceIndex % FishPalette.all.count]
            return render(BulkyFishIcon(palette: palette), size: size)
        case .hostile:
            return render(hostileIcon(for: appearanceIndex), size: size)
        }
    }

    @ViewBuilder
    private static func hostileIcon(for index: Int) -> some View {
        switch index % hostileVariantCount {
        case 0: HostileFishIcon()
        case 1: HostileFishIconB()
        default: HostileFishIconC()
        }
    }

    private static func render<V: View>(_ view: V, size: CGSize) -> SKTexture {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = 3

        guard let uiImage = renderer.uiImage else {
            // ImageRenderer occasionally fails to produce an image (a known
            // SwiftUI timing quirk, not something worth retrying). Without
            // this fallback the fish would get a blank SKTexture() — fully
            // functional (still chases, still damages the player) but
            // completely invisible and impossible to target.
            return fallbackTexture(size: size)
        }
        return SKTexture(image: uiImage)
    }

    private static func fallbackTexture(size: CGSize) -> SKTexture {
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            UIColor.red.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        }
        return SKTexture(image: image)
    }
}
