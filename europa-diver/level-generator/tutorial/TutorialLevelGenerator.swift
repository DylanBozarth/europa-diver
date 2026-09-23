//
//  TutorialLevelGenerator.swift
//  europa-diver
//
//  Layout for the very first level: the same generation engine as
//  LevelGenerator, but with no hostile fish, so the player can learn to
//  move, scan, and collect without being chased or damaged.
//

import CoreGraphics

struct TutorialLevelGenerator {
    let worldMinX: CGFloat
    let worldMaxX: CGFloat
    let worldBottom: CGFloat
    let worldTop: CGFloat

    func generate() -> LevelLayout {
        var generator = LevelGenerator(
            worldMinX: worldMinX,
            worldMaxX: worldMaxX,
            worldBottom: worldBottom,
            worldTop: worldTop
        )
        generator.includeHostileFish = false
        return generator.generate()
    }
}
