//
//  LevelGenerator.swift
//  europa-diver
//
//  Produces the full layout for a map of a given size: where obstacles, fish,
//  and objects of interest go, plus a handful of empty slots reserved for
//  future gameplay ideas. Pure data — GameScene turns this into actual nodes.
//
//  Everything that decides *how much* of each thing appears comes from the
//  DepthProfile it's given, so the same generator produces the gentle
//  tutorial at depth 1 and the crowded, snake-infested deep levels later on.
//

import CoreGraphics

/// What a tunnel wall (and the obstacles making it up) is made of. Purely
/// visual — both materials block and damage the player identically;
/// DepthProfile.rockObstaclePercent decides the mix per depth.
enum ObstacleMaterial {
    case ice
    case rock
}

struct LevelLayout {
    struct ObstacleSlot {
        let position: CGPoint
        let material: ObstacleMaterial
    }

    /// One floor-to-ceiling wall and the single passage through it.
    /// `obstacles` holds the individual chunks that make these up; this is
    /// the summary — handy for tests measuring how tight passages get.
    struct TunnelWall {
        let x: CGFloat
        let gapCenterY: CGFloat
        let gapHeight: CGFloat
        let material: ObstacleMaterial
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

    struct SmallSnakeSlot {
        let position: CGPoint
    }

    let obstacles: [ObstacleSlot]
    let tunnelWalls: [TunnelWall]
    let fishSlots: [FishSlot]
    let ooiSlots: [OOISlot]
    let emptySlots: [EmptySlot]
    let snakeSlots: [SnakeSlot]
    let smallSnakeSlots: [SmallSnakeSlot]
}

struct LevelGenerator {
    let worldMinX: CGFloat
    let worldMaxX: CGFloat
    let worldBottom: CGFloat
    let worldTop: CGFloat

    /// Drives every density/count/roster decision below. See DepthProfile.
    let profile: DepthProfile

    /// Species IDs (see Scannable.speciesID) the player has already scanned.
    /// Used to steer the passive-fish roster toward species they haven't
    /// found yet, since discovery is the main source of points.
    var discoveredSpeciesIDs: Set<String> = []

    private let fishRoamHalfWidth: CGFloat = 60

    init(
        worldMinX: CGFloat,
        worldMaxX: CGFloat,
        worldBottom: CGFloat,
        worldTop: CGFloat,
        profile: DepthProfile,
        discoveredSpeciesIDs: Set<String> = []
    ) {
        self.worldMinX = worldMinX
        self.worldMaxX = worldMaxX
        self.worldBottom = worldBottom
        self.worldTop = worldTop
        self.profile = profile
        self.discoveredSpeciesIDs = discoveredSpeciesIDs
    }

    func generate() -> LevelLayout {
        let walls = generateTunnelWalls()
        return LevelLayout(
            obstacles: walls.flatMap(rocks(for:)),
            tunnelWalls: walls,
            fishSlots: generateFish(),
            ooiSlots: generateOOIs(),
            emptySlots: generateEmptySlots(),
            snakeSlots: generateSnakes(),
            smallSnakeSlots: generateSmallSnakes()
        )
    }

    private func positions(spacing: ClosedRange<CGFloat>, in bounds: ClosedRange<CGFloat>? = nil) -> [CGFloat] {
        let range = bounds ?? (worldMinX...worldMaxX)
        var xs: [CGFloat] = []
        var x = range.lowerBound
        while x <= range.upperBound {
            x += CGFloat.random(in: spacing)
            guard x <= range.upperBound else { break }
            xs.append(x)
        }
        return xs
    }

    /// Exactly `count` x positions spread across the world: the width is cut
    /// into `count` equal bands and one random x is drawn from each, so a
    /// fixed number of things (snakes) can't all bunch up at one end.
    private func spreadPositions(count: Int, edgeMargin: CGFloat = 150) -> [CGFloat] {
        guard count > 0 else { return [] }

        let usableMinX = worldMinX + edgeMargin
        let usableMaxX = worldMaxX - edgeMargin
        guard usableMaxX > usableMinX else { return [] }

        let bandWidth = (usableMaxX - usableMinX) / CGFloat(count)
        return (0..<count).map { index in
            let bandStart = usableMinX + bandWidth * CGFloat(index)
            return CGFloat.random(in: bandStart...(bandStart + bandWidth))
        }
    }

