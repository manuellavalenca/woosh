import Foundation
import SpriteKit
import CoreMotion
import UIKit
import AVFoundation

public class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // SpriteKit Variables
    var cometNode = SKSpriteNode()
    var destX : CGFloat = 0.0
    let planetBitCategory  : UInt32 = 0b001
    let sunBitCategory : UInt32 = 0b010
    let cometBitCategory : UInt32 = 0b100
    var cometAngle : CGFloat = 0.0
    var accelerationx : Double = 0.0
    var motionManager = CMMotionManager()
    
    
    var labelDeath = SKLabelNode()
    var death = false
    var gameStarted = false
    let startButton = SKSpriteNode()
    let wooshLogo = SKSpriteNode()
    let passLabel = SKSpriteNode()
    var arrayLabel = ["After all those billion years, you died","You've seen quite a lot around the space...", "Death is our only true, isn't?", "You had a magnificent life", "But well, life is a cycle", "Enjoy your ride"]
    var arrayLabelPosition = 0
    
    var player : AVAudioPlayer?
    
    
    override public func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        playMusic()
        createSky()
        createHomeScreen()
        
    }
    
    public func createHomeScreen(){
        
        // Create Woosh Logo
        wooshLogo.texture = SKTexture(image: UIImage(named: "wooshName-28.png")!)
        wooshLogo.size = CGSize(width: 800, height: 453)
        wooshLogo.position = CGPoint(x: 0, y: (self.scene?.size.height)!/5)
        wooshLogo.alpha = 1
        self.addChild(wooshLogo)
        
        // Create start button
        startButton.size = CGSize(width: 200, height: 77)
        startButton.texture = SKTexture(image: UIImage(named: "startButton-24.png")!)
        startButton.position = CGPoint(x: 0, y: -(self.scene?.size.height)!/4)
        startButton.alpha = 1
        self.addChild(startButton)
    }
    
    public func playMusic() {
        let url = Bundle.main.url(forResource: "audio_hero_Song", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    public func createSky(){
        
        let arrayImages = [0: "skyBlue-22.png", 1: "skyBlue-22.png", 2: "skyBlueYellow-23.png", 3: "skyYellow-25.png", 4: "skyYellow-25.png", 5: "skyYellowandBlue-24.png"]
        
        // Create one node with each sky image
        for index in 0..<arrayImages.count {
            let imageName = (key: index, value: arrayImages[index]!)
            print(imageName.value)
            if let image = UIImage(named: imageName.value){
                let skyTexture = SKTexture(image: image)
                let skyNode = SKSpriteNode(texture: skyTexture)
                skyNode.name = "sky"
                skyNode.zPosition = 0.0
                skyNode.size = CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!)
                if imageName.key == 0{
                    skyNode.position = CGPoint(x: 0, y: 0)
                } else {
                    skyNode.position = CGPoint(x: 0, y: CGFloat(imageName.key) * (skyNode.size.height-5))
                }
                self.addChild(skyNode)
            }
        }
        
        
        // Create sun node
        let sunNode = SKShapeNode(rectOf: CGSize(width: (self.scene?.size.width)!, height: 100))
        sunNode.zPosition = 2.0
        sunNode.name = "sun"
        
        sunNode.physicsBody = SKPhysicsBody(rectangleOf: sunNode.frame.size)
        sunNode.physicsBody?.categoryBitMask = sunBitCategory
        sunNode.physicsBody?.collisionBitMask = cometBitCategory
        sunNode.physicsBody?.contactTestBitMask = cometBitCategory
        sunNode.physicsBody?.affectedByGravity = false
        sunNode.physicsBody?.allowsRotation = false
        sunNode.physicsBody?.isDynamic = false
        
        sunNode.position = CGPoint(x: 0, y: 2500)
        
        sunNode.alpha = 0.0
        self.addChild(sunNode)

    }
    
    public func moveSky(){
        
        // Move sky nodes and change position after
        self.enumerateChildNodes(withName: "sky") { (node, error) in
            node.position.y -= 0.5
            if node.position.y < -((self.scene?.size.height)!) {
                node.position.y += (self.scene?.size.height)! * 5
            }
        }
        
        // Move sun node and change position after
        self.enumerateChildNodes(withName: "sun") { (node, error) in
            node.position.y -= 0.5
            if node.frame.minY < -((self.scene?.size.height)!/2 + node.frame.height) {
                node.position.y = (4 * (self.scene?.size.height)!) + 400
            }

        }
        
    }
    
    public func createComet(){
        
        cometNode.position = CGPoint(x: 0, y: -(self.scene?.size.height)!/3)
        cometNode.zPosition = 2.0
        
        // Avoid woosh comet to get out of scene
        let xRange = SKRange(lowerLimit: -((scene?.size.width)!/2),upperLimit: (scene?.size.width)!/2)
        let yRange = SKRange(lowerLimit: -(self.scene?.size.height)!/3,upperLimit: -(self.scene?.size.height)!/3)
        cometNode.constraints = [SKConstraint.positionX(xRange,y:yRange)]
        
        let cometImage = UIImage(named: "wooshComet-12.png")!
        cometNode.texture = SKTexture(image: cometImage)
        cometNode.name = "comet"
        cometNode.size = CGSize(width: cometImage.size.width/4, height: cometImage.size.height/4)
        cometNode.physicsBody = SKPhysicsBody(texture: SKTexture(image: cometImage), size: CGSize(width: cometImage.size.width/4, height: cometImage.size.height/4))
        cometNode.physicsBody?.affectedByGravity = false
        cometNode.physicsBody?.allowsRotation = false
        
        cometNode.physicsBody?.categoryBitMask = cometBitCategory
        cometNode.physicsBody?.collisionBitMask =  sunBitCategory
        cometNode.physicsBody?.contactTestBitMask = planetBitCategory
        
        cometNode.alpha = 0
        self.addChild(cometNode)
        cometNode.run(SKAction.fadeAlpha(to:1, duration: 4.0))
        
    }
    
    public func moveComet(){
        
        // Accelerometer data
        if motionManager.isAccelerometerAvailable {
            print("Tem acelerometro")
            
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
                if let accelerometerData = data{
                    self.accelerationx = accelerometerData.acceleration.x
                    let currentX = self.cometNode.position.x
                    
                    self.destX =  currentX + CGFloat(self.accelerationx * 500)
                }
            }
        }
    }
    
    public func createPlanetNode(){
        
        // Create images for textures
        let bluePlanetImage = UIImage(named: "planeta1-18.png")!
        let redPlanetImage = UIImage(named: "planeta2-19.png")!
        let greenPlanetImage = UIImage(named: "planeta3-20.png")!
        
        // Random textures
        let arrayPlanetImages = [bluePlanetImage, redPlanetImage, greenPlanetImage]
        let planetRandomTexture = SKTexture(image: arrayPlanetImages.randomElement()!)
        
        // Random position
        let maxLimit = self.size.width/2 - (bluePlanetImage.size.width)/2
        let minLimit = -(self.size.width/2 + (bluePlanetImage.size.width)/2)
        let randomX = CGFloat.random(in: minLimit ... maxLimit)
        let randomPosition = CGPoint(x: randomX, y:  self.size.height/2 + (bluePlanetImage.size.width)/4)
        
        // Create planet node
        let planet  = SKSpriteNode()
        planet.name = "planet"
        planet.size = CGSize(width: (bluePlanetImage.size.width)/4, height: (bluePlanetImage.size.height)/4)
        planet.position = randomPosition
        planet.zPosition = 2.0
        planet.texture = planetRandomTexture
        
        planet.physicsBody = SKPhysicsBody(texture: planetRandomTexture, size: CGSize(width: (bluePlanetImage.size.width)/4, height: (bluePlanetImage.size.height)/4))
        planet.physicsBody?.categoryBitMask = planetBitCategory
        planet.physicsBody?.collisionBitMask = cometBitCategory
        planet.physicsBody?.contactTestBitMask = cometBitCategory
        planet.physicsBody?.affectedByGravity = false
        
        planet.run(SKAction.fadeIn(withDuration: 2.0))
        self.addChild(planet)
        
    }
    
    public func createPlanetsTimer(){
        let wait = SKAction.wait(forDuration: 4, withRange: 3)
        let spawn = SKAction.run {
            self.createPlanetNode()
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    public func deletePlanets(){
        self.enumerateChildNodes(withName: "planet") { (node, error) in
            if node.position.y < -((self.scene?.size.height)!/2 + node.frame.size.height){
                node.removeFromParent()
            }
            else{
                node.position.y -= 2.0
            }
        }
    }
    
    public func showTextsSun(){
        
        self.labelDeath.position = CGPoint(x: 0, y: 0)
        self.labelDeath.name = "label"
        self.labelDeath.fontSize = 40.0
        self.labelDeath.fontColor = UIColor.white
        self.labelDeath.zPosition = 5.0
        self.labelDeath.text = arrayLabel[arrayLabelPosition]

        self.addChild(self.labelDeath)
        
        // Create button to go through labels
        passLabel.size = CGSize(width: 100, height: 100)
        passLabel.texture = SKTexture(image: UIImage(named: "passLabelButton-27.png")!)
        passLabel.position = CGPoint(x: 0, y: -100);
        self.addChild(passLabel)

    }

    
    public func didBegin(_ contact: SKPhysicsContact) {

        if death == false {
            
            // Death with sun
            if (contact.bodyA.node?.name == "sun" && contact.bodyB.node?.name == "comet") || (contact.bodyA.node?.name == "comet" && contact.bodyB.node?.name == "sun") {
                
                
                self.enumerateChildNodes(withName: "label") { (node, error) in
                    node.removeFromParent()
                }
                
                self.showTextsSun()
                
                self.death = true
                
                var node = SKNode()
                
                
                
//                if contact.bodyB.node?.name == "comet"{
//                    node = contact.bodyB.node!
//                } else if contact.bodyA.node?.name == "comet"{
//                    node = contact.bodyA.node!
//                }
//
//
                // Avoid killing it again when it has just died
                let disablePlanetContact = SKAction.run {
                    self.cometNode.physicsBody?.categoryBitMask = self.sunBitCategory
                }


                let fadeOut = SKAction.fadeAlpha(to:0, duration: 2.0)
                self.cometNode.run(SKAction.sequence([disablePlanetContact,fadeOut]))
                
            }
            
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if self.startButton.contains(touchLocation) && self.gameStarted == false {
            
            self.gameStarted = true
            createComet()
            moveComet()
            createPlanetsTimer()
            let fadeOut = SKAction.fadeAlpha(to:0, duration: 1.5)
            let deleteNode = SKAction.run {
                self.removeFromParent()
            }
            let sequence = SKAction.sequence([fadeOut, deleteNode])
           
            self.wooshLogo.run(sequence)
            self.startButton.run(sequence)
            
            
        }
        
        if self.passLabel.contains(touchLocation) {
            
            arrayLabelPosition += 1
            if arrayLabelPosition < arrayLabel.count{
                self.labelDeath.text = arrayLabel[arrayLabelPosition]
            } else{
                arrayLabelPosition = 0
                self.labelDeath.removeFromParent()
                self.passLabel.removeFromParent()
                self.rebornComet()
            }
        }
        
    }
    
    public func rebornComet(){
        
        let fadeIn = SKAction.fadeAlpha(to:1, duration: 2.0)
        
        let enablePlanetContact = SKAction.run {
            self.cometNode.physicsBody?.categoryBitMask = self.cometBitCategory
        }
        
        self.cometNode.run(SKAction.sequence([fadeIn, enablePlanetContact]))

    }
    
    override public func update(_ currentTime: TimeInterval) {
        if gameStarted == true{
            let xMovement = SKAction.moveTo(x: self.destX, duration: 1)
            
            if self.destX < (self.cometNode.position.x - 40) {
                self.cometNode.texture = SKTexture(image: UIImage(named: "wooshComet-12-2.png")!)
            } else if self.destX > (self.cometNode.position.x + 40){
                self.cometNode.texture = SKTexture(image: UIImage(named: "wooshComet-12.png")!)
            } else{
                self.cometNode.texture = SKTexture(image: UIImage(named: "wooshComet-29.png")!)
            }
            
            self.cometNode.run(xMovement)
            moveSky()
            deletePlanets()
        }
    }
}
