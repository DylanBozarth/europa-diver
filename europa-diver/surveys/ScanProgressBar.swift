//
//  ScanProgressBar.swift
//  europa-diver
//
//  Small HUD progress bar shown while a scan is in progress.
//

import SpriteKit

class ScanProgressBar: SKNode {
    private let barWidth: CGFloat
    private let barHeight: CGFloat
    private let track = SKShapeNode()
    private let fill = SKShapeNode()

    init(width: CGFloat = 90, height: CGFloat = 10) {
        barWidth = width
        barHeight = height

        super.init()
        zPosition = 100
        isHidden = true

        track.path = ScanProgressBar.roundedRect(width: width, height: height)
        track.fillColor = SKColor.black.withAlphaComponent(0.4)
        track.strokeColor = SKColor.white.withAlphaComponent(0.5)
        track.lineWidth = 1

        fill.fillColor = .cyan
        fill.strokeColor = .clear
        fill.zPosition = 1

        addChild(track)
        addChild(fill)

        setProgress(0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setProgress(_ ratio: CGFloat) {
        let clamped = min(max(ratio, 0), 1)
        let filledWidth = max(barWidth * clamped, 0.01)
        fill.path = ScanProgressBar.roundedRect(width: filledWidth, height: barHeight)
    }

    func show() { isHidden = false }
    func hide() { isHidden = true }

    private static func roundedRect(width: CGFloat, height: CGFloat) -> CGPath {
        CGPath(
            roundedRect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height),
            cornerWidth: height / 2,
            cornerHeight: height / 2,
            transform: nil
        )
    }
}