    private func randomY(margin: CGFloat) -> CGFloat {
        CGFloat.random(in: (worldBottom + margin)...(worldTop - margin))
    }

    /// Each obstacle column is a floor-to-ceiling rock wall with a single
    /// gap, like a tunnel the player has to aim for, rather than isolated
    /// floating rocks — the gap's height and position are randomized per
    /// wall so later walls can't be passed on autopilot.
    private func generateTunnelWalls() -> [LevelLayout.TunnelWall] {
        positions(spacing: profile.obstacleSpacing).map { x in
            let gapHeight = CGFloat.random(in: profile.tunnelGapHeight)
            let margin: CGFloat = 50
            let gapCenterY = CGFloat.random(
                in: (worldBottom + margin + gapHeight / 2)...(worldTop - margin - gapHeight / 2)
            )
            let material: ObstacleMaterial = Int.random(in: 0..<100) < profile.rockObstaclePercent ? .rock : .ice
            return LevelLayout.TunnelWall(x: x, gapCenterY: gapCenterY, gapHeight: gapHeight, material: material)
        }
    }

    private func rocks(for wall: LevelLayout.TunnelWall) -> [LevelLayout.ObstacleSlot] {
        stackedRocks(x: wall.x, from: worldBottom, to: wall.gapCenterY - wall.gapHeight / 2, material: wall.material)
            + stackedRocks(x: wall.x, from: wall.gapCenterY + wall.gapHeight / 2, to: worldTop, material: wall.material)
    }

    /// Chains chunks from `startY` to `endY` close enough together that
    /// consecutive ones always overlap (even with the horizontal jitter),
    /// so the wall reads as one solid, slightly jagged face rather than a
    /// perfect line of circles with gaps in it.
    private func stackedRocks(
        x: CGFloat,
        from startY: CGFloat,
        to endY: CGFloat,
        material: ObstacleMaterial
    ) -> [LevelLayout.ObstacleSlot] {
        guard endY > startY else { return [] }

        let radius = WorldConstants.obstacleRadius
        let step = radius * 1.5
        let jitter = radius * 0.3

        var slots: [LevelLayout.ObstacleSlot] = []
        var y = startY
        while y < endY {
            let jitteredX = x + CGFloat.random(in: -jitter...jitter)
            slots.append(LevelLayout.ObstacleSlot(position: CGPoint(x: jitteredX, y: y), material: material))
            y += step
        }
        return slots
    }

    private func generateFish() -> [LevelLayout.FishSlot] {
        let xs = profile.depth == 1 ? edgeFishXs() : positions(spacing: profile.fishSpacing)
        guard !xs.isEmpty else { return [] }

        // Decide which slots are hostile first, then hand every remaining
        // slot a passive species from this depth's roster.
        let isHostile = xs.map { _ in Int.random(in: 0..<100) < profile.hostileFishPercent }
        let passiveSlotCount = isHostile.filter { !$0 }.count
        var passiveSpecies = passiveSpeciesAssignments(count: passiveSlotCount)

        return zip(xs, isHostile).map { x, hostile in
            let kind: FishKind
            let appearanceIndex: Int
            if hostile {
                kind = .hostile
                appearanceIndex = Int.random(in: 0..<max(1, profile.unlockedHostileVariantCount))
            } else {
                let species = passiveSpecies.isEmpty
                    ? PassiveSpeciesCatalog.unlockOrder[0]
                    : passiveSpecies.removeFirst()
                kind = species.kind
                appearanceIndex = species.paletteIndex
            }

            return LevelLayout.FishSlot(
                position: CGPoint(x: x, y: randomY(margin: 20)),
                kind: kind,
                roamHalfWidth: fishRoamHalfWidth,
                appearanceIndex: appearanceIndex
            )
        }
    }

