//
//  AdvisorMessages.swift
//  europa-diver
//
//  Every line of text the advisor overlay can show. Kept in one place so
//  copy changes don't require hunting through GameScene.
//

enum AdvisorMessages {
    /// Shown once at the start of a brand new game.
    static let welcome = "Welcome to Europa Diver! Pilot your submarine through the ice shelf. Remember, we're here to find life!"

    /// Shown the first time a fish comes on screen in a brand new game.
    static let firstFish = "Wow, that was easy! Get close to that fish and scan it with the scan button."

    /// Shown the first time an Object of Interest comes on screen, any level.
    static let firstOOI = "Wow! That looks like a bacterial colony. The science department is telling me: Scan that!"

    /// Shown the first time the player dies in a brand new game.
    static let firstDeath = "Well, we found life that hates our drones too. Don't worry, NASA has authorized the funding for another drone. Keep discovering new species, and we'll get you some upgrades."

    /// Shown the first time the entrance to the next level comes on screen
    /// in a brand new game.
    static let firstLevelEntrance = "That looks like a way through the ice, dive deeper!"
}
