//
//  GameScene.swift
//  MeteorGame
//
//  Created by Macbook Pro 15 on 11/4/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    //Initialize score starting at 0
    var score = 0
    
    var round:Int = 1
    var numberOfMeteor: Int = 1
    
    
    //Set up properties of the scoreLabel
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
        //Called when the scene has been displayed
        
        //TODO: Create three squares with the names one,two,three
        startMeteorShower()
        
        //Setup the scoreLabel
        labelSetUp()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func startMeteorShower() { //start another meteor shower: reset numberOfMeteor, and for each round, add more meteor nodes
        numberOfMeteor = round
//        let sceneHeight = view!.scene!.frame.height
        let sceneWidth = view!.scene!.frame.width
        for _ in 0..<round {
            let meteor: SKSpriteNode = SKSpriteNode(imageNamed: "meteor.png")
            meteor.setScale(0.1) //scale it to 10% its original size
            let randomX:CGFloat = CGFloat.random(in: 0 ..< sceneWidth)
            meteor.position = CGPoint(x: randomX, y: self.view!.frame.height)
            meteor.name = "meteor"
            addChild(meteor)
            let falling = SKAction.moveTo(y: 0, duration: 2)
            meteor.run(falling)
        }
    }
    
    
    func labelSetUp() {
        scoreLabel.position.x = view!.bounds.width / 2
        scoreLabel.position.y = view!.bounds.height - 80
        addChild(scoreLabel)
        
        roundLabel.position.x = view!.bounds.width / 10
        roundLabel.position.y = view!.bounds.height - 40
        addChild(roundLabel)
    }
    
    
    func didTapAMeteor() { //increment our score, update scoreLabel and remove that touchedNode. Also decrement number of meteor
        score += 1
        scoreLabel.text = "Score: \(score)"
        numberOfMeteor-=1
    }
    
    
    func nextRound() {
        round+=1
        roundLabel.text = "Round: \(round)"
        startMeteorShower()
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
                touchedNode.removeFromParent() //then remove it
                didTapAMeteor()
                if numberOfMeteor == 0 { //if number of meteor is 0 then incredement round and start another meteor shower
                    nextRound()
                }
            }
        }
    }
    
}
