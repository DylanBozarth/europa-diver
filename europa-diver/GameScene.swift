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
}

enum WorldConstants {
    static let obstacleRadius: CGFloat = 20
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    private let player = SKShapeNode(circleOfRadius: 12)
    private let cameraNode = SKCameraNode()
    private let joystick = Joystick()
    private var joystickTouch: UITouch?
    private let moveSpeed: CGFloat = 160

    private let worldTop: CGFloat = 180
    private let worldBottom: CGFloat = -180

    private let screensEachSide = 3
    private var worldMinX: CGFloat = 0
    private var worldMaxX: CGFloat = 0

    private var obstacles: [SKShapeNode] = []
    private var furthestSpawnedX: CGFloat = 0
    private var nearestSpawnedLeftX: CGFloat = 0
    private let obstacleSpacing: ClosedRange<CGFloat> = 120...220
    private let spawnAheadDistance: CGFloat = 500
    private let despawnBehindDistance: CGFloat = 500

    private var fish: [Fish] = []
    private var furthestFishSpawnedX: CGFloat = 0
    private var nearestFishSpawnedLeftX: CGFloat = 0
    private let fishSpacing: ClosedRange<CGFloat> = 150...300
    private var lastUpdateTime: TimeInterval = 0

    private var furthestOOISpawnedX: CGFloat = 0
    private var nearestOOISpawnedLeftX: CGFloat = 0
    private let ooiSpacing: ClosedRange<CGFloat> = 300...600

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.02, green: 0.08, blue: 0.18, alpha: 1.0)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        camera = cameraNode
        addChild(cameraNode)

        setUpBoundaries()
        setUpPlayer()
        setUpJoystick()
        setUpMapLimits()

        furthestSpawnedX = player.position.x
        nearestSpawnedLeftX = player.position.x
        spawnObstacles(upTo: player.position.x + spawnAheadDistance)
        spawnObstaclesLeft(downTo: player.position.x - spawnAheadDistance)

        furthestFishSpawnedX = player.position.x
        nearestFishSpawnedLeftX = player.position.x
        spawnFish(upTo: player.position.x + spawnAheadDistance)
        spawnFishLeft(downTo: player.position.x - spawnAheadDistance)

        furthestOOISpawnedX = player.position.x
        nearestOOISpawnedLeftX = player.position.x
        spawnOOIs(upTo: player.position.x + spawnAheadDistance)
        spawnOOIsLeft(downTo: player.position.x - spawnAheadDistance)
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
        body.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.largeFish | PhysicsCategory.hostileFish | PhysicsCategory.ooi
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

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        repositionJoystick()
    }

    private func spawnObstacles(upTo maxX: CGFloat) {
        while furthestSpawnedX < maxX {
            furthestSpawnedX += CGFloat.random(in: obstacleSpacing)
            guard furthestSpawnedX <= worldMaxX else { break }
            let y = CGFloat.random(in: (worldBottom + 40)...(worldTop - 40))
            addObstacle(at: CGPoint(x: furthestSpawnedX, y: y))
        }
    }

    private func spawnObstaclesLeft(downTo minX: CGFloat) {
        while nearestSpawnedLeftX > minX {
            nearestSpawnedLeftX -= CGFloat.random(in: obstacleSpacing)
            guard nearestSpawnedLeftX >= worldMinX else { break }
            let y = CGFloat.random(in: (worldBottom + 40)...(worldTop - 40))
            addObstacle(at: CGPoint(x: nearestSpawnedLeftX, y: y))
        }
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

    private func despawnObstacles(behind minX: CGFloat) {
        obstacles.removeAll { obstacle in
            if obstacle.position.x < minX {
                obstacle.removeFromParent()
                return true
            }
            return false
        }
    }

    private func spawnFish(upTo maxX: CGFloat) {
        while furthestFishSpawnedX < maxX {
            furthestFishSpawnedX += CGFloat.random(in: fishSpacing)
            guard furthestFishSpawnedX <= worldMaxX else { break }
            addFish(around: furthestFishSpawnedX)
        }
    }

    private func spawnFishLeft(downTo minX: CGFloat) {
        while nearestFishSpawnedLeftX > minX {
            nearestFishSpawnedLeftX -= CGFloat.random(in: fishSpacing)
            guard nearestFishSpawnedLeftX >= worldMinX else { break }
            addFish(around: nearestFishSpawnedLeftX)
        }
    }

    private func randomFishKind() -> FishKind {
        switch Int.random(in: 0..<100) {
        case 0..<60: return .small
        case 60..<90: return .large
        default: return .hostile
        }
    }

    private func addFish(around x: CGFloat) {
        let roamLeft = max(x - 60, worldMinX)
        let roamRight = min(x + 60, worldMaxX)
        let roamBottom = worldBottom + 20
        let roamTop = worldTop - 20

        let newFish = Fish(kind: randomFishKind(), roamLeft: roamLeft, roamRight: roamRight, roamBottom: roamBottom, roamTop: roamTop)
        newFish.position = CGPoint(x: x, y: CGFloat.random(in: roamBottom...roamTop))

        addChild(newFish)
        fish.append(newFish)
    }

    private func despawnFish(behind minX: CGFloat) {
        fish.removeAll { fish in
            if fish.position.x < minX {
                fish.removeFromParent()
                return true
            }
            return false
        }
    }

    private func spawnOOIs(upTo maxX: CGFloat) {
        while furthestOOISpawnedX < maxX {
            furthestOOISpawnedX += CGFloat.random(in: ooiSpacing)
            guard furthestOOISpawnedX <= worldMaxX else { break }
            let y = CGFloat.random(in: (worldBottom + 40)...(worldTop - 40))
            addOOI(at: CGPoint(x: furthestOOISpawnedX, y: y))
        }
    }

    private func spawnOOIsLeft(downTo minX: CGFloat) {
        while nearestOOISpawnedLeftX > minX {
            nearestOOISpawnedLeftX -= CGFloat.random(in: ooiSpacing)
            guard nearestOOISpawnedLeftX >= worldMinX else { break }
            let y = CGFloat.random(in: (worldBottom + 40)...(worldTop - 40))
            addOOI(at: CGPoint(x: nearestOOISpawnedLeftX, y: y))
        }
    }

    private func addOOI(at position: CGPoint) {
        let ooi = OOI()
        ooi.position = position
        addChild(ooi)
    }

    private func despawnOOIs(behind minX: CGFloat) {
        for child in children where child.name == "ooi" && child.position.x < minX {
            child.removeFromParent()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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

        if let body = player.physicsBody {
            let input = joystick.vector
            if input.dx != 0 || input.dy != 0 {
                body.velocity = CGVector(dx: input.dx * moveSpeed, dy: input.dy * moveSpeed)
            }
        }

        cameraNode.position.x = player.position.x

        spawnObstacles(upTo: cameraNode.position.x + spawnAheadDistance)
        spawnObstaclesLeft(downTo: cameraNode.position.x - spawnAheadDistance)
        despawnObstacles(behind: cameraNode.position.x - despawnBehindDistance)

        spawnFish(upTo: cameraNode.position.x + spawnAheadDistance)
        spawnFishLeft(downTo: cameraNode.position.x - spawnAheadDistance)
        despawnFish(behind: cameraNode.position.x - despawnBehindDistance)
        let obstaclePositions = obstacles.map { $0.position }
        fish.forEach { $0.update(deltaTime: deltaTime, playerPosition: player.position, nearbyObstacles: obstaclePositions) }

        spawnOOIs(upTo: cameraNode.position.x + spawnAheadDistance)
        spawnOOIsLeft(downTo: cameraNode.position.x - spawnAheadDistance)
        despawnOOIs(behind: cameraNode.position.x - despawnBehindDistance)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let categories = [contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask]

        if categories.contains(PhysicsCategory.obstacle) {
            flash(player, backTo: .white)
        }

        if categories.contains(PhysicsCategory.hostileFish) {
            let hostileFish = [contact.bodyA.node, contact.bodyB.node]
                .compactMap { $0 as? Fish }
                .first { $0.kind == .hostile }
            if let hostileFish {
                flash(hostileFish, backTo: hostileFish.normalColor)
            }
        }

        if categories.contains(PhysicsCategory.ooi) {
            let ooi = [contact.bodyA.node, contact.bodyB.node].compactMap { $0 as? OOI }.first
            ooi?.removeFromParent()
        }
    }

    private func flash(_ node: SKShapeNode, backTo normalColor: SKColor) {
        node.run(SKAction.sequence([
            SKAction.run { node.fillColor = .red },
            SKAction.wait(forDuration: 0.15),
            SKAction.run { node.fillColor = normalColor }
        ]))
    }
}
