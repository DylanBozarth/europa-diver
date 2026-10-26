//
//  GameOverOverlay.swift
//  europa-diver
//
//  Full-screen "Game Over" cover with tappable retry and shop buttons, shown
//  when the submarine's durability reaches zero. Two columns: controls on
//  the left, a Europa fact on the right — previously the fact sat below the
//  buttons and ran off the bottom of the (short, landscape) screen, so it
//  was never actually visible.
//

import SpriteKit

class GameOverOverlay: SKNode {

    private let background = SKShapeNode()
    private let divider = SKShapeNode()
    private let titleLabel = SKLabelNode(text: "Game Over")
    private let retryButton = SKShapeNode(rectOf: CGSize(width: 140, height: 50), cornerRadius: 10)
    private let retryLabel = SKLabelNode(text: "Retry")
    private let shopButton = SKShapeNode(rectOf: CGSize(width: 140, height: 50), cornerRadius: 10)
    private let shopLabel = SKLabelNode(text: "Shop")
    private let mainMenuButton = SKShapeNode(rectOf: CGSize(width: 140, height: 50), cornerRadius: 10)
    private let mainMenuLabel = SKLabelNode(text: "Main Menu")
    private let factTitleLabel = SKLabelNode(text: "DID YOU KNOW?")
    private let factLabel = SKLabelNode()

    override init() {
        super.init()
        zPosition = 300
        isHidden = true

        background.fillColor = SKColor.black.withAlphaComponent(0.85)
        background.strokeColor = .clear

        divider.fillColor = SKColor.white.withAlphaComponent(0.25)
        divider.strokeColor = .clear
        divider.zPosition = 1

        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .white
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 1

        retryButton.name = "retryButton"
        retryButton.fillColor = SKColor.red.withAlphaComponent(0.8)
        retryButton.strokeColor = .white
        retryButton.lineWidth = 2
        retryButton.zPosition = 1

        retryLabel.fontName = "Helvetica-Bold"
        retryLabel.fontSize = 20
        retryLabel.fontColor = .white
        retryLabel.verticalAlignmentMode = .center
        retryLabel.horizontalAlignmentMode = .center
        retryLabel.zPosition = 1
        retryButton.addChild(retryLabel)

        shopButton.name = "shopButton"
        shopButton.fillColor = SKColor.white.withAlphaComponent(0.15)
        shopButton.strokeColor = .white
        shopButton.lineWidth = 2
        shopButton.zPosition = 1

        shopLabel.fontName = "Helvetica-Bold"
        shopLabel.fontSize = 20
        shopLabel.fontColor = .white
        shopLabel.verticalAlignmentMode = .center
        shopLabel.horizontalAlignmentMode = .center
        shopLabel.zPosition = 1
        shopButton.addChild(shopLabel)

        mainMenuButton.name = "mainMenuButton"
        mainMenuButton.fillColor = SKColor.white.withAlphaComponent(0.15)
        mainMenuButton.strokeColor = .white
        mainMenuButton.lineWidth = 2
        mainMenuButton.zPosition = 1

        mainMenuLabel.fontName = "Helvetica-Bold"
        mainMenuLabel.fontSize = 20
        mainMenuLabel.fontColor = .white
        mainMenuLabel.verticalAlignmentMode = .center
        mainMenuLabel.horizontalAlignmentMode = .center
        mainMenuLabel.zPosition = 1
        mainMenuButton.addChild(mainMenuLabel)

        factTitleLabel.fontName = "Helvetica-Bold"
        factTitleLabel.fontSize = 14
        factTitleLabel.fontColor = SKColor.white.withAlphaComponent(0.6)
        factTitleLabel.verticalAlignmentMode = .center
        factTitleLabel.horizontalAlignmentMode = .center
        factTitleLabel.zPosition = 1

        factLabel.fontName = "Helvetica"
        factLabel.fontSize = 15
        factLabel.fontColor = SKColor.white.withAlphaComponent(0.85)
        factLabel.numberOfLines = 0
        factLabel.lineBreakMode = .byWordWrapping
        factLabel.verticalAlignmentMode = .center
        factLabel.horizontalAlignmentMode = .center
        factLabel.zPosition = 1

        addChild(background)
        addChild(divider)
        addChild(titleLabel)
        addChild(retryButton)
        addChild(shopButton)
        addChild(mainMenuButton)
        addChild(factTitleLabel)
        addChild(factLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resize(to size: CGSize) {
        background.path = CGPath(
            rect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height),
            transform: nil
        )

        // Left column: title + buttons. Right column: the fact, which needs
        // its own comfortably wide, vertically-centered block rather than
        // being squeezed below everything else.
        let leftColumnX = -size.width * 0.22
        let rightColumnX = size.width * 0.22
        let rightColumnWidth = min(size.width * 0.4, 340)

        titleLabel.position = CGPoint(x: leftColumnX, y: 70)
        retryButton.position = CGPoint(x: leftColumnX, y: 0)
        shopButton.position = CGPoint(x: leftColumnX, y: -60)
        mainMenuButton.position = CGPoint(x: leftColumnX, y: -120)

        let dividerHeight = min(size.height - 80, 260)
        divider.path = CGPath(
            rect: CGRect(x: -1, y: -dividerHeight / 2, width: 2, height: dividerHeight),
            transform: nil
        )
        divider.position = .zero

        factTitleLabel.position = CGPoint(x: rightColumnX, y: 50)
        factLabel.preferredMaxLayoutWidth = rightColumnWidth
        factLabel.position = CGPoint(x: rightColumnX, y: 0)
    }

    func show() {
        factLabel.text = facts.randomElement() ?? ""
        isHidden = false
    }

    func hide() { isHidden = true }

    /// `point` must be in this node's own coordinate space.
    func hitTestRetry(_ point: CGPoint) -> Bool {
        retryButton.contains(point)
    }

    /// `point` must be in this node's own coordinate space.
    func hitTestShop(_ point: CGPoint) -> Bool {
        shopButton.contains(point)
    }

    /// `point` must be in this node's own coordinate space.
    func hitTestMainMenu(_ point: CGPoint) -> Bool {
        mainMenuButton.contains(point)
    }
}
