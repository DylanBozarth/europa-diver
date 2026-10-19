//
//  GameScene.swift
//  europa-diver
//
//  Created by Dylan Bozarth on 9/15/26.
//

import SpriteKit

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0x1 << 0
    static let obstacle: UInt32 = 0x1 << 1
    static let wall: UInt32 = 0x1 << 2
    static let smallFish: UInt32 = 0x1 << 3
    static let largeFish: UInt32 = 0x1 << 4
    static let hostileFish: UInt32 = 0x1 << 5
    static let ooi: UInt32 = 0x1 << 6
    static let levelEntrance: UInt32 = 0x1 << 7
    static let snake: UInt32 = 0x1 << 8
    static let smallSnake: UInt32 = 0x1 << 9
    static let torpedo: UInt32 = 0x1 << 10
}

enum WorldConstants {
    static let obstacleRadius: CGFloat = 20
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    private let player = SKSpriteNode(texture: SubmarineTexture.make(), size: CGSize(width: 44, height: 35))
    private let playerRadius: CGFloat = 16
    private let playerStats = PlayerStats()
    private let cameraNode = SKCameraNode()
    private let joystick = Joystick()
    private var joystickTouch: UITouch?
    private let baseMoveSpeed: CGFloat = 110
    private let speedBonusPerLevel: CGFloat = 15
    /// Base speed plus whatever the Speed upgrade currently adds.
    private var moveSpeed: CGFloat {
        baseMoveSpeed + CGFloat(upgradeStore.level(of: .speed)) * speedBonusPerLevel
    }

    private var pressedButtonTouches: [UITouch: HUDButton] = [:]

    private let loadingOverlay = LoadingOverlay()
    private var isLoadingLevel = false

    private let scannerButton = HUDButton(icon: "🔍")
    private let lightButton = HUDButton(icon: "💡")
    private let shieldButton = HUDButton(icon: "🛡️")
    private let shockButton = HUDButton(icon: "⚡")
    private let shockRadius: CGFloat = 100
    private let shockPowerCost = 20

    private let torpedoButton = HUDButton(icon: "🎯")
    private let torpedoPowerCost = 10
    private let torpedoSpeed: CGFloat = 70
    private let torpedoFrightenDuration: TimeInterval = 30

    private let waveGeneratorRegenPerLevel = 1
    private var waveGeneratorTimer: TimeInterval = 0
    private let waveGeneratorInterval: TimeInterval = 1.0

    private let autoRepairButton = HUDButton(icon: "🔧")
    private let autoRepairPowerCost = 15
    private let autoRepairDurabilityPerLevel = 10

    private let surveyLog = SurveyLog()
    private let scanRadius: CGFloat = 100
    private let scanProgressBar = ScanProgressBar()
    private var scanTarget: (any Scannable)?
    private var scanElapsed: TimeInterval = 0
    private let scanDuration: TimeInterval = 3.0
    private let scanRewardPoints = 300

    private let statsHUD = PlayerStatsHUD()

    private let pointsManager = PointsManager()
    private let pointsHUD = PointsHUD()
    private let ooiPointValue = 10

    private let gameOverOverlay = GameOverOverlay()
    private var isGameOver = false

    private let shopOverlay = ShopOverlay()
    private var isShopOpen = false

    private let advisorOverlay = AdvisorOverlay()
    private var isAdvisorShowing = false

    private let upgradeStore = UpgradeStore()
    private let durabilityBonusPerLevel = 20

    private var touchingHostileFish: Set<Fish> = []
    private var nibbleTimer: TimeInterval = 0
    private let nibbleInterval: TimeInterval = 0.5
    private let nibbleDamagePerFish = 5
    private let hostileFishContactRange: CGFloat = 50

    private var lastObstacleHitTime: TimeInterval = 0
    private let obstacleHitCooldown: TimeInterval = 0.5
    private let obstacleDamage = 10

    private let worldTop: CGFloat = 180
    private let worldBottom: CGFloat = -180

    private let screensEachSide = 3
    private var worldMinX: CGFloat = 0
    private var worldMaxX: CGFloat = 0

    /// The sub enters from the ice above, so it spawns near the top of the
    /// world rather than dead center.
    private var spawnPosition: CGPoint { CGPoint(x: 0, y: worldTop - 50) }
    /// Obstacles and hostile fish can't generate within this radius of the
    /// spawn point, so the player never appears already stuck in a rock or
    /// nose-to-nose with a hostile fish.
    private let spawnSafeRadius: CGFloat = 120

    private var obstacles: [SKShapeNode] = []
    private var fish: [Fish] = []
    private var snakes: [Snake] = []
    private var smallSnakes: [SmallSnake] = []
    private var levelEntrance: LevelEntrance?
    private var lastUpdateTime: TimeInterval = 0
    /// 1-based level number. Depth 1 is the tutorial; every level entrance
    /// taken adds one, and DepthProfile turns the number into how hostile
    /// (and how rewarding) the generated level is. Retrying after a game
    /// over rebuilds the same depth rather than sending the player back up.
    private var depth = 1
    private var isFirstLevel: Bool { depth == 1 }
    private var depthProfile: DepthProfile { DepthProfile(depth: depth) }
    var skipTutorial = false
    var showAdvisorOnStart = false

