//
//  UpgradeStore.swift
//  europa-diver
//
//  Tracks each submarine upgrade's purchased level. Persists across
//  retries and app relaunches (backed by UserDefaults), same as points.
//
//  Levels track what's been bought and what it costs; every upgrade is
//  wired to an actual gameplay effect (see GameScene) — some (Durability,
//  Speed, Shield, ...) scale per level, others (Electric Shock, Torpedo)
//  just unlock at level 1 for now.
//

import Foundation

enum Upgrade: String, CaseIterable {
    case electricShock
    case light
    case shield
    case speed
    case durability
    case torpedo
    case waveGenerator
    case autoRepair
    case speedThrust

    var displayName: String {
        switch self {
        case .electricShock: return "Electric Shock"
        case .light: return "Light"
        case .shield: return "Shield"
        case .speed: return "Speed"
        case .durability: return "Durability"
        case .torpedo: return "Torpedo"
        case .waveGenerator: return "Wave Generator"
        case .autoRepair: return "Auto Repair"
        case .speedThrust: return "Speed Thrust"
        }
    }

    var icon: String {
        switch self {
        case .electricShock: return "⚡"
        case .light: return "💡"
        case .shield: return "🛡"
        case .speed: return "🚀"
        case .durability: return "🔩"
        case .torpedo: return "🎯"
        case .waveGenerator: return "🌊"
        case .autoRepair: return "🔧"
        case .speedThrust: return "💨"
        }
    }

    var maxLevel: Int { 3 }

    private var baseCost: Int {
        switch self {
        case .electricShock: return 50
        case .light: return 40
        case .shield: return 60
        case .speed: return 45
        case .durability: return 45
        case .torpedo: return 55
        case .waveGenerator: return 50
        case .autoRepair: return 55
        case .speedThrust: return 50
        }
    }

    /// Cost to purchase `level` (1-indexed) — e.g. the cost to go from
    /// level 1 to level 2 is `cost(forLevel: 2)`.
    func cost(forLevel level: Int) -> Int {
        baseCost * level
    }
}

class UpgradeStore {
    private static let levelKeyPrefix = "europaDiver.upgradeLevel."

    func level(of upgrade: Upgrade) -> Int {
        UserDefaults.standard.integer(forKey: Self.levelKeyPrefix + upgrade.rawValue)
    }

    func isOwned(_ upgrade: Upgrade) -> Bool {
        level(of: upgrade) > 0
    }

    /// Cost to buy the next level, or nil if already at max level.
    func nextLevelCost(_ upgrade: Upgrade) -> Int? {
        let next = level(of: upgrade) + 1
        guard next <= upgrade.maxLevel else { return nil }
        return upgrade.cost(forLevel: next)
    }

    @discardableResult
    func levelUp(_ upgrade: Upgrade) -> Bool {
        let next = level(of: upgrade) + 1
        guard next <= upgrade.maxLevel else { return false }
        UserDefaults.standard.set(next, forKey: Self.levelKeyPrefix + upgrade.rawValue)
        return true
    }

    /// Erases every purchased upgrade. Used when starting a New Game.
    func resetAll() {
        for upgrade in Upgrade.allCases {
            UserDefaults.standard.removeObject(forKey: Self.levelKeyPrefix + upgrade.rawValue)
        }
    }
}
