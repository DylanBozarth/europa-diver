//
//  SmallSnakeTexture.swift
//  europa-diver
//
//  Renders the SwiftUI small-snake icon into an SKTexture for use as a sprite.
//

import SwiftUI
import SpriteKit

enum SmallSnakeTexture {
    static func make(size: CGSize) -> SKTexture {
        let renderer = ImageRenderer(content: SmallSnakeIcon().frame(width: size.width, height: size.height))
        renderer.scale = 3

        guard let uiImage = renderer.uiImage else {
            return SKTexture()
        }
        return SKTexture(image: uiImage)
    }
}
