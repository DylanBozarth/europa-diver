//
//  ShopOverlay.swift
//  europa-diver
//
//  Full-screen shop screen, reached from the main menu and the Game Over
//  screen. Shows the player's points plus one row per upgrade, each with
//  its own level (see Upgrade.maxLevel) and a cost for the next one.
//

import SpriteKit

/// One upgrade's row: name/icon, current level, and the cost (or "MAX") to
/// buy the next one. Purely a display — buying is handled by whichever
/// scene owns the overlay, via `ShopOverlay.hitTestUpgrade`.
private class ShopUpgradeRow: SKNode {
    let upgrade: Upgrade

    static let size = CGSize(width: 220, height: 56)

    private let card = SKShapeNode(rectOf: ShopUpgradeRow.size, cornerRadius: 10)
    private let nameLabel = SKLabelNode()
    private let levelLabel = SKLabelNode()
    private let costLabel = SKLabelNode()

    init(upgrade: Upgrade) {
        self.upgrade = upgrade
        super.init()

        card.fillColor = SKColor.white.withAlphaComponent(0.1)
        card.strokeColor = .white
        card.lineWidth = 2
        addChild(card)

        nameLabel.fontName = "Helvetica-Bold"
        nameLabel.fontSize = 16
        nameLabel.fontColor = .white
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.verticalAlignmentMode = .center
        nameLabel.text = "\(upgrade.icon) \(upgrade.displayName)"
        nameLabel.position = CGPoint(x: -100, y: 8)
        nameLabel.zPosition = 1
        addChild(nameLabel)

        levelLabel.fontName = "Helvetica"
        levelLabel.fontSize = 12
        levelLabel.fontColor = SKColor.white.withAlphaComponent(0.7)
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.verticalAlignmentMode = .center
        levelLabel.position = CGPoint(x: -100, y: -11)
        levelLabel.zPosition = 1
        addChild(levelLabel)

        costLabel.fontName = "Helvetica-Bold"
        costLabel.fontSize = 15
        costLabel.fontColor = .white
        costLabel.horizontalAlignmentMode = .right
        costLabel.verticalAlignmentMode = .center
        costLabel.position = CGPoint(x: 95, y: 0)
        costLabel.zPosition = 1
        addChild(costLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// `nextCost` is nil once the upgrade is at `maxLevel`.
    func update(level: Int, maxLevel: Int, nextCost: Int?) {
        levelLabel.text = "Level \(level) / \(maxLevel)"

        if let nextCost {
            costLabel.text = "\(nextCost) pts"
            costLabel.fontColor = .white
            card.strokeColor = .white
        } else {
            costLabel.text = "MAX"
            costLabel.fontColor = .green
            card.strokeColor = .green
        }
    }

    /// `point` must be in this row's own coordinate space.
    func containsTap(_ point: CGPoint) -> Bool {
        card.contains(point)
    }
}

class ShopOverlay: SKNode {

    private let background = SKShapeNode()
    private let titleLabel = SKLabelNode(text: "Shop")
    private let pointsLabel = SKLabelNode()

    private let closeButton = SKShapeNode(rectOf: CGSize(width: 140, height: 50), cornerRadius: 10)
    private let closeLabel = SKLabelNode(text: "Close")

    private var rows: [ShopUpgradeRow] = []
    /// Three upgrades per row — screens here are wide (landscape) and
    /// short, so keeping rows to a minimum leaves enough vertical room for
    /// real padding between them instead of them running into each other.
    private let columns = 3
    private let rowPadding: CGFloat = 18

    override init() {
        super.init()
        zPosition = 300
        isHidden = true

        // Fully opaque: this is a full-screen menu, not a translucent HUD
        // overlay, so nothing of the gameplay behind it should show through.
        background.fillColor = .black
        background.strokeColor = .clear

        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .white
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 1

        pointsLabel.fontName = "Helvetica-Bold"
        pointsLabel.fontSize = 18
        pointsLabel.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        pointsLabel.verticalAlignmentMode = .center
        pointsLabel.horizontalAlignmentMode = .center
        pointsLabel.zPosition = 1

        for upgrade in Upgrade.allCases {
            let row = ShopUpgradeRow(upgrade: upgrade)
            row.zPosition = 1
            rows.append(row)
        }

        closeButton.name = "closeButton"
        closeButton.fillColor = SKColor.white.withAlphaComponent(0.15)
        closeButton.strokeColor = .white
        closeButton.lineWidth = 2
        closeButton.zPosition = 1

        closeLabel.fontName = "Helvetica-Bold"
        closeLabel.fontSize = 20
        closeLabel.fontColor = .white
        closeLabel.verticalAlignmentMode = .center
        closeLabel.horizontalAlignmentMode = .center
        closeLabel.zPosition = 1
        closeButton.addChild(closeLabel)

        addChild(background)
        addChild(titleLabel)
        addChild(pointsLabel)
        rows.forEach(addChild)
        addChild(closeButton)

        layout(for: CGSize(width: 400, height: 300))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resize(to size: CGSize) {
        background.path = CGPath(
            rect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height),
            transform: nil
        )
        layout(for: size)
    }

    /// Spreads every element out to use the full screen (title near the
    /// top, close button near the bottom, upgrade grid filling what's left
    /// between them) instead of a small cluster in the middle. Rows use a
    /// fixed, comfortably-padded spacing and are centered as a block in
    /// whatever vertical room is left — they only shrink (uniformly, via
    /// setScale) on a screen too short to fit that spacing without the
    /// fallback actually overlapping.
    private func layout(for size: CGSize) {
        let halfHeight = size.height / 2

        titleLabel.position = CGPoint(x: 0, y: halfHeight - 45)
        pointsLabel.position = CGPoint(x: 0, y: titleLabel.position.y - 38)

        let closeY = -halfHeight + 48
        closeButton.position = CGPoint(x: 0, y: closeY)

        let gridTop = pointsLabel.position.y - 45
        let gridBottom = closeY + 55
        let availableHeight = gridTop - gridBottom

        let rowCount = Int(ceil(Double(rows.count) / Double(columns)))
        let gapCount = CGFloat(max(rowCount - 1, 0))
        let idealRowSpacing = ShopUpgradeRow.size.height + rowPadding
        let neededHeight = idealRowSpacing * gapCount
        let scale = neededHeight > 0 ? min(1, availableHeight / neededHeight) : 1
        let rowSpacing = idealRowSpacing * scale

        let gridHeight = rowSpacing * gapCount
        let firstRowY = (gridTop + gridBottom) / 2 + gridHeight / 2
        let columnSpacing = min(max(size.width * 0.24, 200), 240)

        for (index, row) in rows.enumerated() {
            let column = index % columns
            let gridRow = index / columns
            let x = (CGFloat(column) - CGFloat(columns - 1) / 2) * columnSpacing
            let y = firstRowY - CGFloat(gridRow) * rowSpacing
            row.position = CGPoint(x: x, y: y)
            row.setScale(scale)
        }
    }

    func show() { isHidden = false }
    func hide() { isHidden = true }

    /// Refreshes the points total and every upgrade row's level/cost.
    func refresh(points: Int, upgradeStore: UpgradeStore) {
        pointsLabel.text = "⭐ \(points) pts"
        for row in rows {
            row.update(
                level: upgradeStore.level(of: row.upgrade),
                maxLevel: row.upgrade.maxLevel,
                nextCost: upgradeStore.nextLevelCost(row.upgrade)
            )
        }
    }

    /// `point` must be in this node's own coordinate space.
    func hitTestClose(_ point: CGPoint) -> Bool {
        closeButton.contains(point)
    }

    /// `point` must be in this node's own coordinate space. Returns the
    /// upgrade whose row was tapped, if any.
    func hitTestUpgrade(_ point: CGPoint) -> Upgrade? {
        for row in rows where row.containsTap(row.convert(point, from: self)) {
            return row.upgrade
        }
        return nil
    }
}
