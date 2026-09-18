//
//  LoadingOverlay.swift
//  europa-diver
//
//  A full-screen "Loading" cover shown while a new level is being generated.
//

import SpriteKit

class LoadingOverlay: SKNode {

    private let background = SKShapeNode()
    private let label = SKLabelNode(text: "Loading")

    override init() {
        super.init()
        zPosition = 200
        isHidden = true

        background.fillColor = .black
        background.strokeColor = .clear

        label.fontName = "Helvetica-Bold"
        label.fontSize = 28
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 1

        addChild(background)
        addChild(label)
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

    func show() { isHidden = false }
    func hide() { isHidden = true }
}
