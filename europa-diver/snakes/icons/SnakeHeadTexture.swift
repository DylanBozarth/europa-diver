//
//  SnakeHeadTexture.swift
//  europa-diver
//
//  Renders the SwiftUI snake-head icon into an SKTexture for use as a sprite.
//

import SwiftUI
import SpriteKit

enum SnakeHeadTexture {
    static func make(size: CGSize) -> SKTexture {
        let renderer = ImageRenderer(content: SnakeHeadIcon().frame(width: size.width, height: size.height))
        renderer.scale = 3

        guard let uiImage = renderer.uiImage else {
            return SKTexture()
        }
        return SKTexture(image: uiImage)
    }
}
