//
//  PlayerStatsHUD.swift
//  europa-diver
//
//  On-screen power and durability meters, driven by PlayerStats. Inventory
//  isn't shown yet.
//

import SpriteKit

class MeterBar: SKNode {
    private let barWidth: CGFloat
    private let barHeight: CGFloat
    private let maxValue: Int
    private let title: String

    private let track = SKShapeNode()
    private let fill = SKShapeNode()
    private let label = SKLabelNode()

    init(title: String, maxValue: Int, color: SKColor, width: CGFloat = 140, height: CGFloat = 14) {
        self.title = title
        self.maxValue = maxValue
        self.barWidth = width
        self.barHeight = height

        super.init()

        track.path = MeterBar.roundedRect(width: width, height: height)
        track.fillColor = SKColor.black.withAlphaComponent(0.4)
        track.strokeColor = SKColor.white.withAlphaComponent(0.5)
        track.lineWidth = 1

        fill.fillColor = color
        fill.strokeColor = .clear
        fill.zPosition = 1

        label.fontName = "Helvetica-Bold"
        label.fontSize = 12
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .bottom
        label.position = CGPoint(x: 0, y: height / 2 + 2)
        label.zPosition = 1

        addChild(track)
        addChild(fill)
        addChild(label)

        update(value: maxValue)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(value: Int) {
        let clamped = min(max(value, 0), maxValue)
        let ratio = maxValue > 0 ? CGFloat(clamped) / CGFloat(maxValue) : 0
        let filledWidth = max(barWidth * ratio, 0.01)

        fill.path = MeterBar.roundedRect(width: filledWidth, height: barHeight)
        label.text = "\(title): \(clamped)/\(maxValue)"
    }

    private static func roundedRect(width: CGFloat, height: CGFloat) -> CGPath {
        CGPath(
            roundedRect: CGRect(x: 0, y: -height / 2, width: width, height: height),
            cornerWidth: height / 2,
            cornerHeight: height / 2,
            transform: nil
        )
    }
}

class PlayerStatsHUD: SKNode {
    private let powerBar: MeterBar
    private let durabilityBar: MeterBar

    override init() {
        powerBar = MeterBar(title: "Power", maxValue: PlayerStats.maxPower, color: .cyan)
        durabilityBar = MeterBar(title: "Durability", maxValue: PlayerStats.maxDurability, color: .green)

        super.init()
        zPosition = 100

        powerBar.position = CGPoint(x: 0, y: 0)
        durabilityBar.position = CGPoint(x: 0, y: -34)

        addChild(powerBar)
        addChild(durabilityBar)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(stats: PlayerStats) {
        powerBar.update(value: stats.power)
        durabilityBar.update(value: stats.durability)
    }
}
