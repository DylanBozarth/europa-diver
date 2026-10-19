//
//  DepthProgress.swift
//  europa-diver
//
//  Remembers the depth the player was at when they last died, so Continue
//  from the main menu resumes there instead of always restarting at depth
//  1. Persists via UserDefaults, same as points.
//

import Foundation

class DepthProgress {
    private static let storageKey = "europaDiver.lastDepth"

    private(set) var depth: Int

    init() {
        let stored = UserDefaults.standard.integer(forKey: Self.storageKey)
        depth = stored > 0 ? stored : 1
    }

    func save(_ depth: Int) {
        self.depth = depth
        UserDefaults.standard.set(depth, forKey: Self.storageKey)
    }

    /// Used when starting a New Game.
    func reset() {
        depth = 1
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
    }
}
