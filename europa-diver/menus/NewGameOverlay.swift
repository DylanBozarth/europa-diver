//
//  NewGameOverlay.swift
//  europa-diver
//
//  Panel shown from the main menu after tapping "New Game": lets the player
//  opt out of the tutorial level before confirming with "Continue".
//

import SpriteKit

class NewGameOverlay: SKNode {

    private let background = SKShapeNode()
    private let panel = SKShapeNode(rectOf: CGSize(width: 280, height: 180), cornerRadius: 12)
    private let titleLabel = SKLabelNode(text: "New Game")

    private let skipTutorialCheckbox = SKShapeNode(rectOf: CGSize(width: 22, height: 22), cornerRadius: 4)
    private let skipTutorialCheckmark = SKLabelNode(text: "✓")
    private var skipTutorialChecked = false

    private let continueButton = SKShapeNode(rectOf: CGSize(width: 180, height: 50), cornerRadius: 10)
    private let continueLabel = SKLabelNode(text: "Continue")

    override init() {
        super.init()
        zPosition = 300
        isHidden = true

        background.fillColor = SKColor.black.withAlphaComponent(0.7)
        background.strokeColor = .clear

        panel.fillColor = SKColor(red: 0.05, green: 0.1, blue: 0.2, alpha: 0.95)
        panel.strokeColor = .white
        panel.lineWidth = 2
        panel.zPosition = 1

        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: 60)
        titleLabel.zPosition = 1

        skipTutorialCheckbox.name = "skipTutorialCheckbox"
        skipTutorialCheckbox.fillColor = .clear
        skipTutorialCheckbox.strokeColor = .white
        skipTutorialCheckbox.lineWidth = 2
        skipTutorialCheckbox.position = CGPoint(x: -70, y: 10)
        skipTutorialCheckbox.zPosition = 1

        skipTutorialCheckmark.fontName = "Helvetica-Bold"
        skipTutorialCheckmark.fontSize = 18
        skipTutorialCheckmark.fontColor = .white
        skipTutorialCheckmark.horizontalAlignmentMode = .center
        skipTutorialCheckmark.verticalAlignmentMode = .center
        skipTutorialCheckmark.isHidden = true
        skipTutorialCheckbox.addChild(skipTutorialCheckmark)

        let skipTutorialLabel = SKLabelNode(text: "Skip Tutorial")
        skipTutorialLabel.fontName = "Helvetica"
        skipTutorialLabel.fontSize = 18
        skipTutorialLabel.fontColor = .white
        skipTutorialLabel.horizontalAlignmentMode = .left
        skipTutorialLabel.verticalAlignmentMode = .center
        skipTutorialLabel.position = CGPoint(x: -52, y: 10)
        skipTutorialLabel.zPosition = 1

        continueButton.name = "continueButton"
        continueButton.fillColor = SKColor.white.withAlphaComponent(0.15)
        continueButton.strokeColor = .white
        continueButton.lineWidth = 2
        continueButton.position = CGPoint(x: 0, y: -50)
        continueButton.zPosition = 1

        continueLabel.fontName = "Helvetica-Bold"
        continueLabel.fontSize = 20
        continueLabel.fontColor = .white
        continueLabel.verticalAlignmentMode = .center
        continueLabel.horizontalAlignmentMode = .center
        continueLabel.zPosition = 1
        continueButton.addChild(continueLabel)

        panel.addChild(titleLabel)
        panel.addChild(skipTutorialCheckbox)
        panel.addChild(skipTutorialLabel)
        panel.addChild(continueButton)

        addChild(background)
        addChild(panel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resize(to size: CGSize) {
        background.path = CGPath(
            rect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height),
            transform: nil
        )
    }

    func show() {
        skipTutorialChecked = false
        skipTutorialCheckmark.isHidden = true
        isHidden = false
    }

    func hide() { isHidden = true }

    private func toggleSkipTutorial() {
        skipTutorialChecked.toggle()
        skipTutorialCheckmark.isHidden = !skipTutorialChecked
    }

    /// `point` must be in this node's own coordinate space. Returns true if
    /// the touch was handled (consumed) by the overlay, along with whether
    /// "Continue" was tapped and, if so, the chosen skip-tutorial state.
    func handleTouch(_ point: CGPoint) -> (handled: Bool, startGame: Bool, skipTutorial: Bool) {
        // `point` is in the overlay's own space; the checkbox/continue button
        // are children of `panel`, so convert into panel space for them.
        let pointInPanel = panel.convert(point, from: self)

        if skipTutorialCheckbox.contains(pointInPanel) {
            toggleSkipTutorial()
            return (true, false, skipTutorialChecked)
        }
        if continueButton.contains(pointInPanel) {
            return (true, true, skipTutorialChecked)
        }
        if panel.contains(point) {
            return (true, false, skipTutorialChecked)
        }
        // Tapped outside the panel: dismiss without starting.
        hide()
        return (true, false, skipTutorialChecked)
    }
}
