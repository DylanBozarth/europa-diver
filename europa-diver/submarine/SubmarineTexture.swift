//
//  SubmarineTexture.swift
//  europa-diver
//
//  Renders the SwiftUI submarine icon (submarine.swift) into an SKTexture
//  so it can be used as the player's sprite in SpriteKit.
//

import SwiftUI
import SpriteKit

enum SubmarineTexture {
    static func make(size: CGSize = CGSize(width: 200, height: 160)) -> SKTexture {
        SwiftUIIconRenderer.render(YellowSubmarineIcon(), size: size, fallbackColor: .yellow)
    }
}
