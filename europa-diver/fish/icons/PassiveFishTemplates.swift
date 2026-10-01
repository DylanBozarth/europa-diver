//
//  PassiveFishTemplates.swift
//  europa-diver
//
//  Two body plans (slim/small, bulky/large) shared by all 20 FishPalette
//  presets. Reuses the Fin/TailFin shapes from friendly-fish.swift and the
//  FloaterFin/FloaterTail shapes from fat-fish.swift.
//

import SwiftUI

struct SlimFishIcon: View {
    let palette: FishPalette

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [palette.primary, palette.secondary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 145, height: 82)

            TailFin()
                .fill(palette.finColor)
                .frame(width: 55, height: 65)
                .offset(x: -78)

            Fin()
                .fill(palette.finColor)
                .frame(width: 45, height: 35)
                .rotationEffect(.degrees(-8))
                .offset(x: 15, y: -52)

            Fin()
                .fill(palette.finColor.opacity(0.85))
                .frame(width: 38, height: 28)
                .rotationEffect(.degrees(12))
                .offset(x: 25, y: 48)

            ForEach(0..<palette.eyeCount, id: \.self) { index in
                Circle()
                    .fill(palette.eyeColor)
                    .frame(width: 20 - CGFloat(index * 4))
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 9 - CGFloat(index * 2))
                    )
                    .offset(x: 40 - CGFloat(index * 12), y: -8 + CGFloat(index * 10))
            }

            ForEach(0..<palette.spotCount, id: \.self) { index in
                Circle()
                    .fill(palette.spotColor)
                    .frame(width: 5)
                    .offset(x: -30 + CGFloat(index * 12), y: -10 + CGFloat(index % 2) * 20)
            }
        }
        .frame(width: 210, height: 170)
    }
}

struct BulkyFishIcon: View {
    let palette: FishPalette

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [palette.primary, palette.secondary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 155, height: 105)

            FloaterTail()
                .fill(palette.finColor)
                .frame(width: 65, height: 90)
                .offset(x: -88)

            FloaterFin()
                .fill(palette.finColor)
                .frame(width: 55, height: 45)
                .rotationEffect(.degrees(-8))
                .offset(x: 5, y: -66)

            FloaterFin()
                .fill(palette.finColor.opacity(0.85))
                .frame(width: 50, height: 38)
                .rotationEffect(.degrees(10))
                .offset(x: 20, y: 63)

            ForEach(0..<palette.eyeCount, id: \.self) { index in
                Circle()
                    .fill(palette.eyeColor)
                    .frame(width: 22 - CGFloat(index * 5))
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 9 - CGFloat(index * 2))
                    )
                    .offset(x: 48 - CGFloat(index * 15), y: -18 + CGFloat(index * 12))
            }

            Ellipse()
                .fill(palette.mouthColor)
                .frame(width: 28, height: 13)
                .offset(x: 52, y: 17)

            ForEach(0..<palette.spotCount, id: \.self) { index in
                Circle()
                    .fill(palette.spotColor)
                    .frame(width: 5)
                    .offset(x: -45 + CGFloat(index * 14), y: -20 + CGFloat(index % 2) * 40)
            }
        }
        .frame(width: 230, height: 190)
    }
}
