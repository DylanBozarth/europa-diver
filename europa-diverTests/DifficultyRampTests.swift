//
//  DifficultyRampTests.swift
//  europa-diverTests
//
//  Data and guard-rails for the depth-based difficulty ramp. Run these and
//  read the console: `levelsGetHarderWithDepth` prints one table row per
//  depth (averaged over many generated levels) so the ramp can be eyeballed
//  without playing through every level. The assertions then pin down the
//  things that must hold — the tutorial is safe, level 2 has no big
//  snakes, and hostiles/obstacles/new species all trend the right way.
//
//  The generator is random, so every trend check compares *averages* over
//  `runs` levels and allows a small tolerance; the per-depth deltas are far
//  larger than the sampling noise, so these don't flake in practice.
//

import Testing
import CoreGraphics
import Foundation
@testable import europa_diver

@Suite("Difficulty ramp", .serialized)
struct DifficultyRampTests {

    /// Levels generated per depth when averaging. Generation is cheap.
    static let runs = 400
    /// Deepest level reported in the tables (a few past `maxRampDepth`, to
    /// show the plateau).
    static let deepestReported = DepthProfile.maxRampDepth + 3

    // MARK: - DepthProfile (deterministic)

    @Test("DepthProfile values ramp in the right direction and then plateau")
    func depthProfileRamps() {
        for depth in 1..<(DepthProfile.maxRampDepth * 2) {
            let shallower = DepthProfile(depth: depth)
            let deeper = DepthProfile(depth: depth + 1)
            let step = "depth \(depth) → \(depth + 1)"

            // Threats only ever go up.
            #expect(deeper.hostileFishPercent >= shallower.hostileFishPercent, "hostile %: \(step)")
            #expect(deeper.unlockedHostileVariantCount >= shallower.unlockedHostileVariantCount, "hostile variants: \(step)")
            #expect(deeper.snakeCount >= shallower.snakeCount, "snakes: \(step)")
            #expect(deeper.smallSnakeCount >= shallower.smallSnakeCount, "small snakes: \(step)")

            // Obstacles get denser and passages tighter.
            #expect(deeper.obstacleSpacing.lowerBound <= shallower.obstacleSpacing.lowerBound, "wall spacing min: \(step)")
            #expect(deeper.obstacleSpacing.upperBound <= shallower.obstacleSpacing.upperBound, "wall spacing max: \(step)")
            #expect(deeper.tunnelGapHeight.lowerBound <= shallower.tunnelGapHeight.lowerBound, "gap min: \(step)")
            #expect(deeper.tunnelGapHeight.upperBound <= shallower.tunnelGapHeight.upperBound, "gap max: \(step)")
            #expect(deeper.fishSpacing.upperBound <= shallower.fishSpacing.upperBound, "fish spacing: \(step)")

            // Reward only ever goes up.
            #expect(deeper.passiveSpeciesPerLevel >= shallower.passiveSpeciesPerLevel, "roster size: \(step)")
            #expect(deeper.newPassiveSpeciesPerLevel >= shallower.newPassiveSpeciesPerLevel, "new species slots: \(step)")
            #expect(deeper.unlockedPassiveSpeciesCount >= shallower.unlockedPassiveSpeciesCount, "unlocked species: \(step)")
            #expect(deeper.scanRewardBonus >= shallower.scanRewardBonus, "scan bonus: \(step)")
        }

        // Past maxRampDepth everything is pinned, not still climbing.
        let cap = DepthProfile(depth: DepthProfile.maxRampDepth)
        let wayDown = DepthProfile(depth: DepthProfile.maxRampDepth * 4)
        #expect(wayDown.hostileFishPercent == cap.hostileFishPercent)
        #expect(wayDown.snakeCount == cap.snakeCount)
        #expect(wayDown.tunnelGapHeight == cap.tunnelGapHeight)
        #expect(wayDown.obstacleSpacing == cap.obstacleSpacing)
        #expect(wayDown.scanRewardBonus == cap.scanRewardBonus)
        #expect(wayDown.progress == 1)
    }

