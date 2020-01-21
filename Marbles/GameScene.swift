//
//  GameScene.swift
//  Marbles
//
//  Created by Julio Collado on 1/20/20.
//  Copyright © 2020 Julio Collado. All rights reserved.
//

import SpriteKit
import CoreMotion


class Ball: SKSpriteNode { }

class GameScene: SKScene {
    
    var balls = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
    var motionManager: CMMotionManager?
    var scoreLabel = SKLabelNode(fontNamed: "Hervetica-Thin")
    
    var matchedBalls = Set<Ball>()
    
    var score = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formatterScore = formatter.string(from: score as NSNumber) ?? "0"
            scoreLabel.text = "SCORE: \(formatterScore)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        
        background.zPosition = -1
        addChild(background)
        background.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 15)))
        
        scoreLabel.fontSize = 45
        scoreLabel.position = CGPoint(x: 20, y: 20)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.zPosition = 100
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        
        let ball = SKSpriteNode(imageNamed: "ballBlue")
        let ballRadius = ball.frame.width / 2
        
        for i in stride(from: ballRadius, to: view.bounds.width - ballRadius, by: ball.frame.width) {
            
            for j in stride(from: 100, to: view.bounds.height - ballRadius, by: ball.frame.height) {
                let ballType = balls.randomElement()!
                let ball = Ball(imageNamed: ballType)
                ball.position = CGPoint(x: i, y: j)
                ball.name = ballType
                addChild(ball)
                
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
                ball.physicsBody?.allowsRotation = false
                ball.physicsBody?.restitution = 0
                ball.physicsBody?.friction = 0
                
            }
        }
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 75, left: 0, bottom: 0, right: 0)))
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let acceletometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: acceletometerData.acceleration.x * 50, dy: acceletometerData.acceleration.y * 50)
        }
    }
    
    func getMatches(from node: Ball) {
        for body in node.physicsBody!.allContactedBodies() {
            guard let ball = body.node as? Ball, ball.name == node.name else { continue }
            if !matchedBalls.contains(ball) {
                matchedBalls.insert(ball)
                getMatches(from: ball)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let position = touches.first?.location(in: self) else { return }
        guard let tappedBall = nodes(at: position).first(where: {$0 is Ball}) as? Ball else { return }
        matchedBalls.removeAll(keepingCapacity: true)
        getMatches(from: tappedBall)
        
        guard matchedBalls.count >= 3 else { return }
        
        score += Int(pow(2, Double(min(matchedBalls.count,16))))
        
        for ball in matchedBalls {
            if let particles = SKEmitterNode(fileNamed: "Explosion") {
                particles.position = ball.position
                addChild(particles)
                
                let removedAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
                particles.run(removedAfterDead)
            }
            
            ball.removeFromParent()
        }
        
        if matchedBalls.count >= 5 {
            let omg = SKSpriteNode(imageNamed: "omg")
            omg.position = CGPoint(x: frame.midX, y: frame.midY)
            omg.zPosition = 100
            omg.xScale = 0.001
            omg.yScale = 0.001
            addChild(omg)
            
            let appear = SKAction.group([SKAction.scale(to: 0.50, duration: 0.20), SKAction.fadeIn(withDuration: 0.20)])
            let disappear = SKAction.group([SKAction.scale(to: 1, duration: 0.20), SKAction.fadeOut(withDuration: 0.20)])
            
            let secuence = SKAction.sequence([appear, SKAction.wait(forDuration: 0.20), disappear])
            
            omg.run(secuence)
        }
        
        if isEndGame() {
            print("GAME OVER")
        }
        
    }
    
    func isEndGame() -> Bool {
        let balls = children.filter({ $0 is Ball}).map({$0 as! Ball})
        for ball in balls {
            let equalBallType = balls.filter({$0.name == ball.name})
            if equalBallType.count >= 3 {
                return false
            }
        }
        return true
    }
    
}
