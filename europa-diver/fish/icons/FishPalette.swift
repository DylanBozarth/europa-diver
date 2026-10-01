//
//  FishPalette.swift
//  europa-diver
//
//  20 distinct color/feature presets for passive (small/large) fish, applied
//  to the shared SlimFishIcon/BulkyFishIcon templates. Hues are spread evenly
//  around the color wheel so every preset reads as genuinely different, with
//  eye/spot counts varied on top for extra silhouette variety.
//

import SwiftUI

struct FishPalette {
    let primary: Color
    let secondary: Color
    let finColor: Color
    let eyeColor: Color
    let mouthColor: Color
    let spotColor: Color
    let eyeCount: Int
    let spotCount: Int

    static let all: [FishPalette] = (0..<20).map { index in
        let hue = Double(index) / 20.0
        let accentHue = (hue + 0.5).truncatingRemainder(dividingBy: 1.0)

        return FishPalette(
            primary: Color(hue: hue, saturation: 0.65, brightness: 0.78),
            secondary: Color(hue: hue, saturation: 0.75, brightness: 0.42),
            finColor: Color(hue: hue, saturation: 0.70, brightness: 0.55),
            eyeColor: Color(hue: accentHue, saturation: 0.25, brightness: 0.95),
            mouthColor: Color(hue: hue, saturation: 0.60, brightness: 0.15),
            spotColor: Color(hue: accentHue, saturation: 0.80, brightness: 0.95),
            eyeCount: index % 3 == 0 ? 3 : 2,
            spotCount: 2 + (index % 4)
        )
    }
}
