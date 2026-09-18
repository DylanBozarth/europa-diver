//
//  Joystick.swift
//  europa-diver
//
//  An on-screen analog joystick: a base + knob pair whose knob follows a
//  touch, clamped to the base's radius, exposing a normalized drive vector.
//

import SpriteKit

class Joystick: SKNode {

    private let knob: SKShapeNode
    private let radius: CGFloat

    private(set) var vector: CGVector = .zero

    init(radius: CGFloat = 40) {
        self.radius = radius
        let base = SKShapeNode(circleOfRadius: radius)
        knob = SKShapeNode(circleOfRadius: radius * 0.45)

        super.init()
        zPosition = 100

        base.fillColor = SKColor.white.withAlphaComponent(0.15)
        base.strokeColor = SKColor.white.withAlphaComponent(0.4)
        base.lineWidth = 2

        knob.fillColor = SKColor.white.withAlphaComponent(0.5)
        knob.strokeColor = .white
        knob.lineWidth = 2

        addChild(base)
        addChild(knob)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// `touchPoint` must already be in this node's local coordinate space (i.e. relative
    /// to the base's center). Pass `nil` when the controlling touch has ended.
    func update(withTouch touchPoint: CGPoint?) {
        guard let touchPoint else {
            knob.position = .zero
            vector = .zero
            return
        }

        let distance = sqrt(touchPoint.x * touchPoint.x + touchPoint.y * touchPoint.y)
        guard distance > 0.001 else {
            knob.position = .zero
            vector = .zero
            return
        }

        if distance <= radius {
            knob.position = touchPoint
            vector = CGVector(dx: touchPoint.x / radius, dy: touchPoint.y / radius)
        } else {
            let scale = radius / distance
            knob.position = CGPoint(x: touchPoint.x * scale, y: touchPoint.y * scale)
            vector = CGVector(dx: touchPoint.x / distance, dy: touchPoint.y / distance)
        }
    }
}
