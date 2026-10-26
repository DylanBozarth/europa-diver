//
//  DepthProfile.swift
//  europa-diver
//
//  Created by Dylan Bozarth on 10/15/26.
//


//
//  DepthProfile.swift
//  europa-diver
//
//  Turns a level number ("depth") into the knobs LevelGenerator runs on, so
//  difficulty and reward ramp up linearly the deeper the player goes instead
//  of every post-tutorial level being rolled from one fixed set of ranges.
//
//  Every value here is derived from `depth`, and most of them lerp from a
//  gentle "shallows" setting at depth 1 to a harsh "abyss" setting at
//  `maxRampDepth`; past that, difficulty stays pinned at the maximum. The
//  few things that shouldn't be continuous (snake counts, which hostile
//  variants exist yet) use explicit per-depth rules instead. Tuning the
//  game's pacing should only ever mean editing numbers in this file.
//

import CoreGraphics

struct DepthProfile {
    /// 1-based level number. Depth 1 is the tutorial.
    let depth: Int

    /// Depth at which every ramping value reaches its maximum.
    static let maxRampDepth = 12

    /// Depth at which the water turns fully black.
    static let maxDarknessDepth = 10

    init(depth: Int) {
        self.depth = max(1, depth)
    }

    /// 0 at depth 1, 1 at `maxRampDepth` and beyond, linear in between.
    var progress: CGFloat {
        let ramp = CGFloat(Self.maxRampDepth - 1)
        guard ramp > 0 else { return 1 }
        return min(1, CGFloat(depth - 1) / ramp)
    }

    /// 0 at the surface, 1 (pitch black) by `maxDarknessDepth` and beyond.
    /// Kept separate from `progress` since the environment should finish
    /// going dark at a different depth than the difficulty ramp maxes out.
    var darkness: CGFloat {
        let ramp = CGFloat(Self.maxDarknessDepth - 1)
        guard ramp > 0 else { return 1 }
        return min(1, CGFloat(depth - 1) / ramp)
    }

    // MARK: - Obstacles

    /// Distance between tunnel walls: sparse in the shallows, dense in the deep.
    var obstacleSpacing: ClosedRange<CGFloat> {
        lerpRange(from: 600...850, to: 260...400)
    }

    /// Height of the gap in each tunnel wall: roomy at first, tight later.
    /// The sub is 44×35, so even the deepest gap still fits it with some
    /// margin — it just takes real aim.
    var tunnelGapHeight: ClosedRange<CGFloat> {
        lerpRange(from: 120...160, to: 60...90)
    }

    /// Percent chance (0–100) that a given tunnel wall is rock rather than
    /// ice. 0 at depth 1 (the tutorial is all ice shelf), climbing to pure
    /// rock by max depth as the ice shelf gives way to the seabed.
    var rockObstaclePercent: Int {
        guard depth > 1 else { return 0 }
        return Int(lerp(from: 0, to: 100).rounded())
    }

    // MARK: - Fish

    /// Distance between fish. Tightens with depth so deeper waters are
    /// busier — both more hostiles and more things to scan.
    var fishSpacing: ClosedRange<CGFloat> {
        lerpRange(from: 220...360, to: 120...220)
    }

    /// Percent chance (0–100) that any given fish slot becomes a hostile
    /// fish. Zero on the tutorial, a token few on level 2, climbing to
    /// nearly a third of all fish by max depth.
    var hostileFishPercent: Int {
        guard depth > 1 else { return 0 }
        return Int(lerp(from: 5, to: 30).rounded())
    }

    /// How many of the three hostile looks can appear. Each look is its own
    /// scannable species, so these are introduced one at a time as both a
    /// new threat and a new discovery.
    var unlockedHostileVariantCount: Int {
        switch depth {
        case ..<2: return 0
        case 2...3: return 1
        case 4...5: return 2
        default: return FishTexture.hostileVariantCount
        }
    }

    /// Number of passive species the level's roster holds — i.e. how many
    /// distinct small/large looks can show up at once. 2 on the tutorial.
    var passiveSpeciesPerLevel: Int {
        Int(lerp(from: 2, to: 8).rounded())
    }

    /// How many roster slots are reserved for species the player hasn't
    /// scanned yet (when any remain). Grows with depth so "brand new" fish
    /// become a bigger share of what's swimming around the deeper you go.
    var newPassiveSpeciesPerLevel: Int {
        min(passiveSpeciesPerLevel, Int(lerp(from: 2, to: 5).rounded()))
    }

