//
//  PointsManager.swift
//  europa-diver
//
//  Tracks the player's persistent point total. Unlike PlayerStats, this
//  survives death (no reset on retry) and app close (backed by UserDefaults).
//

import Foundation

class PointsManager {
    private static let storageKey = "europaDiver.points"

    private(set) var points: Int

    init() {
        points = UserDefaults.standard.integer(forKey: PointsManager.storageKey)
    }

    func addPoints(_ amount: Int) {
        points += amount
        UserDefaults.standard.set(points, forKey: PointsManager.storageKey)
    }

    @discardableResult
    func spendPoints(_ amount: Int) -> Bool {
        guard points >= amount else { return false }
        points -= amount
        UserDefaults.standard.set(points, forKey: PointsManager.storageKey)
        return true
    }
}
