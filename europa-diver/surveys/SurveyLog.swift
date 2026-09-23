//
//  SurveyLog.swift
//  europa-diver
//
//  Tracks which fish species (by FishKind) the player has scanned. Scanning
//  a species that's already logged is a no-op. Persists via UserDefaults.
//

import Foundation

class SurveyLog {
    private static let keyPrefix = "europaDiver.survey.scanned."

    func hasScanned(_ kind: FishKind) -> Bool {
        UserDefaults.standard.bool(forKey: Self.keyPrefix + kind.rawValue)
    }

    func markScanned(_ kind: FishKind) {
        UserDefaults.standard.set(true, forKey: Self.keyPrefix + kind.rawValue)
    }

    /// Erases every scanned species. Used when starting a New Game.
    func resetAll() {
        for kind in FishKind.allCases {
            UserDefaults.standard.removeObject(forKey: Self.keyPrefix + kind.rawValue)
        }
    }
}