    /// Water color at the surface — fades linearly to pure black as
    /// DepthProfile.darkness approaches 1.
    private let shallowBackgroundRed: CGFloat = 0.02
    private let shallowBackgroundGreen: CGFloat = 0.08
    private let shallowBackgroundBlue: CGFloat = 0.18

    private func updateBackgroundColor() {
        let light = 1 - depthProfile.darkness
        backgroundColor = SKColor(
            red: shallowBackgroundRed * light,
            green: shallowBackgroundGreen * light,
            blue: shallowBackgroundBlue * light,
            alpha: 1.0
        )
    }

    private var touchingSnakes: Set<Snake> = []
    private var snakeDamageTimer: TimeInterval = 0
    private let snakeDamageInterval: TimeInterval = 0.5
    private let snakeDamagePerTick = 15
    private let snakeContactRange: CGFloat = 70

    private func currentMaxDurability() -> Int {
        PlayerStats.baseDurability + upgradeStore.level(of: .durability) * durabilityBonusPerLevel
    }

    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        playerStats.reset(maxDurability: currentMaxDurability())

        camera = cameraNode
        addChild(cameraNode)

        setUpBoundaries()
        setUpPlayer()
        setUpJoystick()
        setUpHUDButtons()
        setUpStatsHUD()
        setUpPointsHUD()
        setUpLoadingOverlay()
        setUpGameOverOverlay()
        setUpShopOverlay()
        setUpAdvisorOverlay()
        setUpMapLimits()
        setUpIceRoof()

        if skipTutorial {
            depth = 2
            removeIceRoof()
        }

        generateLevel()
        setUpLevelEntrance()

