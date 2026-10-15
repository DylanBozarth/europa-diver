//
//  SurveyLog.swift
//  europa-diver
//
//  Tracks which species the player has scanned, keyed by Scannable.speciesID
//  (kind + appearance for Fish, so e.g. the large red fish and the small red
//  fish count as different species; a fixed string for single-look species
//  like SmallSnake). Scanning one that's already logged is a no-op.
//  Persists via UserDefaults.
//

import Foundation

class SurveyLog {
    private static let keyPrefix = "europaDiver.survey.scanned."

    func hasScanned(_ speciesID: String) -> Bool {
        UserDefaults.standard.bool(forKey: Self.keyPrefix + speciesID)
    }

    func markScanned(_ speciesID: String) {
        UserDefaults.standard.set(true, forKey: Self.keyPrefix + speciesID)
    }

    /// Every species ID that can ever be scanned: each fish kind/appearance
    /// combination plus the single-look small snake.
    static var allSpeciesIDs: [String] {
        var ids: [String] = []
        for kind in FishKind.allCases {
            let variantCount = kind == .hostile ? FishTexture.hostileVariantCount : FishPalette.all.count
            for index in 0..<variantCount {
                ids.append("\(kind.rawValue)-\(index)")
            }
        }
        ids.append("smallSnake")
        return ids
    }

    /// IDs of everything scanned so far. The level generator uses this to
    /// bias each level toward species the player hasn't found yet.
    func scannedSpeciesIDs() -> Set<String> {
        Set(Self.allSpeciesIDs.filter(hasScanned))
    }

    /// Erases every scanned species. Used when starting a New Game.
    func resetAll() {
        for id in Self.allSpeciesIDs {
            UserDefaults.standard.removeObject(forKey: Self.keyPrefix + id)
        }
    }
}
