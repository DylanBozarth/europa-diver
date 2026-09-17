//
//  GameViewController.swift
//  europa-diver
//
//  Created by Dylan Bozarth on 9/15/26.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Keep scene.size in sync with the view's actual point size so that
                // camera-relative UI (e.g. the joystick) and the on-screen viewport
                // agree on scale — aspectFill would scale/crop the fixed 512x384
                // canvas to fit the device, throwing that off.
                scene.scaleMode = .resizeFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