    /// Size of the passive-species pool that exists at this depth, as a
    /// prefix of `PassiveSpeciesCatalog.unlockOrder`. Two species exist in
    /// the tutorial; each level down adds three more until the catalog runs
    /// out, so going deeper is the only way to find anything new.
    var unlockedPassiveSpeciesCount: Int {
        min(PassiveSpeciesCatalog.unlockOrder.count, 2 + 3 * (depth - 1))
    }

    /// Pool size one level up — anything with an unlock index at or beyond
    /// this count is making its first-ever appearance at this depth.
    var previouslyUnlockedPassiveSpeciesCount: Int {
        depth > 1 ? DepthProfile(depth: depth - 1).unlockedPassiveSpeciesCount : 0
    }

    // MARK: - Snakes

    /// Big hostile snakes are the hardest enemy, so they're held back until
    /// depth 3 and then added one at a time every other level.
    /// Depth 1–2: 0, 3–4: 1, 5–6: 2, 7–8: 3, 9–10: 4, 11+: 5.
    var snakeCount: Int {
        guard depth >= 3 else { return 0 }
        return min(5, (depth - 1) / 2)
    }

    /// Small snakes are harmless but skittish, and scannable — so they're a
    /// reward as much as a challenge. One shows up on level 2; more later.
    /// Depth 1: 0, 2–3: 1, 4–5: 2, 6–7: 3, 8+: 4.
    var smallSnakeCount: Int {
        guard depth >= 2 else { return 0 }
        return min(4, depth / 2)
    }

    // MARK: - Other spawns

    /// Objects of interest are rare — worth hunting for at 1000 points each,
    /// not something you trip over. Still a little denser with depth, same
    /// as everything else, but the whole range is pulled way out compared
    /// to a normal spawn.
    var ooiSpacing: ClosedRange<CGFloat> {
        lerpRange(from: 1600...2400, to: 1000...1600)
    }

    /// Spacing between lone drifting ice chunks, scattered independently of
    /// the tunnel walls.
    var iceChunkSpacing: ClosedRange<CGFloat> { 500...900 }

    // MARK: - Reward

    /// Extra points added to every successful scan at this depth, on top of
    /// GameScene's base scan reward, so a discovery made deep down is worth
    /// more than the same effort near the surface.
    var scanRewardBonus: Int {
        Int(lerp(from: 0, to: 250).rounded())
    }

    // MARK: - Helpers

    private func lerp(from shallow: CGFloat, to abyss: CGFloat) -> CGFloat {
        shallow + (abyss - shallow) * progress
    }

    private func lerpRange(from shallow: ClosedRange<CGFloat>, to abyss: ClosedRange<CGFloat>) -> ClosedRange<CGFloat> {
        let lower = lerp(from: shallow.lowerBound, to: abyss.lowerBound)
        let upper = lerp(from: shallow.upperBound, to: abyss.upperBound)
        return min(lower, upper)...max(lower, upper)
    }
}

/// The fixed order in which passive (small/large) fish species are
/// introduced as the player descends. Each entry is one scannable species
/// (kind + palette, matching Fish.speciesID), and
/// `DepthProfile.unlockedPassiveSpeciesCount` decides how much of this
/// list exists at a given depth.
///
/// The order alternates body shape and strides through the palette list by
/// 7 (coprime with its 20 entries), so consecutive unlocks are different
/// shapes in clearly different colors rather than near-twins. The second
/// half of the list revisits every palette with the opposite body shape.
enum PassiveSpeciesCatalog {
    struct Species: Equatable {
        let kind: FishKind
        let paletteIndex: Int

        /// Must match `Fish.speciesID` for the same kind/appearance.
        var id: String { "\(kind.rawValue)-\(paletteIndex)" }
    }

    static let unlockOrder: [Species] = {
        let paletteCount = FishPalette.all.count
        var order: [Species] = []
        for pass in 0..<2 {
            for step in 0..<paletteCount {
                let palette = (step * 7) % paletteCount
                let kind: FishKind = (step + pass) % 2 == 0 ? .small : .large
                order.append(Species(kind: kind, paletteIndex: palette))
            }
        }
        return order
    }()
}
