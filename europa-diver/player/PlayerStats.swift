//
//  PlayerStats.swift
//  europa-diver
//
//  Tracks the submarine's power, durability, and inventory. Max durability
//  is configurable (rather than a flat constant) so the Durability shop
//  upgrade can raise it.
//

import Foundation

struct InventoryItem: Equatable {
    let name: String
}

class PlayerStats {
    static let basePower = 100
    static let baseDurability = 100

    private(set) var maxPower: Int
    private(set) var maxDurability: Int
    private(set) var power: Int
    private(set) var durability: Int
    private(set) var inventory: [InventoryItem]

    init(maxPower: Int = PlayerStats.basePower, maxDurability: Int = PlayerStats.baseDurability) {
        self.maxPower = maxPower
        self.maxDurability = maxDurability
        self.power = maxPower
        self.durability = maxDurability
        self.inventory = []
    }

    func adjustPower(by amount: Int) {
        power = (power + amount).clamped(to: 0...maxPower)
    }

    func adjustDurability(by amount: Int) {
        durability = (durability + amount).clamped(to: 0...maxDurability)
    }

    func addItem(_ item: InventoryItem) {
        inventory.append(item)
    }

    @discardableResult
    func removeItem(_ item: InventoryItem) -> Bool {
        guard let index = inventory.firstIndex(of: item) else { return false }
        inventory.remove(at: index)
        return true
    }

    /// Restores power/durability to full and applies the current max
    /// durability (e.g. after buying a Durability upgrade in the shop).
    func reset(maxDurability: Int) {
        self.maxDurability = maxDurability
        power = maxPower
        durability = maxDurability
        inventory.removeAll()
    }
}

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