    @Test("Passage height stays wide enough for the submarine at every depth")
    func passagesAlwaysFitTheSub() {
        // Submarine sprite is 44×35 with a 16pt-radius physics body.
        let subHeight: CGFloat = 35
        for depth in 1...(DepthProfile.maxRampDepth * 2) {
            let gap = DepthProfile(depth: depth).tunnelGapHeight
            #expect(gap.lowerBound >= subHeight + 20, "depth \(depth) minimum gap \(gap.lowerBound) is too tight")
        }
    }

    @Test("Species unlock order covers every passive species exactly once")
    func speciesCatalogIsComplete() {
        let order = PassiveSpeciesCatalog.unlockOrder
        #expect(order.count == FishPalette.all.count * 2)
        #expect(Set(order.map(\.id)).count == order.count, "duplicate species in unlock order")
        #expect(DepthProfile(depth: 1).unlockedPassiveSpeciesCount == 2, "tutorial should have exactly two species to find")
    }

    // MARK: - Generated levels: hard guarantees

    @Test("Tutorial (depth 1) has no hostiles, no snakes, and at most two species")
    func tutorialIsSafe() {
        var worst = (hostile: 0, snakes: 0, smallSnakes: 0, species: 0)
        for _ in 0..<Self.runs {
            let census = TestWorld.census(depth: 1)
            worst.hostile = max(worst.hostile, census.hostileFish)
            worst.snakes = max(worst.snakes, census.snakes)
            worst.smallSnakes = max(worst.smallSnakes, census.smallSnakes)
            worst.species = max(worst.species, census.friendlySpecies)
            #expect(census.friendlySpecies >= 1, "tutorial must have something to scan")
        }
        #expect(worst.hostile == 0)
        #expect(worst.snakes == 0)
        #expect(worst.smallSnakes == 0)
        #expect(worst.species <= 2, "tutorial showed \(worst.species) species; wanted 1–2")
    }

    @Test("Depth 2 introduces a few hostile fish but never a big snake")
    func secondLevelIsGentle() {
        let average = TestWorld.sample(depth: 2, runs: Self.runs)
        #expect(average.maxSnakes == 0, "saw \(average.maxSnakes) big snakes on depth 2")
        #expect(average.hostileFish > 0, "depth 2 should introduce hostile fish")
        #expect(average.hostileFish < 3, "depth 2 averages \(average.hostileFish) hostile fish; too many")
        #expect(average.smallSnakes == 1)
    }

    @Test("Per-depth census", arguments: 1...DifficultyRampTests.deepestReported)
    func census(depth: Int) {
        let profile = DepthProfile(depth: depth)
        let unlockedIDs = Set(PassiveSpeciesCatalog.unlockOrder.prefix(profile.unlockedPassiveSpeciesCount).map(\.id))

        for _ in 0..<50 {
            let level = TestWorld.census(depth: depth)

            // Counts that are fixed per depth come out exactly.
            #expect(level.snakes == profile.snakeCount, "depth \(depth) snakes")
            #expect(level.smallSnakes == profile.smallSnakeCount, "depth \(depth) small snakes")

            // Nothing from deeper water leaks upward.
            #expect(level.friendlySpeciesIDs.isSubset(of: unlockedIDs), "depth \(depth) spawned a species not yet unlocked")
            #expect(level.hostileVariants.allSatisfy { $0 < profile.unlockedHostileVariantCount }, "depth \(depth) spawned a hostile variant not yet unlocked")
            #expect(level.friendlySpecies <= profile.passiveSpeciesPerLevel, "depth \(depth) roster overflow")

            // Every passage respects the profile's range.
            #expect(level.gapHeights.allSatisfy { profile.tunnelGapHeight.contains(CGFloat($0)) }, "depth \(depth) gap outside profile range")
        }

        let average = TestWorld.sample(depth: depth, runs: Self.runs)
        if depth == 1 { print(LevelCensusAverage.tableHeader) }
        print(average.tableRow)
    }

    // MARK: - Generated levels: trends