        if showAdvisorOnStart {
            showAdvisorMessage(
                "Welcome to Europa Diver! Pilot your submarine through the ice shelf, scan new fish species for points, and keep an eye on your power and durability — the deep isn't forgiving."
            )
        }
    }

    private func setUpBoundaries() {
        let floor = SKNode()
        floor.position = CGPoint(x: 0, y: worldBottom)
        floor.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -100_000, y: 0), to: CGPoint(x: 100_000, y: 0))
        floor.physicsBody?.categoryBitMask = PhysicsCategory.wall
        floor.physicsBody?.collisionBitMask = PhysicsCategory.player
        addChild(floor)
    }

    private func setUpMapLimits() {
        let halfWorldWidth = size.width * CGFloat(screensEachSide)
        worldMinX = player.position.x - halfWorldWidth
        worldMaxX = player.position.x + halfWorldWidth

        addBoundaryWall(at: worldMinX)
        addBoundaryWall(at: worldMaxX)
    }

    /// Tutorial-only ice ceiling. The patch above spawn is visually marked as
    /// thinner ice (where the sub "came in from"), but the whole roof is
    /// solid — nothing passes through it, including that patch.
    private func setUpIceRoof() {
        let squareSize: CGFloat = 40
        let holePatchHalfWidth: CGFloat = 40

        var x = worldMinX
        while x < worldMaxX {
            let squareCenter = x + squareSize / 2
            let isHolePatch = squareCenter >= -holePatchHalfWidth && squareCenter <= holePatchHalfWidth

            let square = SKShapeNode(rectOf: CGSize(width: squareSize, height: squareSize))
            square.name = "iceRoof"
            square.fillColor = isHolePatch
                ? SKColor(red: 0.85, green: 0.98, blue: 1.0, alpha: 0.5)
                : SKColor(red: 0.75, green: 0.92, blue: 1.0, alpha: 0.9)
            square.strokeColor = .white
            square.lineWidth = 1
            square.position = CGPoint(x: squareCenter, y: worldTop)
            square.zPosition = 8
            addChild(square)

            x += squareSize
        }

        let edge = SKNode()
        edge.name = "iceRoof"
        edge.position = CGPoint(x: 0, y: worldTop)
        edge.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: worldMinX, y: 0), to: CGPoint(x: worldMaxX, y: 0))
        edge.physicsBody?.categoryBitMask = PhysicsCategory.wall
        edge.physicsBody?.collisionBitMask = PhysicsCategory.player
        addChild(edge)
    }

    /// Swaps the tutorial's visible ice ceiling for a plain invisible one, so
    /// later levels stay capped without the level-1-only visual.
    private func removeIceRoof() {
        children.filter { $0.name == "iceRoof" }.forEach { $0.removeFromParent() }

        let ceiling = SKNode()
        ceiling.position = CGPoint(x: 0, y: worldTop)
        ceiling.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -100_000, y: 0), to: CGPoint(x: 100_000, y: 0))
        ceiling.physicsBody?.categoryBitMask = PhysicsCategory.wall
        ceiling.physicsBody?.collisionBitMask = PhysicsCategory.player
        addChild(ceiling)
    }

    private func addBoundaryWall(at x: CGFloat) {
        let squareSize: CGFloat = 40
        var y = worldBottom
        while y < worldTop {
            let square = SKShapeNode(rectOf: CGSize(width: squareSize, height: squareSize))
            square.fillColor = .black
            square.strokeColor = .black
            square.position = CGPoint(x: x, y: y + squareSize / 2)
            square.zPosition = 8
            addChild(square)
            y += squareSize
        }

        let wall = SKNode()
        wall.position = CGPoint(x: x, y: 0)
        wall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: worldBottom), to: CGPoint(x: 0, y: worldTop))
        wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        wall.physicsBody?.collisionBitMask = PhysicsCategory.player
        addChild(wall)
    }

    private func setUpPlayer() {
        player.position = spawnPosition
        player.zPosition = 10

        let body = SKPhysicsBody(circleOfRadius: playerRadius)
        body.affectedByGravity = false
        body.allowsRotation = false
        body.linearDamping = 2.0
        body.restitution = 0.2
        body.categoryBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.obstacle | PhysicsCategory.wall
        body.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.largeFish | PhysicsCategory.hostileFish | PhysicsCategory.ooi | PhysicsCategory.levelEntrance | PhysicsCategory.snake
        player.physicsBody = body

        addChild(player)
        // The camera's y stays fixed at the world's vertical center (the
        // full world height already fits on screen — only x scrolls), so
        // it must not inherit the player's spawn y.
        cameraNode.position = CGPoint(x: player.position.x, y: 0)

        addChild(scanProgressBar)
    }

    private func setUpJoystick() {
        cameraNode.addChild(joystick)
        repositionJoystick()
    }

    private func repositionJoystick() {
        joystick.position = CGPoint(x: size.width / 2 - 80, y: -size.height / 2 + 80)
    }

    private func setUpHUDButtons() {
        cameraNode.addChild(scannerButton)
        cameraNode.addChild(lightButton)
        cameraNode.addChild(shieldButton)
        cameraNode.addChild(shockButton)
        cameraNode.addChild(torpedoButton)
        cameraNode.addChild(autoRepairButton)
        repositionHUDButtons()
        refreshAbilityButtonVisibility()
    }

    private func repositionHUDButtons() {
        let x = -size.width / 2 + 60
        let spacing: CGFloat = 70
        let bottomY = -size.height / 2 + 80

        // Scan is the one button always available, so it anchors the
        // bottom-left corner; the upgrade-gated buttons (often hidden)
        // stack above it in a 2-column grid rather than a single tall
        // column, so the stack stays short enough to clear the power/
        // durability bars anchored at the top-left on shorter screens.
        scannerButton.position = CGPoint(x: x, y: bottomY)
        torpedoButton.position = CGPoint(x: x + spacing, y: bottomY)
        lightButton.position = CGPoint(x: x, y: bottomY + spacing)
        shieldButton.position = CGPoint(x: x + spacing, y: bottomY + spacing)
        shockButton.position = CGPoint(x: x, y: bottomY + spacing * 2)
        autoRepairButton.position = CGPoint(x: x + spacing, y: bottomY + spacing * 2)
    }

    private func refreshAbilityButtonVisibility() {
        // The scan button is a base ability and is always available; the rest
        // only show once their corresponding upgrade has been purchased.
        // Wave Generator has no button at all — it's a passive effect.
        autoRepairButton.isHidden = !upgradeStore.isOwned(.autoRepair)
        shockButton.isHidden = !upgradeStore.isOwned(.electricShock)
        lightButton.isHidden = !upgradeStore.isOwned(.light)
        shieldButton.isHidden = !upgradeStore.isOwned(.shield)
        torpedoButton.isHidden = !upgradeStore.isOwned(.torpedo)
    }

    private func setUpStatsHUD() {
        cameraNode.addChild(statsHUD)
        repositionStatsHUD()
    }

    private func repositionStatsHUD() {
        statsHUD.position = CGPoint(x: -size.width / 2 + 20, y: size.height / 2 - 30)
    }

    private func setUpPointsHUD() {
        cameraNode.addChild(pointsHUD)
        repositionPointsHUD()
        pointsHUD.update(points: pointsManager.points, depth: depth)
    }

    private func repositionPointsHUD() {
        pointsHUD.position = CGPoint(x: size.width / 2 - 20, y: size.height / 2 - 30)
    }

    private func setUpLoadingOverlay() {
        cameraNode.addChild(loadingOverlay)
        loadingOverlay.resize(to: size)
    }

    private func setUpGameOverOverlay() {
        cameraNode.addChild(gameOverOverlay)
        gameOverOverlay.resize(to: size)
    }

    private func setUpShopOverlay() {
        cameraNode.addChild(shopOverlay)
        shopOverlay.resize(to: size)
    }

    private func setUpAdvisorOverlay() {
        cameraNode.addChild(advisorOverlay)
        advisorOverlay.resize(to: size)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        repositionJoystick()
        repositionHUDButtons()
        repositionStatsHUD()
        repositionPointsHUD()
        loadingOverlay.resize(to: size)
        gameOverOverlay.resize(to: size)
        shopOverlay.resize(to: size)
        advisorOverlay.resize(to: size)
    }

    private func isNearSpawn(_ position: CGPoint) -> Bool {
        hypot(position.x - spawnPosition.x, position.y - spawnPosition.y) < spawnSafeRadius
    }

    /// Builds the level for the current `depth`. The generator is told what
    /// the player has already scanned so it can fill the level with species
    /// they still need — the deeper the level, the more of those there are.
    private func generateLevel() {
        updateBackgroundColor()

        let layout = LevelGenerator(
            worldMinX: worldMinX,
            worldMaxX: worldMaxX,
            worldBottom: worldBottom,
            worldTop: worldTop,
            profile: depthProfile,
            discoveredSpeciesIDs: surveyLog.scannedSpeciesIDs()
        ).generate()

        for slot in layout.obstacles where !isNearSpawn(slot.position) {
            addObstacle(at: slot.position)
        }
        for slot in layout.fishSlots where slot.kind != .hostile || !isNearSpawn(slot.position) {
            addFish(kind: slot.kind, appearanceIndex: slot.appearanceIndex, at: slot.position, roamHalfWidth: slot.roamHalfWidth)
        }
        for slot in layout.ooiSlots {
            addOOI(at: slot.position)
        }
        for slot in layout.emptySlots {
            addEmptySlot(at: slot.position)
        }
        for slot in layout.snakeSlots where !isNearSpawn(slot.position) {
            addSnake(at: slot.position)
        }
        for slot in layout.smallSnakeSlots {
            addSmallSnake(at: slot.position)
        }
    }

    private func setUpLevelEntrance() {
        let entrance = LevelEntrance()
        entrance.position = randomLevelEntrancePosition()
        addChild(entrance)
        levelEntrance = entrance
    }

    /// Picks a random spot for the next-level entrance, clear of the spawn
    /// area and not buried inside a tunnel wall — otherwise it could land
    /// somewhere unreachable.
    private func randomLevelEntrancePosition() -> CGPoint {
        let xMargin: CGFloat = 100
        let yMargin: CGFloat = 40

        for _ in 0..<50 {
            let candidate = CGPoint(
                x: CGFloat.random(in: (worldMinX + xMargin)...(worldMaxX - xMargin)),
                y: CGFloat.random(in: (worldBottom + yMargin)...(worldTop - yMargin))
            )
            if !isNearSpawn(candidate) && !isInsideObstacle(candidate) {
                return candidate
            }
        }

        return CGPoint(x: 0, y: worldBottom + 20)
    }

    private func isInsideObstacle(_ position: CGPoint) -> Bool {
        let entranceClearance: CGFloat = 15 + WorldConstants.obstacleRadius
        return obstacles.contains {
            hypot($0.position.x - position.x, $0.position.y - position.y) < entranceClearance
        }
    }

    private func enterNextLevel() {
        guard !isLoadingLevel else { return }
        isLoadingLevel = true

        if isFirstLevel {
            removeIceRoof()
        }
        depth += 1

        player.physicsBody?.velocity = .zero
        loadingOverlay.show()

        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in self?.rebuildLevel() },
            SKAction.run { [weak self] in
                self?.loadingOverlay.hide()
                self?.isLoadingLevel = false
            }
        ]))
    }

    private func rebuildLevel() {
        clearLevel()
        generateLevel()
        setUpLevelEntrance()

        player.position = spawnPosition
        player.physicsBody?.velocity = .zero
        cameraNode.position = CGPoint(x: player.position.x, y: 0)
    }

    private func showGameOver() {
        guard !isGameOver else { return }
        isGameOver = true

        player.physicsBody?.velocity = .zero
        gameOverOverlay.show()
    }

    private func retryGame() {
        playerStats.reset(maxDurability: currentMaxDurability())
        rebuildLevel()

        isGameOver = false
        gameOverOverlay.hide()
    }

    private func returnToMainMenu() {
        guard let view else { return }

        let menuScene = MainMenuScene(size: size)
        menuScene.scaleMode = .resizeFill
        view.presentScene(menuScene, transition: SKTransition.fade(withDuration: 0.5))
    }

    private func openShop() {
        gameOverOverlay.hide()
        shopOverlay.refresh(points: pointsManager.points, upgradeStore: upgradeStore)
        shopOverlay.show()
        isShopOpen = true
    }

    private func closeShop() {
        shopOverlay.hide()
        gameOverOverlay.show()
        isShopOpen = false
    }

    /// Pauses the player, fish, and snakes and shows a dismissible message.
    /// Physics is stopped entirely (not just our own per-frame movement
    /// logic) so obstacle-collision damage can't fire and the player can't
    /// coast on leftover velocity while this is up.
    private func showAdvisorMessage(_ text: String) {
        isAdvisorShowing = true
        player.physicsBody?.velocity = .zero
        physicsWorld.speed = 0
        advisorOverlay.show(message: text)
    }

    private func dismissAdvisorMessage() {
        isAdvisorShowing = false
        physicsWorld.speed = 1
        advisorOverlay.hide()
    }

    private func purchase(_ upgrade: Upgrade) {
        guard let cost = upgradeStore.nextLevelCost(upgrade) else { return }
        guard pointsManager.spendPoints(cost) else { return }

        upgradeStore.levelUp(upgrade)
        pointsHUD.update(points: pointsManager.points, depth: depth)
        shopOverlay.refresh(points: pointsManager.points, upgradeStore: upgradeStore)
        refreshAbilityButtonVisibility()
    }

    private func triggerElectricShock() {
        guard upgradeStore.isOwned(.electricShock) else { return }
        guard playerStats.power >= shockPowerCost else { return }

        playerStats.adjustPower(by: -shockPowerCost)

        let nearbyFish = fish.filter { candidate in
            let dx = candidate.position.x - player.position.x
            let dy = candidate.position.y - player.position.y
            return sqrt(dx * dx + dy * dy) <= shockRadius
        }

        for target in nearbyFish {
            target.removeFromParent()
            touchingHostileFish.remove(target)
        }
        fish.removeAll { nearbyFish.contains($0) }
    }

    private func triggerTorpedo() {
        guard upgradeStore.isOwned(.torpedo) else { return }
        guard playerStats.power >= torpedoPowerCost else { return }

        playerStats.adjustPower(by: -torpedoPowerCost)

        let facing: CGFloat = player.xScale < 0 ? -1 : 1
        let spawnPosition = CGPoint(x: player.position.x + facing * (playerRadius + 10), y: player.position.y)
        Torpedo.fire(from: spawnPosition, direction: facing, speed: torpedoSpeed, in: self)
    }

    private func triggerAutoRepair() {
        guard upgradeStore.isOwned(.autoRepair) else { return }
        guard playerStats.durability < playerStats.maxDurability else { return }
        guard playerStats.power >= autoRepairPowerCost else { return }

        playerStats.adjustPower(by: -autoRepairPowerCost)
        playerStats.adjustDurability(by: upgradeStore.level(of: .autoRepair) * autoRepairDurabilityPerLevel)
    }

    /// Passive regen: only while the player isn't giving any movement input,
    /// restores power once per second, scaled by the upgrade's level.
    private func updateWaveGenerator(deltaTime: TimeInterval) {
        let level = upgradeStore.level(of: .waveGenerator)
        let input = joystick.vector
        guard level > 0, input.dx == 0, input.dy == 0 else {
            waveGeneratorTimer = 0
            return
        }

        waveGeneratorTimer += deltaTime
        guard waveGeneratorTimer >= waveGeneratorInterval else { return }
        waveGeneratorTimer -= waveGeneratorInterval

        playerStats.adjustPower(by: level * waveGeneratorRegenPerLevel)
    }

    private func startScan() {
        guard scanTarget == nil else { return }

        let candidates: [any Scannable] = fish + smallSnakes
        let target = candidates.first { candidate in
            guard !surveyLog.hasScanned(candidate.speciesID) else { return false }
            let dx = candidate.position.x - player.position.x
            let dy = candidate.position.y - player.position.y
            return sqrt(dx * dx + dy * dy) <= scanRadius
        }
        guard let target else { return }

        scanTarget = target
        scanElapsed = 0
        scanProgressBar.setProgress(0)
        scanProgressBar.show()
    }

    private func updateScan(deltaTime: TimeInterval) {
        guard let target = scanTarget else { return }
        guard isScanTargetStillPresent(target) else {
            cancelScan()
            return
        }

        let dx = target.position.x - player.position.x
        let dy = target.position.y - player.position.y
        let distance = sqrt(dx * dx + dy * dy)
        guard distance <= scanRadius else {
            cancelScan()
            return
        }

        scanElapsed += deltaTime
        scanProgressBar.setProgress(CGFloat(scanElapsed / scanDuration))

        if scanElapsed >= scanDuration {
            completeScan(for: target)
        }
    }

    private func isScanTargetStillPresent(_ target: any Scannable) -> Bool {
        if let fishTarget = target as? Fish {
            return fish.contains(fishTarget)
        }
        if let smallSnakeTarget = target as? SmallSnake {
            return smallSnakes.contains(smallSnakeTarget)
        }
        return false
    }

    private func completeScan(for target: any Scannable) {
        surveyLog.markScanned(target.speciesID)
        pointsManager.addPoints(scanRewardPoints + depthProfile.scanRewardBonus)

        let facing: CGFloat = player.xScale < 0 ? -1 : 1
        let effectPosition = CGPoint(x: player.position.x + facing * (playerRadius + 20), y: player.position.y)
        ScanEffect.spawn(at: effectPosition, in: self)

        scanTarget = nil
        scanElapsed = 0
        scanProgressBar.hide()
    }

    private func cancelScan() {
        scanTarget = nil
        scanElapsed = 0
        scanProgressBar.hide()
    }

    private func clearLevel() {
        obstacles.forEach { $0.removeFromParent() }
        obstacles.removeAll()

        fish.forEach { $0.removeFromParent() }
        fish.removeAll()
        touchingHostileFish.removeAll()
        nibbleTimer = 0
        cancelScan()

        snakes.forEach { $0.removeFromParent() }
        snakes.removeAll()
        touchingSnakes.removeAll()
        snakeDamageTimer = 0

        smallSnakes.forEach { $0.removeFromParent() }
        smallSnakes.removeAll()

        children
            .filter { $0.name == "ooi" || $0.name == "emptySlot" }
            .forEach { $0.removeFromParent() }

        levelEntrance?.removeFromParent()
        levelEntrance = nil
    }

    private func addObstacle(at position: CGPoint) {
        let radius = WorldConstants.obstacleRadius
        let rock = SKShapeNode(circleOfRadius: radius)
        rock.name = "obstacle"
        rock.position = position
        rock.fillColor = SKColor(white: 0.4, alpha: 1.0)
        rock.strokeColor = .darkGray

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.player
        rock.physicsBody = body

        addChild(rock)
        obstacles.append(rock)
    }

    private func addFish(kind: FishKind, appearanceIndex: Int, at position: CGPoint, roamHalfWidth: CGFloat) {
        let roamLeft = max(position.x - roamHalfWidth, worldMinX)
        let roamRight = min(position.x + roamHalfWidth, worldMaxX)
        let roamBottom = worldBottom + 20
        let roamTop = worldTop - 20

        let newFish = Fish(
            kind: kind,
            appearanceIndex: appearanceIndex,
            roamLeft: roamLeft,
            roamRight: roamRight,
            roamBottom: roamBottom,
            roamTop: roamTop
        )
        newFish.position = position

        addChild(newFish)
        fish.append(newFish)
    }

    private func addSnake(at position: CGPoint) {
        let snake = Snake()
        snake.position = position

        addChild(snake)
        snakes.append(snake)
    }

    private func addSmallSnake(at position: CGPoint) {
        let smallSnake = SmallSnake()
        smallSnake.position = position

        addChild(smallSnake)
        smallSnakes.append(smallSnake)
    }

    private func addOOI(at position: CGPoint) {
        let ooi = OOI()
        ooi.position = position
        addChild(ooi)
    }

    private func addEmptySlot(at position: CGPoint) {
        let marker = SKShapeNode(circleOfRadius: 15)
        marker.name = "emptySlot"
        marker.position = position
        marker.fillColor = .clear
        marker.strokeColor = SKColor.white.withAlphaComponent(0.25)
        marker.lineWidth = 1
        marker.zPosition = 1
        addChild(marker)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isAdvisorShowing {
            if let touch = touches.first {
                let pointInOverlay = advisorOverlay.convert(touch.location(in: self), from: self)
                if advisorOverlay.hitTestContinue(pointInOverlay) {
                    dismissAdvisorMessage()
                }
            }
            return
        }

        if isShopOpen {
            if let touch = touches.first {
                let pointInOverlay = shopOverlay.convert(touch.location(in: self), from: self)
                if shopOverlay.hitTestClose(pointInOverlay) {
                    closeShop()
                } else if let upgrade = shopOverlay.hitTestUpgrade(pointInOverlay) {
                    purchase(upgrade)
                }
            }
            return
        }

        if isGameOver {
            if let touch = touches.first {
                let pointInOverlay = gameOverOverlay.convert(touch.location(in: self), from: self)
                if gameOverOverlay.hitTestRetry(pointInOverlay) {
                    retryGame()
                } else if gameOverOverlay.hitTestShop(pointInOverlay) {
                    openShop()
                } else if gameOverOverlay.hitTestMainMenu(pointInOverlay) {
                    returnToMainMenu()
                }
            }
            return
        }

        if let touch = touches.first(where: { hitTest(shockButton, touch: $0) }) {
            shockButton.setPressed(true)
            pressedButtonTouches[touch] = shockButton
            triggerElectricShock()
            return
        }

        if let touch = touches.first(where: { hitTest(torpedoButton, touch: $0) }) {
            torpedoButton.setPressed(true)
            pressedButtonTouches[touch] = torpedoButton
            triggerTorpedo()
            return
        }

        if let touch = touches.first(where: { hitTest(autoRepairButton, touch: $0) }) {
            autoRepairButton.setPressed(true)
            pressedButtonTouches[touch] = autoRepairButton
            triggerAutoRepair()
            return
        }

        if let touch = touches.first(where: { hitTest(scannerButton, touch: $0) }) {
            scannerButton.setPressed(true)
            pressedButtonTouches[touch] = scannerButton
            startScan()
            return
        }

        guard joystickTouch == nil else { return }
        guard let touch = touches.first(where: isOnRightSide) else { return }

        joystickTouch = touch
        updateJoystick(with: touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystickTouch, touches.contains(joystickTouch) else { return }
        updateJoystick(with: joystickTouch)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endJoystickTouchIfNeeded(in: touches)
        releasePressedButtons(for: touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endJoystickTouchIfNeeded(in: touches)
        releasePressedButtons(for: touches)
    }

    private func releasePressedButtons(for touches: Set<UITouch>) {
        for touch in touches {
            guard let button = pressedButtonTouches.removeValue(forKey: touch) else { continue }
            button.setPressed(false)
        }
    }

    private func hitTest(_ node: SKNode, touch: UITouch) -> Bool {
        guard let parent = node.parent else { return false }
        let point = parent.convert(touch.location(in: self), from: self)
        return node.contains(point)
    }

    private func isOnRightSide(_ touch: UITouch) -> Bool {
        // Scene-space, relative to the camera, rather than `view.bounds` — the view's
        // bounds can still reflect a pre-rotation (portrait) size at launch since this
        // app forces landscape, which would misplace the left/right split entirely.
        touch.location(in: self).x > cameraNode.position.x
    }

    /// Whether `position` falls within the camera's current visible area.
    /// Camera.y never moves from 0, so this is just a centered rect around
    /// camera.x at the scene's current size.
    private func isOnScreen(_ position: CGPoint) -> Bool {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        return position.x >= cameraNode.position.x - halfWidth
            && position.x <= cameraNode.position.x + halfWidth
            && position.y >= cameraNode.position.y - halfHeight
            && position.y <= cameraNode.position.y + halfHeight
    }

    private func updateJoystick(with touch: UITouch) {
        let scenePoint = touch.location(in: self)
        let localPoint = joystick.convert(scenePoint, from: self)
        joystick.update(withTouch: localPoint)
    }

    private func endJoystickTouchIfNeeded(in touches: Set<UITouch>) {
        guard let current = joystickTouch, touches.contains(current) else { return }
        joystickTouch = nil
        joystick.update(withTouch: nil)
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        guard !isGameOver, !isAdvisorShowing else { return }

        if !isLoadingLevel, let body = player.physicsBody {
            let input = joystick.vector
            if input.dx != 0 || input.dy != 0 {
                body.velocity = CGVector(dx: input.dx * moveSpeed, dy: input.dy * moveSpeed)
                player.xScale = input.dx < 0 ? -abs(player.xScale) : abs(player.xScale)
            }
        }

        cameraNode.position.x = player.position.x
        scanProgressBar.position = CGPoint(x: player.position.x, y: player.position.y + playerRadius + 15)

        let obstaclePositions = obstacles.map { $0.position }
        fish.forEach { $0.update(deltaTime: deltaTime, playerPosition: player.position, nearbyObstacles: obstaclePositions) }
        snakes.forEach { $0.update(deltaTime: deltaTime, playerPosition: player.position) }
        smallSnakes.forEach { smallSnake in
            smallSnake.update(
                deltaTime: deltaTime,
                playerPosition: player.position,
                isOnScreen: isOnScreen(smallSnake.position),
                nearbyObstacles: obstaclePositions,
                worldMinX: worldMinX,
                worldMaxX: worldMaxX,
                worldBottom: worldBottom,
                worldTop: worldTop
            )
        }

        updateHostileFishNibble(deltaTime: deltaTime)
        updateSnakeDamage(deltaTime: deltaTime)
        updateScan(deltaTime: deltaTime)
        updateWaveGenerator(deltaTime: deltaTime)

        statsHUD.update(stats: playerStats)
        pointsHUD.update(points: pointsManager.points, depth: depth)
    }

    private func updateHostileFishNibble(deltaTime: TimeInterval) {
        pruneStaleContacts(&touchingHostileFish, maxDistance: hostileFishContactRange) { $0.position }
        guard !touchingHostileFish.isEmpty else { return }

        nibbleTimer += deltaTime
        guard nibbleTimer >= nibbleInterval else { return }
        nibbleTimer = 0

        applyDurabilityDamage(nibbleDamagePerFish * touchingHostileFish.count)
    }

    private func updateSnakeDamage(deltaTime: TimeInterval) {
        pruneStaleContacts(&touchingSnakes, maxDistance: snakeContactRange) { $0.position }
        guard !touchingSnakes.isEmpty else { return }

        snakeDamageTimer += deltaTime
        guard snakeDamageTimer >= snakeDamageInterval else { return }
        snakeDamageTimer = 0

        applyDurabilityDamage(snakeDamagePerTick * touchingSnakes.count)
    }

    /// Physics contact-end events can occasionally be missed — particularly
    /// for Snake, whose "awkward" movement deliberately relies on abrupt
    /// collision-driven velocity changes against obstacles/walls — leaving
    /// a touch set holding something that's no longer actually nearby. That
    /// shows up as phantom periodic damage from what looks like an empty
    /// spot, since the real (visible) culprit has already moved away. Contact
    /// bookkeeping still drives insertion; this just stops trusting it to
    /// also drive removal, so a stale entry can't linger indefinitely.
    private func pruneStaleContacts<T: Hashable>(
        _ contacts: inout Set<T>,
        maxDistance: CGFloat,
        position: (T) -> CGPoint
    ) {
        guard !contacts.isEmpty else { return }

        let maxDistanceSquared = maxDistance * maxDistance
        contacts = contacts.filter { candidate in
            let point = position(candidate)
            let dx = point.x - player.position.x
            let dy = point.y - player.position.y
            return dx * dx + dy * dy <= maxDistanceSquared
        }
    }

    private func applyDurabilityDamage(_ amount: Int) {
        playerStats.adjustDurability(by: -amount)
        spinPlayer()

        if playerStats.durability <= 0 {
            showGameOver()
        }
    }

    private func spinPlayer() {
        let spin = SKAction.rotate(byAngle: -.pi * 2, duration: 0.4)
        player.run(spin, withKey: "damageSpin")
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let categories = [contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask]

        if categories.contains(PhysicsCategory.obstacle) {
            flashPlayerRed()

            if lastUpdateTime - lastObstacleHitTime >= obstacleHitCooldown {
                lastObstacleHitTime = lastUpdateTime
                applyDurabilityDamage(obstacleDamage)
            }
        }

        if categories.contains(PhysicsCategory.hostileFish), let hostileFish = hostileFishNode(in: contact) {
            flashFishRed(hostileFish)
            touchingHostileFish.insert(hostileFish)
        }

        if categories.contains(PhysicsCategory.snake), let snake = snakeNode(in: contact) {
            touchingSnakes.insert(snake)
        }

        if categories.contains(PhysicsCategory.torpedo) {
            handleTorpedoContact(contact)
        }

        if categories.contains(PhysicsCategory.ooi) {
            let ooi = [contact.bodyA.node, contact.bodyB.node].compactMap { $0 as? OOI }.first
            if ooi != nil {
                pointsManager.addPoints(ooiPointValue)
            }
            ooi?.removeFromParent()
        }

        if categories.contains(PhysicsCategory.levelEntrance) {
            enterNextLevel()
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let categories = [contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask]

        if categories.contains(PhysicsCategory.hostileFish), let hostileFish = hostileFishNode(in: contact) {
            touchingHostileFish.remove(hostileFish)
        }

        if categories.contains(PhysicsCategory.snake), let snake = snakeNode(in: contact) {
            touchingSnakes.remove(snake)
        }
    }

    private func snakeNode(in contact: SKPhysicsContact) -> Snake? {
        [contact.bodyA.node, contact.bodyB.node].compactMap { $0 as? Snake }.first
    }

    private func smallSnakeNode(in contact: SKPhysicsContact) -> SmallSnake? {
        [contact.bodyA.node, contact.bodyB.node].compactMap { $0 as? SmallSnake }.first
    }

    private func fishNode(in contact: SKPhysicsContact) -> Fish? {
        [contact.bodyA.node, contact.bodyB.node].compactMap { $0 as? Fish }.first
    }

    private func hostileFishNode(in contact: SKPhysicsContact) -> Fish? {
        fishNode(in: contact).flatMap { $0.kind == .hostile ? $0 : nil }
    }

    private func torpedoNode(in contact: SKPhysicsContact) -> SKNode? {
        if contact.bodyA.categoryBitMask == PhysicsCategory.torpedo { return contact.bodyA.node }
        if contact.bodyB.categoryBitMask == PhysicsCategory.torpedo { return contact.bodyB.node }
        return nil
    }

    /// A torpedo hit kills small and hostile fish outright (large fish are
    /// spared), scares both kinds of snake into fleeing for a while, and is
    /// consumed on any of those hits.
    private func handleTorpedoContact(_ contact: SKPhysicsContact) {
        guard let torpedo = torpedoNode(in: contact) else { return }

        if let target = fishNode(in: contact), target.kind != .large {
            target.removeFromParent()
            fish.removeAll { $0 === target }
            touchingHostileFish.remove(target)
            torpedo.removeFromParent()
        }

        if let snake = snakeNode(in: contact) {
            snake.frighten(duration: torpedoFrightenDuration)
            torpedo.removeFromParent()
        }

        if let smallSnake = smallSnakeNode(in: contact) {
            smallSnake.frighten(duration: torpedoFrightenDuration)
            torpedo.removeFromParent()
        }
    }

    private func flashPlayerRed() {
        player.run(SKAction.sequence([
            SKAction.run { [weak self] in
                self?.player.color = .red
                self?.player.colorBlendFactor = 0.7
            },
            SKAction.wait(forDuration: 0.15),
            SKAction.run { [weak self] in self?.player.colorBlendFactor = 0 }
        ]))
    }

    private func flashFishRed(_ fish: Fish) {
        fish.run(SKAction.sequence([
            SKAction.run {
                fish.color = .red
                fish.colorBlendFactor = 0.7
            },
            SKAction.wait(forDuration: 0.15),
            SKAction.run { fish.colorBlendFactor = 0 }
        ]))
    }
}
