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
    }
    
    func randomNumber()-> CGFloat {
        //Width of the SKScene's view
        let viewsWidth = self.view!.bounds.width
        //Creates a random number from 0 to the viewsWidth
        let randomNumber = CGFloat.random(in: 0 ... viewsWidth)
        
        return randomNumber
    }
    
    func createSquares(name: String) {
        //TODO: Set up square properties
        //1. Create a CGSize for the square with (width: 80, height: 80)
        //2. Create a Square node with a texture of nil. a color of .green and the size we created above
        //3. Set the squares name to the name we pass into this function
        
        
        //TODO: Set up the Squares x and y positions
        //1. Squares y positions shoud start at 40
        //2. Squares x positon should use the randomNumber generator provided above
        
        //Create an action to move the square up the screen
        let action = SKAction.customAction(withDuration: 2.0, actionBlock: { (square, _) in
            //TODO: Set up the squares animation
            //1. The squares y position should increase by 10
            //2. Create an if statement that checks if the squares y position is >= to the screens height
            //If it is remove the square and create a new square with the same name
        })
        
        //TODO: Have the square run the above animation forever and add the square to the SKScene!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Loop through an array of touch values
        for touch in touches {
            //Grab the position of that touch value
            let positionInScene = touch.location(in: self)
            
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            
            if touchedNode.name == "meteor" { //check if we touched a node named meteor, if it is then increment our score, update scoreLabel and remove that touchedNode. Also decrement number of meteor
                score += 1
                scoreLabel.text = "Score: \(score)"
                touchedNode.removeFromParent()
                numberOfMeteor-=1
                if numberOfMeteor == 0 { //if number of meteor is 0 then incredement round and start another meteor shower
                    round+=1
                    startMeteorShower()
                }
            }
        }
    }
    
}
