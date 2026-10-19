//
//  HUDButton.swift
//  europa-diver
//
//  A simple round HUD button (icon on a translucent circle) that lights up
//  for as long as it's held down.
//

import SpriteKit

class HUDButton: SKNode {

    private let background: SKShapeNode
    private let normalFillColor = SKColor.white.withAlphaComponent(0.15)
    private let pressedFillColor = SKColor.white.withAlphaComponent(0.55)
    private let toggledOnFillColor = SKColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.65)

    private var isPressed = false
    private var isToggledOn = false

    init(icon: String, diameter: CGFloat = 50) {
        background = SKShapeNode(circleOfRadius: diameter / 2)

        super.init()
        zPosition = 100

        background.fillColor = normalFillColor
        background.strokeColor = SKColor.white.withAlphaComponent(0.4)
        background.lineWidth = 2

        let label = SKLabelNode(text: icon)
        label.fontSize = diameter * 0.5
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 1

        addChild(background)
        addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Lights the button up while `pressed` is true; call with `false` on
    /// touch-up/cancel to release it. Reflects the actual held state rather
    /// than a fixed-duration flash.
    func setPressed(_ pressed: Bool) {
        removeAction(forKey: "press")
        isPressed = pressed
        refreshAppearance()
    }

    /// For toggle-style buttons (e.g. Light): a persistent "on" highlight,
    /// independent of the momentary press flash above — tapping to toggle
    /// still presses, but the highlight sticks around after release only
    /// while actually on.
    func setToggledOn(_ on: Bool) {
        isToggledOn = on
        refreshAppearance()
    }

    private func refreshAppearance() {
        xScale = isPressed ? 0.9 : 1.0
        yScale = isPressed ? 0.9 : 1.0

        if isPressed {
            background.fillColor = pressedFillColor
        } else if isToggledOn {
            background.fillColor = toggledOnFillColor
        } else {
            background.fillColor = normalFillColor
        }
    }
}
