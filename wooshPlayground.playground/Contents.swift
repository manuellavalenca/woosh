//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit
import CoreMotion
import QuartzCore
import AVKit
import Vision

class GameScene: SKScene, SKPhysicsContactDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // SpriteKit Variables
    var cometNode = SKSpriteNode()
    var destX : CGFloat = 0.0
    let planetBitCategory  : UInt32 = 0b01
    let cometBitCategory : UInt32 = 0b01
    var cometAngle : CGFloat = 0.0
    var accelerationx : Double = 0.0
    var motionManager = CMMotionManager()
    var labelTimingCount = 0
    let label = SKLabelNode()
    var labelTimer = Timer()
    
    // Labels
    let arraySunTexts = ["After all those billion years, you died","Exploding in the sun. You've seen quite a lot around the space, huh?","Death is our only true, isn't?","And you managed to live your last years as beautiful as your magnificent life","But well, life is a cycle","Enjoy your ride"]
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        createSky()
        createComet()
        moveComet()
        createPlanetsTimer()
    }
    
    func createSky(){
        
        let arrayImages = [0: "testeipad-22.png", 1: "testeipad-22.png", 2: "skySun-23.png", 3: "sunSky-25.png", 4: "sunSky-25.png", 5: "sunEnd-24.png"]
        
        for imageName in arrayImages{
            if let image = UIImage(named: imageName.value){
                let skyTexture = SKTexture(image: image)
                let skyNode = SKSpriteNode(texture: skyTexture)
                skyNode.name = "sky"
                skyNode.size = CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!)
                //skyNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                if imageName.key == 0{
                    skyNode.position = CGPoint(x: 0, y: 0)
                } else{
                    skyNode.position = CGPoint(x: 0, y: CGFloat(imageName.key) * skyNode.size.height)
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
    
    func moveSky(){
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
    
    func createComet(){
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
    
    func moveComet(){
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
    
    func createPlanetNode(){
        // Create images for textures
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
    
    func createPlanetsTimer(){
        let wait = SKAction.wait(forDuration: 2, withRange: 3)
        let spawn = SKAction.run {
            self.createPlanetNode()
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func deletePlanets(){
        self.enumerateChildNodes(withName: "planet") { (node, error) in
            if node.position.y < -((self.scene?.size.height)!/2 + node.frame.size.height){
                node.removeFromParent()
            }
        }
    }
    
    func showTexts(){
        self.label.position = CGPoint(x: 0, y: 0)
        self.label.text = "teste"
        self.label.fontSize = 40.0
        self.label.fontColor = UIColor.white
        self.label.zPosition = 3.0
        
        self.addChild(self.label)
        
        self.labelTimer = Timer(timeInterval: 1.0, target: self, selector:"changeLabel", userInfo: nil, repeats: true)
        self.label.text = "\(self.arraySunTexts[self.labelTimingCount])"
        
    }
    
    func changeLabel() {
        print("ENTROU AQUI NO CHANGE LABEL")
        self.label.text = "\(self.arraySunTexts[self.labelTimingCount])"
        
        if (self.labelTimingCount == self.arraySunTexts.count) {
            self.labelTimer.invalidate()
        }
        
        self.labelTimingCount += 1
    }

    
    func didBegin(_ contact: SKPhysicsContact) {
        print("OA A COLISAO")
        if contact.bodyA.node?.name == "planet" || contact.bodyB.node?.name == "planet"{
            self.showTexts()
            print("OA A COLISAO COM PLANETA")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        let xMovement = SKAction.moveTo(x: self.destX, duration: 1)
        self.cometNode.run(xMovement)
        moveSky()
        deletePlanets()
        
        // ROTATION COMET Z
        //        if self.accelerationx < 0.0 {
        
//            self.cometAngle = 270.0
//        }else {
//            self.cometAngle = 30
//        }
//        let rotation = SKAction.rotate(byAngle: self.cometAngle, duration: 10)
//        self.cometNode.run(rotation)
//        print(self.accelerationx)
    }
}

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 480, height: 640))
if let scene = GameScene(fileNamed: "GameScene") {
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    
    // Present the scene
    sceneView.presentScene(scene)
}
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
