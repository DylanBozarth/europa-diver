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
        let renderer = ImageRenderer(content: YellowSubmarineIcon().frame(width: size.width, height: size.height))
        renderer.scale = 3

        guard let uiImage = renderer.uiImage else {
            return SKTexture()
        }
        return SKTexture(image: uiImage)
    }
}
