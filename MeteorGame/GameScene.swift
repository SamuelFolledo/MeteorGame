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
    var score = 0
    var round:Int = 1
    var meteors:[SKSpriteNode] = []
    var bgStars:SKEmitterNode!
    var scoreLabel: SKLabelNode = {
        let label = SKLabelNode()
        label.text = "Score: 0"
        label.color = .white
        label.fontSize = 50
        return label
    }()
    var roundLabel: SKLabelNode = {
        let label = SKLabelNode()
        label.text = "Round: 1"
        label.color = .white
        label.fontSize = 20
        return label
    }()
    var explosionEffect: SKEmitterNode!
    var explosionSound: SKAction!
    
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
        if meteors.count == 0 {
            nextRound()
            startMeteorShower()
        }
    }
    
    func setupGame() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        explosionEffect = SKEmitterNode(fileNamed: "Explosion")!
        explosionSound = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)
        bgStars = SKEmitterNode(fileNamed: "Starfield")
        bgStars.position = CGPoint(x: 0, y: scene!.size.height)
        bgStars.advanceSimulationTime(10) //advance the simulation
        bgStars.zPosition = -2
        addChild(bgStars)
        startMeteorShower()
        labelSetUp()
        createEarth()
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
//            let meteorRemoving = SKAction.removeFromParent()
//            meteor.run(SKAction.sequence([meteorFalling, meteorRemoving]))
        //PHYSICSBODY
        meteor.physicsBody = SKPhysicsBody(circleOfRadius: meteor.size.width/2)
        meteor.physicsBody?.isDynamic = true //not affected by outside physics engine
        meteor.physicsBody?.categoryBitMask = PhysicsCategory.meteor //physics body is earth
        meteor.physicsBody?.contactTestBitMask = PhysicsCategory.earth //can bump with meteor
        meteor.physicsBody?.collisionBitMask = PhysicsCategory.none //none
//        meteor.physicsBody?.usesPreciseCollisionDetection = true //precise
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
        print("Hit")
        explosionEffect.position = earth.position
        addChild(explosionEffect) //add the explosionEffect to earth
        run(explosionSound) //play sound
        meteor.removeFromParent()
        earth.removeFromParent()
        self.run(SKAction.wait(forDuration: 2)) { //wait 2 seconds before removing explosionEffect
            self.explosionEffect.removeFromParent()
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
        
        roundLabel.position.x = view!.bounds.width / 8
        roundLabel.position.y = view!.bounds.height - 40
        addChild(roundLabel)
    }
    
    
    func nextRound() {
        round+=1
        roundLabel.text = "Round: \(round)"
    }
    
    
    func randomNumber()-> CGFloat {
        //Width of the SKScene's view
        let viewsWidth = self.view!.bounds.width
        //Creates a random number from 0 to the viewsWidth
        let randomNumber = CGFloat.random(in: 0 ... viewsWidth)
        
        return randomNumber
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self) //Grab the position of that touch value
            let touchedNode = self.atPoint(location)
            if touchedNode.name == "meteor" { //check if we touched a node named meteor
                score += 1
                scoreLabel.text = "Score: \(score)"
                removeMeteor(node: touchedNode as! SKSpriteNode)
            }
        }
    }
    
    func removeMeteor(node: SKSpriteNode) { //increment our score, update scoreLabel and remove that touchedNode. Also decrement number of meteor
        node.removeFromParent() //then remove it
        node.removeChildren(in: meteors)
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
