//
//  MenuScene.swift
//  Marbles
//
//  Created by Julio Collado on 1/21/20.
//  Copyright © 2020 Julio Collado. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    private var scores = [Int]()
    var timer: Timer?
    
    override func didMove(to view: SKView) {
        layoutScene()
    }
    
    func layoutScene() {
        getScores()
        setBackground()
        setLabels()
    }

 
    private func getScores() {
        if let userDefaultScores = UserDefaults.standard.array(forKey: "scores") as? [Int] {
            scores = userDefaultScores.sorted{ $0 > $1 }
        } else {
            for _ in 0...2 {
                scores.append(0)
            }
            UserDefaults.standard.set(scores, forKey: "scores")
        }
    }
    
    func setBackground() {
        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.zPosition = -1
        background.alpha = 0.2
        addChild(background)
    }
    
    func setLabels() {
        let gameNameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameNameLabel.text = "Marvels"
        gameNameLabel.fontSize = 70.0
        gameNameLabel.position = CGPoint(x: frame.midX, y: frame.midY + frame.midY/2)
        addChild(gameNameLabel)
        
        let secuence = SKAction.sequence([SKAction.rotate(byAngle: CGFloat.pi/20, duration: 0.5),
                                          SKAction.rotate(byAngle: -CGFloat.pi/20, duration: 0.5),
                                          SKAction.rotate(byAngle: -CGFloat.pi/20, duration: 0.5),
                                          SKAction.rotate(byAngle: CGFloat.pi/20, duration: 0.5),])
        
        let startLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        startLabel.text = "Start!"
        startLabel.fontSize = 60.0
        startLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(startLabel)
        startLabel.run(SKAction.repeatForever(secuence))
        
        //Scores Label
        
        let topScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        topScoreLabel.text = "Top Scores:"
        topScoreLabel.fontSize = 50.0
        topScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - frame.midY/2.5)
        addChild(topScoreLabel)
        
        let scoreFont: CGFloat = 40
        for index in 1...3 {
            let labelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
            let score = "\(scores[index - 1])"
            labelNode.text = "\(index). \(score)"
            labelNode.fontSize = (scoreFont / CGFloat(index)) + 10
            labelNode.position = CGPoint(x: frame.midX, y: frame.midY - (frame.midY / 2) - CGFloat(index * 40))
            addChild(labelNode)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let gameScene = SKScene(fileNamed: "GameScene") {
            view?.presentScene(gameScene)
        }
    }
    
}
