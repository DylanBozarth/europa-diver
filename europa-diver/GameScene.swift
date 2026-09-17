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
}

enum WorldConstants {
    static let obstacleRadius: CGFloat = 20
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    private let player = SKShapeNode(circleOfRadius: 12)
    private let playerStats = PlayerStats()
    private let cameraNode = SKCameraNode()
    private let joystick = Joystick()
    private var joystickTouch: UITouch?
    private let moveSpeed: CGFloat = 160

    private let loadingOverlay = LoadingOverlay()
    private var isLoadingLevel = false

    private let scannerButton = HUDButton(icon: "🔍")
    private let lightButton = HUDButton(icon: "💡")
    private let shieldButton = HUDButton(icon: "🛡️")
    private let shockButton = HUDButton(icon: "⚡")
    private let shockRadius: CGFloat = 100
    private let shockPowerCost = 20

    private let statsHUD = PlayerStatsHUD()

    private let pointsManager = PointsManager()
    private let pointsHUD = PointsHUD()
    private let ooiPointValue = 10

    private let gameOverOverlay = GameOverOverlay()
    private var isGameOver = false

    private let shopOverlay = ShopOverlay()
    private var isShopOpen = false

    private let upgradeStore = UpgradeStore()
    private let electricShockCost = 50

    private var touchingHostileFish: Set<Fish> = []
    private var nibbleTimer: TimeInterval = 0
    private let nibbleInterval: TimeInterval = 0.5
    private let nibbleDamagePerFish = 5

    private var lastObstacleHitTime: TimeInterval = 0
    private let obstacleHitCooldown: TimeInterval = 0.5
    private let obstacleDamage = 10

    private let worldTop: CGFloat = 180
    private let worldBottom: CGFloat = -180

    private let screensEachSide = 3
    private var worldMinX: CGFloat = 0
    private var worldMaxX: CGFloat = 0

