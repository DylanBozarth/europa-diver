//
//  DifficultySettings.swift
//  europa-diver
//
//  Persists the difficulty chosen on the New Game panel (backed by
//  UserDefaults, like points and depth progress) so it stays in effect for
//  the rest of the playthrough, including across "Continue".
//

import Foundation

class DifficultySettings {
    private static let storageKey = "europaDiver.difficulty"

    private(set) var difficulty: Difficulty

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey), let saved = Difficulty(rawValue: raw) {
            difficulty = saved
        } else {
            difficulty = .medium
        }
    }

    func set(_ difficulty: Difficulty) {
        self.difficulty = difficulty
        UserDefaults.standard.set(difficulty.rawValue, forKey: Self.storageKey)
    }
}
