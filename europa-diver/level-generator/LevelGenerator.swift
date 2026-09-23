//
//  LevelGenerator.swift
//  europa-diver
//
//  Produces the full layout for a map of a given size: where obstacles, fish,
//  and objects of interest go, plus a handful of empty slots reserved for
//  future gameplay ideas. Pure data — GameScene turns this into actual nodes.
//

import CoreGraphics

struct LevelLayout {
    struct ObstacleSlot {
        let position: CGPoint
    }

    struct FishSlot {
        let position: CGPoint
        let kind: FishKind
        let roamHalfWidth: CGFloat
    }

    struct OOISlot {
        let position: CGPoint
    }

    /// Reserved spot for a future feature (hazards, power-ups, etc.) — no
    /// gameplay behavior yet, just a marked position.
    struct EmptySlot {
        let position: CGPoint
    }

    let obstacles: [ObstacleSlot]
    let fishSlots: [FishSlot]
    let ooiSlots: [OOISlot]
    let emptySlots: [EmptySlot]
}

struct LevelGenerator {
    let worldMinX: CGFloat
    let worldMaxX: CGFloat
    let worldBottom: CGFloat
    let worldTop: CGFloat

    var obstacleSpacing: ClosedRange<CGFloat> = 120...220
    var fishSpacing: ClosedRange<CGFloat> = 150...300
    var ooiSpacing: ClosedRange<CGFloat> = 300...600
    var emptySlotSpacing: ClosedRange<CGFloat> = 500...900
    var includeHostileFish: Bool = true

    private let fishRoamHalfWidth: CGFloat = 60

    func generate() -> LevelLayout {
        LevelLayout(
            obstacles: generateObstacles(),
            fishSlots: generateFish(),
            ooiSlots: generateOOIs(),
            emptySlots: generateEmptySlots()
        )
    }

    private func positions(spacing: ClosedRange<CGFloat>) -> [CGFloat] {
        var xs: [CGFloat] = []
        var x = worldMinX
        while x <= worldMaxX {
            x += CGFloat.random(in: spacing)
            guard x <= worldMaxX else { break }
            xs.append(x)
        }
        return xs
    }

    private func randomY(margin: CGFloat) -> CGFloat {
        CGFloat.random(in: (worldBottom + margin)...(worldTop - margin))
    }

    private func generateObstacles() -> [LevelLayout.ObstacleSlot] {
        positions(spacing: obstacleSpacing).map {
            LevelLayout.ObstacleSlot(position: CGPoint(x: $0, y: randomY(margin: 40)))
        }
    }

    private func generateFish() -> [LevelLayout.FishSlot] {
        positions(spacing: fishSpacing).map {
            LevelLayout.FishSlot(
                position: CGPoint(x: $0, y: randomY(margin: 20)),
                kind: randomFishKind(),
                roamHalfWidth: fishRoamHalfWidth
            )
        }
    }

    private func randomFishKind() -> FishKind {
        guard includeHostileFish else {
            return Int.random(in: 0..<100) < 60 ? .small : .large
        }

        switch Int.random(in: 0..<100) {
        case 0..<60: return .small
        case 60..<90: return .large
        default: return .hostile
        }
    }

    private func generateOOIs() -> [LevelLayout.OOISlot] {
        positions(spacing: ooiSpacing).map {
            LevelLayout.OOISlot(position: CGPoint(x: $0, y: randomY(margin: 40)))
        }
    }

    private func generateEmptySlots() -> [LevelLayout.EmptySlot] {
        positions(spacing: emptySlotSpacing).map {
            LevelLayout.EmptySlot(position: CGPoint(x: $0, y: randomY(margin: 40)))
        }
    }
}
