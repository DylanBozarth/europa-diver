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
        SwiftUIIconRenderer.render(SmallSnakeIcon(), size: size, fallbackColor: .green)
    }
}
