//
//  SnakeTexture.swift
//  europa-diver
//
//  Renders the SwiftUI snake icon into an SKTexture for use as a sprite.
//

import SwiftUI
import SpriteKit

enum SnakeTexture {
    static func make(size: CGSize) -> SKTexture {
        let renderer = ImageRenderer(content: SnakeIcon().frame(width: size.width, height: size.height))
        renderer.scale = 3

        guard let uiImage = renderer.uiImage else {
            return SKTexture()
        }
        return SKTexture(image: uiImage)
    }
}
