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
        body.contactTestBitMask = PhysicsCategory.obstacle
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
    }

    func didBegin(_ contact: SKPhysicsContact) {
        player.run(SKAction.sequence([
            SKAction.run { [weak self] in self?.player.fillColor = .red },
            SKAction.wait(forDuration: 0.15),
            SKAction.run { [weak self] in self?.player.fillColor = .white }
        ]))
    }
}
