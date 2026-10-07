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
        /// Which look to use — a FishPalette index for small/large, or a
        /// hostile variant index for hostile. Combined with `kind`, this is
        /// also the fish's scan-species identity (see Fish.speciesID).
        let appearanceIndex: Int
    }

    struct OOISlot {
        let position: CGPoint
    }

    /// Reserved spot for a future feature (hazards, power-ups, etc.) — no
    /// gameplay behavior yet, just a marked position.
    struct EmptySlot {
        let position: CGPoint
    }

    struct SnakeSlot {
        let position: CGPoint
    }

    let obstacles: [ObstacleSlot]
    let fishSlots: [FishSlot]
    let ooiSlots: [OOISlot]
    let emptySlots: [EmptySlot]
    let snakeSlots: [SnakeSlot]
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
    var maxPassiveFishTypesPerLevel: Int = 4
    var snakeSpacing: ClosedRange<CGFloat> = 2000...4000
    var includeSnakes: Bool = true

    private let fishRoamHalfWidth: CGFloat = 60

    func generate() -> LevelLayout {
        LevelLayout(
            obstacles: generateObstacles(),
            fishSlots: generateFish(),
            ooiSlots: generateOOIs(),
            emptySlots: generateEmptySlots(),
            snakeSlots: generateSnakes()
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
        // Restricts passive (small/large) fish to a handful of palettes per
        // level, drawn fresh each time, so one level doesn't show every
        // possible species at once. Hostile fish aren't subject to this.
        let availablePalettes = Array(0..<FishPalette.all.count)
            .shuffled()
            .prefix(maxPassiveFishTypesPerLevel)

        return positions(spacing: fishSpacing).map { x in
            let kind = randomFishKind()
            let appearanceIndex: Int
            if kind == .hostile {
                // Hostile variants aren't restricted per level.
                appearanceIndex = Int.random(in: 0..<FishTexture.hostileVariantCount)
            } else {
                appearanceIndex = availablePalettes.randomElement() ?? 0
            }

            return LevelLayout.FishSlot(
                position: CGPoint(x: x, y: randomY(margin: 20)),
                kind: kind,
                roamHalfWidth: fishRoamHalfWidth,
                appearanceIndex: appearanceIndex
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

    private func generateSnakes() -> [LevelLayout.SnakeSlot] {
        guard includeSnakes else { return [] }

        return positions(spacing: snakeSpacing).map {
            LevelLayout.SnakeSlot(position: CGPoint(x: $0, y: randomY(margin: 60)))
        }
    }
}
