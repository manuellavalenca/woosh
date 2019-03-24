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
    
    var rightMoved = false
    var deathScreen = SKShapeNode()
    var leftMoved = false
    var ipadNode = SKSpriteNode()
    var labelIntro = SKLabelNode()
    var labelDeath = SKLabelNode()
    var planetsCollidedLabel = SKLabelNode()
    var planetsCountBackground = SKSpriteNode()
    var planetsCountNodes = [SKSpriteNode()]
    var death = false
    var gameStarted = false
    let startButton = SKSpriteNode()
    var backgroundNode = SKSpriteNode()
    let wooshLogo = SKSpriteNode()
    let passLabel = SKSpriteNode()
    var arrayLabel = ["After all those billion years, you died","You've seen quite a lot around the space...", "Death is our only true, isn't?", "You had a magnificent life", "But well, life is a cycle", "Enjoy your ride"]
    var arrayLabelPosition = 0
    var planetsCollided = 0
    
    var player : AVAudioPlayer?
    
    
    override public func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        playMusic()
        createSky()
        createHomeScreen()
        
    }
    
    public func createHomeScreen(){
        emitStarts()
        // Create Woosh Logo
        wooshLogo.texture = SKTexture(image: UIImage(named: "wooshName-28.png")!)
        wooshLogo.size = CGSize(width: 800, height: 453)
        wooshLogo.position = CGPoint(x: 0, y: (self.scene?.size.height)!/5)
        wooshLogo.alpha = 1
        self.addChild(wooshLogo)
        
        //Create background start button
        backgroundNode.size = CGSize(width: 215, height: 112)
        backgroundNode.position = CGPoint(x: 0, y: -(self.scene?.size.height)!/4)
        backgroundNode.alpha = 1
        self.addChild(backgroundNode)
        
        let wait = SKAction.wait(forDuration: 0.25)
        let imageBGButton1 = SKAction.run {
            self.backgroundNode.texture = SKTexture(image: UIImage(named: "startButtonBg-32.png")!)
        }
        let imageBGButton2 = SKAction.run {
            self.backgroundNode.texture = SKTexture(image: UIImage(named: "startButtonBg2-33.png")!)
        }
        
        let imageBGButton3 = SKAction.run {
            self.backgroundNode.texture = SKTexture(image: UIImage(named: "startButtonBg-34.png")!)
        }
        
        let bgSequence = SKAction.sequence([imageBGButton1, wait, imageBGButton2, wait, imageBGButton3, wait])
        backgroundNode.run(SKAction.repeatForever(bgSequence))
        
        // Create start button
        self.startButton.size = CGSize(width: 200, height: 77)
        self.startButton.position = CGPoint(x: 0, y: -(self.scene?.size.height)!/4)
        self.startButton.alpha = 1
        self.addChild(self.startButton)
        
        let imageButton1 = SKAction.run {
            self.startButton.texture = SKTexture(image: UIImage(named: "startButton-24.png")!)
        }
        let imageButton2 = SKAction.run {
            self.startButton.texture = SKTexture(image: UIImage(named: "startButton2-24.png")!)
        }
        let sequence = SKAction.sequence([imageButton1, wait, imageButton2, wait])
        self.startButton.run(SKAction.repeatForever(sequence))
        
    }
    
    public func showPlanetsCount(){
        //        // Create label with number of planets collided
        //        self.planetsCollidedLabel.position = CGPoint(x: 0, y: (self.scene?.size.height)!/1.3)
        //        self.planetsCollidedLabel.name = "numberPlanets"
        //        self.planetsCollidedLabel.fontSize = 40.0
        //        self.planetsCollidedLabel.fontColor = UIColor.white
        //        self.planetsCollidedLabel.zPosition = 10.0
        //        self.planetsCollidedLabel.text = "Planet collisions left to die: \(5-self.planetsCollided)"
        //
        //        self.addChild(self.planetsCollidedLabel)
        
        
        // Create planets count background
        self.planetsCountBackground.size = CGSize(width: 400, height: 100)
        self.planetsCountBackground.position = CGPoint(x: 0, y: (self.scene?.size.height)!/3)
        self.planetsCountBackground.texture = SKTexture(image: UIImage(named: "backgroundPlanetCount-36.png")!)
        self.planetsCountBackground.zPosition = 10.0
        self.planetsCountBackground.alpha = 1
        self.addChild(self.planetsCountBackground)
        
        // Create planets
        let planet1 = SKSpriteNode()
        let planet2 = SKSpriteNode()
        let planet3 = SKSpriteNode()
        let planet4 = SKSpriteNode()
        let planet5 = SKSpriteNode()
        
        self.planetsCountNodes = [planet1, planet2, planet3, planet4, planet5]
        for planet in self.planetsCountNodes{
            planet.size = CGSize(width: 60, height: 60)
            planet.position = CGPoint(x: CGFloat((70 * self.planetsCountNodes.firstIndex(of: planet)!)) + self.planetsCountBackground.frame.minX + 60, y: (self.scene?.size.height)!/3)
            planet.texture = SKTexture(image: UIImage(named: "planetEmpty-38.png")!)
            planet.zPosition = 10.0
            planet.alpha = 1
            self.addChild(planet)
        }
    }
    
    public func playMusic() {
        
        // Set player to play song in loop
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
        
        sunNode.fillColor = UIColor.red
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
    
    public func moveNodes(){
        
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
        
        // Move planets and delete the ones that got out of screen
        self.enumerateChildNodes(withName: "planet") { (node, error) in
            if node.position.y < -((self.scene?.size.height)!/2 + node.frame.size.height){
                node.removeFromParent()
            }
            else{
                node.position.y -= 2.0
                
            }
        }
        
        self.enumerateChildNodes(withName: "emitter") { (node, error) in
            if node.position.y < -((self.scene?.size.height)!/2 + node.frame.size.height){
                node.removeFromParent()
            }
            else{
                node.position.y -= 2.0
                
            }
        }
        
    }
    
    public func createComet(){
        
        // Create comet node
        cometNode.position = CGPoint(x: 0, y: -(self.scene?.size.height)!/2.3)
        cometNode.zPosition = 2.0
        let cometImage = UIImage(named: "wooshComet-12.png")!
        cometNode.texture = SKTexture(image: cometImage)
        cometNode.name = "comet"
        cometNode.alpha = 0
        cometNode.size = CGSize(width: cometImage.size.width/4, height: cometImage.size.height/4)
        
        // Create physics body to enable collisions
        cometNode.physicsBody = SKPhysicsBody(texture: SKTexture(image: cometImage), size: CGSize(width: cometImage.size.width/4, height: cometImage.size.height/4))
        cometNode.physicsBody?.affectedByGravity = false
        cometNode.physicsBody?.allowsRotation = false
        cometNode.physicsBody?.categoryBitMask = cometBitCategory
        cometNode.physicsBody?.collisionBitMask =  sunBitCategory
        cometNode.physicsBody?.contactTestBitMask = planetBitCategory
        
        // Avoid woosh comet to get out of scene
        let xRange = SKRange(lowerLimit: -((scene?.size.width)!/2),upperLimit: (scene?.size.width)!/2)
        let yRange = SKRange(lowerLimit: -(self.scene?.size.height)!/3,upperLimit: -(self.scene?.size.height)!/3)
        cometNode.constraints = [SKConstraint.positionX(xRange,y:yRange)]
        
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
        
        // Create physics body to enable collisions
        planet.physicsBody = SKPhysicsBody(texture: planetRandomTexture, size: CGSize(width: (bluePlanetImage.size.width)/4, height: (bluePlanetImage.size.height)/4))
        planet.physicsBody?.categoryBitMask = planetBitCategory
        planet.physicsBody?.collisionBitMask = cometBitCategory
        planet.physicsBody?.contactTestBitMask = cometBitCategory
        planet.physicsBody?.affectedByGravity = false
        
        planet.run(SKAction.fadeIn(withDuration: 2.0))
        self.addChild(planet)
        
    }
    
    public func createPlanetsTimer(){
        
        if self.death == false{
            // Create timer to create planets with random interval
            let wait = SKAction.wait(forDuration: 4, withRange: 3)
            let spawn = SKAction.run {
                if self.death == false{
                    self.createPlanetNode()
                }
            }
            
            let sequence = SKAction.sequence([wait, spawn])
            self.run(SKAction.repeatForever(sequence))
            
            
            self.enumerateChildNodes(withName: "planet") { (node, error) in
                if node.position.y < -((self.scene?.size.height)!/2 + node.frame.size.height){
                    node.removeFromParent()
                } else {
                    node.position.y -= 2.0
                }
            }
        }
        
    }
    
    
    public func showTextsSun(){
        
        // Remove sky, planets and emitters
        self.enumerateChildNodes(withName: "sky") { (node, error) in
            node.removeFromParent()
        }
        
        self.enumerateChildNodes(withName: "planet") { (node, error) in
            node.removeFromParent()
        }
        //
        //        self.enumerateChildNodes(withName: "emiter") { (node, error) in
        //            node.removeFromParent()
        //        }
        
        //self.arrayLabelPosition = 0
        
        self.planetsCountBackground.removeFromParent()
        for planet in planetsCountNodes{
            planet.removeFromParent()
        }
        
        self.deathScreen = SKShapeNode(rectOf: CGSize(width: (scene?.size.width)!, height: (scene?.size.height)!))
        self.deathScreen.fillColor = UIColor.black
        self.deathScreen.position = CGPoint(x: 0, y: 0)
        self.deathScreen.name = "deathScreen"
        self.deathScreen.alpha = 1
        self.addChild(self.deathScreen)
        
        // Set label for the comet's death
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
        
        if self.death == false {
            
            // Death with sun
            if (contact.bodyA.node?.name == "sun" && contact.bodyB.node?.name == "comet") || (contact.bodyA.node?.name == "comet" && contact.bodyB.node?.name == "sun") {
                
                self.enumerateChildNodes(withName: "label") { (node, error) in
                    node.removeFromParent()
                }
                
                self.showTextsSun()
                self.death = true
                self.planetsCollided = 0
                
                // Fade out dead comet
                
                let fadeOut = SKAction.fadeAlpha(to:0, duration: 2.0)
                let wait = SKAction.wait(forDuration: 0.25)
                let removeNode = SKAction.run {
                    self.cometNode.removeFromParent()
                }
                self.cometNode.run(SKAction.sequence([fadeOut, wait, removeNode]))
                
                for planet in self.planetsCountNodes{
                    planet.texture = SKTexture(image: UIImage(named: "planetEmpty-38.png")!)
                }
                
            }
            
            // Collision with planet
            if (contact.bodyA.node?.name == "planet" && contact.bodyB.node?.name == "comet") || (contact.bodyA.node?.name == "comet" && contact.bodyB.node?.name == "planet") {
                
                
                var collidedPlanetNode  = SKSpriteNode()
                
                if contact.bodyA.node?.name == "planet"{
                    collidedPlanetNode = contact.bodyA.node as! SKSpriteNode
                    collidedPlanetNode.removeFromParent()
                }
                
                if contact.bodyB.node?.name == "planet"{
                    collidedPlanetNode = contact.bodyB.node as! SKSpriteNode
                    collidedPlanetNode.removeFromParent()
                }
                
                self.emitParticles(node: collidedPlanetNode)
                
            }
            
        }
    }
    
    public func emitParticles(node: SKNode){
        let emitter = SKEmitterNode(fileNamed: "Emitter.sks")
        emitter?.name = "emitter"
        emitter?.position = node.position
        emitter?.particleTexture = SKTexture(image: UIImage(named: "dinossaur-35.png")!)
        if self.planetsCollided <= self.planetsCountNodes.count{
            self.planetsCountNodes[self.planetsCollided].texture = SKTexture(image: UIImage(named: "planetFull-39.png")!)
        } else{
            self.planetsCountNodes[4].texture = SKTexture(image: UIImage(named: "planetFull-39.png")!)
        }
        self.planetsCollided += 1
        
        self.addChild(emitter!)
    }
    
    public func emitStarts(){
        //        let starsEmitter = SKEmitterNode(fileNamed: "Emitter.sks")
        //        starsEmitter?.name = "emitter"
        //        self.addChild(starsEmitter!)
    }
    
    public func verifyPlanetsCollided(){
        print("PLANETS COLLIDED: \(self.planetsCollided)")
        if self.planetsCollided >= 5{
            print("PERDEU MERMAO")
            self.planetsCollided = 0
            for planet in self.planetsCountNodes{
                planet.texture = SKTexture(image: UIImage(named: "planetEmpty-38.png")!)
            }
            self.death = true
            
            let fadeOut = SKAction.fadeAlpha(to:0, duration: 2.0)
            let wait = SKAction.wait(forDuration: 0.25)
            let removeNode = SKAction.run {
                self.cometNode.removeFromParent()
            }
            
            self.cometNode.run(SKAction.sequence([fadeOut, wait, removeNode]))
            self.showTextsSun()
        }
    }
    
    public func introGame(){
        
        // Show users how to move woosh
        createComet()
        moveComet()
        
        self.labelIntro.position = CGPoint(x: 0, y: 0)
        self.labelIntro.name = "labelIntro"
        self.labelIntro.text = "Rotate the ipad to the left and to the right"
        self.labelIntro.fontSize = 40.0
        self.labelIntro.fontColor = UIColor.white
        self.labelIntro.zPosition = 10.0
        self.labelIntro.alpha = 0
        
        self.addChild(self.labelIntro)
        let removeParent = SKAction.run {
            self.removeFromParent()
        }

        let wait = SKAction.wait(forDuration: 5)
        let sequence = SKAction.sequence([SKAction.fadeIn(withDuration: 1.0), wait, SKAction.fadeOut(withDuration: 1.0), removeParent])
        self.labelIntro.run(sequence)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if self.startButton.contains(touchLocation) && self.gameStarted == false {
            
            // Fade out home screen
            let fadeOut = SKAction.fadeAlpha(to:0, duration: 1.5)
            let deleteNode = SKAction.run {
                self.removeFromParent()
            }
            let sequence = SKAction.sequence([fadeOut, deleteNode])
            
            self.wooshLogo.run(sequence)
            self.startButton.run(sequence)
            self.backgroundNode.run(sequence)
            
            // Appear intro part
            self.introGame()
            
            // Start game
            self.gameStarted = true
            createPlanetsTimer()
            showPlanetsCount()
            
        }
        
        if self.passLabel.contains(touchLocation) {
            
            // Button to pass through label texts
            arrayLabelPosition += 1
            print("ARRAY POSITION: \(self.arrayLabelPosition)")
            if arrayLabelPosition < arrayLabel.count{
                print("LENDO AS LABEL")
                self.labelDeath.text = arrayLabel[arrayLabelPosition]
            } else{
                print("ENTROU NA ULTIMA LABEL")
                self.death = false
                self.reviveSky()
                showPlanetsCount()
                self.deathScreen.removeFromParent()
                arrayLabelPosition = 0
                self.labelDeath.removeFromParent()
                self.passLabel.removeFromParent()
                self.reviveComet()
            }
        }
        
    }
    
    public func reviveSky(){
        // REINICIAR POSICOES DO CEU
        
        createSky()
    }
    
    public func reviveComet(){
        
        //let fadeIn = SKAction.fadeAlpha(to:1, duration: 2.0)
        //        let enablePlanetContact = SKAction.run {
        //            self.cometNode.physicsBody?.categoryBitMask = self.cometBitCategory
        //        }
        //let addCometNode = SKAction.run {
        self.addChild(self.cometNode)
        for planet in self.planetsCountNodes{
            planet.texture = SKTexture(image: UIImage(named: "planetEmpty-38.png")!)
        }
        self.cometNode.alpha = 1
        self.cometNode.run(SKAction.fadeIn(withDuration: 2.0))
        //}
        //let wait = SKAction.wait(forDuration: 0.25)
        //self.cometNode.run(SKAction.sequence([addCometNode, wait, SKAction.fadeIn(withDuration: 2.0)]))
        
    }
    
    override public func update(_ currentTime: TimeInterval) {
        if gameStarted == true{
            let xMovement = SKAction.moveTo(x: self.destX, duration: 1)
            
            // Change comet image to the direction it is going
            if self.destX < (self.cometNode.position.x - 40) {
                self.cometNode.texture = SKTexture(image: UIImage(named: "wooshComet-12-2.png")!)
            } else if self.destX > (self.cometNode.position.x + 40){
                self.cometNode.texture = SKTexture(image: UIImage(named: "wooshComet-12.png")!)
            } else{
                self.cometNode.texture = SKTexture(image: UIImage(named: "wooshComet-29.png")!)
            }
            
            
            // Identify user has moved ipad to begin the game
            if self.destX - self.cometNode.position.x > 30 {
                self.rightMoved = true
            }
            
            if self.destX - self.cometNode.position.x < -30{
                self.leftMoved = true
            }
            
            if self.rightMoved == true && self.leftMoved == true{
                self.ipadNode.removeFromParent()
                
            }
            
            self.cometNode.run(xMovement)
            self.moveNodes()
            self.verifyPlanetsCollided()
            self.planetsCollidedLabel.text = "Planet collisions left to die: \(5-self.planetsCollided)"
        }
    }
}