    /// The handful of passive species this level is allowed to show, out of
    /// everything unlocked at this depth. Slots reserved for undiscovered
    /// species are filled first — species making their first-ever
    /// appearance at this depth ahead of older ones the player skipped —
    /// then the rest are padded with familiar, already-scanned species.
    /// Early on, before anything has been scanned, it just ends up being
    /// all-new fish, which is exactly what the tutorial wants.
    private func passiveSpeciesRoster() -> [PassiveSpeciesCatalog.Species] {
        let unlocked = PassiveSpeciesCatalog.unlockOrder.prefix(profile.unlockedPassiveSpeciesCount)
        let firstNewIndex = profile.previouslyUnlockedPassiveSpeciesCount

        var brandNew: [PassiveSpeciesCatalog.Species] = []
        var olderUndiscovered: [PassiveSpeciesCatalog.Species] = []
        var discovered: [PassiveSpeciesCatalog.Species] = []
        for (index, species) in unlocked.enumerated() {
            if discoveredSpeciesIDs.contains(species.id) {
                discovered.append(species)
            } else if index >= firstNewIndex {
                brandNew.append(species)
            } else {
                olderUndiscovered.append(species)
            }
        }

        let undiscovered = brandNew.shuffled() + olderUndiscovered.shuffled()
        let rosterSize = min(profile.passiveSpeciesPerLevel, unlocked.count)
        let newSlots = min(profile.newPassiveSpeciesPerLevel, rosterSize)

        let reservedNew = Array(undiscovered.prefix(newSlots))
        var roster = reservedNew
        roster += discovered.shuffled().prefix(max(0, rosterSize - roster.count))
        // Not enough scanned species to pad with yet — show more new ones.
        roster += undiscovered.dropFirst(reservedNew.count).prefix(max(0, rosterSize - roster.count))
        return roster
    }

    /// One species per passive fish slot. Every roster species gets at least
    /// one fish (slots permitting) so a level's "new discovery" is actually
    /// out there to be found, and the remaining slots are filled at random.
    private func passiveSpeciesAssignments(count: Int) -> [PassiveSpeciesCatalog.Species] {
        let roster = passiveSpeciesRoster()
        guard count > 0, !roster.isEmpty else { return [] }

        var assignments = Array(roster.prefix(count))
        while assignments.count < count {
            assignments.append(roster.randomElement()!)
        }
        return assignments.shuffled()
    }

    /// Tutorial-only: fish only spawn near the far edges of the world,
    /// well outside the player's starting view, so the first-fish tip
    /// triggers once they've actually swum to find one instead of firing
    /// immediately at spawn.
    private func edgeFishXs() -> [CGFloat] {
        let edgeBandWidth = (worldMaxX - worldMinX) * 0.2
        guard edgeBandWidth > 0 else { return [] }

        let left = positions(spacing: profile.fishSpacing, in: worldMinX...(worldMinX + edgeBandWidth))
        let right = positions(spacing: profile.fishSpacing, in: (worldMaxX - edgeBandWidth)...worldMaxX)
        return left + right
    }

    private func generateOOIs() -> [LevelLayout.OOISlot] {
        // Held back from the tutorial entirely — depth 1 is about teaching
        // scanning on fish, not objects of interest.
        guard profile.depth > 1 else { return [] }

        return positions(spacing: profile.ooiSpacing).map {
            LevelLayout.OOISlot(position: CGPoint(x: $0, y: randomY(margin: 40)))
        }
    }

    private func generateEmptySlots() -> [LevelLayout.EmptySlot] {
        positions(spacing: profile.emptySlotSpacing).map {
            LevelLayout.EmptySlot(position: CGPoint(x: $0, y: randomY(margin: 40)))
        }
    }

    private func generateSnakes() -> [LevelLayout.SnakeSlot] {
        spreadPositions(count: profile.snakeCount).map {
            LevelLayout.SnakeSlot(position: CGPoint(x: $0, y: randomY(margin: 60)))
        }
    }

    private func generateSmallSnakes() -> [LevelLayout.SmallSnakeSlot] {
        spreadPositions(count: profile.smallSnakeCount).map {
            LevelLayout.SmallSnakeSlot(position: CGPoint(x: $0, y: randomY(margin: 30)))
        }
    }
}
