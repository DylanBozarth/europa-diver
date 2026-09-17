//
//  PlayerStats.swift
//  europa-diver
//
//  Tracks the submarine's power, durability, and inventory. Pure data/state —
//  nothing in the game triggers or reads these yet, and there's no UI for
//  them yet either.
//

import Foundation

struct InventoryItem: Equatable {
    let name: String
}

class PlayerStats {
    static let maxPower = 100
    static let maxDurability = 100

    private(set) var power: Int
    private(set) var durability: Int
    private(set) var inventory: [InventoryItem]

    init(power: Int = PlayerStats.maxPower, durability: Int = PlayerStats.maxDurability, inventory: [InventoryItem] = []) {
        self.power = power.clamped(to: 0...PlayerStats.maxPower)
        self.durability = durability.clamped(to: 0...PlayerStats.maxDurability)
        self.inventory = inventory
    }

    func adjustPower(by amount: Int) {
        power = (power + amount).clamped(to: 0...PlayerStats.maxPower)
    }

    func adjustDurability(by amount: Int) {
        durability = (durability + amount).clamped(to: 0...PlayerStats.maxDurability)
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
}

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
