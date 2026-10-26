//
//  DeathPenaltyWaiver.swift
//  europa-diver
//
//  Tracks whether the player has already used their one free drone
//  replacement for this playthrough — the point penalty is waived for the
//  very first death, then applies normally after. Persists across app
//  relaunches (backed by UserDefaults) like points and depth progress, and
//  is cleared only when starting a New Game.
//

import Foundation

class DeathPenaltyWaiver {
    private static let storageKey = "europaDiver.firstDeathWaiverUsed"

    private(set) var hasBeenUsed: Bool

    init() {
        hasBeenUsed = UserDefaults.standard.bool(forKey: Self.storageKey)
    }

    func markUsed() {
        hasBeenUsed = true
        UserDefaults.standard.set(true, forKey: Self.storageKey)
    }

    /// Used when starting a New Game.
    func reset() {
        hasBeenUsed = false
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
    }
}
