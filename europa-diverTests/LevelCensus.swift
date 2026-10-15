//
//  LevelCensus.swift
//  europa-diverTests
//
//  Test-side instrumentation for the level generator: runs it the way
//  GameScene does, counts what came out (hostiles, friendlies, snakes,
//  walls, passage sizes…), and averages many runs per depth so the random
//  noise of any single level doesn't hide the trend across depths.
//

import CoreGraphics
import Foundation
@testable import europa_diver

/// A stand-in for GameScene's world: ±180 tall, and `screensEachSide` (3)
/// iPhone-landscape widths either side of spawn.
enum TestWorld {
    static let screenWidth: CGFloat = 852
    static let screensEachSide: CGFloat = 3
    static let minX = -screenWidth * screensEachSide
    static let maxX = screenWidth * screensEachSide
    static let bottom: CGFloat = -180
    static let top: CGFloat = 180

    static func generate(depth: Int, discovered: Set<String> = []) -> LevelLayout {
        LevelGenerator(
            worldMinX: minX,
            worldMaxX: maxX,
            worldBottom: bottom,
            worldTop: top,
            profile: DepthProfile(depth: depth),
            discoveredSpeciesIDs: discovered
        ).generate()
    }

    static func census(depth: Int, discovered: Set<String> = []) -> LevelCensus {
        LevelCensus(layout: generate(depth: depth, discovered: discovered), depth: depth, discovered: discovered)
    }

    static func sample(depth: Int, runs: Int, discovered: Set<String> = []) -> LevelCensusAverage {
        LevelCensusAverage((0..<runs).map { _ in census(depth: depth, discovered: discovered) })
    }
}

/// Everything worth knowing about one generated level.
struct LevelCensus {
    let depth: Int

    let friendlyFish: Int
    /// Distinct friendly (small/large) species present.
    let friendlySpecies: Int
    /// Of those, how many the player hasn't scanned yet — the level's reward.
    let newFriendlySpecies: Int
    let friendlySpeciesIDs: Set<String>

    let hostileFish: Int
    let hostileVariants: Set<Int>

    let snakes: Int
    let smallSnakes: Int

    /// Tunnel walls (each one floor-to-ceiling with a single passage).
    let walls: Int
    /// Individual rock bodies making up those walls.
    let rocks: Int
    /// Passage (gap) height through each wall, in points.
    let gapHeights: [Double]
    /// Horizontal distance between consecutive walls, in points.
    let wallSpacings: [Double]

    let ooi: Int

    init(layout: LevelLayout, depth: Int, discovered: Set<String>) {
        self.depth = depth

        let friendly = layout.fishSlots.filter { $0.kind != .hostile }
        let hostile = layout.fishSlots.filter { $0.kind == .hostile }

        friendlyFish = friendly.count
        friendlySpeciesIDs = Set(friendly.map { "\($0.kind.rawValue)-\($0.appearanceIndex)" })
        friendlySpecies = friendlySpeciesIDs.count
        newFriendlySpecies = friendlySpeciesIDs.subtracting(discovered).count

        hostileFish = hostile.count
        hostileVariants = Set(hostile.map(\.appearanceIndex))

        snakes = layout.snakeSlots.count
        smallSnakes = layout.smallSnakeSlots.count

        walls = layout.tunnelWalls.count
        rocks = layout.obstacles.count
        gapHeights = layout.tunnelWalls.map { Double($0.gapHeight) }
        let xs = layout.tunnelWalls.map { Double($0.x) }.sorted()
        wallSpacings = zip(xs.dropFirst(), xs).map { $0 - $1 }

        ooi = layout.ooiSlots.count
    }

    var meanGapHeight: Double { gapHeights.mean }
    var minGapHeight: Double { gapHeights.min() ?? 0 }
    var meanWallSpacing: Double { wallSpacings.mean }
}

/// Per-depth averages over many generated levels, plus the worst case seen
/// for the things that matter most to "is level N unfair?".
struct LevelCensusAverage {
    let depth: Int
    let runs: Int

    let friendlyFish: Double
    let friendlySpecies: Double
    let newFriendlySpecies: Double
    let hostileFish: Double
    let maxHostileFish: Int
    let snakes: Double
    let maxSnakes: Int
    let smallSnakes: Double
    let walls: Double
    let rocks: Double
    let meanGapHeight: Double
    let minGapHeight: Double
    let meanWallSpacing: Double
    let ooi: Double

    init(_ censuses: [LevelCensus]) {
        precondition(!censuses.isEmpty)
        depth = censuses[0].depth
        runs = censuses.count

        friendlyFish = censuses.map { Double($0.friendlyFish) }.mean
        friendlySpecies = censuses.map { Double($0.friendlySpecies) }.mean
        newFriendlySpecies = censuses.map { Double($0.newFriendlySpecies) }.mean
        hostileFish = censuses.map { Double($0.hostileFish) }.mean
        maxHostileFish = censuses.map(\.hostileFish).max() ?? 0
        snakes = censuses.map { Double($0.snakes) }.mean
        maxSnakes = censuses.map(\.snakes).max() ?? 0
        smallSnakes = censuses.map { Double($0.smallSnakes) }.mean
        walls = censuses.map { Double($0.walls) }.mean
        rocks = censuses.map { Double($0.rocks) }.mean
        // Pool every wall from every run so the gap/spacing averages are
        // per-wall, not per-level (levels with more walls count for more).
        meanGapHeight = censuses.flatMap(\.gapHeights).mean
        minGapHeight = censuses.flatMap(\.gapHeights).min() ?? 0
        meanWallSpacing = censuses.flatMap(\.wallSpacings).mean
        ooi = censuses.map { Double($0.ooi) }.mean
    }

    static let tableHeader: String = {
        let columns = [
            "depth", "friendly", "species", "new", "hostile", "(max)", "snakes", "(max)",
            "sm.snk", "walls", "rocks", "gap avg", "gap min", "wall gap", "ooi",
        ]
        let line = columns.map { $0.padding(toLength: 8, withPad: " ", startingAt: 0) }.joined(separator: " ")
        return line + "\n" + String(repeating: "-", count: line.count)
    }()

    var tableRow: String {
        func f(_ value: Double, _ decimals: Int = 1) -> String {
            String(format: "%.\(decimals)f", value).padding(toLength: 8, withPad: " ", startingAt: 0)
        }
        func i(_ value: Int) -> String {
            String(value).padding(toLength: 8, withPad: " ", startingAt: 0)
        }
        return [
            i(depth), f(friendlyFish), f(friendlySpecies), f(newFriendlySpecies),
            f(hostileFish), i(maxHostileFish), f(snakes), i(maxSnakes),
            f(smallSnakes), f(walls), f(rocks, 0), f(meanGapHeight, 0), f(minGapHeight, 0),
            f(meanWallSpacing, 0), f(ooi),
        ].joined(separator: " ")
    }
}

extension Array where Element == Double {
    var mean: Double {
        isEmpty ? 0 : reduce(0, +) / Double(count)
    }
}
