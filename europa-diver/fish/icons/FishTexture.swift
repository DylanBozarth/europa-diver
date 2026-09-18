//
//  FishTexture.swift
//  europa-diver
//
//  Renders the SwiftUI fish icons (friendly-fish.swift, fat-fish.swift,
//  hostile-fish.swift) into SKTextures so they can be used as sprites.
//

import SwiftUI
import SpriteKit

enum FishTexture {
    static func make(for kind: FishKind, size: CGSize) -> SKTexture {
        switch kind {
        case .small:
            return render(AlienFishIcon(), size: size)
        case .large:
            return render(FloaterFishIcon(), size: size)
        case .hostile:
            return render(HostileFishIcon(), size: size)
        }
    }

    private static func render<V: View>(_ view: V, size: CGSize) -> SKTexture {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = 3

        guard let uiImage = renderer.uiImage else {
            return SKTexture()
        }
        return SKTexture(image: uiImage)
    }
}
