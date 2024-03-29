//: A SpriteKit based Playground

/*: Markup overview
 
 # Woosh
 
 ![Playground icon](wooshName-28.png)
 
 Enjoy your life in space!
 Play woosh in upstand position
 
 Music from https://www.zapsplat.com
 
 */

import PlaygroundSupport
import SpriteKit
import CoreMotion
import UIKit

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 480, height: 640))


if let scene = GameScene(fileNamed: "GameScene") {
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    
    // Present the scene
    sceneView.presentScene(scene)
}

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
