import Foundation
import SpriteKit
import CoreMotion

public class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // SpriteKit Variables
    var cometNode = SKSpriteNode()
    var destX : CGFloat = 0.0
    let planetBitCategory  : UInt32 = 0b01
    let cometBitCategory : UInt32 = 0b01
    let labelBitCategory :UInt32 = 0b00
    var cometAngle : CGFloat = 0.0
    var accelerationx : Double = 0.0
    var motionManager = CMMotionManager()
    var labelTimingCount = 0
    var labelDeath = SKLabelNode()
    var death = false
    
    // Labels
    let arraySunTexts = ["After all those billion years, you died","Exploding in the sun. You've seen quite a lot around the space, huh?","Death is our only true, isn't?","And you managed to live your last years as beautiful as your magnificent life","But well, life is a cycle","Enjoy your ride"]
    
    override public func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        createSky()
        createComet()
        moveComet()
        createPlanetsTimer()
    }
    
    public func createSky(){
        
        let arrayImages = [0: "skyBlue-22.png", 1: "skyBlue-22.png", 2: "skyBlueYellow-23.png", 3: "skyYellow-25.png", 4: "skyYellow-25.png", 5: "skyYellowandBlue-24.png"]
        
        for index in 0..<arrayImages.count{
            let imageName = (key: index, value: arrayImages[index]!)
            print(imageName.value)
            if let image = UIImage(named: imageName.value){
                let skyTexture = SKTexture(image: image)
                let skyNode = SKSpriteNode(texture: skyTexture)
                skyNode.name = "sky"
                skyNode.zPosition = 0.0
                skyNode.size = CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!)
                //skyNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                if imageName.key == 0{
                    skyNode.position = CGPoint(x: 0, y: 0)
                } else {
                    skyNode.position = CGPoint(x: 0, y: CGFloat(imageName.key) * (skyNode.size.height-5))
                    if imageName.key == 2{
                        let sunNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: (self.scene?.size.width)!, height: 300))
                        sunNode.name = "sun"
                        sunNode.position = CGPoint(x: 0, y: CGFloat(imageName.key) * skyNode.size.height)
                        self.addChild(sunNode)
                    }
                }
                self.addChild(skyNode)
            }
        }
    }
    
    public func moveSky(){
        self.enumerateChildNodes(withName: "sky") { (node, error) in
            node.position.y -= 5
            if node.position.y < -((self.scene?.size.height)!) {
                node.position.y += (self.scene?.size.height)! * 5
            }
        }
        
        self.enumerateChildNodes(withName: "sun") { (node, error) in
            node.position.y -= 5
            if node.position.y < -((self.scene?.size.height)!) {
                node.position.y += (self.scene?.size.height)! * 5
            }
        }
        
    }
    
    public func createComet(){
        cometNode.position = CGPoint(x: 0, y: -20)
        cometNode.zPosition = 2.0
        if let cometImage = UIImage(named: "wooshComet-12.png"){
            print("Texture created")
            cometNode.texture = SKTexture(image: cometImage)
            cometNode.size = CGSize(width: cometImage.size.width/4, height: cometImage.size.height/4)
            cometNode.physicsBody = SKPhysicsBody(texture: SKTexture(image: cometImage), size: CGSize(width: cometImage.size.width/4, height: cometImage.size.height/4))
            cometNode.physicsBody?.affectedByGravity = false
        }
        
        cometNode.physicsBody?.categoryBitMask = cometBitCategory
        cometNode.physicsBody?.collisionBitMask = planetBitCategory
        cometNode.physicsBody?.contactTestBitMask = cometBitCategory
        
        self.addChild(cometNode)
        
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
        planet.physicsBody?.contactTestBitMask = planetBitCategory
        
        planet.run(SKAction.fadeIn(withDuration: 2.0))
        self.addChild(planet)
        
        // Move planet
        let action = SKAction.moveBy(x: 0, y: (self.scene?.size.height)!, duration: 5)
        
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
        }
    }
    
    public func showTexts(){
        self.labelDeath.position = CGPoint(x: 0, y: 0)
        self.labelDeath.name = "label"
        //self.label.physicsBody?.categoryBitMask = self.labelBitCategory
        self.labelDeath.text = "ih morreu"
        self.labelDeath.fontSize = 40.0
        self.labelDeath.fontColor = UIColor.white
        self.labelDeath.zPosition = 3.0
        
        self.addChild(self.labelDeath)

//        let showLabel = SKAction.run {
//            self.label.text = "oie"
//        }
//
//        let waitAction = SKAction.wait(forDuration: 1.0)
//        self.label.run(SKAction.sequence([showLabel,waitAction]))
        
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        print("OA A COLISAO")
        if death == false{
            if contact.bodyA.node?.name == "planet" || contact.bodyB.node?.name == "planet"{
                self.showTexts()
                print("OA A COLISAO COM PLANETA")
                death = true
            }
        }
    }
    
    override public func update(_ currentTime: TimeInterval) {
        //let xMovement = SKAction.moveTo(x: self.destX, duration: 1)
        //self.cometNode.run(xMovement)
        moveSky()
        deletePlanets()
        
    }
}
