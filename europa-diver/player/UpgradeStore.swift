//
//  UpgradeStore.swift
//  europa-diver
//
//  Tracks which submarine upgrades have been purchased. Persists across
//  retries and app relaunches (backed by UserDefaults), same as points.
//

import Foundation

enum Upgrade: String, CaseIterable {
    case electricShock
    case light
    case shield
}

class UpgradeStore {
    private static let ownedKeyPrefix = "europaDiver.upgrade."

    func isOwned(_ upgrade: Upgrade) -> Bool {
        UserDefaults.standard.bool(forKey: Self.ownedKeyPrefix + upgrade.rawValue)
    }

    func markOwned(_ upgrade: Upgrade) {
        UserDefaults.standard.set(true, forKey: Self.ownedKeyPrefix + upgrade.rawValue)
    }

    /// Erases every purchased upgrade. Used when starting a New Game.
    func resetAll() {
        for upgrade in Upgrade.allCases {
            UserDefaults.standard.removeObject(forKey: Self.ownedKeyPrefix + upgrade.rawValue)
        }
    }
}
