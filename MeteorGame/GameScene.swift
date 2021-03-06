//
//  GameScene.swift
//  MeteorGame
//
//  Created by Macbook Pro 15 on 11/4/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
  static let none      : UInt32 = 0x1 << 0
  static let all       : UInt32 = UInt32.max
  static let meteor    : UInt32 = 0x1 << 1
  static let earth     : UInt32 = 0x1 << 2
}

class GameScene: SKScene {
    var score:Int = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    var round:Int = 1 {
        didSet {
            dayLabel.text = "Day: \(round)"
        }
    }
    var meteors:[SKSpriteNode] = []
    var bgStars:SKEmitterNode!
    var scoreLabel: SKLabelNode = {
        let label = SKLabelNode()
        label.text = "Score: 0"
        label.color = .white
        label.fontSize = 50
        return label
    }()
    var highScoreLabel: SKLabelNode = {
        let label = SKLabelNode()
        label.text = "Highscore: 0"
        label.color = .white
        label.fontSize = 20
        return label
    }()
    var dayLabel: SKLabelNode = {
        let label = SKLabelNode()
        label.text = "Day: 1"
        label.color = .white
        label.fontSize = 20
        return label
    }()
    var explosionEffect: SKEmitterNode!
    var explosionSound: SKAction!
    var isPlaying: Bool = false
    let kHIGHSCORE: String = "highScore"
    var playAgainButton:SKSpriteNode = SKSpriteNode(imageNamed: "playButton.png")
    
    override func didMove(to view: SKView) {
        setupGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveBG()
        for meteor in meteors {
            if meteor.position.y < 0 {
                removeMeteor(node: meteor)
            }
        }
        if meteors.count == 0 && isPlaying {
            round += 1
            startMeteorShower()
        }
    }
    
    func setupGame() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        preloadFiles()
        labelSetUp()
        setupPlayButton()
        showPlayButton()
    }
    
    func preloadFiles() {
        do { //proper way to preload .sks file
            let fileURL = Bundle.main.url(forResource: "Explosion", withExtension: "sks")!
            let fileData = try Data(contentsOf: fileURL)
            explosionEffect = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as? SKEmitterNode
        } catch {
            print("didn't work")
        }
        explosionSound = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)
        bgStars = SKEmitterNode(fileNamed: "Starfield")
        bgStars.position = CGPoint(x: 0, y: scene!.size.height)
        bgStars.advanceSimulationTime(10) //advance the simulation
        bgStars.zPosition = -2
        addChild(bgStars)
    }
    
    func setupPlayButton() {
        playAgainButton.size = CGSize(width: self.frame.size.width/2, height: self.frame.size.width/2)
        playAgainButton.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        playAgainButton.name = "playAgainButton"
        addChild(playAgainButton)
    }
    
    func createMeteor() {
        let sceneWidth = view!.scene!.frame.width
        let meteor: SKSpriteNode = SKSpriteNode(imageNamed: "meteor.png")
        meteor.setScale(0.1) //scale it to 10% its original size
        let randomX:CGFloat = CGFloat.random(in: 0 ..< sceneWidth)
        meteor.position = CGPoint(x: randomX, y: self.view!.frame.height)
        meteor.name = "meteor"
        let randomDuration:TimeInterval = TimeInterval.random(in: 1.5 ..< 3.5)
        let meteorFalling = SKAction.moveTo(y: -meteor.size.height / 2, duration: randomDuration)
        meteor.run(meteorFalling)
        //PHYSICSBODY
        meteor.physicsBody = SKPhysicsBody(circleOfRadius: meteor.size.width/2)
        meteor.physicsBody?.isDynamic = true //not affected by outside physics engine
        meteor.physicsBody?.categoryBitMask = PhysicsCategory.meteor //physics body is earth
        meteor.physicsBody?.contactTestBitMask = PhysicsCategory.earth //can bump with meteor
        meteor.physicsBody?.collisionBitMask = PhysicsCategory.none //none
        meteor.physicsBody?.usesPreciseCollisionDetection = true //precise
        addChild(meteor)
        meteors.append(meteor)
    }
    
    func createEarth() {
        let sceneWidth = view!.scene!.frame.width
        let earth: SKSpriteNode = SKSpriteNode(imageNamed: "earth.png")
        earth.setScale(0.35) //scale it to 10% its original size
        earth.position = CGPoint(x: sceneWidth / 2, y: 0)
        earth.zPosition = -1 //puts it in the back of the meteors
        earth.name = "earth"
        let earthRotating = SKAction.rotate(byAngle: .pi/3, duration: 1)
        earth.run(SKAction.repeatForever(earthRotating))
        //PHYSICS BODY
        earth.physicsBody = SKPhysicsBody(circleOfRadius: earth.size.width/2) // create a physic body
        earth.physicsBody?.isDynamic = true // physics engine will not control the movement of the meteor
        earth.physicsBody?.categoryBitMask = PhysicsCategory.earth // the category bitmask tells what type of body our meteor is
        earth.physicsBody?.contactTestBitMask = PhysicsCategory.meteor // this triggers something if our meteor collides with a physics body with a category bit mas of earth //listens to meteor and any contact with a physics body that has the physics category of earth
        earth.physicsBody?.collisionBitMask = PhysicsCategory.none // collisionBitMask indicates what categories of objects this object that the physics engine handle contact responses to
        addChild(earth)
    }
    
    func meteorDidCollideWithEarth(meteor: SKSpriteNode, earth: SKSpriteNode) {
        print("Earth is hit, game over")
        isPlaying = false
        explodeEffect(from: meteor)
        earth.removeFromParent()
        checkHighScore()
        showPlayButton()
        for meteor in meteors {
            removeMeteor(node: meteor)
        }
    }
    
    func showPlayButton() {
        playAgainButton.isHidden = false
    }
    
    func play() {
        playAgainButton.isHidden = true
        isPlaying = true
        round=1
        score=0
        createEarth()
        startMeteorShower()
    }
    
    func checkHighScore() {
        let highScore = UserDefaults.standard.integer(forKey: kHIGHSCORE)
        if self.score > highScore {
            UserDefaults.standard.set(self.score, forKey: kHIGHSCORE)
            UserDefaults.standard.synchronize() //set the high score
            highScoreLabel.text = "Highscore: \(UserDefaults.standard.integer(forKey: kHIGHSCORE))" //put the highschore on text
        }
    }
    
    func startMeteorShower() { //start another meteor shower: reset numberOfMeteor, and for each round, add more meteor nodes
        for _ in 0..<round {
            createMeteor()
        }
    }
    
    func backgroundSetup() {
        for i in 0...3 {
            let bg = SKSpriteNode(imageNamed: "bg.jpg")
            bg.name = "universe"
            bg.size = CGSize(width: self.scene!.size.width, height: self.view!.frame.height)
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: -self.frame.size.height / 2) //puts the background next to each other
            addChild(bg)
        }
    }
    
    func moveBG() {
        self.enumerateChildNodes(withName: "universe") { (node, error) in
            node.position.x -= 2
            if node.position.x < -((self.scene?.size.width)!) {
                node.position.x += (self.scene?.size.width)! * 3 //3 is for the amount of time we are looping the bg in bgSetup()
            }
        }
    }
    
    func labelSetUp() {
        scoreLabel.position.x = view!.bounds.width / 2
        scoreLabel.position.y = view!.bounds.height - 80
        addChild(scoreLabel)
        dayLabel.position.x = view!.bounds.width / 8
        dayLabel.position.y = view!.bounds.height - 40
        addChild(dayLabel)
        highScoreLabel.position.x = view!.bounds.width - highScoreLabel.frame.width / 2 - 10
        highScoreLabel.position.y = view!.bounds.height - 40
        addChild(highScoreLabel)
        highScoreLabel.text = "Highscore: \(UserDefaults.standard.integer(forKey: kHIGHSCORE))"
    }
    
    func randomNumber()-> CGFloat {
        //Width of the SKScene's view
        let viewsWidth = self.view!.bounds.width
        //Creates a random number from 0 to the viewsWidth
        let randomNumber = CGFloat.random(in: 0 ... viewsWidth)
        return randomNumber
    }
    