    @Test("Generated levels get harder (and busier) with depth")
    func levelsGetHarderWithDepth() {
        let table = (1...Self.deepestReported).map { TestWorld.sample(depth: $0, runs: Self.runs) }

        print("\nAverage of \(Self.runs) generated levels per depth (world width \(Int(TestWorld.maxX - TestWorld.minX))pt):")
        print(LevelCensusAverage.tableHeader)
        table.forEach { print($0.tableRow) }
        print("")

        // Step-by-step: within the ramp, no metric may move the wrong way
        // between one depth and the next (beyond sampling noise).
        let ramp = table.filter { $0.depth <= DepthProfile.maxRampDepth }
        for (shallower, deeper) in zip(ramp, ramp.dropFirst()) {
            let step = "depth \(shallower.depth) → \(deeper.depth)"

            #expect(deeper.hostileFish >= shallower.hostileFish - 0.5, "hostile fish fell: \(step)")
            #expect(deeper.snakes >= shallower.snakes, "snakes fell: \(step)")
            #expect(deeper.smallSnakes >= shallower.smallSnakes, "small snakes fell: \(step)")
            #expect(deeper.friendlyFish + deeper.hostileFish >= shallower.friendlyFish + shallower.hostileFish - 0.5, "total fish fell: \(step)")

            #expect(deeper.walls >= shallower.walls - 0.5, "wall count fell: \(step)")
            #expect(deeper.rocks >= shallower.rocks - 3, "rock count fell: \(step)")
            #expect(deeper.meanGapHeight <= shallower.meanGapHeight + 1.5, "passages got wider: \(step)")
            #expect(deeper.meanWallSpacing <= shallower.meanWallSpacing + 8, "walls got sparser: \(step)")

            #expect(deeper.friendlySpecies >= shallower.friendlySpecies - 0.3, "species variety fell: \(step)")
        }

        // Big picture: the deepest ramp level must be clearly harder than
        // the tutorial, not just not-easier.
        guard let first = ramp.first, let deepest = ramp.last else {
            Issue.record("no depths sampled")
            return
        }
        #expect(deepest.hostileFish >= first.hostileFish + 4, "hostile fish: \(first.hostileFish) → \(deepest.hostileFish)")
        #expect(deepest.snakes >= 4, "big snakes at max depth: \(deepest.snakes)")
        #expect(deepest.walls >= first.walls * 1.8, "walls: \(first.walls) → \(deepest.walls)")
        #expect(deepest.rocks >= first.rocks * 1.8, "rocks: \(first.rocks) → \(deepest.rocks)")
        #expect(deepest.meanGapHeight <= first.meanGapHeight * 0.6, "mean passage: \(first.meanGapHeight) → \(deepest.meanGapHeight)")
        #expect(deepest.meanWallSpacing <= first.meanWallSpacing * 0.6, "wall spacing: \(first.meanWallSpacing) → \(deepest.meanWallSpacing)")
        #expect(deepest.friendlySpecies >= first.friendlySpecies + 4, "species: \(first.friendlySpecies) → \(deepest.friendlySpecies)")
    }

    @Test("Every depth keeps offering new species to a player who scans everything")
    func deeperLevelsKeepRewardingDiscovery() {
        var discovered: Set<String> = []
        var log: [String] = []

        for depth in 1...DepthProfile.maxRampDepth {
            let average = TestWorld.sample(depth: depth, runs: 100, discovered: discovered)
            log.append("depth \(depth): \(String(format: "%.1f", average.newFriendlySpecies)) undiscovered species per level (\(discovered.count) scanned so far)")

            #expect(average.newFriendlySpecies >= 2, "depth \(depth) offers only \(average.newFriendlySpecies) new species on average")

            // Scan everything in one representative level before descending.
            discovered.formUnion(TestWorld.census(depth: depth, discovered: discovered).friendlySpeciesIDs)
        }

        print("\nCompletionist run:\n" + log.joined(separator: "\n") + "\n")
        #expect(discovered.count >= 30, "only \(discovered.count) species found by depth \(DepthProfile.maxRampDepth)")
        #expect(discovered.count <= DepthProfile(depth: DepthProfile.maxRampDepth).unlockedPassiveSpeciesCount, "found species that shouldn't be unlocked yet")
    }

    @Test("A player who never scans still sees only undiscovered species")
    func undiscoveredSpeciesAreNeverCrowdedOut() {
        for depth in [1, 2, 3, 6, 10] {
            let average = TestWorld.sample(depth: depth, runs: 100, discovered: [])
            #expect(average.newFriendlySpecies == average.friendlySpecies, "depth \(depth) padded with 'familiar' species when nothing has been scanned")
        }
    }
}
