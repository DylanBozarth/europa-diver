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
        SwiftUIIconRenderer.render(SnakeHeadIcon(), size: size, fallbackColor: .purple)
    }
}
