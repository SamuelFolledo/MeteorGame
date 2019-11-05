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
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let meteor    : UInt32 = 0b1       // 1
  static let earth     : UInt32 = 0b10      // 2
}

class GameScene: SKScene {
    var score = 0
    var round:Int = 1
    var meteors:[SKSpriteNode] = []
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
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        startMeteorShower()
        labelSetUp()
        addChild(createEarth()) //called it here so the meteors would be in the front
    }
    
    override func update(_ currentTime: TimeInterval) {
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
    
    func createMeteor() -> SKSpriteNode {
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
        meteor.physicsBody = SKPhysicsBody(rectangleOf: meteor.size) // create a physic body
        meteor.physicsBody?.isDynamic = true // physics engine will not control the movement of the meteor
        meteor.physicsBody?.categoryBitMask = PhysicsCategory.meteor // the category bitmask tells what type of body our meteor is
        meteor.physicsBody?.contactTestBitMask = PhysicsCategory.earth // this triggers something if our meteor collides with a physics body with a category bit mas of earth //listens to meteor and any contact with a physics body that has the physics category of earth
        meteor.physicsBody?.collisionBitMask = PhysicsCategory.none // collisionBitMask indicates what categories of objects this object that the physics engine handle contact responses to
        return meteor
    }
    
    func createEarth() -> SKSpriteNode {
        let sceneWidth = view!.scene!.frame.width
        let earth: SKSpriteNode = SKSpriteNode(imageNamed: "earth.png")
        earth.setScale(0.35) //scale it to 10% its original size
        earth.zRotation = CGFloat.pi
        earth.position = CGPoint(x: sceneWidth / 2, y: 0)
        earth.name = "earth"
//        let randomDuration:TimeInterval = TimeInterval.random(in: 1.5 ..< 3.5)
//        let meteorFalling = SKAction.moveTo(y: -earth.size.height / 2, duration: randomDuration)
//        earth.run(meteorFalling)
        return earth
    }
    
    func startMeteorShower() { //start another meteor shower: reset numberOfMeteor, and for each round, add more meteor nodes
        for _ in 0..<round {
            let meteor = createMeteor()
            addChild(meteor)
            meteors.append(meteor)
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
    
}
