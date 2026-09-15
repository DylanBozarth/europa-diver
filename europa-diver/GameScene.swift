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
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    private let player = SKShapeNode(circleOfRadius: 12)
    private let cameraNode = SKCameraNode()
    private var touchLocation: CGPoint?
    private let moveSpeed: CGFloat = 160

    private let worldTop: CGFloat = 180
    private let worldBottom: CGFloat = -180

    private var furthestSpawnedX: CGFloat = 0
    private let obstacleSpacing: ClosedRange<CGFloat> = 120...220
    private let spawnAheadDistance: CGFloat = 500
    private let despawnBehindDistance: CGFloat = 500

    private var fish: [Fish] = []
    private var furthestFishSpawnedX: CGFloat = 0
    private let fishSpacing: ClosedRange<CGFloat> = 150...300
    private var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.02, green: 0.08, blue: 0.18, alpha: 1.0)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        camera = cameraNode
        addChild(cameraNode)

        setUpBoundaries()
        setUpPlayer()

        furthestSpawnedX = player.position.x
        spawnObstacles(upTo: furthestSpawnedX + spawnAheadDistance)

        furthestFishSpawnedX = player.position.x
        spawnFish(upTo: furthestFishSpawnedX + spawnAheadDistance)
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
        body.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.largeFish | PhysicsCategory.hostileFish
        player.physicsBody = body

        addChild(player)
        cameraNode.position = player.position
    }

    private func spawnObstacles(upTo maxX: CGFloat) {
        while furthestSpawnedX < maxX {
            furthestSpawnedX += CGFloat.random(in: obstacleSpacing)
            let y = CGFloat.random(in: (worldBottom + 40)...(worldTop - 40))
            addObstacle(at: CGPoint(x: furthestSpawnedX, y: y))
        }
    }

    private func addObstacle(at position: CGPoint) {
        let radius: CGFloat = 20
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
    }

    private func despawnObstacles(behind minX: CGFloat) {
        for child in children where child.name == "obstacle" && child.position.x < minX {
            child.removeFromParent()
        }
    }

    private func spawnFish(upTo maxX: CGFloat) {
        while furthestFishSpawnedX < maxX {
            furthestFishSpawnedX += CGFloat.random(in: fishSpacing)
            addFish(around: furthestFishSpawnedX)
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
        let roamLeft = x - 60
        let roamRight = x + 60
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = touches.first?.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = touches.first?.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        if let target = touchLocation, let body = player.physicsBody {
            let dx = target.x - player.position.x
            let dy = target.y - player.position.y
            let distance = sqrt(dx * dx + dy * dy)

            if distance > 4 {
                let direction = CGVector(dx: dx / distance, dy: dy / distance)
                body.velocity = CGVector(dx: direction.dx * moveSpeed, dy: direction.dy * moveSpeed)
            }
        }

        cameraNode.position.x = player.position.x

        spawnObstacles(upTo: cameraNode.position.x + spawnAheadDistance)
        despawnObstacles(behind: cameraNode.position.x - despawnBehindDistance)

        spawnFish(upTo: cameraNode.position.x + spawnAheadDistance)
        despawnFish(behind: cameraNode.position.x - despawnBehindDistance)
        fish.forEach { $0.update(deltaTime: deltaTime, playerPosition: player.position) }
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
    }

    private func flash(_ node: SKShapeNode, backTo normalColor: SKColor) {
        node.run(SKAction.sequence([
            SKAction.run { node.fillColor = .red },
            SKAction.wait(forDuration: 0.15),
            SKAction.run { node.fillColor = normalColor }
        ]))
    }
}
