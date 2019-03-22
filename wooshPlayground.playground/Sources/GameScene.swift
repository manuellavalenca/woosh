import Foundation
import SpriteKit
import CoreMotion

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
    var labelTimingCount = 0
    var labelDeath = SKLabelNode()
    var death = false
    var gameStarted = false
    let startButton = SKSpriteNode()
    
    override public func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        createSky()
        
        startButton.size = CGSize(width: 300, height: 202)
        startButton.texture = SKTexture(image: UIImage(named: "startButton-21.png")!)
        startButton.position = CGPoint(x: 0, y: 0);
        self.addChild(startButton)
    }
    
    public func createSky(){
        
        let arrayImages = [0: "skyBlue-22.png", 1: "skyBlue-22.png", 2: "skyBlueYellow-23.png", 3: "skyYellow-25.png", 4: "skyYellow-25.png", 5: "skyYellowandBlue-24.png"]
        
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
        
        let sunNode = SKShapeNode(rectOf: CGSize(width: (self.scene?.size.width)!, height: 100))
        
        
        sunNode.fillColor = UIColor.white
        sunNode.zPosition = 2.0
        sunNode.name = "sun"
        
        sunNode.physicsBody = SKPhysicsBody(rectangleOf: sunNode.frame.size)// CGSize(width: (self.scene?.size.width)!, height: 100))
        sunNode.physicsBody?.categoryBitMask = sunBitCategory
        sunNode.physicsBody?.collisionBitMask = cometBitCategory
        sunNode.physicsBody?.contactTestBitMask = cometBitCategory

        sunNode.physicsBody?.affectedByGravity = false
        sunNode.physicsBody?.allowsRotation = false
        sunNode.physicsBody?.isDynamic = false
        
        sunNode.position = CGPoint(x: 0, y: 2500)
        
        self.addChild(sunNode)

    }
    
    public func moveSky(){
        
        self.enumerateChildNodes(withName: "sky") { (node, error) in
            node.position.y -= 0.5
            if node.position.y < -((self.scene?.size.height)!) {
                node.position.y += (self.scene?.size.height)! * 5
            }
        }
        
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
        if let cometImage = UIImage(named: "wooshComet-12.png"){
            print("Texture created")
            cometNode.texture = SKTexture(image: cometImage)
            cometNode.name = "comet"
            cometNode.size = CGSize(width: cometImage.size.width/4, height: cometImage.size.height/4)
            cometNode.physicsBody = SKPhysicsBody(texture: SKTexture(image: cometImage), size: CGSize(width: cometImage.size.width/4, height: cometImage.size.height/4))
            cometNode.physicsBody?.affectedByGravity = false
            cometNode.physicsBody?.allowsRotation = false
        }
        
        cometNode.physicsBody?.categoryBitMask = cometBitCategory
        cometNode.physicsBody?.collisionBitMask =  sunBitCategory //| planetBitCategory
        cometNode.physicsBody?.contactTestBitMask = planetBitCategory
        
        cometNode.alpha = 0
        self.addChild(cometNode)
        cometNode.run(SKAction.fadeAlpha(to:1, duration: 2.0))
        
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
        
        //MUDAR AQUI
        var bluePlanetImage = UIImage()
        var redPlanetImage = UIImage()
        var greenPlanetImage = UIImage()
        
        if let image = UIImage(named: "planeta1-18.png"){
            bluePlanetImage = image
        }
        if let image = UIImage(named: "planeta2-19.png"){
            redPlanetImage = image
        }
        if let image = UIImage(named: "planeta3-20.png"){
            greenPlanetImage = image
        }
        
        // Random textures
        let arrayPlanetImages = [bluePlanetImage, redPlanetImage, greenPlanetImage]
        
        //VER AQUI TB
        let planetRandomTexture = SKTexture(image: arrayPlanetImages.randomElement() ?? bluePlanetImage)
        
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
        
        planet.run(SKAction.fadeIn(withDuration: 2.0))
        self.addChild(planet)
        
        // Move planet
        let action = SKAction.moveBy(x: 0, y: (self.scene?.size.height)!, duration: 15)

        //SKAction.moveTo(y: -(self.scene?.size.height)!, duration: 10)
        planet.run(action)
    }
    
    public func createPlanetsTimer(){
        let wait = SKAction.wait(forDuration: 2, withRange: 3)
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
//            else{
//                print("andando")
//                node.position.y -= 1
//            }
        }
    }
    
    public func showTextsSun(){
        self.labelDeath.position = CGPoint(x: 0, y: 0)
        self.labelDeath.name = "label"
        //self.label.physicsBody?.categoryBitMask = self.labelBitCategory
        self.labelDeath.text = ""
        self.labelDeath.fontSize = 40.0
        self.labelDeath.fontColor = UIColor.white
        self.labelDeath.zPosition = 5.0

        
        
        self.addChild(self.labelDeath)

        let showLabel1 = SKAction.run {
            self.labelDeath.text = "After all those billion years, you died"
        }
        
        let showLabel2 = SKAction.run {
            self.labelDeath.text = "You've seen quite a lot around the space..."
        }
        
        let showLabel3 = SKAction.run {
            self.labelDeath.text = "Death is our only true, isn't?"
        }
        
        let showLabel4 = SKAction.run {
            self.labelDeath.text = "You lived your last years as beautiful as your magnificent life"
        }
        
        let showLabel5 = SKAction.run {
            self.labelDeath.text = "But well, life is a cycle"
        }
        
        let showLabel6 = SKAction.run {
            self.labelDeath.text = "Enjoy your ride"
        }
        
        let deleteNode = SKAction.run {
            self.labelDeath.removeFromParent()
        }

        let waitAction = SKAction.wait(forDuration: 4.0)
        self.labelDeath.run(SKAction.sequence([showLabel1,waitAction,showLabel2,waitAction,showLabel3,waitAction,showLabel4,waitAction,showLabel5,waitAction,showLabel6,waitAction,deleteNode]))
        
    }
    

    
    public func didBegin(_ contact: SKPhysicsContact) {

        if death == false {
            
            // Death with sun
            if (contact.bodyA.node?.name == "sun" && contact.bodyB.node?.name == "comet") || (contact.bodyA.node?.name == "comet" && contact.bodyB.node?.name == "sun") {
                
                
                self.enumerateChildNodes(withName: "label") { (node, error) in
                    node.removeFromParent()
                }
                
                self.showTextsSun()
                
                print("OA A COLISAO COM O SOLLL")
                death = true
                
                var node = SKNode()
                
                if contact.bodyB.node?.name == "comet"{
                    node = contact.bodyB.node!
                } else if contact.bodyA.node?.name == "comet"{
                    node = contact.bodyA.node!
                }
                
                
                let disablePlanetContact = SKAction.run {
                    node.physicsBody?.categoryBitMask = self.sunBitCategory
                }
                let fadeOut = SKAction.fadeAlpha(to:0, duration: 2.0)
                let changePosition = SKAction.run {
                    node.position = CGPoint(x: 0, y: -20)
                    self.death = false
                }
                let fadeIn = SKAction.fadeAlpha(to:1, duration: 2.0)
                let enablePlanetContact = SKAction.run {
                    node.physicsBody?.categoryBitMask = self.cometBitCategory
                }
                let wait = SKAction.wait(forDuration: 5.0)
                
                node.run(SKAction.sequence([disablePlanetContact,fadeOut,changePosition, wait, fadeIn, enablePlanetContact]))
                
            }
            
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        // Check if the location of the touch is within the button's bounds
        if self.startButton.contains(touchLocation) {
            moveSky()
            createComet()
            createPlanetsTimer()
            self.startButton.removeFromParent()
            print("tapped!")
        }
        
    }
    
    override public func update(_ currentTime: TimeInterval) {
        if gameStarted == true{
            let xMovement = SKAction.moveTo(x: self.destX, duration: 1)
            self.cometNode.run(xMovement)
            moveSky()
            deletePlanets()
        }
    }
}
