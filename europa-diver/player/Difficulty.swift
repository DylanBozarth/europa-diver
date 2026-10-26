//
//  Difficulty.swift
//  europa-diver
//
//  Chosen once per playthrough from the New Game panel. The only thing it
//  changes is how many points a scan is worth — nothing about spawn rates,
//  damage, or hostility ramps with it. More points means an easier time
//  affording upgrades and drone replacements, so every reward (fish/snake
//  scans and OOI alike) pays more on Easy and less on Hard.
//

import Foundation

enum Difficulty: String, CaseIterable {
    case easy
    case medium
    case hard

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }

    /// Points for scanning a fish or snake (before DepthProfile.scanRewardBonus).
    var scanRewardPoints: Int {
        switch self {
        case .easy: return 300
        case .medium: return 200
        case .hard: return 100
        }
    }

    /// Points for scanning an Object of Interest.
    var ooiPointValue: Int {
        switch self {
        case .easy: return 1000
        case .medium: return 500
        case .hard: return 250
        }
    }
}
