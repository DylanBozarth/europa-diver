//
//  SwiftUIIconRenderer.swift
//  europa-diver
//
//  Shared helper for rendering a SwiftUI icon into an SKTexture. Guards
//  against a known ImageRenderer timing quirk: querying `.uiImage`
//  synchronously right after creation (exactly how every icon in this game
//  is rendered, once per spawn) can return nil, or a non-nil image with
//  nothing actually drawn into it. Either way, without this guard the
//  sprite would be fully functional (still moves, still collides/damages)
//  but completely invisible — this falls back to a plain, guaranteed-
//  visible colored shape instead.
//

import SwiftUI
import SpriteKit
import UIKit

enum SwiftUIIconRenderer {
    static func render<V: View>(_ view: V, size: CGSize, fallbackColor: UIColor = .red) -> SKTexture {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = 3

        guard let uiImage = renderer.uiImage, !isEffectivelyBlank(uiImage) else {
            return fallbackTexture(size: size, color: fallbackColor)
        }
        return SKTexture(image: uiImage)
    }

    /// Downsamples into a tiny fixed-format (RGBA8, alpha-last) buffer so
    /// the check doesn't depend on the source image's own pixel layout,
    /// then looks for any non-transparent pixel at all.
    private static func isEffectivelyBlank(_ image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else { return true }

        let side = 8
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: &pixels,
            width: side,
            height: side,
            bitsPerComponent: 8,
            bytesPerRow: side * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return true
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: side, height: side))

        return !stride(from: 3, to: pixels.count, by: 4).contains { pixels[$0] != 0 }
    }

    private static func fallbackTexture(size: CGSize, color: UIColor) -> SKTexture {
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            color.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        }
        return SKTexture(image: image)
    }
}