    private var obstacles: [SKShapeNode] = []
    private var fish: [Fish] = []
    private var levelEntrance: LevelEntrance?
    private var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.02, green: 0.08, blue: 0.18, alpha: 1.0)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

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
        setUpMapLimits()
        generateLevel()
        setUpLevelEntrance()
    }

    private func setUpBoundaries() {
        for y in [worldTop, worldBottom] {
            let wall = SKNode()
            wall.position = CGPoint(x: 0, y: y)
            wall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -100_000, y: 0), to: CGPoint(x: 100_000, y: 0))
            wall.physicsBody?.categoryBitMask = PhysicsCategory.wall
            wall.physicsBody?.collisionBitMask = PhysicsCategory.player
            addChild(wall)
        }
    }

    private func setUpMapLimits() {
        let halfWorldWidth = size.width * CGFloat(screensEachSide)
        worldMinX = player.position.x - halfWorldWidth
        worldMaxX = player.position.x + halfWorldWidth

        addBoundaryWall(at: worldMinX)
        addBoundaryWall(at: worldMaxX)
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
        player.position = CGPoint(x: 0, y: 0)
        player.fillColor = .white
        player.strokeColor = .cyan
        player.zPosition = 10

        let body = SKPhysicsBody(circleOfRadius: 12)
        body.affectedByGravity = false
        body.linearDamping = 2.0
        body.restitution = 0.2
        body.categoryBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.obstacle | PhysicsCategory.wall
        body.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.largeFish | PhysicsCategory.hostileFish | PhysicsCategory.ooi | PhysicsCategory.levelEntrance
        player.physicsBody = body

        addChild(player)
        cameraNode.position = player.position
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
        repositionHUDButtons()
        refreshShockButtonAvailability()
    }

    private func repositionHUDButtons() {
        let x = -size.width / 2 + 60
        let spacing: CGFloat = 70
        let bottomY = -size.height / 2 + 80

        scannerButton.position = CGPoint(x: x, y: bottomY + spacing * 3)
        lightButton.position = CGPoint(x: x, y: bottomY + spacing * 2)
        shieldButton.position = CGPoint(x: x, y: bottomY + spacing)
        shockButton.position = CGPoint(x: x, y: bottomY)
    }

    private func refreshShockButtonAvailability() {
        shockButton.alpha = upgradeStore.isOwned(.electricShock) ? 1.0 : 0.4
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
        pointsHUD.update(points: pointsManager.points)
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

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        repositionJoystick()
        repositionHUDButtons()
        repositionStatsHUD()
        repositionPointsHUD()
        loadingOverlay.resize(to: size)
        gameOverOverlay.resize(to: size)
        shopOverlay.resize(to: size)
    }

    private func generateLevel() {
        let layout = LevelGenerator(
            worldMinX: worldMinX,
            worldMaxX: worldMaxX,
            worldBottom: worldBottom,
            worldTop: worldTop
        ).generate()

        for slot in layout.obstacles {
            addObstacle(at: slot.position)
        }
        for slot in layout.fishSlots {
            addFish(kind: slot.kind, at: slot.position, roamHalfWidth: slot.roamHalfWidth)
        }
        for slot in layout.ooiSlots {
            addOOI(at: slot.position)
        }
        for slot in layout.emptySlots {
            addEmptySlot(at: slot.position)
        }
    }

    private func setUpLevelEntrance() {
        let entrance = LevelEntrance()
        entrance.position = CGPoint(x: 0, y: worldBottom + 20)
        addChild(entrance)
        levelEntrance = entrance
    }

    private func enterNextLevel() {
        guard !isLoadingLevel else { return }
        isLoadingLevel = true

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

        player.position = .zero
        player.physicsBody?.velocity = .zero
        cameraNode.position = player.position
    }

    private func showGameOver() {
        guard !isGameOver else { return }
        isGameOver = true

        player.physicsBody?.velocity = .zero
        gameOverOverlay.show()
    }

    private func retryGame() {
        playerStats.reset()
        rebuildLevel()

        isGameOver = false
        gameOverOverlay.hide()
    }

    private func openShop() {
        gameOverOverlay.hide()
        shopOverlay.updateElectricShock(owned: upgradeStore.isOwned(.electricShock), cost: electricShockCost)
        shopOverlay.show()
        isShopOpen = true
    }

    private func closeShop() {
        shopOverlay.hide()
        gameOverOverlay.show()
        isShopOpen = false
    }

    private func purchaseElectricShock() {
        guard !upgradeStore.isOwned(.electricShock) else { return }
        guard pointsManager.spendPoints(electricShockCost) else { return }

        upgradeStore.markOwned(.electricShock)
        pointsHUD.update(points: pointsManager.points)
        shopOverlay.updateElectricShock(owned: true, cost: electricShockCost)
        refreshShockButtonAvailability()
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

    private func clearLevel() {
        obstacles.forEach { $0.removeFromParent() }
        obstacles.removeAll()

        fish.forEach { $0.removeFromParent() }
        fish.removeAll()
        touchingHostileFish.removeAll()
        nibbleTimer = 0

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

    private func addFish(kind: FishKind, at position: CGPoint, roamHalfWidth: CGFloat) {
        let roamLeft = max(position.x - roamHalfWidth, worldMinX)
        let roamRight = min(position.x + roamHalfWidth, worldMaxX)
        let roamBottom = worldBottom + 20
        let roamTop = worldTop - 20

        let newFish = Fish(kind: kind, roamLeft: roamLeft, roamRight: roamRight, roamBottom: roamBottom, roamTop: roamTop)
        newFish.position = position

        addChild(newFish)
        fish.append(newFish)
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
        if isShopOpen {
            if let touch = touches.first {
                let pointInOverlay = shopOverlay.convert(touch.location(in: self), from: self)
                if shopOverlay.hitTestClose(pointInOverlay) {
                    closeShop()
                } else if shopOverlay.hitTestElectricShock(pointInOverlay) {
                    purchaseElectricShock()
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
                }
            }
            return
        }

        if touches.contains(where: { hitTest(shockButton, touch: $0) }) {
            triggerElectricShock()
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
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endJoystickTouchIfNeeded(in: touches)
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

        guard !isGameOver else { return }

        if !isLoadingLevel, let body = player.physicsBody {
            let input = joystick.vector
            if input.dx != 0 || input.dy != 0 {
                body.velocity = CGVector(dx: input.dx * moveSpeed, dy: input.dy * moveSpeed)
            }
        }

        cameraNode.position.x = player.position.x

        let obstaclePositions = obstacles.map { $0.position }
        fish.forEach { $0.update(deltaTime: deltaTime, playerPosition: player.position, nearbyObstacles: obstaclePositions) }

        updateHostileFishNibble(deltaTime: deltaTime)

        statsHUD.update(stats: playerStats)
        pointsHUD.update(points: pointsManager.points)
    }

    private func updateHostileFishNibble(deltaTime: TimeInterval) {
        guard !touchingHostileFish.isEmpty else { return }

        nibbleTimer += deltaTime
        guard nibbleTimer >= nibbleInterval else { return }
        nibbleTimer = 0

        applyDurabilityDamage(nibbleDamagePerFish * touchingHostileFish.count)
    }

    private func applyDurabilityDamage(_ amount: Int) {
        playerStats.adjustDurability(by: -amount)

        if playerStats.durability <= 0 {
            showGameOver()
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let categories = [contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask]

        if categories.contains(PhysicsCategory.obstacle) {
            flash(player, backTo: .white)

            if lastUpdateTime - lastObstacleHitTime >= obstacleHitCooldown {
                lastObstacleHitTime = lastUpdateTime
                applyDurabilityDamage(obstacleDamage)
            }
        }

        if categories.contains(PhysicsCategory.hostileFish), let hostileFish = hostileFishNode(in: contact) {
            flash(hostileFish, backTo: hostileFish.normalColor)
            touchingHostileFish.insert(hostileFish)
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
        guard categories.contains(PhysicsCategory.hostileFish), let hostileFish = hostileFishNode(in: contact) else { return }
        touchingHostileFish.remove(hostileFish)
    }

    private func hostileFishNode(in contact: SKPhysicsContact) -> Fish? {
        [contact.bodyA.node, contact.bodyB.node]
            .compactMap { $0 as? Fish }
            .first { $0.kind == .hostile }
    }

    private func flash(_ node: SKShapeNode, backTo normalColor: SKColor) {
        node.run(SKAction.sequence([
            SKAction.run { node.fillColor = .red },
            SKAction.wait(forDuration: 0.15),
            SKAction.run { node.fillColor = normalColor }
        ]))
    }
}