//MARK: Touches Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self) //Grab the position of that touch value
            let touchedNode = self.atPoint(touchLocation)
            if touchedNode.name == "meteor" { //check if we touched a node named meteor
                score += 1
                explodeEffect(from: touchedNode as! SKSpriteNode)
            } else if touchedNode.name == "playAgainButton" {
                play()
            }
        }
    }
    
    func explodeEffect(from node: SKSpriteNode) { //initialize our explosionEffect, position it with the node we passed, run sound effect, and remove the explosionEffect after a delay
        addExplosionEmitter(point: node.position)
        run(explosionSound)
        removeMeteor(node: node)
    }
    
    func addExplosionEmitter(point: CGPoint) { //copies preloaded explosion effect, and place it to meteor node's position
        let emitterToAdd = explosionEffect.copy() as! SKEmitterNode
        emitterToAdd.position = point
        emitterToAdd.zPosition = -1
        let addEmitterAction = SKAction.run({self.addChild(emitterToAdd)})
        let wait = SKAction.wait(forDuration: TimeInterval(2)) //2 seconds wait
        let remove = SKAction.run({
            emitterToAdd.removeFromParent()
        })
        let sequence = SKAction.sequence([addEmitterAction, wait, remove])
        self.run(sequence)
    }
    
    func removeMeteor(node: SKSpriteNode) { //remove meteor node and from meteors array
        node.removeFromParent()
        guard let index = meteors.firstIndex(of: node) else { print("meteor index does not exist"); return }
        meteors.remove(at: index)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) { //This method passes you the two bodies that collide
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
     
        if ((firstBody.categoryBitMask & PhysicsCategory.meteor != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.earth != 0)) { //check if two bodies that collided are the earth and monster, then run our method
            if let earth = firstBody.node as? SKSpriteNode, let meteor = secondBody.node as? SKSpriteNode {
                meteorDidCollideWithEarth(meteor: meteor, earth: earth)
            }
        }
    }
}
